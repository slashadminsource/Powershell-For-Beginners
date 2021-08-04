<#
    .SYNOPSIS

    Example of creating a background job which executes code within a script block.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 15
    Code listing: 15_1.ps1
    
    .EXAMPLE
    C:\PS> .\15_1.ps1
#>

$scriptBlock = 
{
    param($countTo) 
    
    for ($i = 0; $i -le $countTo; $i++) {
        Write-Host "Counter:$i"
        Start-Sleep -Seconds 1
    }
}

Start-Job $scriptBlock -ArgumentList 100 
