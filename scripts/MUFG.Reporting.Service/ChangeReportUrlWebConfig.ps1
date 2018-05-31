Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SourceFolder,
	[string]$ReportServerUrl
)

Write-Host " ";
Write-Host " ";
Write-Host "Start preparing 'Web.Config' file..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SourceFolder: '"$SourceFolder"'" ; 
Write-Host "	SourceFolder: '"$ReportServerUrl"'" ; 
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";


[xml]$webConfigXml = New-Object XML;
$webConfig = ($SourceFolder+"\web.config");
$webConfigXml.Load($webConfig);

$nodes = $webConfigXml.SelectNodes("//configuration/system.serviceModel/client/endpoint");


foreach($node in $nodes)
{
	$node.address = $ReportServerUrl;
}

$webConfigXml.Save($webConfig);