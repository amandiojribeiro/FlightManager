Param( 
	[Parameter(Mandatory=$true)] 
	[string]$WebFolderToPublish
)

If(!(test-path $WebFolderToPublish))
{
      New-Item -ItemType Directory -Force -Path $WebFolderToPublish
}