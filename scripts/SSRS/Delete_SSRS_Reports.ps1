Param( 
	[Parameter(Mandatory=$true)] 
	[string]$ReportServerUrl,
    [string]$ReportsToDelete
)


Write-Output " ";
Write-Output "Deleting SSRS Reports..."
Write-Output " ";
Write-Output "###############################################################################################################";
Write-Output "Parameters";
Write-Output "	ReportServerUrl         : '"$ReportServerUrl"'";
Write-Output "	ReportServerUrlFolder   : '"$ReportsToDelete"'";
Write-Output "###############################################################################################################";
Write-Output " ";


#Connecting to SSRS
Write-Host "ReportServerUrl: $ReportServerUrl" -ForegroundColor Magenta
Write-Host "Creating Proxy, connecting to : $ReportServerUrl/ReportService2010.asmx?WSDL"
Write-Host ""
$ssrsProxy = New-WebServiceProxy -Uri $ReportServerUrl'/ReportService2010.asmx?WSDL' -UseDefaultCredential

$reports = $ReportsToDelete.Split(',')

foreach($report in $reports)
{
    $ssrsProxy.DeleteItem($report.ToString());
}