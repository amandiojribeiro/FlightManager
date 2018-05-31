Write-Host " "
Write-Host "Stoping Neuron Services in MIBLESBPRD01"
Write-Host " "

invoke-command -ComputerName MIBLESBPRD01 -ScriptBlock { get-service 'NeuronESBv3_MiblEsbPrd01Inst01' | where { $_.status -eq 'running' } | stop-service -pass }
invoke-command -ComputerName MIBLESBPRD01 -ScriptBlock { get-service 'Neuron ESB v3 Discovery Service' | where { $_.status -eq 'running' } | stop-service -pass }

Write-Host " "
Write-Host "Neuron Services stopped in MIBLESBPRD01"
Write-Host " "
Write-Host "Searching for NeuronExplorer.exe processes"
Write-Host " "
$processes = Get-WmiObject -Class Win32_Process -ComputerName MIBLESBPRD01 -Filter "name='NeuronExplorer.exe'"
Write-Host "Found " $processes.Count "processes";

foreach ($process in $processes) 
{
	$processid = $process.handle
	write-host "Killing NeuronExplorer.exe with PID $processid..."
	$returnval = $process.terminate()

	if($returnval.returnvalue -eq 0) 
	{
		write-host "the process neuronexplorer.exe with PID $processid terminated successfully"
	}
	else 
	{
		write-host "the process neuronexplorer.exe with PID $processid termination has some problems"
	}
}
