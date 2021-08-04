<#
    .SYNOPSIS

    Example of creating a simple Class containing properties.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 8
    Code listing: 8_4.ps1
    
    .EXAMPLE
    C:\PS> .\8_4.ps1
#>

Class Player {
    #Define properties
    [string]$name
    [int]$positionX
    [int]$positionY
    [int]$health
    [int]$speed

    #Class contructor
    Player() {
    }
        
    #Define methods
    DisplayPlayerStats() {
        Write-Host "Name:" $this.name
        Write-Host "Position X:" $this.positionX
        Write-Host "Position Y:" $this.positionY
        Write-Host "Health:" $this.health
        Write-Host "Speed:" $this.speed
    }

    SetPosition([int]$x, [int]$y) {
        $this.positionX = $x
        $this.positionY = $y
    }
}

#Create player object
$gamePlayer = New-Object Player

#Set player variables
$gamePlayer.name = "Vincent"
$gamePlayer.positionX = 10
$gamePlayer.positionY = 10
$gamePlayer.health = 100
$gamePlayer.speed = 5

#Move player to position 20 20
$gamePlayer.SetPosition(20, 20)

#Dump players stats (useful for debugging problems)
$gamePlayer.DisplayPlayerStats() 
