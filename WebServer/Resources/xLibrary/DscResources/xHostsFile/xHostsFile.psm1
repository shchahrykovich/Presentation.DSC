$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

function Get-TargetResource{
[CmdletBinding()] 
[OutputType([System.Collections.Hashtable])]
param
(
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [System.String]
    $Ip
)
    $content = Get-Content $hostsPath;
    $result = @{
            Ip = ""
            Name = $Name
        };
    
    $line = $content | where { $_.Contains($Name) } | Select-Object -First 1;
    if($line)
    {
        Write-Verbose("Found record - $line");

        $ip = $line.Split(" ",  [System.StringSplitOptions]::RemoveEmptyEntries)[0];
        $result.Ip = $ip;
    }

    return $result;
}

function Set-TargetResource{
[CmdletBinding()]
param
(
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [System.String]
    $Ip
)
    try
    {
        $content = Get-Content $hostsPath;
        $content += "$Ip    $Name";
        $content | Set-Content $hostsPath -Encoding Ascii;
    }
    catch
    {
        $errorRecord = Create-Error "Set-TargetResource" $_.Exception.ToString();
        $PSCmdlet.ThrowTerminatingError($errorRecord);
    }
}

function Test-TargetResource{
[CmdletBinding()]
[OutputType([System.Boolean])]
param
(
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [System.String]
    $Ip
)
    try
    {
        $resource = Get-TargetResource $Name $Ip;
        $result = $resource.Ip -ne "";

        Write-Verbose("Ip - $($resource.Ip)");
        return $result;
    }
    catch
    {
        $errorRecord = Create-Error "Test-TargetResource" $_.Exception.ToString();
        $PSCmdlet.ThrowTerminatingError($errorRecord);
    }
}

function Create-Error($message, $originalException)
{
    $errorId = "xHostsFile"; 
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation;
    $exception = New-Object System.InvalidOperationException $message ;
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    Write-Verbose($originalException)

    return $errorRecord;
}

Export-ModuleMember -Function *-TargetResource