Param([Parameter(Mandatory=$true)] 
	  [string]$ReportServerUrl,
      [string]$ReportServerUrlFolder,
      [string]$userGroups,
	  [string]$requiredRole,
	  [bool]$inheritFromParent)

Write-Host " ";
Write-Host " ";
Write-Host "Changing privileges over SSRS..." -ForegroundColor Magenta;
Write-Host " ";
Write-Host " ";
Write-Host "###############################################################################################################";
Write-Host "Parameters";
Write-Host "	ReportServerUrl			: '"$ReportServerUrl"'";
Write-Host "	ReportServerUrlFolder	: '"$ReportServerUrlFolder"'";
Write-Host "	UserGroups				: '"$userGroups"'";
Write-Host "	RequiredRole			: '"$requiredRole"'";
Write-Host "	InheritFromParent		: '"$inheritFromParent"'";
Write-Host "###############################################################################################################";
Write-Host " ";
Write-Host " ";

    $userGroupsList = $userGroups.Split(",");
	$folders = ('/,'+$ReportServerUrlFolder).Split(",");
	#Ensure we stop on errors
    $ErrorActionPreference = "Stop";
    
	#Connect to the SSRS webservice 
    $webServiceUrl = $ReportServerUrl;
	Write-Host "ReportServerUrl: $webServiceUrl" -ForegroundColor Magenta
	Write-Host "Creating Proxy, connecting to : $webServiceUrl/ReportService2010.asmx?WSDL"
	Write-Host ""
	$ssrs = New-WebServiceProxy -Uri $webServiceUrl'/ReportService2010.asmx?WSDL' -UseDefaultCredential

    $namespace = $ssrs.GetType().Namespace;
	foreach($folder in $folders)
	{
		$changesMade = $false;
		
		#Look for a matching policy     
		$policies = $ssrs.GetPolicies($folder, [ref]$inheritFromParent);
		foreach($userGroup in $userGroupsList)
		{
			if ($policies.GroupUserName -contains $userGroup)
			{
				Write-Host "User/Group already exists. Using existing policy.";
				$policy = $policies | where {$_.GroupUserName -eq $userGroup} | Select -First 1 ;
			}
			else
			{
				#A policy for the User/Group needs to be created
				Write-Host "User/Group was not found. Creating new policy.";
				$policy = New-Object -TypeName ($namespace + '.Policy');
				$policy.GroupUserName = $userGroup;
				$policy.Roles = @();
				$policies += $policy;
				$changesMade = $true;
			}

			#Now we have the policy, look for a matching role
			$roles = $policy.Roles;
			if (($roles.Name -contains $requiredRole) -eq $false)
			{
				#A role for the policy needs to added
				Write-Host "Policy doesn't contain specified role. Adding.";
				$role = New-Object -TypeName ($namespace + '.Role');
				$role.Name = $requiredRole;
				$policy.Roles += $role;
				$changesMade = $true;
			}
			else 
			{
				Write-Host "Policy already contains specified role. No changes required.";
			}
		}
		
		#If changes were made...
		if ($changesMade)
		{
			#...save them to SSRS
			Write-Host "Saving changes to SSRS.";
			$ssrs.SetPolicies($folder, $policies);
		}
	}
	Write-Host "Complete.";