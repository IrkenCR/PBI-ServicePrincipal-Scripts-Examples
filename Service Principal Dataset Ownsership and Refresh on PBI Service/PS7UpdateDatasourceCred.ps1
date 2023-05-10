# Command line Parameters ======================================================
[CmdletBinding()]
param
(
    
    [string] $pbixPath

)

# ==============================================================================


$powerbiUrl = "https://api.powerbi.com/v1.0"

Function Update-PowerBIGatewayDataSourceCredentials {
    Param(
        [parameter(Mandatory = $true)]$gatewayId,
        [parameter(Mandatory = $true)]$datasourceId,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$credentialType,
        [parameter(Mandatory = $false)]$userName,
        [parameter(Mandatory = $false)]$password
     )

    # PATCH https://api.powerbi.com/v1.0/myorg/gateways/{gatewayId}/datasources/{datasourceId}
    $url = $powerbiUrl + "/myorg/gateways/$gatewayId/datasources/$datasourceId"

    if ($credentialType -eq "OAuth2") {
$body = @"
{
    "credentialDetails": 
    {
        "credentialType": "OAuth2",
        "credentials": "{ \"credentialData\": [{\"name\":\"accessToken\", \"value\": \"$accessToken\"}]}",
        "encryptedConnection": "Encrypted",
        "encryptionAlgorithm": "None",
        "privacyLevel": "None"
    }
}
"@

}

if ($credentialType -eq "Basic") {

$body = @"
{
    "credentialDetails": 
    {
        "credentialType": "Basic",
        "credentials": "{ \"credentialData\": [{\"name\":\"username\", \"value\": \"$userName\"},{\"name\":\"password\", \"value\": \"$password\"}]}"
    }
}
"@

}


   <#$apiHeaders = @{
        'Content-Type'  = 'application/json'
        'Accept'  = 'application/json'
        'Authorization' = "Bearer $AccessToken"
    }#>

    #$result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method "Patch" -Body $Body
    $result = Invoke-RestMethod -Uri $Url -Method Patch -Body $Body

}



# ********************************************************************************************
#
# Main entry point
#
# ********************************************************************************************




<#
.Synopsis
    Publishes selected Power BI report (.pbix file) into a designated workspace

.Description
    Publishes selected Power BI report (.pbix file) into a designated workspace.
    The script uses publisher.csv file to determine what report goes to which tenant/workspace.
    First time (for a user) the script will ask for a username and password. Next time no questions will be asked.

.Parameter pbixPath
    .pbix file to publish (full path)

.Example
    ./publsiher.ps1 "C:\powerbi\Report.pbix"

#>

# Microsoft's documentations ===================================================

#Microsoft Power BI Cmdlets for Windows PowerShell and PowerShell Core documentation
# https://docs.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps

# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.profile/connect-powerbiserviceaccount?view=powerbi-ps
# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.workspaces/get-powerbiworkspace?view=powerbi-ps
# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.data/get-powerbidataset?view=powerbi-ps
# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.reports/new-powerbireport?view=powerbi-ps
# https://docs.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.profile/invoke-powerbirestmethod?view=powerbi-ps

#Power BI REST APIs documentation
# https://docs.microsoft.com/en-us/rest/api/power-bi/

# ==============================================================================


#TLS1.2
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Install Microsoft Power BI Cmdlets for Windows PowerShell
#Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser

#get report file name from the full path
#$report = Get-ChildItem C:\Users\drabon\PowerShell\Efficiency.pbix #$pbixPath
#$reportFileToPublish = $report.name

#Write-Host "`nReport file to publish: "$reportFileToPublish

#read data from the .csv file
$reports = import-csv $PSScriptRoot\publisher.csv

#for all records (reports) in the CSV file
Foreach ($i in $reports) {

    #get report full path
    $report = Get-ChildItem $i.reportPath #$pbixPath
    $reportFileToPublish = $report.name
    Write-Host "`nReport file to publish: "$reportFileToPublish

    #get report name
    $reportName = $i.reportName
    $reportFileName = $i.reportName + ".pbix"

    if ($reportFileToPublish -eq $reportFileName) {
    #report found in the CSV file

        $workspaceName = $i.workspace
        $userName = $i.username
        $parameter1Name = $i.Param1Name
        $parameter1Value = $i.Param1Value
        #$parameter2Name = $i.Param2Name
        #$parameter2Value = $i.Param2Value
        $datasetRefresh = $i.datasetRefresh
        $datasetName = $i.reportName

if (!($userName)) {
Write-Host "`nReport not found in the CSV file!`n"
exit
}
else {
Write-Host "`nUserName: "$userName
}

$credentialsFile = "$PSScriptRoot\data\$userName.txt"

#read username and encrypted password from a file
if (Test-Path $PSScriptRoot\data\$userName.txt) { 

    $azure_username = Get-Content $PSScriptRoot\data\$userName.txt -First 1
    $securepassword = (Get-Content $PSScriptRoot\data\$userName.txt -TotalCount 2)[-1] | ConvertTo-SecureString    $credential = Get-Credential 
    $azure_username = $credential.UserName
    $securepassword = $credential.Password

    $output = $azure_username + "`r`n" + ($securepassword| ConvertFrom-SecureString)

    Write-Host "Stored credentials found"

}
else { 

    Write-Host "Stored credentials not found! In the pop up window enter you Azure (Power BI Service) username and password:"
    
    $credential = Get-Credential 
    $azure_username = $credential.UserName
    $securepassword = $credential.Password

    $output = $azure_username + "`r`n" + ($securepassword| ConvertFrom-SecureString)
    $output | Set-Content $PSScriptRoot\data\$userName.txt

    Write-Host "Credentials saved"

}

Write-Host "`nSigning in to a Microsoft Azure account:"

#get PSCredential object 
$credential = New-Object System.Management.Automation.PSCredential ( $azure_username, $securepassword)
#log in using PSCredential object
#If using a service account *Premium only
#Connect-PowerBIServiceAccount -ServicePrincipal -TenantId $TenantId -Credential $credential
Connect-PowerBIServiceAccount #-Credential $credential



#get workspace by workspace name ----------------------------------------------------
$workspaceObject = ( Get-PowerBIWorkspace -Name $workspaceName )
#get #workspace id
$groupid=$workspaceObject.id


#if workspace not exists create it
if($workspaceObject -eq $null){
Write-Host "`nWorkspace not found!`n"

$urlbase = "groups"

New-PowerBIWorkspace -Name $workspaceName

$workspaceObject = ( Get-PowerBIWorkspace -Name $workspaceName )
#get #workspace id
$groupid=$workspaceObject.id

Write-Host "`nWorkspace Created`n"

}

#publish a copy of the report (overwrite existing)
$result = New-PowerBIReport -Path $pbixPath -Name $reportName -Workspace $workspaceObject -ConflictAction CreateOrOverwrite
#get report id
$reportid = $result.id

Write-Host "============================================================================`n"
Write-Host -NoNewline "Report: "$reportName" (published)`n`nReport id: "$reportid

Write-Host "`n`nWorkspace id: "$workspaceObject.id

#get dataset ------------------------------------------------------------------
#$dataset = Get-PowerBIDataset -Workspace $workspace -Name $reportName
#bug:
# https://github.com/microsoft/powerbi-powershell/issues/132
#workaround:
$dataset = Get-PowerBIDataset -Workspace $workspaceObject | Where-Object {$_.Name -eq $reportName}
#get dataset
$datasetid = $dataset.id

Write-Host "`nDatasetid: "$dataset.id

$urlbase = "groups/$groupid/datasets/$datasetid/"

#update parameters ----------------------------------------------

if ($parameter1Name) { 

    #url and body for UpdateParameters API call
    $url = $urlbase + "UpdateParameters"
  
$body = @"
  {
  "updateDetails": [
    {
      "name": "$parameter1Name",
      "newValue": "$parameter1Value"
    }
  ]
  }
"@
  
    #update parameter's value
    Invoke-PowerBIRestMethod -Url $url -Method Post -Body $body
  
    Write-Host "`n -> parameter '"$parameter1Name"' updated. New value: "$parameter1Value

}
else {
    Write-Host "`nNo parameters to update"
}


   

# Endable dataset refresh ------------------------------------------

if ($datasetRefresh -eq "yes") { 

    #url and body for refreshSchedule
    $url = $urlbase + "refreshSchedule"
  
$body = @"

{
  "value": {
    "enabled": true
  }
}

"@
  
    #update dataset refresh
    Invoke-PowerBIRestMethod -Url $url -Method PATCH -Body $body
  
    Write-Host "`n -> refresh Schedule enabled. "


# Set dataset refresh times ------------------------------------------

    #url and body for refreshSchedule
    $url = $urlbase + "refreshSchedule"
  
$body = @"

{
  "value": {
    "times": [
      "01:00",
      "13:00"
    ]
  }
}

"@
  
    #update refresh time
    Invoke-PowerBIRestMethod -Url $url -Method PATCH -Body $body
  
    Write-Host "`n -> refresh Time updated. "


#url and body for refreshes API call ----------------------------------------


  $url=$urlbase + "refreshes"
  $body = @"
  {
    "notifyOption": "NoNotification"
  }
"@




 Write-Host "`n -> Before Update Credentials. ***** " 

 #Update Credentials------------------------------------------------------------------


    #Get Access Token -----------------------------------------------------------------
    try {
        $token = Get-PowerBIAccessToken 
    } 
    catch [System.Exception] {
        Connect-PowerBIServiceAccount
        $token = Get-PowerBIAccessToken 
    }

    $accessToken = $token.Values -replace "Bearer ", ""


    $ds = Get-PowerBIDatasource -WorkspaceId $groupid -DatasetId $datasetid

    $ds

    # set credentials using OAuth2 
Update-PowerBIGatewayDataSourceCredentials -gatewayId $ds.GatewayId -datasourceId $ds.DatasourceId -AccessToken $accessToken -credentialType "OAuth2"




Write-Host "`n -> After Update Credentials. *****   - Access Token: $accessToken"






  
# Refresh the dataset -------------------------------------------------------- 
Invoke-PowerBIRestMethod -Url $url -Method Post -Body $body

Write-Host " -> dataset refreshed"

}
else {
    Write-Host "`nDataset refresh not required"
}


    }

}

#open workspace in a browser
#$workspaceURL = "https://app.powerbi.com/groups/$groupid/list/dashboards"
#start $workspaceURL

#Log out of the Power BI service
Disconnect-PowerBIServiceAccount

Write-Host "`nLogged out"

# ==============================================================================