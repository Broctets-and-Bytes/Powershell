###Query Active Directory for all objects identified as 'Computers'. Select the DNSHostName and cat to file for temporary use. Use optional '-server' and '-credential' parameters to specify a different domain.
Get-ADComputer -Filter * | Select-Object DNSHostName >>Hostnames.txt
###Get the Hostname file previously created and clean out the first 4 lines that powershell appends so that they do not cause issues with NSlookup.
Get-Content Hostnames.txt |
    Select -Skip 4 |
    Set-Content "Hostnames-temp"
Move "Hostnames-temp" Hostnames.txt -Force
###Loop through the hostnames extracted and clean from Active Directory and identify the last known IP address using nslookup. Then select, using RegEx (IPV4), Lines containing Ip Addresses.Cat out to file for next operation. 
$ADComputers = (Get-Content .\Hostnames.txt)
ForEach ($C in $ADComputers)
{
        nslookup $C | Select-String -Pattern '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b' >>Resolved.txt
}

###Take the messy list of IP addresses and remove the 'Address:' preceeding all of the IP addresses. Cat out to a temporary file.
$IPList = ".\Resolved.txt"
Get-Content $IPList | ForEach-Object {
    $_.split(":")[1] >>IPsTmp.txt
}

###Take the Temporary file of IP addresses that still contain white spaces and remove the white spaces preceding the IP addresses.
$IPList2 = ".\IPsTmp.txt"
Get-Content $IPList2 | ForEach-Object {
    $_.Trim() >>IPsTmp2.txt
}
###Get only Unique IP addresses from the created list, removing the lookup server redundancy.
Get-Content .\IPsTmp2.txt | Sort | Get-Unique >IPs.txt
###Cleanup the mess of files we just made leaving only desired files (IP addresses only, and FQDNs).

rm IPsTmp.txt
rm IPsTmp2.txt
rm Resolved.txt

Read-Host -Prompt "Process completed. Check Script Directory for results."
