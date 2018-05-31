Param( 
	[Parameter(Mandatory=$true)] 
	[string]$serverName, 
	[string]$appPoolName, 
	[string]$action
)
		
Write-Host " ";
Write-Host " ";
Write-Host "Start or Stop Application Pool" -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	ServerName	: '"$serverName"'";
Write-Host "	AppPoolName	: '"$appPoolName"'";
Write-Host "	Action		: '"$action"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

Enable-PSRemoting -Force;

If ($action -eq "Start")
{
	Invoke-Command -Computer $serverName -ScriptBlock {
		Param([string]$ic_appPoolName)
		
			Try
			{
				import-module WebAdministration

				if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Started')
				{		
					Write-Host "Starting AppPool $ic_appPoolName";
					Start-WebAppPool -Name $ic_appPoolName
				}
				else
				{
					Write-Host "Not Found";
				}
			}
			catch
			{
				Write-Host "Error occurred";
				Write-Host $_.Exception.Message;
			}

	} -ArgumentList $appPoolName
}
elseif ($action -eq "Stop")
{
	Invoke-Command -Computer $serverName -ScriptBlock {
		Param([string]$ic_appPoolName)
		
			Try
			{
				import-module WebAdministration

				if((Get-WebAppPoolState $ic_appPoolName).Value -ne 'Stopped')
				{		
					Write-Host "Stopping AppPool $ic_appPoolName";
					Stop-WebAppPool -Name $ic_appPoolName
				}
				else
				{
					Write-Host "Not Found";
				}
			}
			catch
			{
				Write-Host "Error occurred";
				Write-Host $_.Exception.Message;
			}

	} -ArgumentList $appPoolName

}
else
{
	Write-Host "Unknown Action."
	Write-Host "Must be Start or Stop"
}
