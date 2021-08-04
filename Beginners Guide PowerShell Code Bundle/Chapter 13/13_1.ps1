<#
    .SYNOPSIS

    Outputs a character table aka 'ASCII table' as HTML for easy viewing

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 13
    Code listing: 13_1.ps1
    
    .EXAMPLE
    C:\PS> .\13_1.ps1
#>


$fileName = "ASCII Table.html"
$tableWidth = 17
$showASCIITo = 260

#Remove Existing File If It Exists
if (Test-Path $filename) {
    Remove-Item $filename
}

Add-Content $fileName "<!DOCTYPE html><html><body><style>table {border-collapse: collapse;}
  th, td {border: 1px solid black;padding: 3px;text-align: center;}</style><table><tr>"

#Add Column Headers
for ($i = 0; $i -le $tableWidth; $i++) {
    if ($i % 2) {
        Add-Content $fileName "<th>Char</th>"
    }
    else {
        Add-Content $fileName "<th>Dec</th>"
    }
}

Add-Content $fileName "</tr>"

#Add Row Data
$counter = 0
for ($i = 0; $i -le (($showASCIITo / $tableWidth) * 2); $i++) {
    Add-Content $fileName "<tr>"
    
    for ($j = 0; $j -le $tableWidth; $j++) {
        if ($j % 2) {
            Add-Content $fileName "<td>$([char]$counter)</td>"
        }
        else {
            Add-Content $fileName "<td>$($counter)</td>"
            $counter++
        }
    }
    
    Add-Content $fileName "</tr>"
}
