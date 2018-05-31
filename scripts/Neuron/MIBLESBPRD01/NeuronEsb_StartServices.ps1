Write-Host " "
Write-Host "Starting Neuron Services in MIBLESBPRD01"
Write-Host " "

invoke-command -ComputerName MIBLESBPRD01 -ScriptBlock { get-service 'Neuron ESB v3 Discovery Service' | where { $_.status -eq 'stopped' } | start-service -pass }
invoke-command -ComputerName MIBLESBPRD01 -ScriptBlock { get-service 'NeuronESBv3_MiblEsbPrd01Inst01' | where { $_.status -eq 'stopped' } | start-service -pass }

Write-Host " "
Write-Host "Neuron Services started in MIBLESBPRD01"
Write-Host " "
