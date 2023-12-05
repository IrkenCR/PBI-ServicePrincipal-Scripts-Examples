# Power BI API endpoint URLs
$authorityUrl = "https://login.microsoftonline.com/f6bd1ff3-86a2-4bc9-811c-82be3d1a2049"
#$authorityUrl = "https://login.microsoftonline.com/f6bd1ff3-86a2-4bc9-811c-82be3d1a2049"
$resourceUrl = "https://analysis.windows.net/powerbi/api"
$clientId = ""
$clientSecret = ""
$tenant = ""

# Get Access Token
$tokenEndpoint = "https://login.microsoftonline.com/f6bd1ff3-86a2-4bc9-811c-82be3d1a2049/oauth2/token"
 
 
$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = $resourceUrl
}
$tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body
 

$PWord = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $PWord

Connect-PowerBIServiceAccount -Tenant $tenant -ServicePrincipal -Credential $credential


# Access Token
$accessToken = $tokenResponse.access_token
 
# Get List of Workspaces
$workspaces = Get-PowerBIWorkspace -Scope Organization -All
 # Get List of Workspaces
$workspaces = Get-PowerBIWorkspace -Scope Organization

# Create an array to store workspace information
$workspaceIds = @()

# Output Workspaces
foreach ($workspace in $workspaces) {
    if ($workspace.Type -ne "personalGroup") {
        $workspaceId = $workspace.Id
        Write-Host "Workspace ID: $workspaceId"
        $workspaceIds += $workspaceId
    }
}

# Create a hashtable with the "workspaces" key and the array of workspace IDs
$jsonData = @{
    workspaces = $workspaceIds
}

# Convert the hashtable to JSON and save it to a file
$jsonData | ConvertTo-Json | Set-Content -Path "C:\Temp\WorkspaceIds2.json"

Write-Host "Workspace IDs (excluding personalGroup) saved to C:\Temp\WorkspaceIds.json"

$jsonBody = $jsonData | ConvertTo-Json


# POST request to https://api.powerbi.com/v1.0/myorg/admin/workspaces/getInfo
$apiEndpoint = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/getInfo"

$response = Invoke-RestMethod -Uri $apiEndpoint -Headers @{ Authorization = "Bearer $accessToken" } -Method Post -Body $jsonBody -ContentType "application/json"

Write-Host "Response from the API:"
$response


#Get the scan results

$scanId = $response.id
$statusEndpoint = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/scanStatus/$scanId"

# Wait until the scan status is "Succeeded"
do {
    $statusResponse = Invoke-RestMethod -Uri $statusEndpoint -Headers @{ Authorization = "Bearer $accessToken" } -Method Get
    $status = $statusResponse.status
    Write-Host "Scan Status: $status"

    if ($status -eq "NotStarted" -or $status -eq "InProgress") {
        Start-Sleep -Seconds 10  # Adjust the sleep duration as needed
    }
} while ($status -eq "NotStarted" -or $status -eq "Running")

# Check if the scan has succeeded
if ($status -eq "Succeeded") {
    # Get the result using the scanId
    $resultEndpoint = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/scanResult/$scanId"
    $resultResponse = Invoke-RestMethod -Uri $resultEndpoint -Headers @{ Authorization = "Bearer $accessToken" } -Method Get

    # Extract workspace and dataset information
    $workspaceDatasetInfo = $resultResponse.workspaces | ForEach-Object {
        $workspaceId = $_.id
        $workspaceName = $_.name

        $_.datasets | ForEach-Object {
            [PSCustomObject]@{
                WorkspaceId   = $workspaceId
                WorkspaceName = $workspaceName
                DatasetId     = $_.id
                DatasetName   = $_.name
            }
        }
    }

    # Save the information in an Excel file
    $resultPath = "C:\Temp\WorkspaceDatasetInfo.xlsx"
    $workspaceDatasetInfo | Export-Excel -Path $resultPath -AutoSize -FreezeTopRow -BoldTopRow -Show
    Write-Host "Workspace and Dataset Information saved to $resultPath"
} else {
    Write-Host "Scan did not succeed. Status: $status"
}