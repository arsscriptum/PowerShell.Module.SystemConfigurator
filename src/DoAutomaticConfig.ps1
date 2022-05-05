<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩
#>




function Invoke-AutomaticConfig{

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-WellKnownPaths"
    Set-WellKnownPaths

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "New-PowerShellDirectoryStructure"
    New-PowerShellDirectoryStructure

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-RegistryOrganizationHKCU"
    Set-RegistryOrganizationHKCU

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellModuleBuilder"
    Save-PowerShellModuleBuilder

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellDevelopmentModules"
    Save-PowerShellDevelopmentModules

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-ModulesEnvironmwntVariables"
    Set-ModulesEnvironmwntVariables
    Show-ModuleVariablesInfo

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellDevelopmentModules"
    Save-PowerShellProfile

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-RefreshEnvironmentVariables"
    Invoke-RefreshEnvironmentVariables

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleShimInit"
    Invoke-ModuleShimInit

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleShimMenuSetup"
    Invoke-ModuleShimMenuSetup

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleDownloaderSetup"
    Invoke-ModuleDownloaderSetup

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-RefreshEnvironmentVariables"
    Invoke-RefreshEnvironmentVariables
}

