<#
    .SYNOPSIS

    Moves the cursor around the window randomly to create a starfield effect.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 14
    Code listing: 14_2.ps1
    
    .EXAMPLE
    C:\PS> .\14_2.ps1
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

function Move-Cursor([int]$x, [int] $y) {
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
} 

Clear-Host
Setup-Display "Move Cursor Demo" 120 25

#Loop 20 times and display an X in a random location
For ($i = 0; $i -lt 20; $i++) {

    #Generate random values for the X and Y positions
    $x = Get-Random -Minimum 0 -Maximum 119
    $y = Get-Random -Minimum 0 -Maximum 24

    #Move to the random location
    Move-Cursor $x $y

    #Display an X and disable a new line character
    Write-Host "X" -NoNewline
}

#Move to cursor to the bottom of the display
Move-Cursor 0 31 

