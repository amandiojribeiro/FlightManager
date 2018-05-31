Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SSISSolutionName,
	[string]$SSISSolutionPath,
	[string]$Configuration,
	[string]$SSISBuildSharedFolder,
	[string]$SSISServerName,
	[string]$SSISCatalogFolderName
)

Write-Host " ";
Write-Host "Deploying SSIS Solution..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SSISSolutionName	 	: '$SSISSolutionName'";
Write-Host "	SSISSolutionPath	 	: '$SSISSolutionPath'";
Write-Host "	Configuration		 	: '$Configuration'";
Write-Host "	SSISBuildSharedFolder 	: '$SSISBuildSharedFolder'";
Write-Host "	SSISServerName		 	: '$SSISServerName'";
Write-Host "	SSISCatalogFolderName		: '$SSISCatalogFolderName'";
Write-Host "###############################################################################################################";

$slnPath = $("$SSISSolutionPath\$SSISSolutionName");

$projects = Get-Content $slnPath | Select-String 'Project\(' |
				ForEach-Object {
					$projectParts = $_ -Split '[,=]' | ForEach-Object { $_.Trim('[ "{}]') };
						New-Object PSObject -Property @{
						Name = $projectParts[1];
						File = $projectParts[2];
						Guid = $projectParts[3]
					}
				}

$isFirst = [bool]$true;				
foreach($item in $projects)
{
	if ($item.File.EndsWith(".dtproj"))
	{
		Write-Host "Starting build project: '$($item.Name)'...";
		$projPath = $item.File.Split("\")[0]
		$ssisProjectPath = $("$SSISSolutionPath\$projPath");
		$ssisProjecName = $item.Name;
		.\SSISProjectDeploy.ps1 		-SSISProjectName:"$ssisProjecName" -SSISProjectPath:"$ssisProjectPath" -Configuration:"$Configuration" 	-SSISServerName:"$SSISServerName" -SSISCatalogFolderName:"$SSISCatalogFolderName"
		.\SSISMiscellaneousDeploy.ps1	-SSISProjectName:"$ssisProjecName" -SSISProjectPath:"$ssisProjectPath" -Configuration:"$Configuration"  -SSISBuildSharedFolder:"$SSISBuildSharedFolder"
		Write-Host "Finished build project: '$($item.Name)'...";
	}
	else
	{
		Write-Host "Skipping project '$($item.Name)'. There is no project file...";
	}
	$isFirst = [bool]$false;	
}