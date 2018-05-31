Function fnCheckWebAPI(
 [Parameter(Mandatory=$True,Position=0)]
 [string]$AppPoolName,
 [Parameter(Mandatory=$True,Position=1)]
 [string]$WebAPIName,
 [Parameter(Mandatory=$True,Position=2)]
 [string]$AppFolder)
{
	$anonAuthFilter = "system.webServer/security/authentication/anonymousAuthentication";
	$windowsAuthFilter = "system.webServer/security/authentication/windowsAuthentication"; 

	Import-Module WebAdministration;
	
	if(Test-Path IIS:\Sites\MUFGWeb\$WebAPIName)
	{
		Echo "WebAPI is already there"
		return $true;
	}
	else
	{
		Echo "WebAPI is not present"
		Echo "Creating WebAPI"
		New-WebApplication -Site MUFGWeb -name $WebAPIName  -PhysicalPath $AppFolder -ApplicationPool $AppPoolName;
		
		Echo "Anonymous Authentication Enabled"
		Set-WebConfiguration $anonAuthFilter -PSPath IIS:\ -Location "MUFGWeb/$WebAPIName" -Value @{enabled="True"};
		
		Echo "Windows Authentication Disabled"
		Set-WebConfiguration $windowsAuthFilter -PSPath IIS:\ -Location "MUFGWeb/$WebAPIName" -Value @{enabled="False"};
		
		return $true;
	}
	return $false;
	
}

Function fnCheckWebApp(
 [Parameter(Mandatory=$True,Position=0)]
 [string]$AppPoolName,
 [Parameter(Mandatory=$True,Position=1)]
 [string]$WebAppName,
 [Parameter(Mandatory=$True,Position=2)]
 [string]$AppFolder)
{
	$anonAuthFilter = "system.webServer/security/authentication/anonymousAuthentication";
	$windowsAuthFilter = "system.webServer/security/authentication/windowsAuthentication"; 

	Import-Module WebAdministration;
	
	if(Test-Path IIS:\Sites\MUFGWeb\$WebAppName)
	{
		"WebApp is already there"
		return $true;
	}
	else
	{
		Echo "WebApp is not present"
		Echo "Creating WebApp"
		New-WebApplication -Site MUFGWeb -name $WebAppName  -PhysicalPath $AppFolder -ApplicationPool $AppPoolName;
		
		Echo "Anonymous Authentication Disabled"
		Set-WebConfiguration $anonAuthFilter -PSPath IIS:\ -Location "MUFGWeb/$WebAppName" -Value @{enabled="False"};
		
		Echo "Windows Authentication Enabled"
		Set-WebConfiguration $windowsAuthFilter -PSPath IIS:\ -Location "MUFGWeb/$WebAppName" -Value @{enabled="True"};
		
		return $true;
	}

	return $false;
}
 
Function InvokeCheckWebAPI([string]$ServerName, [string]$AppPoolName, [string]$WebAPIName, [string]$AppFolder)
{
	Try
	{
		Enable-PSRemoting -Force;
		
		$result = icm -cn $ServerName -ScriptBlock ${function:fnCheckWebAPI} -ArgumentList "$AppPoolName", "$WebAPIName", "$AppFolder";
	}
	Catch
	{
		Echo "$_.Exception.Message";
		Echo "$_.Exception.ItemName";
		$result = $false;
	}
	return $result;
}

Function InvokeCheckWebApp([string]$ServerName, [string]$AppPoolName, [string]$WebAppName, [string]$AppFolder)
{
	Try
	{
		Enable-PSRemoting -Force;

		$result = icm -cn $ServerName -ScriptBlock ${function:fnCheckWebApp} -ArgumentList "$AppPoolName", "$WebAppName", "$AppFolder";
	}
	Catch
	{
		Echo "$_.Exception.Message";
		Echo "$_.Exception.ItemName";
		$result = $false;
	}
	return $result;
}