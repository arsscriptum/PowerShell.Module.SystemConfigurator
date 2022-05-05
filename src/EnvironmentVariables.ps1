<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩
#>




function Show-ModuleVariablesInfo{

    Write-Host "                 𝙐𝙎𝙀𝙁𝙐𝙇 𝙀𝙉𝙑𝙄𝙍𝙊𝙉𝙈𝙀𝙉𝙏 𝙑𝘼𝙍𝙄𝘼𝘽𝙇𝙀𝙎              " -Foreground DarkCyan
    $ModDev = Get-ModulesDevPath
    $Modules = gci -Path $ModDev -Directory -Filter 'PowerShell.Module.*'
    ForEach($m in $Modules){
        $name = $m.Name
        $s = $name.split('.')
        $EnvVarName = 'Mod' + $s[2]
        $fp = $m.Fullname
        
        Write-Host "$EnvVarName `t==>`t" -NoNewLine -ForegroundColor Magenta
        Write-Host "`$env:$EnvVarName " -ForegroundColor DarkRed

    }
    gci -Path "ENV:\" | Where Value -match 'PowerShell.Module.*'
}



function Set-ModuleVariables {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $false)]
        [switch]$Test
    )  

    $ModDev = Get-ModulesDevPath
    $Modules = gci -Path $ModDev -Directory -Filter 'PowerShell.Module.*'
    ForEach($m in $Modules){
        $name = $m.Name
        $s = $name.split('.')
        $EnvVarName = 'Mod' + $s[2]
        $fp = $m.Fullname
        
        
        if($Test){
            Write-Host -n -f DarkRed "[Test] "
            Write-Host -f DarkYellow "Set-EnvironmentVariable -Name `"$EnvVarName`" -Value `"$fp`" -Scope `"User`""
        }else{
            Write-Host -n -f DarkRed "[$EnvVarName] "
            Write-Host -f DarkGreen "Set-EnvironmentVariable `"$EnvVarName`""
            Set-EnvironmentVariable -Name "$EnvVarName" -Value "$fp" -Scope 'User'
            Set-EnvironmentVariable -Name "$EnvVarName" -Value "$fp" -Scope 'Session'
        }
        
    }
}

function Set-ModuleGotoFunctions {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$Run,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )  

    if($Force){
        $Null = Remove-Item -Path $Path -Force -Recurse -ErrorAction Ignore
    }
    if(Test-Path -Path $Path -PathType Leaf){
        throw "File $Path already exists (-Force maybe)"
    }

    Set-Content -Path $Path -Value "# Modules GOTO Functions`n`n"

    $ModDev = Get-ModulesDevPath
    $Modules = gci -Path $ModDev -Directory -Filter 'PowerShell.Module.*'
    ForEach($m in $Modules){
        $name = $m.Name
        $s = $name.split('.')
        $EnvVarName = 'Mod' + $s[2]
        $fp = $m.Fullname
        Write-Host -n -f DarkCyan "[$name] "

        $FunctionCode = "function Push-$EnvVarName {  Write-Host `"Pushd => `$env:$EnvVarName`" ; Push-location `$env:$EnvVarName; }"
        $AliasCode = "New-Alias $EnvVarName -Value `"Push-$EnvVarName`" -Description `"Push-location `$env:$EnvVarName`" -Scope Global -Force -ErrorAction Stop -Option ReadOnly,AllScope"

        Add-Content -Path $Path -Value $FunctionCode
    }
    if($Run){
        Write-Host -n -f DarkYellow "[$name] "
        Write-Host -n -f DarkRed "Running new file $Path"
        . "$Path"
        Write-Host -n -f DarkGreen " [OK] "
    }
}


function Set-ModuleGotoAliases {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$Run,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )  

    if($Force){
        $Null = Remove-Item -Path $Path -Force -Recurse -ErrorAction Ignore
    }
    if(Test-Path -Path $Path -PathType Leaf){
        throw "File $Path already exists (-Force maybe)"
    }

    Set-Content -Path $Path -Value "# Modules GOTO Functions`n`n"

    $ModDev = Get-ModulesDevPath
    $Modules = gci -Path $ModDev -Directory -Filter 'PowerShell.Module.*'
    ForEach($m in $Modules){
        $name = $m.Name
        $s = $name.split('.')
        $EnvVarName = 'Mod' + $s[2]
        $fp = $m.Fullname
        Write-Host -n -f DarkCyan "[$name] "

        $AliasCode = "New-Alias $EnvVarName -Value `"Push-$EnvVarName`" -Description `"Push-location `$env:$EnvVarName`" -Scope Global -Force -ErrorAction Stop -Option ReadOnly,AllScope"

        Add-Content -Path $Path -Value $AliasCode
    }
    if($Run){
        Write-Host -n -f DarkYellow "[$name] "
        Write-Host -n -f DarkRed "Running new file $Path"
        . "$Path"
        Write-Host -n -f DarkGreen " [OK] "
    }
}

