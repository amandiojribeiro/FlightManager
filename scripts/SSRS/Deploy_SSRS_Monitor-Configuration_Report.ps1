Param( 
	[Parameter(Mandatory=$true)] 
	[string]$ReportServerUrl,
    [string]$NeuronServerName,
    [string]$ReportServerUrlFolder,
    [string]$ReportSourceFolder,
    [string]$DataSourcePath,
    [string]$DataSetFolder
)


Write-Host " ";
Write-Host " ";
Write-Host "Deploying SSRS Monitor-Configuration Project..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	ReportServerUrl         : '"$ReportServerUrlUrl"'";
Write-Host "	NeuronServerName        : '"$NeuronServerName"'";
Write-Host "	ReportServerUrlFolder   : '"$ReportServerUrlFolder"'";
Write-Host "	ReportReportSourceFolder: '"$ReportReportSourceFolder"'";
Write-Host "	DataSourcePath          : '"$DataSourcePath"'";
Write-Host "	DataSetFolder           : '"$DataSetFolder"'";
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

##########################################    
#Create Report Folder
Write-host "Create Report Folder" -ForegroundColor Blue
try
{
    $folders = $ReportServerUrlFolder.Split('/');
    for ($index = 0; $index -lt $folders.Length; $index++)
    {
        if ($index -gt 0)
        {
            if ($reportPath="/")
            {
                $reportPath = $reportPath + $folders[$index-1];
            }
            else
            {
                $reportPath = $reportPath + "/" + $folders[$index-1];
            }
        }

        try
        {
            $ssrsProxy.CreateFolder($folders[$index], $reportPath, $null)
            Write-Host "Created new folder: $($folders[$index])" -ForegroundColor Green
        }
        catch [System.Web.Services.Protocols.SoapException]
        {
            if ($_.Exception.Detail.InnerText.ToString().Contains("rsItemAlreadyExists400"))
	        {
		        Write-Host "Folder: $($folders[$index]) already exists in $reportPath. Skipping folder creation." -ForegroundColor Yellow
	        }
	        else
	        {
    		    throw $_;
	        }	
        }
    }
}
catch [System.Web.Services.Protocols.SoapException]
{
	$msg = "Error creating folder: $ReportServerUrlFolder. Msg: '{0}'" -f $_.Exception.Detail.InnerText
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
        $HiddenProp.Value = 'false'
        $Properties = @($DescProp, $HiddenProp)

        $Definition = New-Object ($datatype)
        $Definition.ConnectString = $ConnProps.ConnectString
        $Definition.Extension = $ConnProps.Extension 
        if ([Convert]::ToBoolean($ConnProps.IntegratedSecurity)) 
		{
            $Definition.CredentialRetrieval = 'Integrated'
        }
    
        $DataSource = New-Object -TypeName PSObject -Property 
		@{
            Name = $Rds.RptDataSource.Name
            Path =  $Folder + '/' + $Rds.RptDataSource.Name
        }

		if ($IsOverwriteDataSource -eq 1)
		{
			[boolean]$IsOverwriteDataSource = 1
		}
		else
		{
			[boolean]$IsOverwriteDataSource = 0

		}

        $warnings = $ssrsProxy.CreateDataSource($rdsf, $ReportServerUrlFolder_Final ,$IsOverwriteDataSource, $Definition, $Properties)
            
        #Write-Host $warnings
    }
    catch [System.IO.IOException]
    {
        $msg = "Error while reading rds file : '{0}', Message: '{1}'" -f $rdsfile, $_.Exception.Message;
        Write-Error msgcler -ForegroundColor Red;
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
			Write-Error $msg -ForegroundColor Red;
		}
	}
 }


########################################## 
# Create Dataset
Write-host "dataset changes start" -ForegroundColor Blue;
$rdsFiles = Get-ChildItem $ReportSourceFolder -Filter *.rsd
foreach($rsdfile in $rdsFiles)
{
	Write-host ""

	$rsdf =  [System.IO.Path]::GetFileNameWithoutExtension($rsdfile)
    $RsdPath = $ReportSourceFolder+'\'+$rsdf+'.rsd'
    
    Write-Verbose "New-SSRSDataSet -RsdPath $RsdPath -Folder $DataSetFolder"
    
	$RawDefinition = Get-Content -Encoding Byte -Path $RsdPath
	$warnings = $null

	$Results = $ssrsProxy.CreateCatalogItem("DataSet", $rsdf, $ReportServerUrlFolder_Final, $IsOverwriteDataSet, $RawDefinition, $null, [ref]$warnings) 
    
	write-host "dataset created successfully"  -ForegroundColor Green;
}


#############################
#For each RDL file in Folder

foreach($rdlfile in Get-ChildItem $ReportSourceFolder -Filter *.rdl)
{
	Write-host " "

	#ReportName
	$reportName = [System.IO.Path]::GetFileNameWithoutExtension($rdlFile);
	write-host $reportName -ForegroundColor Green 
	#Upload File
    try
    {
        #The datasources are embedded
        if ($rdsFiles.Length -eq 0)
        {
            [xml]$fileContentXML = New-Object XML;
            $fileContentXML.Load($rdlFile.FullName);
            
            $ns = New-Object System.Xml.XmlNamespaceManager($fileContentXML.NameTable)
            $ns.AddNamespace("ns", $fileContentXML.DocumentElement.NamespaceURI)
            $nodes = $fileContentXML.SelectNodes("//ns:ConnectString", $ns)

            foreach($node in $nodes)
            {
                Write-Host $node
                $currMachineName = ""
                if (($node.'#text').StartsWith('='))
                {
                    $currMachineName = $node.'#text'.Replace('="http://', '').Split('/')[0];
                }
                else
                {
                    $currMachineName = $node.'#text'.Replace('http://', '').Split('/')[0];
                }

                Write-Host $currMachineName
                $node.'#text' = $node.'#text'.Replace($currMachineName, $NeuronServerName);
                Write-Host $node;
            }
            $fileContentXML.Save($rdlFile.FullName);
        }
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
		$HiddenProp.Value = 'false'
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
			write-host $warnings 
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
    ##Change Datasource
    if ($rdsFiles.Length > 0)
    {
        $reportFullName = $ReportServerUrlFolder_Final+"/"+$reportName
        Write-Host "datasource record $reportFullName"

        $dataSources = $ssrsProxy.GetItemDataSources(([string]$reportFullName));

        foreach($dataSource in $dataSources)
        {
            $proxyNamespace = $dataSource.GetType().Namespace;
  
            $constDatasource = New-Object ("$proxyNamespace.DataSource")
    
            $constDatasource.Item = New-Object ("$proxyNamespace.DataSourceReference")
            $FinalDatasourcePath =  $DataSourcePath+"/" + $($dataSource.Name)
            $constDatasource.Item.Reference = $FinalDatasourcePath

            $dataSource.item = $constDatasource.Item
            $ssrsProxy.SetItemDataSources($reportFullName, $dataSource)
            Write-Host "Changing datasource `"$($dataSource.Name)`" to $($dataSource.Item.Reference)"
        }
    }
}

Write-host ""
Write-host " We have successfully Deployed SSRS Project" -ForegroundColor Magenta
Write-host ""
