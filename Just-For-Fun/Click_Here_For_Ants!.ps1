###This literally will just make the equivalent of ants in whatever directory you tell it to. Be Careful. 
$AntHouse = Read-Host "Directory to convert to ants"
$NowYouHaveAnts = (Get-ChildItem $AntHouse)
 ForEach ($A in $NowYouHaveAnts){

 Rename-Item -Path $A.PSPath -NewName ("Ant{0}" -f $nr++)
 }
Read-Host -Prompt "Congratulations, now you have ants! Press any key to exit."








