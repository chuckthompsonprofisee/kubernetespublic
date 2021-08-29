param(
[bool]$deployArtifacts=$false,
[bool]$dropDatabases=$false
)
#Provision envionment
$configManagerFolder = "D:\DevOps\Repos\platform\Server\Configuration\bin\debug\"
$configManagerExe = $configManagerFolder+"Profisee.MasterDataMaestro.Services.Configuration.exe";
$dropDatabasesText='false'
if($dropDatabases -eq $true)
{
    $dropDatabasesText='true'
}

$configManagerParms = @"
-webSiteName="Default Web Site"
-sqlServer=".\sql2019"
-dropMaestroDatabase="$dropDatabasesText"
-maestroDatabase="Profisee"
-maestroWebAppName="Profisee"
-maestroAppPoolName="Profisee"
-maestroAppPoolUserName="corp\svc_web"
-maestroAppPoolUserPassword="Profisee1"
-maestroServicePort="8003"
-maestroServiceUserName="corp\svc_maestro"
-maestroServiceUserPassword="Profisee1"
-licenseFile:"D:\Prof_2020_1Inst_1Nodes_AllFeatures_AllConnectors_Production_@.corp.profisee.com.plic"
-useWindowsAuthentication:"true"
-adminAccount:"corp\chuckth"
-AttachmentRepositoryLocation:"D:\temp\repo"
-AttachmentRepositoryUserName:"corp\svc_web"
-AttachmentRepositoryUserPassword:"Profisee1"
-AttachmentRepositoryLogonType:"Interactive"
-UseSeparateDatabases:"true"
-useHttps:"true"
-authAdName:"Windows"
-authOidcEnabled="true"
-authOidcName:"Azure Active Directory"
-authOidcAuthority:"https://login.microsoftonline.com/profisee1.onmicrosoft.com"
-authOidcClientId:"e39cbd7d-cee0-4b0f-aded-cdd73060e8c6"
-authOidcUsernameClaim:"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
-authOidcUserIdClaim:"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
-authOidcFirstNameClaim:"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
-authOidcLastNameClaim:"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
-authOidcEmailClaim:"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
-purviewURL:"https://chuckthpurview.catalog.purview.azure.com"
-purviewTennantId:"e4ba15d0-7fe2-4bd4-a3ef-a97a4378231e"
-purviewClientId:"0614c5ee-cde3-4aef-bd6f-adcf6b86d2ae"
-purviewClientSecret:"2sEf_25-6f.1OqPS-a9_Fk-gt.fi7G35zi"
"@;

Start-Process -FilePath $configManagerExe -WorkingDirectory $configManagerFolder -ArgumentList $configManagerParms  -NoNewWindow -PassThru -Wait; 

if($deployArtifacts -eq $true)
{
    #Deploy artifacts
    $env:ProfiseeSqlServer=".\sql2019";
    $env:ProfiseeSqlUserName="sa";
    $env:ProfiseeSqlPassword="!!Bridget33!!";
    $env:ProfiseeAdminAccount='corp\chuckth';
    $env:ProfiseeExternalDNSUrl = "https://corpltchuckth.corp.profisee.com"
    $guid=New-Guid;

    $basePath = "D:\"+ $guid;
    $deployScriptPath='D:\deployProfiseeArtifacts.ps1';
    $cluexe = "D:\DevOps\Repos\platform\Common\Utilities\bin\Debug\Profisee.MasterDataMaestro.Utilities.exe";
    #container
    #$basePath = "C:\"+ $guid;
    #$deployScriptPath='C:\deployProfiseeArtifacts.ps1';
    #$cluexe = "C:\Profisee\Utilities\Profisee.MasterDataMaestro.Utilities.exe";
    Invoke-WebRequest -outfile $deployScriptPath -usebasicparsing https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/deployProfiseeArtifacts.ps1;
    Invoke-Expression "$deployScriptPath $basePath $cluexe";
}
