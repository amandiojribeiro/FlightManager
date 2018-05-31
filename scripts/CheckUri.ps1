#
# CheckUri.ps1
#
param([string]$url, [boolean]$proxy, [boolean]$credential)

function GetStatusCodeFromURL
{
  param([string]$url, [boolean]$useProxy, [boolean]$usecredential)


  try {
    Write-Host "$url => " -NoNewline
	
	$req=[system.Net.HttpWebRequest]::Create($url);

	#if param is set to use proxy we use the system webproxy with default credentials
	if ($useProxy) {
		$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
		$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
		$req.Proxy=$proxy;
	}
	#if the web site requiere credential (like tfs) pass the current user credential
	if ($usecredential) {
		$req.UseDefaultCredentials = [System.Net.CredentialCache]::DefaultCredentials
	}
    $res = $req.getresponse();
    $stat = $res.statuscode;
    $res.Close();

	#check the response status
    if ($stat -eq "OK") {
      Write-Host "$stat" -ForegroundColor:Green
    }
    else  {
      Write-Host "$stat" -ForegroundColor:Red
    }


  }
  #exception handling
  catch [System.Exception] {
    $exceptionMessage = $url + ": " + $_.Exception.Message
    Write-Host $exceptionMessage -ForegroundColor:Red
  }


}
 
#Main
GetStatusCodeFromURL $url $Proxy $credential
