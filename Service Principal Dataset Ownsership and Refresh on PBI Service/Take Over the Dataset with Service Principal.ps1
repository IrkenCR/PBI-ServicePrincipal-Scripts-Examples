# Parameters
$TenantId  = "f6bd1ff3-86a2-4bc9-811c-82be3d1a2049" 
$AppId     = "a40917e9-8c42-44fc-8791-4a88c0caa19c"  # Service PRincipal ID
$Secret    = "r.N7Q~GaVaGXxjjq2gdwKbmmfdzxJdzpcMd1l"  # Secret from Service Principal
$GroupId   = "b008a208-af93-44f1-81b2-ce92e08e92dc"  # Workspace ID
$DatasetId = "c230407c-a53f-4b36-94c5-f7b28364a259"



$headers = Get-PowerBIAccessToken

$authHeader = @{
'Content-Type'='application/json'
'Authorization'= $headers.Authorization
}



# Connect the Service Principal
$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

$headers = Get-PowerBIAccessToken


$uri = "https://api.powerbi.com/v1.0/myorg/groups/"+ $GroupId +"/datasets/"+ $datasetId +"/Default.TakeOver"
$response = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Verbose |  ConvertTo-Json 
$response
#Disconnect-PowerBIServiceAccount