Function fnCheckApplicationPoolAurelia([string]$appPoolName)
{
	Try
	{
		Echo "$serverName"
		Echo "$appPoolName"
		Echo "$webType"
		Import-Module WebAdministration;
		if(Test-Path IIS:\AppPools\$appPoolName)
		{
			"AppPool is already there"
			if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
			{
				Echo "Stopping AppPool  $appPoolName";
				Stop-WebAppPool -Name $appPoolName
			}
			return $true;
		}
		else
		{
			"AppPool is not present"
			"Creating AppPool"
			$appPool = New-WebAppPool -Name "$appPoolName" -Force
			$appPool.managedPipelineMode = "Integrated";
			$appPool.managedRuntimeVersion = "";
			
			$appPool |Set-Item
			
			if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
			{
				Echo "Stopping AppPool  $appPoolName";
				Stop-WebAppPool -Name $appPoolName
			}
			
			return $true;
		}
	}
	Catch
	{
		return $false;
	}
}

Function fnCheckApplicationPoolAPI([string]$appPoolName)
{
	Try
	{
		Echo "$serverName"
		Echo "$appPoolName"
		Echo "$webType"
		Import-Module WebAdministration;
		if(Test-Path IIS:\AppPools\$appPoolName)
		{
			"AppPool is already there"
			if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
			{
				Echo "Stopping AppPool  $appPoolName";
				Stop-WebAppPool -Name $appPoolName
			}
			return $true;
		}
		else
		{
			"AppPool is not present"
			"Creating AppPool"
			$appPool = New-WebAppPool -Name "$appPoolName" -Force
			"Set as Integrated"
			$appPool.managedPipelineMode = "Integrated";
			$appPool.managedRuntimeVersion = "v4.0";
			
			$appPool |Set-Item
			
			if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
			{
				Echo "Stopping AppPool  $appPoolName";
				Stop-WebAppPool -Name $appPoolName
			}
			
			return $true;
		}
	}
	Catch
	{
		return $false;
	}
}

Function fnStartApplicationPool([string]$appPoolName)
{
	import-module WebAdministration

    if((Get-WebAppPoolState $appPoolName).Value -ne 'Started')
    {
		Echo "Starting AppPool  $appPoolName";
	    Start-WebAppPool -Name $appPoolName
    }
	else
	{
		Echo "Not Found";
	}
}

Function fnStopApplicationPool([string]$appPoolName)
{
	import-module WebAdministration

    if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
    {		
		   Echo "Stopping AppPool $appPoolName";
	       Stop-WebAppPool -Name $appPoolName
    }
	else
	{
		Echo "Not Found";
	}
}

Function InvokeCheckApplicationPool([string]$ServerName, [string]$AppPoolName, [string]$WebType)
{
	Try
	{
		Enable-PSRemoting -Force;

		$result = $false;
		
		if ($WebType -eq 'API')
		{
			$result = icm -cn $ServerName -ScriptBlock ${function:fnCheckApplicationPoolAPI} -ArgumentList $AppPoolName
		}
		elseif ($webType -eq "Aurelia")
		{
			$result = icm -cn $ServerName -ScriptBlock ${function:fnCheckApplicationPoolAurelia} -ArgumentList $AppPoolName
		}
		else 
		{
			"Unknown type $WebType"
			"Must be API or Aurelia"
			return $false;
		}
	}
	Catch
	{
		Echo "$_.Exception.Message";
		Echo "$_.Exception.ItemName";
		
		$result = $false;
		
	}

	return $result;
}

Function InvokeStartApplicationPool([string]$ServerName, [string]$AppPoolName)
{
	Try
	{
		Enable-PSRemoting -Force;

		
		$result = icm -cn $ServerName -ScriptBlock ${function:fnStartApplicationPool} -ArgumentList $AppPoolName
	}
	Catch
	{
		$result = $false;
		
	}

	return $result;
}

Function InvokeStopApplicationPool([string]$ServerName, [string]$AppPoolName)
{
	Try
	{
		Enable-PSRemoting -Force;
		Echo "$ServerName";
		Echo "$AppPoolName";
		$result = icm -cn $ServerName -ScriptBlock ${function:fnStopApplicationPool} -ArgumentList $AppPoolName
	}
	Catch
	{
		$result = $false;
		
	}

	return $result;
}