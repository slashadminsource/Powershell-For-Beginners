<#
    .SYNOPSIS

    Using .net windows sound player to play a wav sound file.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 18
    Code listing: 18_2.ps1
    
    .EXAMPLE
    C:\PS> .\18_2.ps1
#>


$sound = New-Object System.Media.SoundPlayer

$sound.SoundLocation = "C:\scripts\sound.wav"

$sound.Play()

$sound.Dispose() 
