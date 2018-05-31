Param( 
	[Parameter(Mandatory=$true)] 
	[string]$NeuronConfigurationSourceFolder,
	[string]$NeuronHost
)

Write-Host " ";
Write-Host " ";
Write-Host "Start preparing 'esb_configuration.xml' file..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	NeuronConfigurationSourceFolder: '"$NeuronConfigurationSourceFolder"'" ; 
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

[xml]$configurationXml = New-Object XML;
$esbFile = ($NeuronConfigurationSourceFolder+"\esb_configuration.xml");
$configurationXml.Load($esbFile);

Write-Host "Removing nodes ...'//ESBConfiguration/ChangeList/Additions/string'...";
$configurationXml.SelectNodes("//ESBConfiguration/ChangeList/Additions/string") | % { $_.ParentNode.RemoveChild($_) };
Write-Host " ";
Write-Host "Removing nodes ...'//ESBConfiguration/ChangeList/Revisions/string'...";
$configurationXml.SelectNodes("//ESBConfiguration/ChangeList/Revisions/string") | % { $_.ParentNode.RemoveChild($_) };
Write-Host " ";
Write-Host "Removing nodes ...'//ESBConfiguration/ChangeList/Deletions/string'...";
$configurationXml.SelectNodes("//ESBConfiguration/ChangeList/Deletions/string") | % { $_.ParentNode.RemoveChild($_) };
Write-Host " ";
Write-Host "Saving 'esb_configuration.xml' file...";
$configurationXml.Save($esbFile);
Write-Host " ";
Write-Host "Finish preparing 'esb_configuration.xml' file..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";

Write-Host " ";
Write-Host " ";
Write-Host "Start preparing swaggers files..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	NeuronConfigurationSourceFolder: '"$NeuronConfigurationSourceFolder"'";
Write-Host "	NeuronHost	                   : '"$NeuronHost"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

$swaggersFolder = ($NeuronConfigurationSourceFolder+"\docs");

if(Test-Path -Path $swaggersFolder)
{
	$files = Get-ChildItem ($swaggersFolder+"\*.json");
	Write-Host " ";
	Write-Host " ";
	Write-Host "Found $files.Count swagger files...";
	Write-Host " ";
	Write-Host " ";

	foreach($file in $files)
	{
		Write-Host " ";
		Write-Host " ";
		Write-Host "Preparing file: "$file;
		Write-Host " ";
		Write-Host " ";
		$swaggerFile = Get-Content ($file);
		$match = $swaggerFile  -match '"host"*'
		if (([string]$match).Contains("host"))
		{
			Write-Host " ";
			Write-Host "Found matching string..."
			Write-Host " ";
			$newHost = '"host": "'+$NeuronHost.ToLower()+'",';
			Write-Host " ";
			Write-Host "Replacing '"$match"' by '"$newHost"' in file '"$file"'";
			Write-Host " ";
			$swaggerFile | % { $_.Replace($match, $newHost) } | Set-Content ($file);
			Write-Host " ";
			Write-Host "File '"$file"' saved..." ;
			Write-Host " ";
		}
		else
		{
			Write-Host "String not found in file '"$file"'";
		}
	}
}
else
{
	Write-Host " ";
	Write-Host " ";
	Write-Host "There are no wagger files to prepare...";
	Write-Host " ";
	Write-Host " ";
}