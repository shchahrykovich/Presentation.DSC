function Copy-Configuration($mofs)
{
    $mof = $mofs[0];
    Write-Host("Copying mof $($mof.Name)");

    $guid = '6d923c36-961a-4fe8-987c-88061edc1979';
    $dest = "c:\program files\windowspowershell\dscservice\configuration\$guid.mof"
    copy $mof.FullName $dest -Force

    $checksumFile = $dest + ".checksum";
    ri $checksumFile -Force -ErrorAction SilentlyContinue

    New-DSCChecksum $dest
}

function Copy-Modules()
{
    Write-Host("Copying modules");

    #Update module version
    $moduleFolder = "$PSScriptRoot\Resources\xLibrary";
    $moduleDescriptionPath = "$moduleFolder\xLibrary.psd1";
    $moduleInfo = Test-ModuleManifest $moduleDescriptionPath
    New-ModuleManifest -Path $moduleDescriptionPath -ModuleVersion "1.$($moduleInfo.Version.Minor + 1)"
    $moduleInfo = Test-ModuleManifest $moduleDescriptionPath

    #Create zip
    $moduleName = "xLibrary_$($moduleInfo.Version.ToString()).zip";
    $modulePath = "$PSScriptRoot\$moduleName";
    Compress-Archive $moduleFolder -DestinationPath $modulePath -Force

    #Copy
    $moduleFolder = "$env:ProgramFiles\WindowsPowerShell\DscService\Modules\";
    Copy $modulePath $moduleFolder  -Force

    #Calculate checksum
    New-DSCCheckSum –path $moduleFolder -force
}

function Install-DscResources()
{
    $target = "C:\Program Files\WindowsPowerShell\Modules";
    foreach($m in (ls "$PSScriptRoot\Resources"))
    {
        Write-Host("Installing module $($m.name)")
        del "$target\$($m.Name)" -Force -Recurse -ErrorAction SilentlyContinue -Confirm:$false
        copy $m.FullName $target -Force -Recurse
    }
}

$ConfigData = @{
  AllNodes = @(
    @{
       #For all nodes 
       NodeName = "*"
       RegisterServerIp = $true
     },
    @{
       NodeName = "WebServer"
       Roles = "Web"
       PSDscAllowPlainTextPassword=$true
     },
    @{
       NodeName = "ToolsServer"
       Roles = "Tools"
       RegisterServerIp=$false
     }
   );
}

Copy-Modules
Install-DscResources

$mofs = &"$PSScriptRoot\Configuration.ps1" –ConfigurationData $ConfigData

Copy-Configuration $mofs
