Param( 
	[Parameter(Mandatory=$true)] 
	[string]$serverName, 
	[string]$appPoolName, 
	[string]$applicationType, 
	[string]$userName, 
	[string]$passWord
)
		
Write-Host " ";
Write-Host " ";
Write-Host "Checking Application Pool" -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	ServerName		: '"$serverName"'";
Write-Host "	AppPoolName		: '"$appPoolName"'";
Write-Host "	ApplicationType	: '"$applicationType"'";
Write-Host "	UserName		: '"$userName"'";
Write-Host "	Password		: '"$passWord"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

Enable-PSRemoting -Force;

If ($applicationType -eq "API")
{
	Invoke-Command -Computer $serverName -ScriptBlock {
		Param([string]$ic_appPoolName, 
			  [string]$ic_userName, 
			  [string]$ic_passWord)
		
			Try
			{

				Import-Module WebAdministration;
				if(Test-Path IIS:\AppPools\$ic_appPoolName)
				{
					Write-Host "AppPool is already there"
					
					$identityType = Get-ItemProperty IIS:\AppPools\$ic_appPoolName -name "processModel.identityType";
					if ($identityType -ne "SpecificUser")
					{
						Write-Host "Setting user for Application Pool"
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.identityType -Value 3 
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.userName -Value $ic_userName
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.password -Value $ic_passWord
						Write-Host "User set for Application Pool"
					}
						
					if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Stopped')
					{
						
						
						Write-Host "Stopping AppPool $ic_appPoolName";
						Stop-WebAppPool -Name $ic_appPoolName
						Write-Host "AppPool $ic_appPoolName stopped";
					}
				}
				else
				{
					Write-Host "AppPool is not present"
					Write-Host "Creating AppPool"
					$appPool = New-WebAppPool -Name "$ic_appPoolName" -Force
					Write-Host "Set as Integrated"
					$appPool.managedPipelineMode = "Integrated";
					$appPool.managedRuntimeVersion = "v4.0";
					
					$appPool |Set-Item
					
					Write-Host "ApplicationPool Created"
					
					Write-Host "Setting user for Application Pool"
					Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.identityType -Value 3 
					Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.userName -Value $ic_userName
					Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.password -Value $ic_passWord
					Write-Host "User set for Application Pool"
					
					if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Stopped')
					{
						"Stopping AppPool  $ic_appPoolName";
						Stop-WebAppPool -Name $ic_appPoolName
						Write-Host "AppPool $ic_appPoolName stopped";
					}
					
				}
			}
			catch
			{
				Write-Host "Error occurred";
				Write-Host $_.Exception.Message;
			}

	} -ArgumentList $appPoolName, $userName, $passWord
}
 elseif ($applicationType -eq "WebApp")
 {
	 Invoke-Command -Computer $serverName -ScriptBlock {
		 Param([string]$ic_appPoolName, 
			   [string]$ic_userName, 
			   [string]$ic_passWord)
		
			 Try
			 {

				 Import-Module WebAdministration;
				 if(Test-Path IIS:\AppPools\$ic_appPoolName)
				 {
					Write-Host "AppPool is already there"
					
					$identityType = Get-ItemProperty IIS:\AppPools\$ic_appPoolName -name "processModel.identityType";
					if ($identityType -ne "SpecificUser")
					{
						Write-Host "Setting user for Application Pool"
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.identityType -Value 3 
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.userName -Value $ic_userName
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.password -Value $ic_passWord
						Write-Host "User set for Application Pool"
					}
					
					if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Stopped')
					{
						Write-Host "Stopping AppPool $ic_appPoolName";
						Stop-WebAppPool -Name $ic_appPoolName
						Write-Host "AppPool $ic_appPoolName stopped";
					}
				}
				else
				{
					Write-Host "AppPool is not present"
					Write-Host "Creating AppPool"
					$appPool = New-WebAppPool -Name "$ic_appPoolName" -Force
					Write-Host "Set as Integrated"
					$appPool.managedPipelineMode = "Integrated";
					$appPool.managedRuntimeVersion = "";
					
					$appPool |Set-Item
					
					Write-Host "ApplicationPool Created"
					
					$identityType = Get-ItemProperty IIS:\AppPools\TestMR1 -name "processModel.identityType";
					if (identityType -ne "SpecificUser")
					{
						Write-Host "Setting user for Application Pool"
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.identityType -Value 3 
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.userName -Value $ic_userName
						Set-ItemProperty IIS:\AppPools\$ic_appPoolName -name processModel.password -Value $ic_passWord
						Write-Host "User set for Application Pool"
					}

					if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Stopped')
					{
						Write-Host "Stopping AppPool  $ic_appPoolName";
						Stop-WebAppPool -Name $ic_appPoolName
						Write-Host "AppPool $ic_appPoolName stopped";
					}
					
				}
			}
			catch
			{
				Write-Host "Error occurred";
				Write-Host $_.Exception.Message;
			}

	} -ArgumentList $appPoolName, $userName, $passWord
}
else
{
	Write-Host "Unknown Application Type."
	Write-Host "Must be API or WebApp."
}
