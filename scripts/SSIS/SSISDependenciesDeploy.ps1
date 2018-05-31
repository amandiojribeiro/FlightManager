Param( 
	[Parameter(Mandatory=$true)] 
	[string]$NeuronDependenciesSourceFolder,
	[string]$NeuronConfigurationServerRootFolder,
	[string]$NeuronConfigurationLocalFolder,
	[string]$NeuronInstanceServerFolder,
	[string]$NeuronServerName
)
Write-Host " ";
Write-Host " ";
Write-Host "Deploying Neuron Dependencies..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	NeuronDependenciesSourceFolder     : '"$NeuronDependenciesSourceFolder"'";
Write-Host "	NeuronConfigurationServerRootFolder: '"$NeuronConfigurationServerRootFolder"'";
Write-Host "	NeuronConfigurationLocalFolder	   : '"$NeuronConfigurationLocalFolder"'";
Write-Host "	NeuronInstanceServerFolder	       : '"$NeuronInstanceServerFolder"'";
Write-Host "	NeuronServerName				   : '"$NeuronServerName"'";
Write-Host "	BuildNumber				           : '"$BuildNumber"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

#### Copy Pipeline Folder ####
$sourcePipelineFolder = $NeuronDependenciesSourceFolder + "\Pipelines"; 
$instancePipelineFolder = $NeuronInstanceServerFolder + "\Pipelines"; 

Write-Host 'Preparing to copy Pipelines from '$sourcePipelineFolder' to '$instancePipelineFolder;
if(Test-Path -Path $sourcePipelineFolder)
{
	$pipelineDlls = Get-ChildItem $sourcePipelineFolder -Filter "MUFG.Neuron.Custom.Pipeline.*.dll";
	$copiedPipelines = $false;
	foreach($pipelineDll in $pipelineDlls)
	{
		$newPipelineVersion = (get-item $pipelineDll.FullName).VersionInfo.ProductVersion;
		
		if (Test-Path -Path ($instancePipelineFolder +"\" + $pipelineDll))
		{
			$currentPipelineVersion = (get-item ($instancePipelineFolder +"\" + $pipelineDll)).VersionInfo.ProductVersion;
			#if([System.Version]$newPipelineVersion -ne [System.Version]$currentPipelineVersion)
			#{
				Copy-Item $pipelineDll.FullName -Destination $($instancePipelineFolder +"\" + $pipelineDll);
				$copiedPipelines = $true;
			#}
		}
		else
		{
			Copy-Item $pipelineDll.FullName -Destination $($instancePipelineFolder +"\" + $pipelineDll);
			$copiedPipelines = $true;
		}
	}
	
	if ($copiedPipelines -eq $true)
	{
		Copy-Item ($sourcePipelineFolder + "\neuronpipelines.config") -Destination ($instancePipelineFolder + "\neuronpipelines.config");
		Remove-Item $instancePipelineFolder"\*.typecache" -Force;
		Write-Host "Pipelines copied";
	}
	else
	{ Write-Host "No Pipelines to copy"; }
}
else
{ Write-Host "No Pipelines to deploy"; }

#### Copy Pipeline Folder ####


#### Copy Adapter Folder ####
$sourceAdapterFolder = $NeuronDependenciesSourceFolder + "\Adapters"; 
$instanceAdapterFolder = $NeuronInstanceServerFolder + "\Adapters"; 

Write-Host 'Preparing to copy Adapters from '$sourceAdapterFolder' to '$instanceAdapterFolder;
if(Test-Path -Path $sourceAdapterFolder)
{
	$adapterDlls = Get-ChildItem $sourceAdapterFolder -Filter "MUFG.Neuron.Custom.Adapter.*.dll";
	$copiedAdapter = $false;
	foreach($adapterDll in $adapterDlls)
	{
		$newAdapterVersion = (get-item $adapterDll.FullName).VersionInfo.ProductVersion;
		
		if (Test-Path -Path ($instanceAdapterFolder +"\" + $adapterDll))
		{
			$currentAdapterVersion = (get-item ($instanceAdapterFolder +"\" + $adapterDll)).VersionInfo.ProductVersion;
			#if([System.Version]$newAdapterVersion -ne [System.Version]$currentAdapterVersion)
			#{
				Copy-Item $adapterDll.FullName -Destination ($instanceAdapterFolder+"\" + $adapterDll);
				$copiedAdapter = $true;
			#}
		}
		else
		{
			Copy-Item $adapterDll.FullName -Destination ($instanceAdapterFolder +"\" + $adapterDll);
			$copiedAdapter = $true;
		}
	}
	if($copiedAdapter -eq $true) 
	{ Write-Host "Adapters copied"; }
	else
	{ Write-Host "No adapters to copy"; }
}
else
{ 
	Write-Host "No adapters to deploy"; 
}
#### Copy Adapter Folders ####


#### Register DLLs in GAC ####
$sourceGACFolder = $NeuronDependenciesSourceFolder + "\GAC"; 
$configurationGACFolder = $NeuronConfigurationServerRootFolder + "\GAC"; 
$localNeuronGACFolder = $NeuronConfigurationLocalFolder + "\Gac";
		
Write-Host 'Preparing to register Dependencies in GAC from '$sourceGACFolder' to '$configurationGACFolder;
if(Test-Path -Path $sourceGACFolder)
{
	$gacTestPath = Test-Path -Path $configurationGACFolder;
	if($gacTestPath -eq $false)
	{
		Write-Host "Gac folder does not exists. Creating folder";
		New-Item -Path $configurationGACFolder -ItemType directory;
		Write-Host "Gac folder created";
	}
	else
	{
		Write-Host "Gac folder exists";
	}

	$componentDlls = Get-ChildItem $sourceGACFolder -Filter "MUFG.*.dll";
	$copiedComponents = $false;
	Write-Host 'Preparing to copy Components from '$sourceGACFolder' to '$configurationGACFolder;
	foreach($componentDll in $componentDlls)
	{
		Copy-Item $componentDll.FullName -Destination ($configurationGACFolder +"\" + $componentDll);
		$copiedComponents = $true;
	}

	if ($copiedComponents)
	{ Write-Host "Components copied"; }
	else
	{ Write-Host "No components to copy"; }

	if ($copiedComponents)
	{
		Invoke-Command -Computer $NeuronServerName -ScriptBlock {
			Param([string]$localNeuronGACFolder)
			
			Write-Host "Preparing to register Components into the Gac";
			$registeredComponent = $false;
     		$found = $false;
		
			Write-Host $("Looking for components in '$localNeuronGACFolder'");
			$componentDlls = Get-ChildItem $localNeuronGACFolder -Filter "MUFG.*.dll";
			Write-Host $("Found components to register");
			foreach($componentDll in $componentDlls)
			{	
				$newComponentVersion = (get-item $componentDll.FullName).VersionInfo.ProductVersion;
				Write-Host $("New Component Version is: $newComponentVersion");
				
				$currentComponentsGac = Get-GacAssembly -Name $componentDll.BaseName;
				if ($currentComponentsGac -eq $null)
				{ 
					Write-Host $("There is no component registered. Registering New one: '$newComponentVersion'"); 
					Add-GacAssembly $componentDll.FullName;
					$registeredComponent = $true;
				}
				else
				{
					foreach($currentComponentGac in $currentComponentsGac)
					{
						#Write-Host $("Current Component Version: " + [System.Version]$currentComponentGac.Version);
						#Write-Host $("New Component Version: " + [System.Version]$newComponentVersion);
						if([System.Version]$newComponentVersion -eq [System.Version]$currentComponentGac.Version)
						{
							$found = $true;
						}
					}
					
					#if ($found -eq $false)
					#{
						Write-Host $("Registering new version of Component. From version '$currentComponentGac.Version' to version '$newComponentVersion'");
						Add-GacAssembly $componentDll.FullName; 
						$registeredComponent = $true;
					#}
					#else
					#{
					#	Write-Host $("No action taken. Version '$newComponentVersion' already registered");
					#}
				}		
			}
			if ($registeredComponent) 
			{ Write-Host "Registered Components into the Gac"; }
			else
			{ Write-Host "No Components registered into the Gac"; }
		} -ArgumentList $localNeuronGACFolder
	}
}
else
{
 Write-Host "No components to deploy to the GAC"; 
}
#### Register DLLs in GAC ####

#### Finalize the deployment delete GAC folder ####
Write-Host "Deleting all GAC folder";
#Get GAC files and folders 
$includeString = "GAC"
$includeFilter = $includeString -split ",";
Write-Host " "

Write-Host "Exclude String is: "$includeString;
Write-Host " "
Write-Host "Neuron Config Server Root Folder is "$NeuronConfigurationServerRootFolder 
#Remove all except the ones in the exclude
Get-ChildItem -Path $NeuronConfigurationServerRootFolder -Include $includeFilter | remove-item -recurse;
Write-Host "GAC folder deleted";

Write-Host " "
Write-Host " "
Write-Host "Neuron Dependencies deployed..." -ForegroundColor Magenta;
#### Finalize the deployment delete GAC folder ####