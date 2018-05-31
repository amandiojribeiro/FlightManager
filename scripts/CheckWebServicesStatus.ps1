#
# CheckWebServiceStatus.ps1
# if policy block the execution you can bypass by running this command :
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# or use this command as in a powershell run as administrator to change the policy for your user
# Set-ExecutionPolicy Unrestricted -scope CurrentUser
#
param([string]$env, [string]$app)

function CheckWebApiFromURL ( [string]$uri, [string]$token){
 try {


    Write-Host "    Checking web api $uri => " -ForegroundColor:Cyan -NoNewline
    $res=Invoke-RestMethod -Method Get -Uri $uri -ErrorVariable RestError -ErrorAction SilentlyContinue -ContentType "application/json" -Headers @{"Authorization"= "$token"}
            
    if ($RestError)
    {
        $HttpStatusCode = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
        $HttpStatusDescription = $RestError.ErrorRecord.Exception.Response.StatusDescription
    
        Throw "Http Status Code: $($HttpStatusCode) `nHttp Status Description: $($HttpStatusDescription)"
    } else {
        Write-Host "OK"  -ForegroundColor:Green
    }

    }
      catch [System.Exception] {
        $exceptionMessage = $_.Exception.Message
        Write-Host $exceptionMessage -ForegroundColor:Red
    }

}

#Main

#if no parameter is passed set it to all
 if ($env.Length -eq 0) { $env="all"}
 if ($app.Length -eq 0) { $app="all"}

# check that the parameter is accepted
 if ($env -notin "dev","uat","int","intg","prd","prod","all" ) {Throw "env parameter must be dev,uat,int,intg,prd,prod or all" }

 #fill the list of env to check
 if ($env -eq "all") {
    $envlist=("dev","uat","int","prd")
 } else {
	if($env.ToUpperInvariant() -eq "INTG") { $env="int" }
	if($env.ToUpperInvariant() -eq "PROD") { $env="prd" }
    $envlist = ($env)
 }
 [boolean]$processed = $false
 #loop on each env
foreach ($currentenv in $envlist) {

    Write-Host "Testing WEB API in env" $currentenv -ForegroundColor:Green

    #parse all app
    foreach ($Application in Get-ChildItem ".\Applications" ) {
      $ApplicationName = $Application.Name
	if ($app -ne "all" ) { 
		if ( $ApplicationName.ToUpperInvariant() -ne $app.ToUpperInvariant() ) {
		#change the name like this the next test will fail and exclude this application
		$ApplicationName = "do not process"
		}
	
	} 

      $appUriFile = ".\Applications\$ApplicationName\$currentenv\uri.txt"  
      $appTokenFile = ".\Applications\$ApplicationName\$currentenv\token.txt" 
      $appWebApiFile = ".\Applications\$ApplicationName\$currentenv\webapi.txt" 
	  #if one file does not exist then don't test
      if ((Test-Path $appUriFile) -and (Test-Path $appTokenFile) -and  (Test-Path $appWebApiFile)) {
	      $uri = Get-Content $appUriFile -First 1
	      $token = Get-Content $appTokenFile -First 1
	      $apilist = Get-Content $appWebApiFile
	      Write-Host "  Start check for application $ApplicationName"  -ForegroundColor:Magenta
		  #check all api one by one
	      foreach ($api in $apilist  ) { 
		    $fulluri = $uri+$api
		    CheckWebApiFromURL $fulluri $token
			$processed=$true
	      }
      }
  }
}

if (-not $processed) {
 Throw "No application or Env is matching your parameters"

}