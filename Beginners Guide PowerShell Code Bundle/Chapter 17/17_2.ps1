<#
    .SYNOPSIS

    Writes the contents of a text file out to the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 17
    Code listing: 17_2.ps1
    
    .EXAMPLE
    C:\PS> .\17_2.ps1
#>


#Clear the console
Clear-Host

#Save full file path to variable
$filePath = "c:\scripts\testfile.txt"

#Check if file exists
$fileExists = Test-Path $filePath 

if ($fileExists -eq $True) {
    #Read lines in one go and access lines
    $lines = Get-Content $filePath

    Write-Host "Number of lines in the file:" $lines.Count

    #Loop throught the $lines array of string values
    Foreach ($line in $lines) {
        Write-Host $line
    }
}
else {
    Write-Host "$filePath is missing"
}

