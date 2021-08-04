<#
    .SYNOPSIS

    Example of customising the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 9
    Code listing: 9_1.ps1
    
    .EXAMPLE
    C:\PS> .\9_1.ps1
#>

#Get the console window
$psHost = Get-Host
$window = $psHost.ui.rawui

#Set the window properties
$window.WindowTitle = "My PowerShell Game"
$window.ForegroundColor = "Red"
$window.BackgroundColor = "Black"

#Clear the console
Clear-Host

Write-Host "Wow this is fun!" 
