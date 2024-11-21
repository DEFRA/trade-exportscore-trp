param(
    [Parameter(Mandatory)]
    [string]$JarFilePath,
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$PropertiesFilePath,
    [Parameter(Mandatory)]
    [string]$Server,
    [Parameter(Mandatory)]
    [string]$DatabaseName,
    [Parameter(Mandatory)]
    [string]$UserName
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
Write-Debug "${functionName}:JarFilePath=$JarFilePath"
Write-Debug "${functionName}:PropertiesFilePath=$PropertiesFilePath"
Write-Debug "${functionName}:UserName=$UserName"
Write-Debug "${functionName}:Server=$Server"
Write-Debug "${functionName}:DatabaseName=$DatabaseName"
Write-Debug "${functionName}:UserName=$UserName"

[System.IO.DirectoryInfo]$scriptDir = $PSCommandPath | Split-Path -Parent
Write-Debug "${functionName}:scriptDir.FullName=$scriptDir.FullName"

try {
    [System.IO.DirectoryInfo]$moduleDir = Join-Path -Path $scriptDir.FullName -ChildPath "modules/psql"
    Write-Debug "${functionName}:moduleDir.FullName=$($moduleDir.FullName)"

    Import-Module $moduleDir.FullName -Force

    [string]$output = Invoke-Liquibase -JarFilePath $JarFilePath `
                                       -PropertiesFilePath $PropertiesFilePath `
                                       -Server $Server `
                                       -DatabaseName $DatabaseName `
                                       -UserName $UserName 
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
    [DateTime]$endTime = [DateTime]::UtcNow
    [Timespan]$duration = $endTime.Subtract($startTime)
    Write-Host "${functionName} finished at $($endTime.ToString('u')) (duration $($duration -f 'g')) with exit code $exitCode"

    if ($setHostExitCode) {
        Write-Debug "${functionName}:Setting host exit code"
        $host.SetShouldExit($exitCode)
    }
    exit $exitCode
}
