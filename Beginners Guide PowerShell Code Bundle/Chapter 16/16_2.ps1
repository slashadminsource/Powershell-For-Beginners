<#
    .SYNOPSIS

    Example of creating a client application which connects to a server on port 2000.
    
    You can type messages which get sent to the server after pressing enter.

    Type QUIT and press enter to close the connection.

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
$server = "localhost"
$client = New-Object System.Net.Sockets.TcpClient $server, $port
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter $stream
$writer.AutoFlush = $true

do {
    $message = Read-Host -Prompt "Send Message"
    $writer.WriteLine($message)

}
while ($message -notlike "QUIT")

$writer.Dispose()
$stream.Dispose()
$client.Dispose()

