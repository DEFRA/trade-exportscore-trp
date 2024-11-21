param(
    [Parameter(Mandatory)]
    [string]$Server,
    [Parameter(Mandatory)]
    [string]$UserName,
    [Parameter(Mandatory)]
    [string]$ManagedIdentityName,
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory)]
    [string]$Subscription
)

Set-StrictMode -Version 3.0

[string]$functionName = $MyInvocation.MyCommand
[DateTime]$startTime = [DateTime]::UtcNow
[int]$exitCode = -1
[bool]$setHostExitCode = (Test-Path -Path ENV:TF_BUILD) -and ($ENV:TF_BUILD -eq "true")
[bool]$enableDebug = (Test-Path -Path ENV:SYSTEM_DEBUG) -and ($ENV:SYSTEM_DEBUG -eq "true")

Set-Variable -Name ErrorActionPreference -Value Continue -scope global
Set-Variable -Name VerbosePreference -Value Continue -Scope global

if ($enableDebug) {
    Set-Variable -Name DebugPreference -Value Continue -Scope global
    Set-Variable -Name InformationPreference -Value Continue -Scope global
}

Write-Host "${functionName} started at $($startTime.ToString('u'))"
Write-Debug "${functionName}:Server=$Server"
Write-Debug "${functionName}:UserName=$UserName"
Write-Debug "${functionName}:ManagedIdentityName=$ManagedIdentityName"
Write-Debug "${functionName}:ResourceGroupName=$ResourceGroupName"
Write-Debug "${functionName}:Subscription=$Subscription"

[System.IO.DirectoryInfo]$scriptDir = $PSCommandPath | Split-Path -Parent
Write-Debug "${functionName}:scriptDir.FullName=$scriptDir.FullName"

[System.IO.FileInfo]$tempFile = [System.IO.Path]::GetTempFileName()

try {
    [System.IO.DirectoryInfo]$moduleDir = Join-Path -Path $scriptDir.FullName -ChildPath "modules/psql"
    Write-Debug "${functionName}:moduleDir.FullName=$($moduleDir.FullName)"

    Import-Module $moduleDir.FullName -Force
    
    $mid = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $ManagedIdentityName

    if ($null -eq $mid) {
        throw "$ManagedIdentityName not found"
    }

    [string]$clientId = $mid.ClientId
    Write-Debug "${functionName}:clientId=$clientId"

    if ([string]::IsNullOrEmpty($clientId)) {
      throw "ClientId not resolved"
    }

    [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append(' SET aad_validate_oids_in_tenant = off; ')
    [void]$builder.Append(' DO $$ ')
    [void]$builder.Append(' BEGIN ')
    [void]$builder.Append("   IF EXISTS (select 1 from pg_roles WHERE rolname='$ManagedIdentityName') THEN ")
    [void]$builder.Append("     ALTER ROLE `"$ManagedIdentityName`" WITH LOGIN PASSWORD '$clientId'; ")
    [void]$builder.Append('   ELSE ')
    [void]$builder.Append("     CREATE ROLE `"$ManagedIdentityName`" WITH LOGIN PASSWORD '$clientId' IN ROLE azure_ad_user; ")
    [void]$builder.Append('   END IF; ')
    [void]$builder.Append(' END $$; ')
    [string]$command = $builder.ToString()
    Write-Debug "${functionName}:command=$command"

    [System.IO.FileInfo]$tempFile = [System.IO.Path]::GetTempFileName()

    [string]$content = Set-Content -Path $tempFile.FullName -Value $command -Force -PassThru 
    Write-Debug "${functionName}:$($tempFile.FullName)=$content"

    [string]$output = Invoke-PSQLScript -Path $tempFile.FullName -Host $Server -UserName $UserName -DatabaseName 'postgres'
    Write-Debug "${functionName}:output=$output"

    Write-Output $output
    # getting this far means success
    $exitCode = 0   
}
catch {
    $exitCode = -2
    Write-Error $_.Exception.ToString()
    throw $_.Exception
}
finally {
    Remove-Item -Path $tempFile.FullName -Force -ErrorAction SilentlyContinue

    [DateTime]$endTime = [DateTime]::UtcNow
    [Timespan]$duration = $endTime.Subtract($startTime)

    Write-Host "${functionName} finished at $($endTime.ToString('u')) (duration $($duration -f 'g')) with exit code $exitCode"

    if ($setHostExitCode) {
        Write-Debug "${functionName}:Setting host exit code"
        $host.SetShouldExit($exitCode)
    }
    exit $exitCode
}
