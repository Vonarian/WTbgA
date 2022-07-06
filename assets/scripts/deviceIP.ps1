Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $( Get-NetConnectionProfile | Select-Object -ExpandProperty InterfaceIndex ) | Select-Object -ExpandProperty IPAddress
