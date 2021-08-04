<#
    .SYNOPSIS

    Demonstrates a basic function to group code into a useful and reuseable piece of code which can 
    be called from anywhere in your script.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 7
    Code listing: 7_1.ps1
    
    .EXAMPLE
    C:\PS> .\7_1.ps1
#>


#Beginners Guide to Functions

function Show-Menu {
    #Display menu options
    Write-Host "------------"
    Write-Host "Menu Options"
    Write-Host "------------"
    Write-Host "Press P to play"
    Write-Host "Press Q to Quit"
}

#Start of Script

#Clear Console
Clear-Host

#Call function
Show-Menu 
