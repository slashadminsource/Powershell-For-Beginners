<#
    .SYNOPSIS

    Example of how to move a game object around the screen.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 14
    Code listing: 14_3.ps1
    
    .EXAMPLE
    C:\PS> .\14_3.ps1
#>

#Variables###########
[bool]$done = $false
[int]$xPosition = 0
[int]$yPosition = 0
[bool]$update = $true
[int]$displayWidth = 110
[int]$displayHeight = 55
[int]$characterHeight = 4
[int]$characterWidth = 4
#####################

#Functions###################################################################
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

function Read-Character() {
    if ($host.ui.RawUI.KeyAvailable) {
        return $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    }
   
    return $null
}

function Draw-Character() {
    Move-Cursor $xPosition $yPosition
    Write-Host "####"
    Move-Cursor $xPosition ($yPosition + 1)
    Write-Host "#  #"
    Move-Cursor $xPosition ($yPosition + 2)
    Write-Host "#  #"
    Move-Cursor $xPosition ($yPosition + 3)
    Write-Host "####"
    Move-Cursor 0 0
}
###############################################################################

#Start Running Program Commands

#Clear screen
Clear-Host

Setup-Display "Move Character" $displayWidth $displayHeight

while (!$done) {
    #See what keys the player is pressing
    $char = Read-Character
    
    if ($char -eq 'q') {
        $done = $true
        $update = $true
    }
    elseif ($char -eq 'a') {
        $xPosition--
        $update = $true
    }
    elseif ($char -eq 'd') {
        $xPosition++
        $update = $true
    }
    elseif ($char -eq 's') {
        $yPosition++
        $update = $true
    }
    elseif ($char -eq 'w') {
        $yPosition--
        $update = $true
    }

    #Keep player inside the display
    if ($xPosition -le 0) {
        $xPosition = 0
    }
    elseif ($xPosition -ge $displayWidth - $characterWidth) {
        $xPosition = $displayWidth - $characterWidth
    }

    if ($yPosition -le 0) {
        $yPosition = 0
    }
    elseif ($yPosition -ge $displayHeight - $characterHeight) {
        $yPosition = $displayHeight - $characterHeight
    }
    
    #Only draw display if there is an update
    if ($update) {
        Clear-Host
        Draw-Character
        $update = $false
    }
}

#Clear screen
Clear-Host 
