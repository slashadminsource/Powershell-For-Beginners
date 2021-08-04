<#
    .SYNOPSIS

    Function which adds two int values and returns the results

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 7
    Code listing: 7_3.ps1
    
    .EXAMPLE
    C:\PS> .\7_3.ps1
#>


function Add-Numbers([int]$numberA, [int]$numberB) {
    $sumOfNumbers = $numberA + $numberB

    #return the value of the results variable
    return $sumOfNumbers
}

#Start of Script

#Clear Console
Clear-Host

#Call function
$results = Add-Numbers 5 10

#Display results to console
Write-Host "Adding 5 and 10 equals: $results" 
