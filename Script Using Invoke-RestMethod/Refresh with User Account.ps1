Login-PowerBI

$token = Get-PowerBIAccessToken

$datasetID = "c230407c-a53f-4b36-94c5-f7b28364a259"
$groupID = "b008a208-af93-44f1-81b2-ce92e08e92dc"

# Build the access token into the authentication header
$authHeader = @{
    'Content-Type' = 'application/json'
    'Authorization' = $token.Authorization
}

# Dataset Refresh
$uri = "https://api.powerbi.com/v1.0/myorg/groups/$groupID/datasets/$datasetID/refreshes"

$json = '{"notifyOption": "MailOnFailure"}' | ConvertFrom-Json
$body = $json | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $body -Method POST

# Get Dataset Refresh History
# $uri = "https://api.powerbi.com/v1.0/myorg/groups/$groupID/datasets/$datasetID/refreshes"
# Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET -Verbose | ConvertTo-Json | ConvertFrom-Json | Select -ExpandProperty value | Select id, refreshType, startTime, endTime, status

Disconnect-PowerBIServiceAccount
