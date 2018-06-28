###Script to wrap the Python module by CrowdStrike. Aims to make interacting with the interface slightly more straight forward and easily repeatable. Many updates to come. 
####Last updated on 06/28/2018; Designed with Powershell version 5.1.17134.112; Created by Brock Bell; Git @Broctets-and-Bytes
###Script assumes you have downloaded and installed Python.
###Script assumes you have downloaded and installed Python module 'requests'; Requests can be found here: https://github.com/requests/requests ;Also can be installed via 'pip install requests'. 
###Script assumes you have downloaded and unpacked (if packed) the 'O365-Outlook-Activities' Python scripts from CrowdStrike.(https://github.com/CrowdStrike/Forensics/tree/master/O365-Outlook-Activities)
#Collect the account name that the logs will be collected from.
$CollectAccount = Read-Host 'Type the name of the account to be collected'
#Identify the file name and location the results will be saved to.
$OutputFileName = Read-Host 'Type the filename you wish to save as. File will be placed in current directory unless full path is provided'
#Prepare a table style printout of the parameters or 'types' to present to the user so they know what is available. Colors are utilized for ease. No new line to create table style printout.
Write-Host 'Table of collection parameters' -ForegroundColor Yellow
Write-Host '----------------------------------------------------------------------------------------------------------------------------------------' -ForegroundColor Green
Write-Host 'Forward' -ForegroundColor Red -NoNewline; Write-Host '                      A message was forwarded' -ForegroundColor Gray
Write-Host 'LinkClicked' -ForegroundColor Red -NoNewline; Write-Host '                  A link in a message was clicked (does not apply to all application types)' -ForegroundColor Gray
Write-Host 'MarkAsRead' -ForegroundColor Red -NoNewline; Write-Host '                   A message was marked as read' -ForegroundColor Gray
Write-Host 'MarkAsUnread' -ForegroundColor Red -NoNewline; Write-Host '                 A message was marked as unread' -ForegroundColor Gray
Write-Host 'MessageDelivered' -ForegroundColor Red -NoNewline; Write-Host '             A message was delivered to the mailbox' -ForegroundColor Gray
Write-Host 'MessageSent' -ForegroundColor Red -NoNewline; Write-Host '                  A message was sent from the mailbox' -ForegroundColor Gray
Write-Host 'Move' -ForegroundColor Red -NoNewline; Write-Host '                         A message was moved (by a user or by Exchange)' -ForegroundColor Gray
Write-Host 'OpenedAnAttachment' -ForegroundColor Red -NoNewline; Write-Host '           An attachment was opened (does not apply to all application types)' -ForegroundColor Gray
Write-Host 'ReadingPaneDisplayEnd' -ForegroundColor Red -NoNewline; Write-Host '        A message was deselected in the reading pane' -ForegroundColor Gray
Write-Host 'ReadingPaneDisplayStart' -ForegroundColor Red -NoNewline; Write-Host '      A message was selected in the reading pane (a message was viewed)' -ForegroundColor Gray
Write-Host 'Reply' -ForegroundColor Red -NoNewline; Write-Host '                        A message was replied to (also ReplyAll)' -ForegroundColor Gray
Write-Host 'SearchResult' -ForegroundColor Red -NoNewline; Write-Host '                 Search results were generated' -ForegroundColor Gray
Write-Host 'ServerLogon' -ForegroundColor Red -NoNewline; Write-Host '                  A logon event occurred (may also be accompanied by a Logon activity)' -ForegroundColor Gray
Write-Host '----------------------------------------------------------------------------------------------------------------------------------------' -ForegroundColor Green
#Ask the user what parameters they want to collect at this time. 
$CollectionParams = Read-Host 'Name the parameters you wish to collect. Supply names space delimeted. E.g. Reply ServerLogon'
#Identify the location of the python modules for the 0365 log collection.
$0365_CS = Read-Host 'What is the path to the root folder of the O365-Outlook-Activities script by CrowdStrike'
#Join the CrowdStrike execution directory with the start module name to be used in the command later.
$0365_CSP = (Join-Path -Path $0365_CS -ChildPath 'retriever.py')
#Collect start of date span from user in the specific format Microsoft requires.
$StartDate = Read-Host 'Enter the start date and time for collection. Dates are in ISO8601 format. E.g. June 27 2018 is 2018-06-27T00:00:00Z'
#Collect end of date span from user in the specific format Microsoft requires.
$EndDate = Read-Host 'Enter the end date and time for collection. Dates are in ISO8601 format. E.g. June 28 2018 is 2018-06-2T23:59:59Z'
#Create a new instance of Internet Explorer to use for navigating to the 0Auth sandbox.
$InternetExplorer=new-object -com internetexplorer.application
#Navigate to the 0Auth sandbox in the new instance of IE to speed up the user process.
$InternetExplorer.navigate2("https://oauthplay.azurewebsites.net/")
#Present IE.
$InternetExplorer.visible=$true
#Write the host a note that they should have a new window pointed to the site to generate the token. Offer the link in the event IE doesn't. 
Write-Host 'Internet Explorer should open to the window. If not, go to https://oauthplay.azurewebsites.net and generate an access token'
#Collect the token associated with the account to be collected. This must be the access token. Token is good for one hour of requests.
$AuthToke = Read-Host 'Generate an access token from the 0365 sandbox. The account to be collected must be the account used. Copy and paste the token here' 
#Identify if Python is installed (version 2.7) to the default location. If it is, ask the user one less question before command execution.
Write-Host 'Is Python installed to default path at:C:\Python27'
#Create y/n switch. Identify answer and use for processing with default Python path or with user identified Python path.
$PythonExecPath = Read-Host " ( y / n ) " 
    Switch ($PythonExecPath) 
        { 
            Y {Write-host "Executing Python command from C:\Python27"; $PythonExecPath=$true} 
            N {Write-Host "Asking for Python installation directory to excute from"; $PythonExecPath=$false} 
            Default {Write-Host "Executing Python command from C:\Python27"; $PythonExecPath=$false} 
        } 
#If default path is selected, execute Python utilizing the 0365 collection module with the collected parameters. Execution command will also be written to host so that they can identify any user made error.
IF ($PythonExecPath -eq $true)
{
$CollectCommand = ("C:\Python27\python.exe $0365_CSP --user $CollectAccount --output $OutputFileName --types $CollectionParams --start $StartDate --end $EndDate --token $AuthToke")
Write-Host $CollectCommand
iex $CollectCommand
}
#Collect the Python installation directory from the user and join it to the command. Execute Python utilizing the 0365 collection module with the collected parameters. Execution command will also be written to host so that they can identify any user made error.
ELSE
{
$PyPath = Read-Host 'What is the installation directory for the root of Python. It should contain python.exe'
$PyExecPath = (Join-Path -Path $PyPath -ChildPath 'python.exe')
$CollectCommand = ("$PyExecPath $0365_CSP --user $CollectAccount --output $OutputFileName --types $CollectionParams --start $StartDate --end $EndDate --token $AuthToke")
Write-Host $CollectCommand
iex $CollectCommand
}
Read-Host -Prompt "Process complete. Resulting log can be found at $OutputFileName. Press enter to exit"