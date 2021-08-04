<#
    .SYNOPSIS

    Example of creating a server application which listens for connections on port 2000.

    It then listens for messages from connected clients and displays the data to the console window.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 16
    Code listing: 16_1.ps1
    
    .EXAMPLE
    C:\PS> .\16_1.ps1
#>


Clear-Host

$port = 2000
$endPoint = New-Object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
$listener = New-Object System.Net.Sockets.TcpListener $endPoint
$listener.Start()

Write-Host "Server Running"

$client = $listener.AcceptTcpClient()

Write-Host "Client Connected"

$stream = $client.GetStream();
$reader = New-Object System.IO.StreamReader $stream
$line = ""

while ($line -ne "QUIT") {
    $line = $reader.ReadLine()
    if ($line -ne $null) {
        Write-Host "Message Recieved:" $line
    }
}

Write-Host "Shutting Down"

$reader.Dispose()
$stream.Dispose()
$client.Dispose()
$listener.Stop()
