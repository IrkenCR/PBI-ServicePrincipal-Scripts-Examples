#Pre-requisites:
# Install the PBI Cmdlets: https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps
# User must be Office 365 Global Administrator or Power BI Administrator.
# Create C:\temp\ folder. The user that run the scrip should have write access to this folder, or choose another path.


# Logic:
# The script will get all the workspaces in a Capacity and will transfer those worspace to a new capacity. 
# All the moved workspaces will be stored in a CSV file named "SuccessWorkspaces.csv" under C:\temp\ path.
# If there are some failures in the process they will be stored in "FailureWorkspaces".
# What can cause a failure? If you create any Fabric artifact and try to move to a P capacity, it can throw an error, to avoid this delete the Fabric artifact.
# This will happen only if there is a NEW artifact, for example, after the migration of the workspaces an user saw a new artifact type, they create a new one for curiosity and let it created. This will cause an issue if try to revert back the change to the previous capacity.

# This script has been tested under a certain conditions, if it throws errors it could be because a new condition, we can't guarantee this will work 100% of the times.

# Set the source and target Premium Capacities
$sourceCapacityId = "DDED435E-6B6E-44E8-AE2F-680F9D99C38C"
$targetCapacityId = "187E6C18-A7B9-43D1-8EE7-345B054BCFCC"
$filesPath = "C:\temp"

# Connect to Power BI service
Connect-PowerBIServiceAccount

# Get all workspaces in the source Premium Capacity - You can also add filters, or change the Scope to individual. 
# https://learn.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.workspaces/get-powerbiworkspace?view=powerbi-ps
# https://learn.microsoft.com/en-us/rest/api/power-bi/groups/get-groups
$sourceWorkspaces = Get-PowerBIWorkspace -Scope Organization -Filter "capacityId eq '$sourceCapacityId'"

# Initialize arrays to store success and failure details
$successWorkspaces = @()
$failureWorkspaces = @()

foreach ($workspace in $sourceWorkspaces) {
    try {
        # Move the workspace to the target Premium Capacity
        Set-PowerBIWorkspace -Id $workspace.Id -CapacityId $targetCapacityId -Scope Organization

        # Add details to the success array
        $successWorkspaces += [PSCustomObject]@{
            WorkspaceName = $workspace.Name
            WorkspaceId = $workspace.Id
            Status = "Success"
        }
    } catch {
        # If an error occurs, add details to the failure array
        $failureWorkspaces += [PSCustomObject]@{
            WorkspaceName = $workspace.Name
            WorkspaceId = $workspace.Id
            Status = "Failure"
            ErrorMessage = $_.Exception.Message
        }
    }
}

# Disconnect from Power BI service
Disconnect-PowerBIServiceAccount

# Save details to CSV files
$successWorkspaces | Export-Csv -Path "$filesPath\SuccessWorkspaces.csv" -NoTypeInformation
$failureWorkspaces | Export-Csv -Path "$filesPath\FailureWorkspaces.csv" -NoTypeInformation
