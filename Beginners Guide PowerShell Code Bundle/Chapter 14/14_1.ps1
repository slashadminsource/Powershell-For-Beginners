<#
    .SYNOPSIS

    Example of moving the cursor around the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 14
    Code listing: 14_1.ps1
    
    .EXAMPLE
    C:\PS> .\14_1.ps1
#>

function Move-Cursor([int]$x, [int] $y) {
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
} 

Clear-Host
Move-Cursor 5 2
Write-Host "X" -NoNewline
Move-Cursor 10 4
Write-Host "X" -NoNewline
Move-Cursor 30 6
Write-Host "X" -NoNewline
Move-Cursor 20 5
Write-Host "X" -NoNewline
