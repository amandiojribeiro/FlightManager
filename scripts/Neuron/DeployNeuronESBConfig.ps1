Param( 
	[Parameter(Mandatory=$true)] 
	[string]$NeuronConfigurationSourceFolder,
	[string]$NeuronConfigurationServerFolder,
	[string]$BuildNumber
)


Write-Host " ";
Write-Host " ";
Write-Host "Deploying Neuron Config..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	NeuronConfigurationSourceFolder: '"$NeuronConfigurationSourceFolder"'";
Write-Host "	NeuronConfigurationServerFolder: '"$NeuronConfigurationServerFolder"'";
Write-Host "	BuildNumber                    : '"$BuildNumber"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

#################### Rename current neuron Config Folder #################### 
Write-Host "Renaming current Neuron folder..." -ForegroundColor Magenta;

$splittedPath = $NeuronConfigurationServerFolder.Split("\");

$neuronConfigFolderName = $splittedPath[$splittedPath.Lenght-1];
$neuronConfigServerRootFolder = $NeuronConfigurationServerFolder.Replace($neuronConfigFolderName, "");

$renamedConfigFolderName = $NeuronConfigurationServerFolder.Replace($neuronConfigFolderName, "Archive_"+$neuronConfigFolderName+"_Old");


Write-Host "Renaming folder '"$NeuronConfigurationServerFolder"' to '"$renamedConfigFolderName"'";
Rename-Item $NeuronConfigurationServerFolder $renamedConfigFolderName
Write-Host "Folder renamed from '"$NeuronConfigurationServerFolder"' to '"$renamedConfigFolderName"'";
Write-Host " "

#################### Create new folder for neuron config #################### 
Write-Host "Creating Folder '"$NeuronConfigurationServerFolder"'";
New-Item -ItemType directory -Path $NeuronConfigurationServerFolder;
Write-Host "Folder '"$NeuronConfigurationServerFolder"' created...";
Write-Host " "

#################### Copy previous Zones and Administrators #################### 
Write-Host "Copy Zones folder from previous version..."
Copy-item -Force -Recurse -Verbose ($renamedConfigFolderName+"\Zones") -Destination ($NeuronConfigurationServerFolder);
Write-Host "Zones folder copied..."
Write-Host " "
Write-Host "Copy Administrators folder from previous version..."
Copy-item -Force -Recurse -Verbose ($renamedConfigFolderName+"\Administrators") -Destination ($NeuronConfigurationServerFolder);
Write-Host "Administrators folder copied..."
Write-Host " "

#################### Copy neuron config to server #################### 
Write-Host "Creating exclude filter";
$excludeFilter = '\.gitignore';
Write-Host "Exclude filter is: "$excludeFilter;
Write-Host "Copy all files and folders from '"$NeuronConfigurationSourceFolder"' to '"$NeuronConfigurationServerFolder"' (except the excluded)...";
Get-ChildItem $NeuronConfigurationSourceFolder -Recurse  | where {$_.FullName -notmatch $excludeFilter} | 
    Copy-Item -Destination {Join-Path $NeuronConfigurationServerFolder $_.FullName.Substring($NeuronConfigurationSourceFolder.length)}
Write-Host "Files and folders copied from '"$NeuronConfigurationSourceFolder"' to '"$NeuronConfigurationServerFolder"'";
Write-Host " "


#################### Creating Build Number file for new deployment #################### 
Write-Host "Creating BuildNumber file 'Build_"$BuildNumber".info' in '"$NeuronConfigurationServerFolder"'";
New-Item ($NeuronConfigurationServerFolder + "\Build_" + $BuildNumber + ".info") -ItemType file
Write-Host "BuildNumber file 'Build_"$BuildNumber".info' creatend in '"$NeuronConfigurationServerFolder"'";
Write-Host " "


#################### Renaming previous folder with the proper build number #################### 
Write-Host "Check if previous folder has BuildNumber file..."
$old_buildNumber = 0;
if(Test-Path -Path ($renamedConfigFolderName +"\Build_*.info"))
{
	Write-Host "Folder has BuildNumber information file..."
	$infoFile = Get-ChildItem ($renamedConfigFolderName) -Filter "Build_*.info" | Select-Object -First 1;
	$old_buildNumber = $infoFile.Name.Replace(".info", "").Split("_")[1];
	Write-Host "Old BuildNumber is: "$old_buildNumber;
	Write-Host " "
}
else
{
	Write-Host "There is no BuildNumber information file. BuildNumber set to 0 (zero)...";
	Write-Host " "
	$old_buildNumber = "0";
}

$renamedConfigFolderNameWithBuildNumber = $renamedConfigFolderName.Replace("_Old", "_"+$old_buildNumber);
Write-Host "Renaming folder '"$renamedConfigFolderName"' to '"$renamedConfigFolderNameWithBuildNumber"'";
Rename-Item $renamedConfigFolderName $renamedConfigFolderNameWithBuildNumber;
Write-Host "Folder renamed from '"$renamedConfigFolderName"' to '"$renamedConfigFolderNameWithBuildNumber"'";


Write-Host "Deleting all old folders";
#Get all files and folders except current one and previous
$excludeString = ($renamedConfigFolderNameWithBuildNumber.Replace($neuronConfigServerRootFolder, "") + "," + $neuronConfigFolderName)
$excludeFilter = $excludeString -split ",";
Write-Host " "

Write-Host "Exclude String is: "$excludeString;
Write-Host " "

#Remove all except the ones in the exclude
Get-ChildItem -Path $neuronConfigServerRootFolder -Exclude $excludeFilter | remove-item -recurse;
Write-Host "Old folders deleted";

Write-Host " "
Write-Host " "
Write-Host "Neuron Config deployed..." -ForegroundColor Magenta;





