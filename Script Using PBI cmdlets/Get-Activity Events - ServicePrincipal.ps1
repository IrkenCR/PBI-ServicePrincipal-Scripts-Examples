$TenantId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 
$AppId     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Service PRincipal ID
$Secret    = "VqF8Q~2B6mRyrf191cyMtAajSRzSK1449G5sadrK"  # Secret from Service Principal


##Requirements before running the script:

## 1. SP need to have Tenant.ReadAll or Tenant.ReadWriteAll permissions with the Admin consent.
## 2. The Service Principal security group must be added to "Allow Service Principal to use Power BI APIs" security groups.
## 3. The Service Principal security group must be added to "Allow service principals to use read-only admin APIs" security groups. 

$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

$headers = Get-PowerBIAccessToken

$startDate = Get-Date -Format "yyyy-MM-ddT00:00:00"

$endDate = Get-Date -Format "yyyy-MM-ddT23:59:59"
 
$activities = Get-PowerBIActivityEvent -StartDateTime $startDate -EndDateTime $endDate  | ConvertFrom-Json ##-ActivityType 'ViewDashboard'

$activities.Count