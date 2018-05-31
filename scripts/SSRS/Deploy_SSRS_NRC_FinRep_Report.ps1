Param( 
	[Parameter(Mandatory=$true)] 
	[string]$ReportServerUrl,
    [string]$ReportServerUrlFolder,
    [string]$ReportSourceFolder,
    [string]$DataSourcePath,
    [string]$DataSetFolder,
	[string]$DBName,
	[string]$DBUserName,
	[string]$DBPassword
)


Write-Host " ";
Write-Host " ";
Write-Host "Deploying SSRS Monitor-Configuration Project..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	ReportServerUrl         : '"$ReportServerUrl"'";
Write-Host "	ReportServerUrlFolder   : '"$ReportServerUrlFolder"'";
Write-Host "	ReportSourceFolder      : '"$ReportSourceFolder"'";
Write-Host "	DataSourcePath          : '"$DataSourcePath"'";
Write-Host "	DataSetFolder           : '"$DataSetFolder"'";
Write-Host "	DatabaseName            : '"$DBName"'";
Write-Host "	DatabaseUserName        : '"$DBUserName"'";
Write-Host "	DatabasePassword        : '"$DBPassword"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";


#Set variables with configure values
$ReportPath ="/"  # Rool Level
$IsOverwriteDataSource =1
$IsOverwriteDataSet =1
$IsOverwriteReport =1


$webServiceUrl = $ReportServerUrl;

#Connecting to SSRS
Write-Host "ReportServerUrl: $webServiceUrl" -ForegroundColor Magenta
Write-Host "Creating Proxy, connecting to : $webServiceUrl/ReportService2010.asmx?WSDL"
Write-Host ""
$ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl'/ReportService2010.asmx?WSDL' -UseDefaultCredential


$ReportServerUrlFolder_Final = $reportPath +  $ReportServerUrlFolder
$ReportServerUrlDatasourceFolder = $reportPath + $DataSourcePath
$ReportServerUrlDatasetFolder = $reportPath + $DataSetFolder

##########################################    
#Create needed folders
Write-host "Create Report Folder" -ForegroundColor Blue
try
{
	# reports / datasources / datasets folders
	$foldersArrayToCreate = $ReportServerUrlFolder,$DataSourcePath,$DataSetFolder

	foreach ($foldersToCreate in $foldersArrayToCreate)
	{
	    Write-host "Checking folder $foldersToCreate " -ForegroundColor Blue
		$folders = $foldersToCreate.Split('/');
		$reportPathStart = "/";
		for ($index = 0; $index -lt $folders.Length; $index++)
		{
			if ($index -gt 0)
			{
				if ($reportPathStart -eq "/")
				{
					$reportPathStart = $reportPathStart + $folders[$index-1];
				}
				else
				{
					$reportPathStart = $reportPathStart + "/" + $folders[$index-1];
				}
			}
		
			try
			{
				
				Write-Host "Creating Folder: " $folders[$index]
				Write-Host "DataSourcePath: " $("/"+$DataSourcePath)
				Write-Host "DataSetFolder: " $("/"+$DataSetFolder)
				Write-Host "FullPath: " $($reportPathStart+"/"+$folders[$index])
				
				if ($($reportPathStart+"/"+$folders[$index]) -eq $("/"+$DataSourcePath) -or
				    $($reportPathStart+"/"+$folders[$index]) -eq $("/"+$DataSetFolder))
				{
					Write-Host "Hidding the folder "+$folders[$index];
					$type = $ssrsProxy.GetType().Namespace
					$datatype = ($type + '.Property')

					$HiddenSpecifiedProp = New-Object($datatype)
					$HiddenSpecifiedProp.Name = 'HiddenSpecified'
					$HiddenSpecifiedProp.Value = $true;
					$HiddenProp = New-Object($datatype)
					$HiddenProp.Name = 'Hidden'
					$HiddenProp.Value = $true;
					$Properties = @($HiddenSpecifiedProp, $HiddenProp)
			
					$ssrsProxy.CreateFolder($folders[$index], $reportPathStart, $Properties)
				}
				else
				{
					$ssrsProxy.CreateFolder($folders[$index], $reportPathStart, $null)
				}
				
				Write-Host "Created new folder: $($folders[$index])" -ForegroundColor Green
			}
			catch [System.Web.Services.Protocols.SoapException]
			{
				if ($_.Exception.Detail.InnerText.ToString().Contains("rsItemAlreadyExists400"))
				{
					Write-Host "Folder: $($folders[$index]) already exists in $reportPathStart. Skipping folder creation." -ForegroundColor Yellow
				}
				else
				{
					throw $_;
				}	
			}
		}
	}
}
catch [System.Web.Services.Protocols.SoapException]
{
	$msg = "Error creating folder: $reportPathStart $($folders[$index]) . Msg: '{0}'" -f $_.Exception.Detail.InnerText
	Write-Error $msg
}


##########################################
#Create datasource
Write-host "Check to create datasource" -ForegroundColor Cyan;
$rdsFiles = Get-ChildItem $ReportSourceFolder -Filter *.rds
foreach($rdsfile in $rdsFiles)
{
	Write-host $rdsfile -ForegroundColor Magenta;

	#create data source
	Write-host "Create datasource" -ForegroundColor Blue;
	try
    {
        $rdsf = [System.IO.Path]::GetFileNameWithoutExtension($rdsfile);

        $RdsPath = $ReportSourceFolder+"\"+$rdsf+".rds"

        Write-host "Reading data from $RdsPath" -ForegroundColor Blue;

        [xml]$Rds = Get-Content -Path $RdsPath
        $ConnProps = $Rds.RptDataSource.ConnectionProperties

        $type = $ssrsProxy.GetType().Namespace
        $datatype = ($type + '.DataSourceDefinition')
        $datatype_Prop = ($type + '.Property')

        $DescProp = New-Object($datatype_Prop)
        $DescProp.Name = 'Description'
        $DescProp.Value = ''
        $HiddenProp = New-Object($datatype_Prop)
        $HiddenProp.Name = 'Hidden'
        $HiddenProp.Value = 'true'
        $Properties = @($DescProp, $HiddenProp)

        $Definition = New-Object ($datatype)
        $Definition.ConnectString = $ConnProps.ConnectString
        $Definition.Extension = $ConnProps.Extension 
        if ([Convert]::ToBoolean($ConnProps.IntegratedSecurity)) 
		{
            $Definition.CredentialRetrieval = 'Integrated'
        }
		else
		{
			$Definition.ConnectString = 'DATA SOURCE=' + $DBName + ';PERSIST SECURITY INFO=True' 
			$credentialRetrievalDataType = ($type + '.CredentialRetrievalEnum'); 
			$credentialRetrieval = new-object ($credentialRetrievalDataType);
			$credentialRetrieval.value__ = 1;# Stored
			$Definition.CredentialRetrieval = $credentialRetrieval;
			$Definition.WindowsCredentials = $false;
			$Definition.UserName = $DBUserName;
			$Definition.Password = $DBPassword
		}
    
        #$DataSource = New-Object -TypeName PSObject -Property 
		#@{
        #    Name = $Rds.RptDataSource.Name
        #    Path =  $Folder + '/' + $Rds.RptDataSource.Name
        #}

		if ($IsOverwriteDataSource -eq 1)
		{
			[boolean]$IsOverwriteDataSource = 1
		}
		else
		{
			[boolean]$IsOverwriteDataSource = 0

		}

        $warnings = $ssrsProxy.CreateDataSource($rdsf, $ReportServerUrlDatasourceFolder ,$IsOverwriteDataSource, $Definition, $Properties)
            
        #Write-Host $warnings
    }
    catch [System.IO.IOException]
    {
        $msg = "Error while reading rds file : '{0}', Message: '{1}'" -f $rdsfile, $_.Exception.Message;
        Write-Error $msg ;
    }
    catch [System.Web.Services.Protocols.SoapException]
	{
        if ($_.Exception.Detail.InnerText.ToString().Contains("rsItemAlreadyExists400"))
        {
			Write-Host "DataSource: $rdsf already exists." -ForegroundColor Orange;
        }
        else
		{
		
			$msg = "Error uploading report: $rdsf. Msg: '{0}'" -f $_.Exception.Detail.InnerText;
			Write-Error $msg ;
		}
	}
 }


########################################## 
# Create Dataset
Write-host "dataset changes start" -ForegroundColor Blue;
$rsdFiles = Get-ChildItem $ReportSourceFolder -Filter *.rsd
foreach($rsdfile in $rsdFiles)
{
	Write-host ""

	$rsdf =  [System.IO.Path]::GetFileNameWithoutExtension($rsdfile)
    $RsdPath = $ReportSourceFolder+'\'+$rsdf+'.rsd'
    
    Write-Verbose "New-SSRSDataSet -RsdPath $RsdPath -Folder $DataSetFolder"
    
	$RawDefinition = Get-Content -Encoding Byte -Path $RsdPath
	$warnings = $null

	$Results = $ssrsProxy.CreateCatalogItem("DataSet", $rsdf, $ReportServerUrlDatasetFolder, $IsOverwriteDataSet, $RawDefinition, $null, [ref]$warnings) 
    
	write-host "dataset $rsdf created successfully"  -ForegroundColor Green;
}

$sharedDataSetsToUpdate = New-Object 'System.Collections.Generic.HashSet[string]'

#############################
#For each RDL file in Folder

foreach($rdlfile in Get-ChildItem $ReportSourceFolder -Filter *.rdl)
{
	Write-host " "

	#ReportName
	$reportName = [System.IO.Path]::GetFileNameWithoutExtension($rdlFile);
    $reportFullName = $ReportServerUrlFolder_Final+"/"+$reportName;
	write-host $reportName -ForegroundColor Green 
	#Upload File
    try
    {
        #The datasources are embedded 
		
		###### not needed for the moment as the only datasource we have is DWH 
		#
        #if ($rdsFiles.Length -eq 0)
        #{
        #    [xml]$fileContentXML = New-Object XML;
        #    $fileContentXML.Load($rdlFile.FullName);
        #    
        #    $ns = New-Object System.Xml.XmlNamespaceManager($fileContentXML.NameTable)
        #    $ns.AddNamespace("ns", $fileContentXML.DocumentElement.NamespaceURI)
        #    $nodes = $fileContentXML.SelectNodes("//ns:ConnectString", $ns)
		#
        #    foreach($node in $nodes)
        #    {
        #        Write-Host $node
        #        $currMachineName = ""
        #        if (($node.'#text').StartsWith('='))
        #        {
        #            $currMachineName = $node.'#text'.Replace('="http://', '').Split('/')[0];
        #        }
        #        else
        #        {
        #            $currMachineName = $node.'#text'.Replace('http://', '').Split('/')[0];
        #        }
		#
        #        Write-Host $currMachineName
        #        $node.'#text' = $node.'#text'.Replace($currMachineName, $NeuronServerName);
        #        Write-Host $node;
        #    }
        #    $fileContentXML.Save($rdlFile.FullName);
        #}
		
        #Get Report content in bytes
        Write-Host "Getting file content of : $rdlFile"
        $byteArray = gc $rdlFile.FullName -encoding byte
        $msg = "Total length: {0}" -f $byteArray.Length
        Write-Host $msg
 
        Write-Host "Uploading to: $ReportServerUrlFolder_Final"

        $type = $ssrsProxy.GetType().Namespace
        $datatype = ($type + '.Property')

        $DescProp = New-Object($datatype)
		$DescProp.Name = 'Description'
		$DescProp.Value = ''
		$HiddenProp = New-Object($datatype)
		$HiddenProp.Name = 'Hidden'
		
		if ($reportName.endswith("Sub"))
		{
			$HiddenProp.Value = $true;
		}
		else
		{
			$HiddenProp.Value = $false;
		}
		
		$Properties = @($DescProp, $HiddenProp)
 
        #Call Proxy to upload report
        $warnings = $null;
		$Results = $ssrsProxy.CreateCatalogItem("Report", $reportName,$ReportServerUrlFolder_Final, $IsOverwriteReport,$byteArray,$Properties,[ref]$warnings) 

		if($warnings.length -le 1) 
        { 
			Write-Host "Upload Success." -ForegroundColor Green
        }
        else 
        { 
            foreach($warn in $warnings) {
                write-host $warn.Message
            }			
        }  
    }
    catch [System.IO.IOException]
    {
        $msg = "Error while reading rdl file : '{0}', Message: '{1}'" -f $rdlFile, $_.Exception.Message
        Write-Error msg
    }
    catch [System.Web.Services.Protocols.SoapException]
	{
		$msg = "Error uploading report: $reportName. Msg: '{0}'" -f $_.Exception.Detail.InnerText
		Write-Error $msg
	}

	##########################################
    ##Change report's datasources
    if ($rdsFiles.Length -gt 0)
    {        
        Write-Host "Checking datasources for $reportFullName"

        $dataSources = $ssrsProxy.GetItemDataSources(([string]$reportFullName));
        $datasourcesFound = $datasources.length;
        Write-Host "Datasources found $datasourcesFound"

        if ($datasources.length -gt 0)
        {
            foreach($dataSource in $dataSources)
            {
                $proxyNamespace = $dataSource.GetType().Namespace;
    
                $constDatasource = New-Object ("$proxyNamespace.DataSource")
        
                $constDatasource.Item = New-Object ("$proxyNamespace.DataSourceReference")
                $FinalDatasourcePath =  $ReportServerUrlDatasourceFolder +"/" + $($dataSource.Name)
                $constDatasource.Item.Reference = $FinalDatasourcePath
				
                $dataSource.item = $constDatasource.Item
                $ssrsProxy.SetItemDataSources($reportFullName, $dataSource)
                Write-Host "Changing datasource `"$($dataSource.Name)`" to $($dataSource.Item.Reference)"
            }
        }
    }

	##########################################
    ## Change report's shared dataset Reference
    ## partially inspired by http://www.sqlservercentral.com/blogs/data-adventures/2015/05/14/powershell-for-ssrs-in-sharepoint-multiple-data-sources-and-shared-datasets/
    
    Write-Host "Checking datasets for $reportFullName"
       
    # storing data sets references
    $datasetsInReport = $ssrsProxy.GetItemReferences($reportFullName, "DataSet");
 
    Write-Host "Loading report's XML"
    [xml]$rptXml = Get-Content $rdlfile.FullName;

    # counter for logging purposes
    $sharedDataSetCount = 0;


    $proxyNS = $ssrsProxy.GetType().Namespace;
    $itemRefType = ($type + '.ItemReference');

    Write-Host "Looping on datasets"
    # Check all of the report's datasets
    foreach ($node in $rptXml.Report.dataSets.DataSet)
    {
        $reportDataSetName = $node.Name;
        foreach ($subnode in $node)
        {
            # check if it's a shared dataset
            $reportDataSetReference = $subnode.SharedDataSet.SharedDataSetReference;
            if(!([system.string]::IsNullOrEmpty($reportDataSetReference)))
            {
                foreach($ds in $datasetsInReport)
                {
                    if($ds.Name -eq $reportDataSetName)
                    {
                        Write-Host "Processing $reportDataSetName";

                        $newDataSetRef = New-Object($itemRefType);
                        $newDataSetRef.Name = $reportDataSetName;
                        $newDataSetRef.Reference = "$ReportServerUrlDatasetFolder/$reportDataSetReference";
                        
                        $sharedDataSetsToUpdate.Add($newDataSetRef.Reference);

                        $ssrsProxy.SetItemReferences($reportFullName, @($newDataSetRef));
                        Write-Host "Dataset $reportDataSetName mapped to $($newDataSetRef.Reference)";
                        $sharedDataSetCount++;
                    }
                }
            }
        }
    }

    Write-Host "Processed $sharedDataSetCount shared dataset(s)";

}

	##########################################
    ## Change shared datasets datasources to point to new location

foreach($sharedDs in $sharedDataSetsToUpdate)
{
    Write-host " "
    Write-host "Updating shared data set's datasource $sharedDs";

    #Write-Host "Checking datasources for $reportFullName";

    $dataSources = $ssrsProxy.GetItemDataSources($sharedDs);
    $datasourcesFound = $datasources.length;
    Write-Host "Datasources found $datasourcesFound"

    if ($datasources.length -gt 0)
    {
        foreach($dataSource in $dataSources)
        {
            $proxyNamespace = $ssrsProxy.GetType().Namespace;

            $constDatasource = New-Object ("$proxyNamespace.DataSource")
        
            Write-Host "Test datasource object $dataSource";
            Write-Host "Test Name $($dataSource.Name)";
            Write-Host "Test Value $($dataSource.Value)";
            Write-Host "Test Content $($dataSource.Content)";
            
            $constDatasource.Item = New-Object ("$proxyNamespace.DataSourceReference")
            $FinalDatasourcePath =  $ReportServerUrlDatasourceFolder + "/DWH"; # + $($dataSource.Item.Reference);
            $constDatasource.Item.Reference = $FinalDatasourcePath;

            $dataSource.item = $constDatasource.Item;
            $ssrsProxy.SetItemDataSources($sharedDs, $dataSource);
            Write-Host "Changing datasource `"$($dataSource.Name)`" to $($dataSource.Item.Reference)";
            
        }
    }
}

Write-host ""
Write-host " We have successfully Deployed SSRS Project" -ForegroundColor Magenta
Write-host ""




## credits to the original author of the initial skeleton script
## script found on technet: https://social.technet.microsoft.com/wiki/contents/articles/34521.powershell-script-for-ssrs-project-deployment.aspx