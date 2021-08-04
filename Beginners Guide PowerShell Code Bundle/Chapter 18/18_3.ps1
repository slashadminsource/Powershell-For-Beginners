<#
    .SYNOPSIS

    Using windows .net Speech synthesizer to convert text into spoken sounds.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 18
    Code listing: 18_3.ps1
    
    .EXAMPLE
    C:\PS> .\18_3.ps1
#>


#Define .Net Class to use in session
Add-Type -AssemblyName System.speech

#Instanciate an object from the SpeechSynthesizer class
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

#Speak the text from the speakers
$speak.Speak("Would you like to play a game?") 

#Clean up used memory
$speak.Dispose() 
