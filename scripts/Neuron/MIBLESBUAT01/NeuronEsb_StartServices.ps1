Write-Host " "
Write-Host "Starting Neuron Services in MIBLESBUAT01"
Write-Host " "

invoke-command -ComputerName MIBLESBUAT01 -ScriptBlock { get-service 'Neuron ESB v3 Discovery Service' | where { $_.status -eq 'stopped' } | start-service -pass }
invoke-command -ComputerName MIBLESBUAT01 -ScriptBlock { get-service 'NeuronESBv3_MiblEsbUat01Inst01' | where { $_.status -eq 'stopped' } | start-service -pass }

Write-Host " "
Write-Host "Neuron Services started in MIBLESBUAT01"
Write-Host " "
