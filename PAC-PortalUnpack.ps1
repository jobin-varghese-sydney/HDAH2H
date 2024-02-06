
#User Location: C:\Users\jobin.varghese\Projects\PRJ-HCC-H2H\src\HealthDirect.H2H.Release\PowerShell ..When executed from the PowerShell$ folder

#$solutionName = Read-Host "Please enter the unique CRM solution name" #The unique CRM solution name eg:H2HCustomisation 

$UserLocation= (Get-Item .).FullName
$dropLocation= $UserLocation -replace "PowerShell$","PortalCode\"

$PAC = "C:\Users\jobin.varghese\Projects\PRJ-HCC-H2H\src\HealthDirect.H2H.Release\PowerApps.CLI\Pac.exe"  #The full path to the PAC.exe  #The full path to the PAC.exe

#Gloabal Variable
$sitEnviromentUrl="https://hcc-h2h-dev.crm6.dynamics.com"
$clientSecret="Nwa8Q~8Dk..QA-MqxLDCTDk8ur-gs3wKE9J6lcto"
$applicationId="79116079-5658-4d5d-9e5f-639492d7bbd0"
$tenantId="4a9328ed-b20e-4d33-a7b4-179d35983562"
$sevicePrincipalName="H2HDEV-SPN"
$BuildBuildId="1.0.0"


 #Named Create with Service Principal
 powershell.exe –command "& { "$PAC" auth create --url $sitEnviromentUrl --name $sevicePrincipalName --applicationId $applicationId --clientSecret $clientSecret --tenant $tenantId}"

 #List you CRM Enviorments in you profile
  powershell.exe –command "& { "$PAC"  auth list }"
 
 # Set the CRM Enviorment pac auth select --index 2
  powershell.exe –command "& { "$PAC"  auth select --index 1 }"

 
 #Write-Output "$PAC" solution export --path $dropLocation  $solutionName ".zip" --name $solutionName



 #Download the portal code:
 $dropLocation= $UserLocation -replace "PowerShell$","PortalCode"
 

  #Remove the Folder content
  powershell.exe –command "& { Remove-Item $dropLocation\* -Recurse -Force}"

 #pac paportal download --path C:\Users\jobin.varghese\Projects\PRJ-HCC-H2H\src\HealthDirect.H2H.Portals -id ea502fcd-d6ee-ed11-8849-000d3a6ad223
 powershell.exe –command "& { "$PAC" paportal download --path  $dropLocation -id ea502fcd-d6ee-ed11-8849-000d3a6ad223 }"
  

 Exit