<#-------------------------------------------------------------------------------------------
Automated Connection with Username & Password - Running the code below will connect without user prompts 
** The account you're using will need Power BI administrator permissions
** The method below will not work if MFA is required for the account
-------------------------------------------------------------------------------------------#>

#Variables 
$PbiUser = ""
$PbiPassword = ""

$ServiceAccount = ""

$WsnoSvcacct = @()
#Create secure string and credential for username & password 
$PbiSecurePassword = ConvertTo-SecureString $PbiPassword -Force -AsPlainText
$PbiCredential = New-Object Management.Automation.PSCredential($PbiUser, $PbiSecurePassword)

#Connect to the Power BI service
Connect-PowerBIServiceAccount -Credential $PbiCredential 

$workSpaces1 = Get-PowerBIWorkspace -Scope Organization -Type Workspace -All | Where-Object {$_.Type -notlike "PersonalGroup*"}
$workSpaces2 = $workSpaces1 | Where-Object {$_.State -notlike "Deleted"}
$workSpaces3 = $workSpaces2 | Where-Object {$_.Type -notlike "AdminWorkspace"}
$workSpaces = $workSpaces3 | Where-Object {$_.IsOrphaned -notlike "True"}


#$workspaces = $workspaces | Select-Object -last 6
#$workspaces
$maxNumberofWorkspaces = $workSpaces.count
write-host "Total workspaces: $($workSpaces.count)`n"



$requestCounter = 0
$Int = 1

while($requestCounter  -lt 10){
    echo $requestCounter
    ForEach ($WS in $workSpaces)
    {  
        #Write-Host "WS#: "$Int
        $int++
        $WS.WorkspaceId

        $users2= $WS | select-object -ExpandProperty users 

        $chk = 0
        foreach ($User in $users2) {
            If($User.UserPrincipalName -eq $ServiceAccount){
                $chk = 1
        	    }
    	    }
        
        If($chk -EQ 0){
            $WsnoSvcacct += $WS
            $requestCounter = $requestCounter +1
            }

        If($maxNumberofWorkspaces -gt $Int){
            $requestCounter = 999999
        
        }    

    }
}


#$WsnoSvcacct
Write-Host 'Start to assign user to workspaces'
write-Host "Number of workspaces to be assign: $($WsnoSvcacct.count)`n"

$limit = 150 #Can be changed to 200

ForEach ($w in $WsnoSvcacct)
{
    if($limit -gt 0) {
        try
        {  echo $w.Id
           ### Add an Admin of the workspace
           $result = Add-PowerBIWorkspaceUser -Scope Organization -Id $w.Id -UserEmailAddress $ServiceAccount -AccessRight Admin 
           $limit = $limit - 1
        }
    #test timer to wait 1 hour limit

        catch [System.Net.WebException]{
            Write-Host "Catch"
            $ex = $result.Exception
            $statusCode = $ex.Response.StatusCode
            if ($statusCode -eq 429){                              
                $waitSeconds = [int]::Parse($ex.Response.Headers["Retry-After"])          
                Write-Host "429 Throthling Error - Need to wait $waitSeconds seconds..."
                Start-Sleep -Seconds ($waitSeconds + 5) 
		        Connect-PowerBIServiceAccount -Credential $PbiCredential                
		        #$authToken = Get-PBIAuthToken -clientId $config.ServicePrincipal.AppId -clientSecret $config.ServicePrincipal.AppSecret -tenantId $config.ServicePrincipal.TenantId
	
            }      
        }

        if($limit -eq 0){
            #sleep 1 hours
            $sleepTime = 3700
            Write-Host "Request limit per hour has been reached, seconds needed to send a new requests:  $($sleepTime)`n"
            while($sleepTime -gt 0){ 
                Start-Sleep -Seconds (60)
                $sleepTime = $sleepTime - 60
                Write-Host "Seconds left:  $($sleepTime)`n" 
                
            }
            Connect-PowerBIServiceAccount -Credential $PbiCredential
            $limit = 150 #Can be change to 200  
        } 
    }

}
