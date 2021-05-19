param(
[Parameter(Mandatory=$true)]
[string]$basePath,
[Parameter(Mandatory=$true)]
[string]$cluexe
)
If(!(test-path $basePath))
{
    New-Item -ItemType Directory -Force -Path $basePath
}
If(!(test-path "$basePath\Tools"))
{
    New-Item -ItemType Directory -Force -Path "$basePath\Tools"
}
If(!(test-path "$basePath\Import"))
{
    New-Item -ItemType Directory -Force -Path "$basePath\Import"
}
Start-Sleep -Seconds 1 #waits for folders to be ready
Invoke-WebRequest -outfile "$basePath\Import\model.archive" -usebasicparsing -Uri  https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/smallmodel.archive;
Invoke-WebRequest -outfile "$basePath\Import\model.maestromodel" -usebasicparsing -Uri https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/smallmodel.maestromodel;
Invoke-WebRequest -outfile "$basePath\Import\Product.maestroform" -usebasicparsing -Uri https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/Product.maestroform;
Invoke-WebRequest -outfile "$basePath\Import\Product.portalapplication" -usebasicparsing -Uri https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/Product.portalapplication;
Invoke-WebRequest -outfile "$basePath\Import\Product.presentationview" -usebasicparsing -Uri https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/Product.presentationview;
Invoke-WebRequest -outfile "$basePath\Tools\Profisee.Platform.Utilities.Internal.EncryptDecrypt.zip" -usebasicparsing -Uri https://raw.githubusercontent.com/chuckthompsonprofisee/kubernetespublic/main/Profisee.Platform.Utilities.Internal.EncryptDecrypt.zip;
Get-ChildItem $basePath\import;
Expand-Archive $basePath\Tools\Profisee.Platform.Utilities.Internal.EncryptDecrypt.zip -DestinationPath $basePath\Tools;
Get-ChildItem $basePath\Tools;
Write-Output "get encrypted clientid from database";
$connectionString="Provider=SQLOLEDB;Server="+$env:ProfiseeSqlServer+";Database=Profisee;User Id="+$env:ProfiseeSqlUserName+";Password="+$env:ProfiseeSqlPassword;
$sql="SELECT ISNULL(ClientID,'') FROM [meta].[tUser] WHERE NAME LIKE '$env:ProfiseeAdminAccount'";
$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString;
$command = New-Object System.Data.OleDb.OleDbCommand $sql,$connection;
$connection.Open();
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command;
$dataset = New-Object System.Data.DataSet;
$adapter.Fill($dataSet);
$connection.Close();
$rows=($dataset.Tables | Select-Object -Expand Rows);
$clientid = $rows[0];
Write-Output "encrypted clientid=$clientid"
Write-Output "decrypt the clientid from db to a file called out.txt";
Start-Process -FilePath "$basePath\Tools\Profisee.Platform.Utilities.Internal.EncryptDecrypt.exe" -WorkingDirectory "$basePath\Tools" -ArgumentList " DECRYPT $clientid"  -NoNewWindow -PassThru -Wait;
Start-Sleep 5;
Write-Output "get unencrypted clientid from out.txt";
$clientid = [IO.File]::ReadAllText("$basePath\Tools\out.txt");
Write-Output "clientid=$clientid";
$url = $env:ProfiseeExternalDNSUrl + "/profisee/api/";
Write-Output "url=$url";
Write-Output "cluexe=$cluexe";
$clientidAndUrl = "/ClientID:"+$clientid+" /URL:"+$url;
$allImportParms =" /IMPORT /FILE:$basePath\Import /TYPE:ALL";
$dataImportParms =" /DeployData /FILE:$basePath\Import\model.archive";
Write-Output "Import All";
$allArgs=$clientidAndUrl + $allImportParms;
Start-Process -FilePath $cluexe  -ArgumentList $allArgs  -NoNewWindow -PassThru -Wait;
Write-Output "Import Data";
$allArgs=$clientidAndUrl + $dataImportParms;
Start-Process -FilePath $cluexe  -ArgumentList $allArgs  -NoNewWindow -PassThru -Wait;
#Remove-Item -Path $basePath -Force -Recurse
write-host 'done';