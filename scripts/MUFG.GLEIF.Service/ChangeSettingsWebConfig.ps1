Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SourceFolder,
	[string]$LeiDbContextConnectionString,
	[string]$KibanaEndpoint,
	[string]$GleifApiEndpoint,
	[string]$LogLevel,
	[string]$Environment
)

Write-Host " ";
Write-Host " ";
Write-Host "Start preparing 'Web.Config' file..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SourceFolder: '"$SourceFolder"'" ; 
Write-Host "	LeiDbContextConnectionString: '"$LeiDbContextConnectionString"'" ; 
Write-Host "	KibanaEndpoint: '"$KibanaEndpoint"'" ; 
Write-Host "	GleifApiEndpoint: '"$GleifApiEndpoint"'" ; 
Write-Host "	LogLevel: '"$LogLevel"'" ; 
Write-Host "	Environment: '"$Environment"'" ; 
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";


[xml]$webConfigXml = New-Object XML;
$webConfig = ($SourceFolder+"\web.config");
$webConfigXml.Load($webConfig);

$nodesConnStr = $webConfigXml.SelectNodes("//configuration/connectionStrings/add");


foreach($nodeConnStr in $nodesConnStr)
{
	if ($nodeConnStr.name -eq "LeiDbContextConnectionString")
	{
		$nodeConnStr.connectionString = $LeiDbContextConnectionString;
	}
}

$nodesKeybana = $webConfigXml.SelectNodes("//configuration/appSettings/add");


foreach($nodeKeybana in $nodesKeybana)
{
	if ($nodeKeybana.key -eq "KibanaEndpoint")
	{
		$nodeKeybana.value = $KibanaEndpoint;
	}
	
	if ($nodeKeybana.key -eq "GleifApiEndpoint")
	{
		$nodeKeybana.value = $GleifApiEndpoint;
	}
	
	if ($nodeKeybana.key -eq "LogLevel")
	{
		$nodeKeybana.value = $LogLevel;
	}
	
	if ($nodeKeybana.key -eq "Environment")
	{
		$nodeKeybana.value = $Environment;
	}
	
}

$webConfigXml.Save($webConfig);