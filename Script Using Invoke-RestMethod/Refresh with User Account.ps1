Login-PowerBI

$token = Get-PowerBIAccessToken

#Build the access token into the authentication header
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'= $token.Authorization
}


$uri = "https://api.powerbi.com/v1.0/myorg/datasets/4093e5db-aef8-4195-bc56-385a036beed0/refreshes"
Invoke-RestMethod -Uri $uri –Headers $headers –Method POST –Verbose


$uri = "https://api.powerbi.com/v1.0/myorg/groups/$GroupId/datasets/$DatasetId/refreshes?$top=2"
Invoke-RestMethod -Uri $uri –Headers $headers –Method GET –Verbose | ConvertTo-Json | ConvertFrom-Json | Select -ExpandProperty value | Select id, refreshType, startTime, endTime, status

Disconnect-PowerBIServiceAccount
