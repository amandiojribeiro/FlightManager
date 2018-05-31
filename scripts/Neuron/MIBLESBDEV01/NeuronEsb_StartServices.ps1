Write-Host " "
Write-Host "Starting Neuron Services in MIBLESBDEV01"
Write-Host " "

invoke-command -ComputerName MIBLESBDEV01 -ScriptBlock { get-service 'Neuron ESB v3 Discovery Service' | where { $_.status -eq 'stopped' } | start-service -pass }
invoke-command -ComputerName MIBLESBDEV01 -ScriptBlock { get-service 'NeuronESBv3_MiblEsbDev01Inst01' | where { $_.status -eq 'stopped' } | start-service -pass }

Write-Host " "
Write-Host "Neuron Services started in MIBLESBDEV01"
Write-Host " "
