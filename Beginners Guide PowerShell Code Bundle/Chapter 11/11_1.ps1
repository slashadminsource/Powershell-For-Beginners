<#
    .SYNOPSIS

    Building a text based adventure game.

    Demonstrating the basic game loop.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 11
    Code listing: 11_1.ps1
    
    .EXAMPLE
    C:\PS> .\11_1.ps1
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

Setup-Display "Dragon Slayer" 64 38

Title-Screen

while ($global:runGame) {

    Character-Selection

    $accept = Accept-TheQuest

    if ($accept -eq $true) {
        Arrive-AtVillage
    }
    else {
        #Player Quit
        Write-Host ""
        Write-Host "Thanks for Playing"
        $global:runGame = $false
        Start-Sleep 3
    }
} 
