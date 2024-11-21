param(
    [Parameter(Mandatory)]
    [string]$Server,
    [Parameter(Mandatory)]
    [string]$UserName,
    [Parameter(Mandatory)]
    [string]$ManagedIdentityName,
    [Parameter(Mandatory)]
    [string]$DatabaseName
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
Write-Debug "${functionName}:DatabaseName=$DatabaseName"

[System.IO.DirectoryInfo]$scriptDir = $PSCommandPath | Split-Path -Parent
Write-Debug "${functionName}:scriptDir.FullName=$scriptDir.FullName"

[System.IO.FileInfo]$tempFile = [System.IO.Path]::GetTempFileName()

try {
    [System.IO.DirectoryInfo]$moduleDir = Join-Path -Path $scriptDir.FullName -ChildPath "modules/psql"
    Write-Debug "${functionName}:moduleDir.FullName=$($moduleDir.FullName)"

    Import-Module $moduleDir.FullName -Force
    
    [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append(" GRANT CONNECT ON DATABASE `"$DatabaseName`" TO `"$ManagedIdentityName`"; ")
    [void]$builder.Append(" GRANT ALL PRIVILEGES ON DATABASE `"$DatabaseName`" TO `"$ManagedIdentityName`"; ")
    [void]$builder.Append(" GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO `"$ManagedIdentityName`"; ")
    [void]$builder.Append(" GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO `"$ManagedIdentityName`"; ")
    [void]$builder.Append(" GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO `"$ManagedIdentityName`"; ")
    [string]$command = $builder.ToString()
    Write-Debug "${functionName}:command=$command"

    [System.IO.FileInfo]$tempFile = [System.IO.Path]::GetTempFileName()

    [string]$content = Set-Content -Path $tempFile.FullName -Value $command -Force -PassThru 
    Write-Debug "${functionName}:$($tempFile.FullName)=$content"

    [string]$output = Invoke-PSQLScript -Path $tempFile.FullName -Host $Server -UserName $UserName -DatabaseName $DatabaseName
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
