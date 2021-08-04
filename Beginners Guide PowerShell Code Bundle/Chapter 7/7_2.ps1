<#
    .SYNOPSIS

    Function which adds two int values and returns the results

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 7
    Code listing: 7_2.ps1
    
    .EXAMPLE
    C:\PS> .\7_2.ps1
#>


function Add-Numbers([int]$numberA, [int]$numberB) {
    $sumOfNumbers = $numberA + $numberB

    #Display results to console
    Write-Host "Adding 5 and 10 equals: $sumOfNumbers" 
}

#Start of Script

#Clear Console
Clear-Host

#Call function
Add-Numbers 5 10
