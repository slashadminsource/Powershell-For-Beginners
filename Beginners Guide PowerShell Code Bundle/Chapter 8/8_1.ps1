<#
    .SYNOPSIS

    Example of creating a simple Class and creating an instance of it to use in the script.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 8
    Code listing: 8_1.ps1
    
    .EXAMPLE
    C:\PS> .\8_1.ps1
#>

Class Person {
    [string]$name

    Person() {
    }
}

$friend = New-Object Person
$friend.name = "Ian"

Write-Host "Hi" $friend.name "how are you?" 
