<#
    .SYNOPSIS

    Using windows .net Speech synthesizer to convert text into spoken sounds and save them to a wav file.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 18
    Code listing: 18_4.ps1
    
    .EXAMPLE
    C:\PS> .\18_4.ps1
#>


#Define .Net Class to use in session
Add-Type -AssemblyName System.speech

#Instanciate an object from the SpeechSynthesizer class
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

#Change the output to a local wav file
$speak.SetOutputToWaveFile("C:\scripts\sound.wav")

#Speak the text to the wav file
$speak.Speak("Would you like to play a game?")

#Clean up used memory
$speak.Dispose() 
