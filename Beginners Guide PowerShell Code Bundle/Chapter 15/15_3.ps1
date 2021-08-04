<#
    .SYNOPSIS

    Example of creating a background job and monitoring its progress.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 15
    Code listing: 15_3.ps1
    
    .EXAMPLE
    C:\PS> .\15_3.ps1
#>

$scriptBlock = 
{
    param($countFrom, $countTo) 
    
    for ($i = 0; $i -le $countTo; $i++) {
        Write-Output "Counter:$i"
        Start-Sleep -Seconds 1
    }
}

Write-Host "Starting Job"

$job = Start-Job $scriptBlock -ArgumentList 0, 100

Write-Host "Job Started ID:$($job.Id)"

Write-Host "Getting Job Status"
Get-Job -Id $job.Id

Write-Host "Stopping Job"
Stop-Job -Id $job.Id

Write-Host "Getting Job Status"
Get-Job -Id $job.Id
