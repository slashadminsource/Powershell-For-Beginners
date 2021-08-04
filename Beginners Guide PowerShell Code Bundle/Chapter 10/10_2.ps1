<#
    .SYNOPSIS

    Example of reading a line of text from the keyboard.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 10
    Code listing: 10_2.ps1
    
    .EXAMPLE
    C:\PS> .\10_2.ps1
#>

#Clear console
Clear-Host

#Ask questions using -Prompt
$userResponse = Read-Host -Prompt 'What is your name? '
Write-Host "Hi $userResponse nice to meet you!"

#Read input from next line
Write-Host "Where are you from?"
$userResponse = Read-Host 
