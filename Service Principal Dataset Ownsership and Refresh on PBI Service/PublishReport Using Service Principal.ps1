#SP details
$TenantId  = "f6bd1ff3-86a2-4bc9-811c-82be3d1a2049" 
$AppId     = "a40917e9-8c42-44fc-8791-4a88c0caa19c"  # Service PRincipal ID
$Secret    = "r.N7Q~GaVaGXxjjq2gdwKbmmfdzxJdzpcMd1l"  # Secret from Service Principal
$GroupId   = "3e0d2a99-4399-4d1a-9f98-f58b5cec8f0f"  # Workspace ID
$DatasetId = ""


# Connect the Service Principal
$password = ConvertTo-SecureString $Secret -AsPlainText -Force
$Creds = New-Object PSCredential $AppId, $password
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $Creds -Tenant $TenantId

# Publish a Report

New-PowerBIReport -Path 'C:\Users\joseama\OneDrive - Microsoft\Frist Training\Sample Files\AW Person Import.pbix' -Name 'SPReport' -WorkspaceId "3e0d2a99-4399-4d1a-9f98-f58b5cec8f0f"

