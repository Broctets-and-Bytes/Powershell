###using Get-NetNeighbor (like arp -a) check for friends on the network that are potentially reachable. Select the IP address from output.
$Targets = (Get-NetNeighbor | Where-Object {$_.State -NotLike 'Unreachable'} | Select-Object -ExpandProperty IPAddress)
###Loop through network neighbors and check for the currently logged user accounts and associated domain information for each user account.
###Exporting to a file and pulling back in to console because neither 'out-string' or $Formatenumeration=-1 would always allow the full host name to show. 
ForEach-Object -InputObject $Targets {

gwmi win32_LoggedOnUser -ComputerName $Targets | Select Antecedent,__SERVER | Export-csv .\Friends.txt

}
Get-Content .\Friends.txt
rm .\Friends.txt

Read-Host -Prompt "Process Complete. Check script directory for results."
