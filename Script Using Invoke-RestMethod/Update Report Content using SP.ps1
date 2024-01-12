# Power BI Report content update.

# Please check the SP permissions requirement before running it.
# SP should be in both workspaces. https://learn.microsoft.com/en-us/rest/api/power-bi/reports/update-report-content-in-group

# Parameters
$TenantId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 
$AppId     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"   # Service PRincipal ID
$Secret    = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"   # Secret from Service Principal
$SuorceGroupId   ="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"   # Workspace ID
$SourceReportId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 
$TargetGroupId  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 
$TargetReportId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 

# JSON Body
$jsonBody = @{
    sourceReport = @{
        sourceReportId = $SourceReportId
        sourceWorkspaceId = $SuorceGroupId
    }
    sourceType = "ExistingReport"
} | ConvertTo-Json

# Connect the Service Principal
$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

$headers = Get-PowerBIAccessToken

# Optional
# Refresh the dataset with JSON Body
$uri = "https://api.powerbi.com/v1.0/myorg/groups/$targetGroupId/reports/$targetReportId/UpdateReportContent"
Invoke-RestMethod -Uri $uri –Headers $headers –Method POST –Body $jsonBody -ContentType "application/json" –Verbose

Disconnect-PowerBIServiceAccount
