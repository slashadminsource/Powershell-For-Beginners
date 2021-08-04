<#
    .SYNOPSIS

    Checks to see if a file exists and writes the result to the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 17
    Code listing: 17_1.ps1
    
    .EXAMPLE
    C:\PS> .\17_1.ps1
#>

Clear-Host

#Save file name and path to a variable
$file = "c:\scripts\testfile.txt" 

#Call Test-Path cmdlet and pass in the full file path
#It will return $True if the file exists and $False if not
$fileExists = Test-Path $file 

#Test if the $fileExists variable is true which means the file does exist
if ($fileExists -eq $True) {
    Write-Host "c:\scripts\Testfile.txt exists"
}
else {
    Write-Host "c:\scripts\Testfile.txt does not exist"
} 
