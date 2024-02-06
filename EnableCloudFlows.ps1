[CmdletBinding()]
param(
  [string]$tenantId,
  [string]$applicationId,
  [string]$clientSecret,
  [string]$solutionName,
  [string]$azureactivedirectoryobjectid
)
$url = $Env:url
$connectionString  = "AuthType=ClientSecret;ClientId=$applicationId;ClientSecret=$clientSecret;Url=$url"

Write-Host "Starting Enabling Cloud Flows Power Shell Script..."

# Login to PowerApps for the Admin commands
Write-Host "Login to PowerApps for the Admin commands"
Install-Module  Microsoft.PowerApps.Administration.PowerShell -RequiredVersion "2.0.105" -Force -Scope CurrentUser -AllowClobber
Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $applicationId -ClientSecret $clientSecret -Endpoint "prod"
 
# Login to PowerApps for the Xrm.Data commands
Write-Host "Login to PowerApps for the Xrm.Data commands"
Install-Module  Microsoft.Xrm.Data.PowerShell -RequiredVersion "2.8.14" -Force -Scope CurrentUser -AllowClobber
$conn = Get-CrmConnection -ConnectionString $connectionString
$user = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute azureactivedirectoryobjectid -FilterOperator eq -FilterValue $azureactivedirectoryobjectid
 
# Create a new Connection to impersonate the creator of the connection reference
$impersonatedconn = Get-CrmConnection -ConnectionString $connectionString
$impersonatedconn.OrganizationWebProxyClient.CallerId = $user.CrmRecords[0].systemuserid
 
$existingconnectionreferences = (ConvertTo-Json ($connectionsrefs | Select-Object -Property connectionreferenceid, connectionid)) -replace "`n|`r",""
Write-Host "##vso[task.setvariable variable=CONNECTION_REFS]$existingconnectionreferences"
Write-Host "Connection References:$existingconnectionreferences"

# Get the flows that are turned off
Write-Host "Get Flows that are turned off"
$fetchFlows = @"
<fetch>
  <entity name='workflow' >
    <attribute name='category' />
    <attribute name='name' />
    <attribute name='statecode' />
    <attribute name='workflowid' />
    <filter type='and' >
      <condition attribute='category' operator='eq' value='5' />
      <condition attribute='statecode' operator='eq' value='0' />
    </filter>
    <link-entity name='solutioncomponent' from='objectid' to='workflowid' >
      <filter>
        <condition attribute='solutionidname' operator='eq' value='$solutionName' />
      </filter>
    </link-entity>
  </entity>
</fetch>
"@;

$flows = (Get-CrmRecordsByFetch  -conn $conn -Fetch $fetchFlows -Verbose).CrmRecords
if ($flows.Count -eq 0)
{
    Write-Host "##vso[task.logissue type=warning]No Flows that are turned off in $solutionName."
    Write-Output "No Flows that are turned off"
    exit(0)
}
 
# Turn on flows
foreach ($flow in $flows){
  try {
    Write-Output "Turning on Flow:$(($flow).name)"
    Set-CrmRecordState -conn $impersonatedconn -EntityLogicalName workflow -Id $flow.workflowid -StateCode Activated -StatusCode Activated -Verbose -Debug
  }
  catch {
    Write-Warning "An error occored when activating flow:$(($flow).name)"
    Write-Warning $_
  }
    
}