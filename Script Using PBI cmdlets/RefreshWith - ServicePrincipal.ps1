# Power BI Dataset Refresh
# Parameters
$TenantId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 
$AppId     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Service PRincipal ID
$Secret    = "i3he2~O4-uwBOlA~1238Acr.UPlg~Th34GFL"  # Secret from Service Principal
$GroupId   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Workspace ID
$DatasetId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

#Considerations
#Service Principal must be in the allowed security group at the admin portal API Service Principal Settings.
#The Service Principal can be added in the Azure Active Directory, copying the App Id.
#Service Principal must be as a workspace memeber.


# Connect the Service Principal
$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

$headers = Get-PowerBIAccessToken

#These refreshes are examples to use the API using the Invole-RestMethod function.

# Optional
# Refresh the dataset
$uri = "https://api.powerbi.com/v1.0/myorg/groups/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/datasets/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/refreshes"
Invoke-RestMethod -Uri $uri –Headers $headers –Method POST –Verbose

# Check the refresh history
$uri = "https://api.powerbi.com/v1.0/myorg/groups/$GroupId/datasets/$DatasetId/refreshes?$top=2"
Invoke-RestMethod -Uri $uri –Headers $headers –Method GET –Verbose | ConvertTo-Json | ConvertFrom-Json | Select -ExpandProperty value | Select id, refreshType, startTime, endTime, status

Disconnect-PowerBIServiceAccount