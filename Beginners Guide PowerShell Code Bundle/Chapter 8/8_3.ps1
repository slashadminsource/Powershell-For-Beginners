<#
    .SYNOPSIS

    Example of creating a simple Class and calling a method within it.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 8
    Code listing: 8_3.ps1
    
    .EXAMPLE
    C:\PS> .\8_3.ps1
#>

Class Player {

    #Define variables
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
}

#Create player object
$gamePlayer = New-Object Player

#Set player variables
$gamePlayer.name = "Vincent"
$gamePlayer.positionX = 10
$gamePlayer.positionY = 10
$gamePlayer.health = 100
$gamePlayer.speed = 5

#Dump players stats (useful for debugging problems)
$gamePlayer.DisplayPlayerStats() 
