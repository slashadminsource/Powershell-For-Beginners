<#
    .SYNOPSIS

    Example of creating a function to customise the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 9
    Code listing: 9_2.ps1
    
    .EXAMPLE
    C:\PS> .\9_2.ps1
#>

function Setup-Display([string]$title, [int]$width, [int]$height) {
    $psHost = Get-Host
    $window = $psHost.ui.rawui
    $newsize = $window.WindowSize
    $newsize.Height = $height
    $newsize.Width = $width
    $window.WindowSize = $newsize
    $window.WindowTitle = $title
}

#Start of stript

#Clear the console
Clear-Host

Setup-Display "My Powershell Window" 110 30
