<#
#Process comparison script. For those engagements where you have nothing :).
#Last updated on 08/23/2018; Designed with Powershell version 5.1.17134.228; Created by Brock Bell; Git @Broctets-and-Bytes
This script is designed to take a list of processes reports created by Powershells "Get-Process" cmdlet and compare it to a known good report from the same Get-Process command.
Example for creating baseline by local process export or via invoke-command (Get-Process | Export-csv -NoTypeInformation -Path \\Network-local-path\$env:COMPUTERNAME.csv)
Format must follow "Get-Process | Export-csv -NoTypeInformation" 
As designed this compares the (Name) and the (Path) of the process. Below it is easy to configure alternate options. If either the name, or path differ the name & path of the process will be exported to a file "Non-Standard-Processes.txt" under the name of the file the original process list was stored as.
There will be another file generated called "Review_List.csv". This is a list of all the process reports the script iterated over.

Once a report has been generated analysis is up to the responder. One possible example is noted below for culling via Excel by app occurance (Name). 

1.) Once a report is generated Excel can be opened and the user can select to "Add data from txt"
2.) Use a "space" as the delimiter 
3.) Create a new column to the right of the "Name" column.
4.) Utilize the following expression to create a count for how many times an app name occurs
5.) =COUNTIF($A:$A,A2)
6.) look for app names (or execution paths) that occur a low number of times accross the collected date.
#>


#Prompt the user the root level directory containing all of the nested process reports.
$Start_Location = read-host "Enter Root level directory holding reports. Search is recursive for *.csv"
#Change to user supplied top level directory for processing.
CD $Start_Location
#Prompt the user to supply the full filename and path of the known good configuration they wish to use.
$KnownGoodReport = Read-Host "Enter the path to the known good Process report including file name and extension; Don't use quotes for paths with spaces."
#Create a variable to hold all of the recursively identified Process Reports.
$CM_PR_Report = (Get-Childitem -r .\*.csv)
#Create a directory for storing generated reports. Directory will be opened at the end of processing.
mkdir Generated-Reports
#Run a loop against all collected reports comparing them to the known good configuration; Decision metrics are <Name,Path>; Select the results that do not match the known good configuration and compile into a list to review.
ForEach ($PRReport in $CM_PR_Report) {
Get-Item $PRReport >>.\Generated-Reports\Review_List.csv
$PRReport.FullName >>.\Generated-Reports\Non-Standard-Processes.txt
Compare-Object -DifferenceObject (import-csv $PRReport) -ReferenceObject (import-csv $KnownGoodReport) -Property Name,Path | WHERE {$_.SideIndicator -eq "=>"} >>.\Generated-Reports\Non-Standard-Processes.txt
}
#Open the reports directory.
ii $Start_Location\Generated-Reports
Read-Host "Press any key to exit"
