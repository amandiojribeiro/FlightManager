Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SSISProjectName,
	[string]$SSISProjectPath,
	[string]$Configuration,
	[string]$SSISBuildSharedFolder
)

Write-Host " ";
Write-Host "Deploying SSIS Miscellaneous Content..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SSISProjectName		: '$SSISProjectName'";
Write-Host "	SSISProjectPath		: '$SSISProjectPath'";
Write-Host "	Configuration		: '$Configuration'";
Write-Host "	SSISBuildSharedFolder 	: '$SSISBuildSharedFolder'";
Write-Host "###############################################################################################################";

Try
{
	Write-Host $("DEPLOY $SSISProjectName Miscellaneous Content to Miscellaneous Folder");
	Write-Host " "

	
	Write-Host "GET Miscellaneous files for project: '$SSISProjectName'";
	$SSISProjectFullPath = $SSISProjectPath + "\" + $SSISProjectName + ".dtproj";

	[xml]$SSISProjectXml = New-Object XML;
	$SSISProjectXml.Load($SSISProjectFullPath);

	$nodeMiscFiles = $SSISProjectXml.SelectSingleNode("//Project/Miscellaneous");
	$nodesMiscFilesName = $nodeMiscFiles.SelectNodes("ProjectItem/Name");

	if(($nodesMiscFilesName -ne $null) -and ($nodesMiscFilesName.count -gt 0))
	{
		$isFirst = $true;
		Write-Host "DEPLOY Miscellaneous content into Build Shared Folder";
		Write-Host " ================ " -ForegroundColor Green;
		foreach ($nodeMiscFileName in $nodesMiscFilesName) 
		{
			if($isFirst -eq $false)
			{
				Write-Host " "
			}

			$SSISBuildMiscFolder = $SSISBuildSharedFolder + "\Miscellaneous"
			
			$miscFileName = $nodeMiscFileName.InnerText;
			$miscFullFileName = $SSISProjectPath + "\" + $miscFileName;

			Write-Host " COPY : " $miscFullFileName;
			Write-Host " INTO : " $SSISBuildMiscFolder;
			Copy-Item $miscFullFileName $SSISBuildMiscFolder -force;# -verbose;
			$isFirst = $false;
		}
		Write-Host " ================ " -ForegroundColor Green;

		#****************************** TODO **************************************
		###################### COPY REMOTLY FROM SHARED INTO CONFIG FOR ENVIRONMENT ######################
		#Write-Host "GET Miscellaneous folder for environment configuration: '$Configuration'";
		#$SSISProjectMiscFolder = "E:\SSIS\Miscellaneous";
		#
		#Write-Host "DEPLOY Miscellaneous content for environment configuration: '$Configuration'";
		#REMOTE COPY FILES
		#Write-Host " ================ " -ForegroundColor Green;
		#Write-Host " COPY : " $SSISBuildMiscFolder;
		#Write-Host " INTO : " $SSISProjectMiscFolder;
		#Copy-Item $SSISBuildMiscFolder $SSISProjectMiscFolder -force;# -verbose;
		#Write-Host " ================ " -ForegroundColor Green;
		###################### COPY REMOTLY FROM SHARED INTO CONFIG FOR ENVIRONMENT ######################
		#****************************** TODO **************************************
	}
	else
	{
		Write-Host " THERE IS NO Miscellaneous CONTENT TO DEPLOY"  -ForegroundColor Green;
	}
	Write-Host " "
	Write-Host $("DEPLOYED Miscellaneous Content for $SSISProjectName.")
}
Catch
{
	Write-Host $("Error when deploying $SSISProjectName");
	Write-Host $("	Failed Item  : $_.Exception.ItemName");
	Write-Host $("	Error Message: $_.Exception.Message");
}
