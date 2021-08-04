<#
    .SYNOPSIS

    Example of creating a simple Class with a custom constructor which allows you to pass in values when its created.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 8
    Code listing: 8_2.ps1
    
    .EXAMPLE
    C:\PS> .\8_2.ps1
#>

Class Person {
    
    [string]$name

    Person() {
    }

    Person([string]$name) {
        $this.name = $name
    }
}

$friend = New-Object Person "Rebecca"
$friend.name

