<#
    .SYNOPSIS

    Example of creating multiple background jobs.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 15
    Code listing: 15_2.ps1
    
    .EXAMPLE
    C:\PS> .\15_2.ps1
#>

$scriptBlock = 
{
    param($countFrom, $countTo) 
    
    for ($i = 0; $i -le $countTo; $i++) {
        Write-Host "Counter:$i"
        Start-Sleep -Seconds 1
    }
}

$job1 = Start-Job $scriptBlock -ArgumentList 50, 100
$job2 = Start-Job $scriptBlock -ArgumentList 0, 100
$job3 = Start-Job $scriptBlock -ArgumentList 20, 100

Write-Host "Job 1 id:$($job1.Id)"
Write-Host "Job 2 id:$($job2.Id)"
Write-Host "Job 3 id:$($job3.Id)" 
