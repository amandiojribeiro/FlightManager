Param( 
	[Parameter(Mandatory=$true)] 
	[string]$SSISProjectName,
	[string]$SSISProjectPath,
	[string]$Configuration,
	[string]$SSISServerName,
	[string]$SSISCatalogFolderName
)

Write-Host " ";
Write-Host "Deploying SSIS Project..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	SSISProjectName			  : '$SSISProjectName'";
Write-Host "	SSISProjectPath			  : '$SSISProjectPath'";
Write-Host "	Configuration			  : '$Configuration'";
Write-Host "	SSISServerName			  : '$SSISServerName'";
Write-Host "	SSISCatalogFolderName	  	  : '$SSISCatalogFolderName'";
Write-Host "###############################################################################################################";


Try
{
	Write-Host $("START Prepare $SSISProjectName to Deploy.");
	Write-Host " "

	##############################################
	#Write-Host $("START Prepare Project Package Params.");
	#
	#$SSISProjectFullPath = $SSISProjectPath + "\" + $SSISProjectName + ".dtproj";

#	if (test-path $SSISProjectFullPath)
#	{
#		[xml]$SSISProjectXml = New-Object XML;
#		$SSISProjectXml.Load($SSISProjectFullPath);
#
#		$nodeProjectManifest = $SSISProjectXml.SelectSingleNode("//Project/DeploymentModelSpecificContent/Manifest");
#		$ns = new-object Xml.XmlNamespaceManager $SSISProjectXml.NameTable;
#		$ns.AddNamespace("SSIS", "www.microsoft.com/SqlServer/SSIS");
#
#		$nodeDebugmode = $nodeProjectManifest.SelectSingleNode("//SSIS:Parameter[@SSIS:Name='_SSISDebugMode']/SSIS:Properties/SSIS:Property[@SSIS:Name='Value']", $ns);
#		if($nodeDebugmode -ne $null)
#		{
#			Write-Host " ================ " -ForegroundColor Green;
#			Write-Host " Param 	:  _SSISDebugMode";
#			Write-Host " OLD 	: " $nodeDebugmode.InnerText;
#			Write-Host " NEW 	:  false" ;
#			$nodeDebugmode.InnerText = "false";
#			Write-Host " ================ " -ForegroundColor Green;
#		}
#		$SSISProjectXml.Save($SSISProjectFullPath);
#	}
#	else
#	{
#		Write-Host " "
#		Write-Host $("NOT FOUND: $SSISProjectFullPath");
#		Write-Host " "
#	}
#
#	Write-Host $("DONE Prepare Project Package Params.");
#	Write-Host " "
#	##############################################

#	##############################################
#	Write-Host $("START Prepare Executable Package Params.");
#
#	$filter	= "*.dtsx";
#	$executablesList = $(get-childitem $SSISProjectPath -include $filter -recurse);
#
#    foreach ($file in $executablesList)
#    {
#		$fileName = $file.Name;
#		$SSISExecutableFullPath = Join-Path -Path $file.Directory -ChildPath $fileName;
#		
#		if (test-path $SSISExecutableFullPath)
#		{
#			[xml]$SSISExecutableXml = New-Object XML;
#			$SSISExecutableXml.Load($SSISExecutableFullPath);
#
#			$ns = new-object Xml.XmlNamespaceManager $SSISExecutableXml.NameTable;
#			$ns.AddNamespace("DTS", "www.microsoft.com/SqlServer/Dts");
#
#			$nodeDebugmode = $SSISExecutableXml.SelectSingleNode("//DTS:PackageParameter[@DTS:ObjectName='_SSISDebugMode']/DTS:Property[@DTS:Name='ParameterValue']", $ns);
#			if($nodeDebugmode -ne $null)
#			{
#				Write-Host " ================ " -ForegroundColor Green;
#				Write-Host " Param 	:  _SSISDebugMode";
#				Write-Host " OLD 	: " $nodeDebugmode.InnerText;
#				Write-Host " NEW 	:  0" ;
#				$nodeDebugmode.InnerText = "0";
#				Write-Host " ================ " -ForegroundColor Green;
#			}
#			
#			$SSISExecutableXml.Save($SSISExecutableFullPath);
#		}
#		else
#		{
#			Write-Host " "
#			Write-Host $("NOT FOUND: $SSISExecutableFullPath");
#			Write-Host " "
#		}
#	}
#	Write-Host $("DONE Prepare Executable Package Params.");
#	Write-Host " "
#	##############################################
#
#	
#	Write-Host " "
#	Write-Host $("DONE Prepare project $SSISProjectName to Deploy.")
#	Write-Host " "

	Write-Host $("Deploying $SSISProjectName to Server '$SSISServerName' in Catalog Folder '$SSISCatalogFolderName'");
	Write-Host " "
	#*******************************
	$command = """D:\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"" ""D:\scripts\SSIS\SSIS.MSBuild.proj"" /t:SSISBuild,SSISDeploy /p:SSISProjName=" + $SSISProjectName + ",SSISProjPath=" + $SSISProjectPath + ",Configuration=" + $Configuration + ",SSISServer=" + $SSISServerName + ",FolderName=" + $SSISCatalogFolderName + ",Environment=" + $Configuration;
	cmd /c $command;
	#*******************************
	
	Write-Host " "
	Write-Host $("Deployed project $SSISProjectName.")
}
Catch
{
	Write-Host $("Error when deploying $SSISProjectName");
	Write-Host $("	Failed Item  : $_.Exception.ItemName");
	Write-Host $("	Error Message: $_.Exception.Message");
}

