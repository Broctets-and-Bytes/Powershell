#File Hash comparison script for automating the necessary.
#Last updated on 06/15/2018; Designed with Powershell version 5.1.17134.112; Created by Brock Bell; Git @Broctets-and-Bytes
#Ask user for the location of the files that they coped. Store that as $OriginFiles
$OriginFiles = Read-Host 'What is the root directory of the files that were copied?'
#Ask user for the location where the files were copied to. Store that as $CopiedFiles.
$CopiedFiles = Read-Host 'What is the root directory of the copied version of the files?'
#Usr input switch for deciding if the files should be hashed recursively or not.
Write-Host 'Should file hashes be collected for files recursively or not.'
$Recurse = Read-Host " ( y / n ) " 
    Switch ($Recurse) 
        { 
            Y {Write-host "Collecting file hashes recursively"; $Recursive=$true} 
            N {Write-Host "Only collecting top level file hashes"; $Recursive=$false} 
            Default {Write-Host "Only collecting top level file hashes"; $Recursive=$false} 
        } 
IF ($Recursive -eq $true)
{
    #Hash all of the files in the origin location with recurse.
    $OriginFilesHash = (Get-ChildItem $OriginFiles -Recurse | Get-FileHash -Algorithm MD5)
    #Hash all of the copied files  with recurse.
    $CopiedFilesHash = (Get-ChildItem $CopiedFiles -Recurse | Get-FileHash -Algorithm MD5)
}
ELSE
{
    #Hash all of the files in the origin location without recurse.
    $OriginFilesHash = (Get-ChildItem $OriginFiles | Get-FileHash -Algorithm MD5)
    #Hash all of the copied files without recurse.
    $CopiedFilesHash = (Get-ChildItem $CopiedFiles | Get-FileHash -Algorithm MD5)
}
#Compare the hash values stored in the origin and copied values and identify hash mismatches. Then push into WHERE to select the copied files that do not match origin hash values.
$Unveri = (Compare-Object -ReferenceObject $OriginFilesHash -DifferenceObject $CopiedFilesHash -Property Hash | WHERE {$_.SideIndicator -eq "=>"})
#Write a file to the current working directory that contains and mismatched hashes.
$Unveri | Out-File .\Copied-File-Mismatches.txt
#Grab only the hash value from any file mismatches. Store that as a new variable to use as a list of search strings
$SearchHashs = ($Unveri.Hash)
#Write a list of the file hashes for all copied files to the current working directory.
$CopiedFilesHash | Export-Csv .\CopiedHash.csv
#Write a list of the file hashes for all origin files to the current working directory.
$OriginFilesHash | Export-csv .\OriginHash.csv
#ForEach loop to take any identified hash mismatches and correlate them back to their identified path and name so that the user knows what file needs copied over again.
#Select the string and iterate through the list of copied files to make the correlation. Pipe identified file matches into a ForEach loop and select the entire line so that the
#user also knows the name and path of the file instead of just the hash.
ForEach ($H in $SearchHashs)
{
Select-String -SimpleMatch -Pattern $H -Path .\CopiedHash.csv | % {$_.line} >>BadFiles.txt

}
Read-Host -Prompt "Process complete. Resulting hash lists are in script directory. Press enter to exit"

