Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SourceFolder,
	[string]$MUFGDBContext,
	[string]$KibanaEndpoint
)

Write-Host " ";
Write-Host " ";
Write-Host "Start preparing 'Web.Config' file..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SourceFolder: '"$SourceFolder"'" ; 
Write-Host "	MUFGDBContext: '"$MUFGDBContext"'" ; 
Write-Host "	KibanaEndpoint: '"$KibanaEndpoint"'" ; 
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";


[xml]$webConfigXml = New-Object XML;
$webConfig = ($SourceFolder+"\web.config");
$webConfigXml.Load($webConfig);

$nodesConnStr = $webConfigXml.SelectNodes("//configuration/connectionStrings/add");


foreach($nodeConnStr in $nodesConnStr)
{
	if ($nodeConnStr.name -eq "MUFGDBContext")
	{
		$nodeConnStr.connectionString = $MUFGDBContext;
	}
}

$nodesKeybana = $webConfigXml.SelectNodes("//configuration/appSettings/add");


foreach($nodeKeybana in $nodesKeybana)
{
	if ($nodeKeybana.key -eq "KibanaEndpoint")
	{
		$nodeKeybana.value = $KibanaEndpoint;
	}
}

$webConfigXml.Save($webConfig);