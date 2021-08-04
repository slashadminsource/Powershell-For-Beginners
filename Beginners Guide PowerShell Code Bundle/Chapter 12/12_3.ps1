<#
    .SYNOPSIS

    Example of using a function to customise the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 12
    Code listing: 12_3.ps1
    
    .EXAMPLE
    C:\PS> .\12_3.ps1
#>
function Setup-Display([string]$title, [int]$width, [int]$height, 
    [string]$backgroundColour, [string]$foregroundColour) {
    $psHost = Get-Host
    $window = $psHost.ui.rawui
    $newsize = $window.WindowSize
    $newsize.Height = $height
    $newsize.Width = $width
    $window.WindowSize = $newsize
    $window.WindowTitle = $title
    $window.BackgroundColor = $backgroundColour
    $window.ForegroundColor = $foregroundColour

}

Setup-Display "Changing Colours" 70 30 "Black" "Red"
Clear-Host
Write-Host "Hello this is some test text" 
