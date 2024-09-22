#Requires -RunAsAdministrator

Clear-Host

# Double-check installation of Github
winget install Git.Git --source winget --exact --accept-source-agreements

Install-Module -Name PackageManagement, PowershellGet

# Install oh-my-posh
winget install jazzdelightsme.WingetPathUpdater --source winget --exact --accept-source-agreements
winget install JanDeDobbeleer.OhMyPosh --source winget --exact --accept-source-agreements

# Install JetBrainsMono Nerd Font font
oh-my-posh font install JetBrainsMono

# Apply a PowerShell prompt theme
if (-not (Test-Path -Path $PROFILE))
{
	Set-Content -Path $PROFILE -Value 'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin.json" | Invoke-Expression' -Force
}
else
{
	Add-Content -Path $PROFILE -Value 'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin.json" | Invoke-Expression' -Force
}

# Install Terminal-Icons
# https://github.com/devblackops/Terminal-Icons
Write-Verbose -Message "Installing Terminal-Icons" -Verbose
Install-Module -Name Terminal-Icons -Force
Add-Content -Path $PROFILE -Value "`nImport-Module -Name Terminal-Icons" -Force

Invoke-Item -Path $PROFILE

$settings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

try
{
	$Terminal = Get-Content -Path $settings -Encoding UTF8 -Force | ConvertFrom-Json
}
catch [System.Exception]
{
	Write-Warning -Message "Terminal: settings.json is not valid!"
	Invoke-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

	exit
}

# Set JetBrainsMono Nerd Font as a default font
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

if ((New-Object -TypeName System.Drawing.Text.InstalledFontCollection).Families.Name -contains "JetBrainsMono NF")
{
	if ($Terminal.profiles.defaults.font.face)
	{
		$Terminal.profiles.defaults.font.face = "JetBrainsMono Nerd Font"
	}
	else
	{
		$Terminal.profiles.defaults | Add-Member -Name font -MemberType NoteProperty -Value @{face = "JetBrainsMono Nerd Font"} -Force
	}
}

if ($Terminal.confirmCloseAllTabs)
{
	$Terminal.confirmCloseAllTabs = $false
}
else
{
	$Terminal | Add-Member -Name confirmCloseAllTabs -MemberType NoteProperty -Value $false -Force
}

# Use AtlasEngine
if ($Terminal.profiles.defaults.useAtlasEngine)
{
	$Terminal.profiles.defaults.useAtlasEngine = $true
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name useAtlasEngine -MemberType NoteProperty -Value $true -Force
}

# Use acrylic
if ($Terminal.profiles.defaults.useAcrylic)
{
	$Terminal.profiles.defaults.useAcrylic = $true
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name useAcrylic -MemberType NoteProperty -Value $true -Force
}

# Acrylic opacity
if ($Terminal.profiles.defaults.opacity)
{
	$Terminal.profiles.defaults.opacity = 65
}
else
{
	$Terminal.profiles.defaults | Add-Member -Name opacity -MemberType NoteProperty -Value 65 -Force
}

# Show acrylic in tab row
if ($Terminal.useAcrylicInTabRow)
{
	$Terminal.useAcrylicInTabRow = $true
}
else
{
	$Terminal | Add-Member -Name useAcrylicInTabRow -MemberType NoteProperty -Value $true -Force
}

# Remove trailing white-space in rectangular selection
if ($Terminal.trimBlockSelection)
{
	$Terminal.trimBlockSelection = $true
}
else
{
	$Terminal | Add-Member -Name trimBlockSelection -MemberType NoteProperty -Value $true -Force
}

# Create new tabs in the most recently used window on this desktop. If there's not an existing window on this virtual desktop, then create a new terminal window
if ($Terminal.windowingBehavior)
{
	$Terminal.windowingBehavior = "useExisting"
}
else
{
	$Terminal | Add-Member -Name windowingBehavior -MemberType NoteProperty -Value "useExisting" -Force
}

# Re-save in the UTF-8 without BOM encoding due to JSON must not has the BOM: https://datatracker.ietf.org/doc/html/rfc8259#section-8.1
if ($Host.Version.Major -ne 5)
{
	ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $settings -Encoding utf8nobom -Force
}
else
{
	ConvertTo-Json -InputObject $Terminal -Depth 4 | Set-Content -Path $settings -Encoding UTF8 -Force
	Set-Content -Path $settings -Value (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false).GetBytes($(Get-Content -Path $settings -Raw)) -Encoding Byte -Force
}

. $PROFILE
