# Connect to the Power BI service
Connect-PowerBIServiceAccount

# Set the start and end dates
$startDate = "04/04/2023"
$endDate = "05/04/2023"


$startDateFormat = Get-Date $startDate -Format "yyyy-MM-ddT00:00:00" 
$endDateFormat = Get-Date $endDate -Format "yyyy-MM-ddT23:59:00" 

$day = [DateTime]::ParseExact($startDateFormat, "yyyy-MM-ddTHH:mm:ss", $null)
$dayString = $day.ToString("yyyy-MM-ddTHH:mm:ss")
while ($day -le [DateTime]::ParseExact($endDateFormat, "yyyy-MM-ddTHH:mm:ss", $null)) {
    # Get the audit logs for the current day
    $auditLogs = Get-PowerBIActivityEvent -StartDateTime $dayString -EndDateTime $day.ToString("yyyy-MM-ddT23:59:59") -ActivityType 'DeleteGroup' | ConvertFrom-Json 

    $auditLogs
    # Export the audit logs to a CSV file
    
    $auditLogs | Export-Csv -Path "C:\PowerBI_Activity_Logs_DeleteGroup.csv" -NoTypeInformation -Append

    # Move to the next day
    $day = $day.AddDays(1)
    $dayString = $day.ToString("yyyy-MM-ddTHH:mm:ss")
    $day
}
