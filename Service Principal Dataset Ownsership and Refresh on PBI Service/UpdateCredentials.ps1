# Parameters
$TenantId  = "f6bd1ff3-86a2-4bc9-811c-82be3d1a2049" 
$AppId     = "a40917e9-8c42-44fc-8791-4a88c0caa19c"  # Service PRincipal ID
$Secret    = "r.N7Q~GaVaGXxjjq2gdwKbmmfdzxJdzpcMd1l"  # Secret from Service Principal
$GroupId   = "3e0d2a99-4399-4d1a-9f98-f58b5cec8f0f"  # Workspace ID
$DatasetId = "4b1065e4-89ec-44dd-b6ae-50f4fc57e67d"
$workspaceID = "3e0d2a99-4399-4d1a-9f98-f58b5cec8f0f"
$VGatewayID = "34f6f0cf-d9e7-462b-bf21-c1a71566c614"
$datasourceID = "6b190df1-1b4c-41fc-8e02-3702338bccc0"

$username = "andrei.amador"
$password = "Goldie9226!!"




# Connect the Service Principal
$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

$headers = Get-PowerBIAccessToken

$authHeader = @{
'Content-Type'='application/json'
'Authorization'= $headers.Authorization
}


#$Cred = Get-Credential



$body = @"
{
    "credentialDetails": 
    {
        "credentialType": "Basic",
        "credentials": "{ \"credentialData\":[{\"name\":\"username\", \"value\": \"andrei.amador\"},{\"name\":\"password\", \"value\": \"Goldie9226!!\"}]}",
        "encryptedConnection": "Encrypted",
        "encryptionAlgorithm": "None",
        "privacyLevel": "None",
        "useEndUserOAuth2Credentials": "False"
    }
}
"@





#$uri = "https://api.powerbi.com/v1.0/myorg/gateways/" + $VGatewayID + "/datasources/"+$datasourceID
#$response = Invoke-RestMethod -Uri $uri -Method GET 
$response = ""

$uri = "https://api.powerbi.com/v1.0/myorg/gateways/"+ $VGatewayID +"/datasources/" + $datasourceID
$response = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Patch -Body $body
$response