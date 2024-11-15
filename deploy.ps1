<#

.SYNOPSIS
his a BICEP template based on Daniel Mauser's lab which can be found here - https://github.com/dmauser/azure-virtualwan/blob/main/inter-region-nvabgp T 

.NOTES
Make sure you have the correct versions of PowerShell 7.x installed, by running this command:

    $PSVersionTable.PSVersion

If the AZ PowerShell module is not installed, then you can run these PowerShell commands in an eleveated shell:

    Set-ExecutionPolicy -Scope "CurrentUser" -ExecutionPolicy "Bypass" -ErrorAction SilentlyContinue -Force
    Find-PackageProvider -Name "Nuget" -Force -Verbose | Install-PackageProvider -Scope "AllUsers" -Force
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -PackageManagementProvider "Nuget"
    Install-Module -Name "PowerShellGet" -Repository "PSGallery" -Scope "AllUsers" -SkipPublisherCheck -Force -AllowClobber
    Install-Module -Name "Az" -Repository "PSGallery" -Scope "AllUsers" -SkipPublisherCheck -Force -AllowClobber

    https://docs.microsoft.com/powershell/azure/install-az-ps
#>

$powerShellVersion = $PSVersionTable.PSVersion
if ($powerShellVersion.Major -lt 7)
{
    Write-Host -BackgroundColor Red -ForegroundColor White "PowerShell needs to be version 7.x. or higher"
    Return
}

$azModuleVersion = Get-InstalledModule -Name Az -MinimumVersion 12.0
if ($null -eq $azModuleVersion)
{
    Write-Host -BackgroundColor Red -ForegroundColor White "PowerShell AZ module needs to be version 12.0 or higher"
    Return
}

# Login to the user's default Azure AD Tenant
Write-Host "Login to Entra ID and select deployment Subscription"
Connect-AzAccount
Write-Host

$errorActionPreference = 'Stop'
$dateTime = Get-Date -f 'yyyy-MM-dd-HHmmss'
$deploymentName = "vwan-bgp-nva-" + $dateTime

Write-Host "Start BICEP Deployment."
New-AzSubscriptionDeployment -Name $deploymentName -Location "uksouth" -TemplateFile ".\main.bicep" -ErrorAction $errorActionPreference
