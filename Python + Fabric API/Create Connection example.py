# On-Premises Connection with Basic Credentials (Microsoft Hybrid Encrypted for 2048-bit RSA) - Microsoft Fabric API

import requests
import json
import msal
import base64
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes, hmac, padding as sym_padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.asymmetric import rsa, padding

# Configuration
TENANT_ID = 'cc1b8fa3-de45-4d36-89f1-7347f740fc3a'
CLIENT_ID = '' #Your service principal ID
CLIENT_SECRET = '' #SP secret
GATEWAY_ID = '' #Gateway ID can be pulled from On-Premises Data Gateway manage (See point 1. from the script documentation)
SCOPE = ['https://api.fabric.microsoft.com/.default']
AUTHORITY = f'https://login.microsoftonline.com/{TENANT_ID}'


#This is a On-Prem SQL Database example
SERVER_NAME = 'GWTraining\AMAZINGBD' 
DATABASE_NAME = 'CustomerDB'
USERNAME = 'andrei'
PASSWORD = ''

# Getting the access token
app = msal.ConfidentialClientApplication(
    CLIENT_ID,
    authority=AUTHORITY,
    client_credential=CLIENT_SECRET
)
token_result = app.acquire_token_for_client(scopes=SCOPE)
if 'access_token' not in token_result:
    raise Exception("Access token acquisition failed")
access_token = token_result['access_token']
print("Access token acquired")

# Get Gateway Public Key
key_url = f"https://api.powerbi.com/v1.0/myorg/gateways/{GATEWAY_ID}"
headers = {'Authorization': f'Bearer {access_token}'}
key_response = requests.get(key_url, headers=headers)
if key_response.status_code != 200:
    raise Exception(f"Failed to get public key: {key_response.text}")
key_data = key_response.json()
modulus_bytes = base64.b64decode(key_data['publicKey']['modulus'])
exponent_bytes = base64.b64decode(key_data['publicKey']['exponent'])
modulus_int = int.from_bytes(modulus_bytes, byteorder='big')
exponent_int = int.from_bytes(exponent_bytes, byteorder='big')
public_key = rsa.RSAPublicNumbers(exponent_int, modulus_int).public_key(default_backend())
print("Public key constructed (RSA-OAEP)")

# Hybrid encryption (AES + HMAC), keys encrypted with RSA
aes_key = os.urandom(32)
hmac_key = os.urandom(64)
iv = os.urandom(16)

credentials_json = json.dumps({
    "credentialData": [
        {"name": "username", "value": USERNAME, "type": "Basic"},
        {"name": "password", "value": PASSWORD, "type": "Basic"}
    ]
}).encode("utf-8")

# PKCS7 Padding for AES
padder = sym_padding.PKCS7(128).padder()
padded_credentials = padder.update(credentials_json) + padder.finalize()
cipher = Cipher(algorithms.AES(aes_key), modes.CBC(iv), backend=default_backend())
enc = cipher.encryptor()
ciphertext = enc.update(padded_credentials) + enc.finalize()

# Authenticated tag = algorithms + iv + ciphertext
auth_data = bytearray([0, 0]) + iv + ciphertext
h = hmac.HMAC(hmac_key, hashes.SHA256(), backend=default_backend())
h.update(auth_data)
auth_tag = h.finalize()

# Format: [algos + tag + iv + ciphertext]
out = bytearray([0, 0]) + auth_tag + iv + ciphertext

# RSA-encrypt keys with key length prefix
keyblock = bytearray([0, 1]) + aes_key + hmac_key
encrypted_keyblock = public_key.encrypt(
    bytes(keyblock),
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

# Final encrypted blob
final_encrypted = base64.b64encode(encrypted_keyblock).decode() + base64.b64encode(out).decode()

# Build request payload
url = 'https://api.fabric.microsoft.com/v1/connections'
headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': 'application/json'
}

payload = {
    "connectivityType": "OnPremisesGateway",
    "gatewayId": GATEWAY_ID,
    "displayName": "GWTraining_Basic2",
    "connectionDetails": {
        "type": "SQL",
        "creationMethod": "SQL",
        "parameters": [
            {"dataType": "Text", "name": "server", "value": SERVER_NAME},
            {"dataType": "Text", "name": "database", "value": DATABASE_NAME}
        ]
    },
    "privacyLevel": "Organizational",
    "credentialDetails": {
        "singleSignOnType": "None",
        "connectionEncryption": "NotEncrypted",
        "skipTestConnection": False,
        "credentials": {
            "credentialType": "Basic",
            "values": [
                {
                    "gatewayId": GATEWAY_ID,
                    "encryptedCredentials": final_encrypted
                }
            ]
        }
    }
}

response = requests.post(url, headers=headers, json=payload)
print("Status Code:", response.status_code)
print("Response:", response.text)