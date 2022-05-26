function global:Set-AWSEnvHelper {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        $AWSProfile,

        [Parameter(Mandatory=$False)]
        $AWSRegion
    )

    if ($($(Get-Module -ListAvailable -Name AWSPowerShell).Name | Select-String -Pattern "AWSPowerShell").Matches.Success) {
        Write-Host "The AWSPowerShell Module is already loaded. Continuing..."
    }
    else {
        Import-Module AWSPowerShell
    }

    # Ensure System Path and $env:Path can find aws.exe, if it is installed
    $AWSCli64 = "$env:ProgramFiles\Amazon\AWSCLI"
    $AWSCli32 = "${env:ProgramFiles(x86)}\Amazon\AWSCLI"
    if (Test-Path $AWSCli64) {
        $AWSCliPathToAdd = $AWSCli64
    }
    elseif (Test-Path $AWSCli32) {
        $AWSCliPathToAdd = $AWSCli32
    }
    else {
        Write-Host "Unable to find aws.exe directory. It is probably not installed. Continuing..."
    }

    if ($AWSCliPathToAdd) {
        # Update $env:Path that is specific to the current PowerShell Session
        $envPathArray = $env:Path -split ";"
        if ($envPathArray -notcontains $AWSCliPathToAdd) {
            if ($env:Path[-1] -eq ";") {
                $env:Path = "$env:Path$AWSCliPathToAdd"
            }
            else {
                $env:Path = "$env:Path;$AWSCliPathToAdd"
            }
        }
        
        # Make a Permanent Change to the System PATH if necessary
        $OldSystemPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
        $OldSystemPathArray = $OldSystemPath -split ";"
        if ($OldSystemPathArray -contains $AWSCliPathToAdd) {
            if ($OldSystemPath[-1] -eq ";") {
                $UpdatedSystemPath = "$OldSystemPath$AWSCliPathToAdd"
            }
            else {
                $UpdatedSystemPath = "$OldSystemPath;$AWSCliPathToAdd"
            }
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $UpdatedSystemPath
        }
    }

    # Validate $AWSIAMProfile parameter...
    $ValidAWSIAMProfiles = Get-AWSCredentials -ListProfiles
    if ($AWSProfile -eq $null) {
        Write-Host "Available AWS IAM Profiles under this Windows account are as follows:"
        $ValidAWSIAMProfiles
        $AWSProfile = Read-Host -Prompt "Please enter the AWS IAM Profile you would like to use in this PowerShell session."
    }
    if ($AWSProfile -ne $null) {
        if ($ValidAWSIAMProfiles -notcontains $AWSProfile) {
            Write-Host "$AWSProfile is NOT a valid AWS IAM Profile available to PowerShell under the current Windows user account. Available AWS IAM Profiles are as follows:"
            $ValidAWSIAMProfiles
            $CreateNewAWSIAMProfileSwtich = Read-Host -Prompt "Would you like to create a new AWS IAM Profile under this Windows account? [Yes/No]"
            if ($CreateNewAWSIAMProfileSwtich -eq "Yes" -or $CreateNewAWSIAMProfileSwtich -eq "y") {
                $AWSAccessKey = Read-Host -Prompt "Please enter the AccessKey for AWS IAM user $AWSProfile"
                $AWSSecretKey = Read-Host -Prompt "Please enter the SecretKey for AWS IAM user $AWSProfile"
                Set-AWSCredentials -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -StoreAs $AWSProfile
            }
            if ($CreateNewAWSIAMProfileSwtich -eq "No" -or $CreateNewAWSIAMProfileSwtich -eq "n") {
                $AWSProfile = Read-Host -Prompt "Please enter the AWS IAM Profile you would like to use in this PowerShell session."
                if ($ValidAWSIAMProfiles -notcontains $AWSProfile) {
                    Write-Host "$AWSIAMProfile is NOT a valid AWS IAM Profile available to PowerShell under the current Windows user account. Halting!"
                    $global:FunctionResult = "1"
                    return
                }
            }
        }
    }
    
    # Validate $AWSRegion parameter...
    $ValidAWSRegions = @("eu-central-1","ap-northeast-1","ap-northeast-2","ap-south-1","sa-east-1","ap-southeast-2",`
    "ap-southeast-1","us-east-1","us-east-2","us-west-2","us-west-1","eu-west-1")
    if ($AWSRegion -eq $null) {
        Write-Host "You must set a default AWS Region for this PowerShell session. Valid AWS Regions are as follows:"
        $ValidAWSRegions
        $AWSRegion = Read-Host -Prompt "Please enter the default AWS Region for this PowerShell session"
    }
    if ($AWSRegion -ne $null) {
        if ($ValidAWSRegions -notcontains $AWSRegion) {
            Write-Host "$AWSRegion is not a valid AWS Region. Valid AWS Regions are as follows:"
            $ValidAWSRegions
            $AWSRegion = Read-Host -Prompt "Please enter the default AWS Region for this PowerShell session"
            if ($ValidAWSRegions -notcontains $AWSRegion) {
                Write-Host "$AWSRegion is not a valid AWS Region. Halting!"
                $global:FunctionResult = "1"
                return
            }
        }
    }

    # Set the AWS IAM Profile and Default AWS Region
    $global:SetAWSEnv = "Set-AWSCredentials -ProfileName $AWSProfile; Set-DefaultAWSRegion -Region $AWSRegion"
    $global:StoredAWSRegion = $AWSRegion

    Write-Host "Use the following command to complete setting the AWS Environment in your current scope:"
    Write-Host "Invoke-Expression `$global:SetAWSEnv"

    $global:FunctionResult = "0"
}



# SIG # Begin signature block
# MIIMLAYJKoZIhvcNAQcCoIIMHTCCDBkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeip23xI3khaC32AfcQj7emq8
# ITagggmhMIID/jCCAuagAwIBAgITawAAAAQpgJFit9ZYVQAAAAAABDANBgkqhkiG
# 9w0BAQsFADAwMQwwCgYDVQQGEwNMQUIxDTALBgNVBAoTBFpFUk8xETAPBgNVBAMT
# CFplcm9EQzAxMB4XDTE1MDkwOTA5NTAyNFoXDTE3MDkwOTEwMDAyNFowPTETMBEG
# CgmSJomT8ixkARkWA0xBQjEUMBIGCgmSJomT8ixkARkWBFpFUk8xEDAOBgNVBAMT
# B1plcm9TQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCmRIzy6nwK
# uqvhoz297kYdDXs2Wom5QCxzN9KiqAW0VaVTo1eW1ZbwZo13Qxe+6qsIJV2uUuu/
# 3jNG1YRGrZSHuwheau17K9C/RZsuzKu93O02d7zv2mfBfGMJaJx8EM4EQ8rfn9E+
# yzLsh65bWmLlbH5OVA0943qNAAJKwrgY9cpfDhOWiYLirAnMgzhQd3+DGl7X79aJ
# h7GdVJQ/qEZ6j0/9bTc7ubvLMcJhJCnBZaFyXmoGfoOO6HW1GcuEUwIq67hT1rI3
# oPx6GtFfhCqyevYtFJ0Typ40Ng7U73F2hQfsW+VPnbRJI4wSgigCHFaaw38bG4MH
# Nr0yJDM0G8XhAgMBAAGjggECMIH/MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQW
# BBQ4uUFq5iV2t7PneWtOJALUX3gTcTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMA
# QTAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBR2
# lbqmEvZFA0XsBkGBBXi2Cvs4TTAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vcGtp
# L2NlcnRkYXRhL1plcm9EQzAxLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUH
# MAKGIGh0dHA6Ly9wa2kvY2VydGRhdGEvWmVyb0RDMDEuY3J0MA0GCSqGSIb3DQEB
# CwUAA4IBAQAUFYmOmjvbp3goa3y95eKMDVxA6xdwhf6GrIZoAg0LM+9f8zQOhEK9
# I7n1WbUocOVAoP7OnZZKB+Cx6y6Ek5Q8PeezoWm5oPg9XUniy5bFPyl0CqSaNWUZ
# /zC1BE4HBFF55YM0724nBtNYUMJ93oW/UxsWL701c3ZuyxBhrxtlk9TYIttyuGJI
# JtbuFlco7veXEPfHibzE+JYc1MoGF/whz6l7bC8XbgyDprU1JS538gbgPBir4RPw
# dFydubWuhaVzRlU3wedYMsZ4iejV2xsf8MHF/EHyc/Ft0UnvcxBqD0sQQVkOS82X
# +IByWP0uDQ2zOA1L032uFHHA65Bt32w8MIIFmzCCBIOgAwIBAgITWAAAADw2o858
# ZSLnRQAAAAAAPDANBgkqhkiG9w0BAQsFADA9MRMwEQYKCZImiZPyLGQBGRYDTEFC
# MRQwEgYKCZImiZPyLGQBGRYEWkVSTzEQMA4GA1UEAxMHWmVyb1NDQTAeFw0xNTEw
# MjcxMzM1MDFaFw0xNzA5MDkxMDAwMjRaMD4xCzAJBgNVBAYTAlVTMQswCQYDVQQI
# EwJWQTEPMA0GA1UEBxMGTWNMZWFuMREwDwYDVQQDEwhaZXJvQ29kZTCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ8LM3f3308MLwBHi99dvOQqGsLeC11p
# usrqMgmEgv9FHsYv+IIrW/2/QyBXVbAaQAt96Tod/CtHsz77L3F0SLuQjIFNb522
# sSPAfDoDpsrUnZYVB/PTGNDsAs1SZhI1kTKIjf5xShrWxo0EbDG5+pnu5QHu+EY6
# irn6C1FHhOilCcwInmNt78Wbm3UcXtoxjeUl+HlrAOxG130MmZYWNvJ71jfsb6lS
# FFE6VXqJ6/V78LIoEg5lWkuNc+XpbYk47Zog+pYvJf7zOric5VpnKMK8EdJj6Dze
# 4tJ51tDoo7pYDEUJMfFMwNOO1Ij4nL7WAz6bO59suqf5cxQGd5KDJ1ECAwEAAaOC
# ApEwggKNMA4GA1UdDwEB/wQEAwIHgDA9BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3
# FQiDuPQ/hJvyeYPxjziDsLcyhtHNeIEnofPMH4/ZVQIBZAIBBTAdBgNVHQ4EFgQU
# a5b4DOy+EUyy2ILzpUFMmuyew40wHwYDVR0jBBgwFoAUOLlBauYldrez53lrTiQC
# 1F94E3EwgeMGA1UdHwSB2zCB2DCB1aCB0qCBz4aBq2xkYXA6Ly8vQ049WmVyb1ND
# QSxDTj1aZXJvU0NBLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXplcm8sREM9bGFiP2NlcnRp
# ZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmli
# dXRpb25Qb2ludIYfaHR0cDovL3BraS9jZXJ0ZGF0YS9aZXJvU0NBLmNybDCB4wYI
# KwYBBQUHAQEEgdYwgdMwgaMGCCsGAQUFBzAChoGWbGRhcDovLy9DTj1aZXJvU0NB
# LENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxD
# Tj1Db25maWd1cmF0aW9uLERDPXplcm8sREM9bGFiP2NBQ2VydGlmaWNhdGU/YmFz
# ZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MCsGCCsGAQUFBzAC
# hh9odHRwOi8vcGtpL2NlcnRkYXRhL1plcm9TQ0EuY3J0MBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwDQYJKoZIhvcNAQEL
# BQADggEBACbc1NDl3NTMuqFwTFd8NHHCsSudkVhuroySobzUaFJN2XHbdDkzquFF
# 6f7KFWjqR3VN7RAi8arW8zESCKovPolltpp3Qu58v59qZLhbXnQmgelpA620bP75
# zv8xVxB9/xmmpOHNkM6qsye4IJur/JwhoHLGqCRwU2hxP1pu62NUK2vd/Ibm8c6w
# PZoB0BcC7SETNB8x2uKzJ2MyAIuyN0Uy/mGDeLyz9cSboKoG6aQibnjCnGAVOVn6
# J7bvYWJsGu7HukMoTAIqC6oMGerNakhOCgrhU7m+cERPkTcADVH/PWhy+FJWd2px
# ViKcyzWQSyX93PcOj2SsHvi7vEAfCGcxggH1MIIB8QIBATBUMD0xEzARBgoJkiaJ
# k/IsZAEZFgNMQUIxFDASBgoJkiaJk/IsZAEZFgRaRVJPMRAwDgYDVQQDEwdaZXJv
# U0NBAhNYAAAAPDajznxlIudFAAAAAAA8MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSCXP6OfaGf
# GdT1cxam+eS3UONK9jANBgkqhkiG9w0BAQEFAASCAQAyCmFVK21kpgDFLuz6DJxA
# CFWR03xr9oXeU7gUrE/n/RsI9iam8RNevGtL9HcBE+cg6G88D2HrRXjsiPnsk5Sc
# rwXA2r0dChapbsIcQYDTfuOd6y3k6Eg/QIXR/VSOLtyhkrzupZc2d3AGix5gU35c
# wDv5yA54V8ennmwd04eRv686lkuJuV0Y+qtCvy76VPq8kVg01ibxpo66kuc4Brpt
# WtRWy3nGnnOlDZ7FxyKViN640cbRDW6/WNdsJXIBKo6s6efdy36ail21W15jXh2x
# SwuFWiFtx+j5Qs/nraNBDCnWHQqUvhGaNDYBD1TmLyggF/Kbw+fniTBHGUcGtTOk
# SIG # End signature block
