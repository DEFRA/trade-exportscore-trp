Set-StrictMode -Version 3.0


function Invoke-PSQLScript {
  param(
    [Parameter(Mandatory)]
    [string]$Hostname,
    [Parameter(Mandatory)]
    [string]$UserName,
    [Parameter()]
    [string]$DatabaseName,
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Path,
    [switch]$ReturnExitCode
  )

  
  begin {
    [string]$functionName = $MyInvocation.MyCommand
    Write-Debug "${functionName}:begin:start"
    Write-Debug "${functionName}:begin:Hostname=$Hostname"
    Write-Debug "${functionName}:begin:UserName=$UserName"
    Write-Debug "${functionName}:begin:DatabaseName=$DatabaseName"
    Write-Debug "${functionName}:begin:end"
  }

  process {
    Write-Debug "${functionName}:process:start"
    Write-Debug "${functionName}:begin:Path=$Path"

    [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new("psql -A -q ")
    [void]$builder.Append(" -h " + $Hostname)
    [void]$builder.Append(" -U " + $UserName)
    [void]$builder.Append(" " + $DatabaseName)
    [void]$builder.Append(" -f '")
    [void]$builder.Append($Path)
    [void]$builder.Append("'")

    [string]$expression = $builder.ToString()
    Write-Debug "${functionName}:begin:expression=$expression"
    Write-Host $expression

    $token = Get-AzAccessToken -ResourceUrl "https://ossrdbms-aad.database.windows.net"
    $ENV:PGPASSWORD = $token.Token
    
    [string]$output = Invoke-Expression -Command $expression
    [int]$exitCode = $LASTEXITCODE
    Write-Debug "${functionName}:begin:exitCode=$exitCode"
    Write-Debug "${functionName}:begin:output=$output"

    if ($ReturnExitCode) {
      Write-Output $exitCode
    }
    else {
      Write-Output $output
      if ($exitCode -ne 0) {
        throw "Non zero exit code: $exitCode"
      }
    }

    Write-Debug "${functionName}:process:end"
  }

  end {
    Write-Debug "${functionName}:end:start"
    Write-Debug "${functionName}:end:end"
  }
}


function Invoke-Liquibase {
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

  begin {
    [string]$functionName = $MyInvocation.MyCommand
    Write-Debug "${functionName}:begin:start"
    Write-Debug "${functionName}:begin:JarFilePath=$JarFilePath"
    Write-Debug "${functionName}:begin:UserName=$UserName"
    [string]$urlValue = "jdbc:postgresql://$Server/$DatabaseName"
    Write-Debug "${functionName}:begin:urlValue=$urlValue"
    [System.IO.FileInfo]$jarFile = $JarFilePath
    Write-Debug "${functionName}:begin:jarFile.FullName=$($jarFile.FullName)"

    if (-not $jarFile.Exists) {
      throw [System.IO.FileNotFoundException]::new($jarFile.FullName)
    }

    Write-Debug "${functionName}:begin:end"
  }

  process {
    Write-Debug "${functionName}:process:start"
    Write-Debug "${functionName}:process:PropertiesFilePath=$PropertiesFilePath"

    [System.IO.FileInfo]$propertiesFile = $PropertiesFilePath
    Write-Debug "${functionName}:process:propertiesFile.FullName=$($propertiesFile.FullName)"

    if (-not $propertiesFile.Exists) {
      throw [System.IO.FileNotFoundException]::new($propertiesFile.FullName)
    }

    $token = Get-AzAccessToken -ResourceUrl "https://ossrdbms-aad.database.windows.net"
    [hashtable]$propertyDictionary = Import-LiquibasePropertiesFile -Path $propertiesFile.FullName
    $propertyDictionary["username"] = $UserName
    $propertyDictionary["password"] = $token.Token
    $propertyDictionary["url"] = $urlValue
    Export-LiquibasePropertiesFile -Path $propertiesFile.FullName -PropertyDictionary $propertyDictionary -Force
    
    [string]$command = "java -jar $($jarFile.FullName) --defaultsFile='$($propertiesFile.FullName)' update"
    Write-Host $command

    [string]$output = Invoke-Expression -Command $command
    [int]$exitCode = $LASTEXITCODE
    Write-Host $output

    if ($exitCode -ne 0) {
      throw "Non zero exit code: $exitCode"
    }

    Write-Debug "${functionName}:process:end"
  }

  end {
    Write-Debug "${functionName}:end:start"
    Write-Debug "${functionName}:end:end"
  }
}

function Import-LiquibasePropertiesFile {
  param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$Path
  )

  begin {
    [string]$functionName = $MyInvocation.MyCommand
    Write-Debug "${functionName}:begin:start"
    [hashtable]$PropertyDictionary = @{}
    Write-Debug "${functionName}:begin:end"
  }

  process {
    Write-Debug "${functionName}:process:start"
    Write-Debug "${functionName}:process:Path=$Path"

    [System.IO.FileInfo]$propertiesFile = $Path
    Write-Debug "${functionName}:process:propertiesFile.FullName=$($propertiesFile.FullName)"

    if (-not $propertiesFile.Exists) {
      throw [System.IO.FileNotFoundException]::new($propertiesFile.FullName)
    }

    [array]$propertyEntries = Get-Content -Path $propertiesFile.FullName

    foreach($entry in $propertyEntries) {
      Write-Debug "${functionName}:process:entry=$entry"
      [int]$colonIndex = $entry.IndexOf(':')
      Write-Debug "${functionName}:process:colonIndex=$colonIndex"
      [string]$propertyName = $entry.Substring(0, $colonIndex) # deliberately one short to avoid bringing the colon
      Write-Debug "${functionName}:process:propertyName=$propertyName"
      [string]$propertyValue = $entry.Substring($colonIndex +1).Trim() # deliberately one above to avoid bringing the colon
      Write-Debug "${functionName}:process:propertyValue=$propertyValue"

      $PropertyDictionary[$propertyName] = $propertyValue
    }
    
    Write-Debug "${functionName}:process:end"
  }

  end {
    Write-Debug "${functionName}:end:start"
    Write-Output $PropertyDictionary
    Write-Debug "${functionName}:end:end"
  }  
}


function Export-LiquibasePropertiesFile {
  param(
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [hashtable]$PropertyDictionary,
    [switch]$Force
  )

  begin {
    [string]$functionName = $MyInvocation.MyCommand
    Write-Debug "${functionName}:begin:start"
    Write-Debug "${functionName}:begin:Path=$Path"
    Write-Debug "${functionName}:begin:Force=$Force"
    [System.IO.FileInfo]$propertiesFile = $Path
    Write-Debug "${functionName}:begin:propertiesFile.FullName=$($propertiesFile.FullName)"

    if ($propertiesFile.Exists -and -not $Force) {
      throw "File already exists $($propertiesFile.FullName)"
    }
    Write-Debug "${functionName}:begin:end"
  }

  process {
    Write-Debug "${functionName}:process:start"
    Write-Debug "${functionName}:process:PropertyDictionary=$PropertyDictionary"

    [array]$lines = $PropertyDictionary.Keys | Sort-Object | ForEach-Object -Process {
      [string]$key = $_
      [string]$value = $PropertyDictionary[$key]
      [string]$entry = "$key`: $value"
      Write-Debug "${functionName}:process:key=$key"
      Write-Debug "${functionName}:process:value=$value"
      Write-Debug "${functionName}:process:entry=$entry"
      return $entry
    }
    
    $lines | Set-Content -Path $propertiesFile.FullName -Force

    Write-Debug "${functionName}:process:end"
  }

  end {
    Write-Debug "${functionName}:end:start"
    Write-Debug "${functionName}:end:end"
  }  
}
