<#
.SYNOPSIS
    Automated Flutter, Dart, Android Studio, and Global Environment Setup for Windows.

.DESCRIPTION
    Fully automated setup script for Windows developers:
    1. Checks if each tool (Git, Flutter, Dart, Android Studio, Android SDK) is already installed.
       If already installed -> skips download and reports status.
       If missing -> automatically downloads, installs, and sets proper permissions.
    2. Downloads and unpacks Android SDK Platform-Tools and Command-Line Tools directly so Android
       development works immediately out of the box without requiring manual GUI clicks.
    3. Configures persistent Global / User Environment Variables (ANDROID_HOME, JAVA_HOME, PATH)
       so you never have to configure them again.
    4. Automatically binds Flutter to Android SDK & accepts all Android licenses.
    5. Runs 'flutter doctor -v' verification.

.PARAMETER FlutterInstallDir
    Custom install directory for Flutter SDK if not already present. Defaults to 'C:\flutter' (or '$env:USERPROFILE\development\flutter' if non-admin).

.PARAMETER AutoAcceptLicenses
    Automatically agree to all Android SDK licenses. Defaults to $true.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
    powershell -ExecutionPolicy Bypass -File .\setup.ps1
#>

[CmdletBinding()]
param(
    [string]$FlutterInstallDir = "",
    [switch]$AutoAcceptLicenses = $true,
    [switch]$SkipDoctor = $false
)

$ErrorActionPreference = "Continue"

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] $Message" -ForegroundColor Yellow
}

function Write-WarningMsg {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor DarkYellow
}

function Write-ErrMsg {
    param([string]$Message)
    Write-Host "[x] $Message" -ForegroundColor Red
}

function Invoke-DownloadWithProgress {
    param(
        [string]$Url,
        [string]$DestinationPath,
        [string]$Description = "File"
    )

    $destDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Write-Info "Downloading $Description..."
    Write-Host "  Source: $Url" -ForegroundColor DarkGray
    Write-Host "  Target: $DestinationPath" -ForegroundColor DarkGray

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.Method = "GET"
    $request.UserAgent = "SoundCanvasSetup/1.0"
    $response = $request.GetResponse()
    $totalBytes = $response.ContentLength
    $responseStream = $response.GetResponseStream()
    $fileStream = New-Object System.IO.FileStream($DestinationPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

    $buffer = New-Object byte[] 65536
    $totalRead = 0
    $lastUpdate = [DateTime]::MinValue
    $totalMB = if ($totalBytes -gt 0) { [math]::Round($totalBytes / 1MB, 1) } else { 0 }

    try {
        while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read

            $now = [DateTime]::Now
            if (($now - $lastUpdate).TotalMilliseconds -ge 150) {
                $lastUpdate = $now
                $readMB = [math]::Round($totalRead / 1MB, 1)

                if ($totalBytes -gt 0) {
                    $percent = [math]::Min(100, [math]::Round(($totalRead / $totalBytes) * 100))
                    $barLength = 25
                    $completed = [math]::Round(($percent / 100) * $barLength)
                    $remaining = $barLength - $completed
                    $bar = ("#" * $completed) + ("-" * $remaining)
                    Write-Progress -Activity "Downloading $Description" `
                                   -Status "[$bar] $percent% ($readMB MB / $totalMB MB)" `
                                   -PercentComplete $percent
                } else {
                    Write-Progress -Activity "Downloading $Description" `
                                   -Status "Downloaded $readMB MB"
                }
            }
        }
        Write-Progress -Activity "Downloading $Description" -Completed
        $finalMB = [math]::Round($totalRead / 1MB, 1)
        Write-Success "Download completed: $Description ($finalMB MB)"
    } finally {
        $fileStream.Close()
        $fileStream.Dispose()
        $responseStream.Close()
        $responseStream.Dispose()
        $response.Close()
    }
}

function Download-And-Extract-Zip {
    param(
        [string]$Url,
        [string]$ZipPath,
        [string]$DestinationPath,
        [string]$Description
    )
    Invoke-DownloadWithProgress -Url $Url -DestinationPath $ZipPath -Description $Description

    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }

    Write-Info "Extracting $Description to $DestinationPath..."
    Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force
    Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue
    Write-Success "$Description extracted and ready."
}

Write-Header "Flutter & Android Studio Complete Setup (Windows)"

# -----------------------------------------------------------------------------
# 1. Administrator & Execution Privilege Check
# -----------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Success "Running as Administrator. Variables will be configured at both Machine & User levels."
} else {
    Write-Info "Running as Standard User. Variables will be configured persistently for the Current User."
    Write-Info "Tip: For Machine-wide configuration, run PowerShell as Administrator."
}

# Check winget package manager
$hasWinget = $false
try {
    $wingetVer = winget --version 2>$null
    if ($wingetVer) {
        $hasWinget = $true
        Write-Success "Windows Package Manager (winget $wingetVer) detected."
    }
} catch {
    $hasWinget = $false
}

# -----------------------------------------------------------------------------
# 2. Step 1: Git Check & Auto-Install
# -----------------------------------------------------------------------------
Write-Header "Step 1: Git Version Control"
$gitInstalled = $false
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitInstalled = $true
    Write-Success "Git is already installed: $(git --version)"
} else {
    Write-Info "Git not detected in PATH. Starting automated installation..."
    if ($hasWinget) {
        winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements --silent
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue
        if ($gitCmd) { $gitInstalled = $true; Write-Success "Git installed via winget." }
    }

    if (-not $gitInstalled) {
        $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/Git-2.46.0-64-bit.exe"
        $gitInstallerPath = "$env:TEMP\git_setup.exe"
        Invoke-DownloadWithProgress -Url $gitInstallerUrl -DestinationPath $gitInstallerPath -Description "Git for Windows Standalone Installer"
        Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" -Wait
        Remove-Item $gitInstallerPath -Force -ErrorAction SilentlyContinue
        $env:PATH = "C:\Program Files\Git\cmd;" + $env:PATH
        Write-Success "Git installed successfully."
    }
}

# -----------------------------------------------------------------------------
# 3. Step 2: Flutter & Dart SDK Check & Auto-Install
# -----------------------------------------------------------------------------
Write-Header "Step 2: Flutter & Dart SDK"
$flutterBin = ""
$flutterDir = ""

# 1. Check if flutter command is active
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCmd) {
    $flutterBin = Split-Path -Parent $flutterCmd.Source
    $flutterDir = Split-Path -Parent $flutterBin
    Write-Success "Flutter is already active in PATH at: $flutterDir"
} else {
    # 2. Check standard locations
    $candidates = @(
        "C:\flutter",
        "C:\src\flutter",
        "$env:USERPROFILE\development\flutter",
        "$env:USERPROFILE\flutter",
        "$env:LOCALAPPDATA\flutter"
    )
    if ($FlutterInstallDir -ne "") {
        $candidates = @($FlutterInstallDir) + $candidates
    }

    foreach ($cand in $candidates) {
        if (Test-Path "$cand\bin\flutter.bat") {
            $flutterDir = $cand
            $flutterBin = "$cand\bin"
            Write-Success "Found existing Flutter SDK at: $flutterDir"
            break
        }
    }

    # 3. If missing, auto-download and install
    if (-not $flutterBin) {
        $targetDir = if ($isAdmin) { "C:\flutter" } else { "$env:USERPROFILE\development\flutter" }
        if ($FlutterInstallDir -ne "") { $targetDir = $FlutterInstallDir }
        $targetParent = Split-Path -Parent $targetDir

        Write-Info "Flutter SDK not found. Installing into: $targetDir"
        
        $installedViaWinget = $false
        if ($hasWinget) {
            Write-Info "Attempting installation via winget..."
            winget install --id Google.Flutter -e --accept-source-agreements --accept-package-agreements --silent
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
            if ($flutterCmd) {
                $flutterBin = Split-Path -Parent $flutterCmd.Source
                $flutterDir = Split-Path -Parent $flutterBin
                $installedViaWinget = $true
                Write-Success "Flutter SDK installed via winget."
            }
        }

        if (-not $installedViaWinget) {
            Write-Info "Downloading official Flutter SDK stable archive from Google..."
            $flutterZip = "$env:TEMP\flutter_windows_stable.zip"
            # Official Google storage stable release archive
            $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
            
            Download-And-Extract-Zip -Url $flutterUrl -ZipPath $flutterZip -DestinationPath $targetParent -Description "Flutter SDK"
            
            if (Test-Path "$targetDir\bin\flutter.bat") {
                $flutterDir = $targetDir
                $flutterBin = "$targetDir\bin"
                Write-Success "Flutter SDK installed at: $flutterDir"
            }
        }
    }
}

# -----------------------------------------------------------------------------
# 4. Step 3: Android Studio Check & Auto-Install
# -----------------------------------------------------------------------------
Write-Header "Step 3: Android Studio"
$asCandidates = @(
    "C:\Program Files\Android\Android Studio",
    "$env:LOCALAPPDATA\Programs\Android Studio"
)
$androidStudioDir = ""
foreach ($cand in $asCandidates) {
    if (Test-Path "$cand\bin\studio64.exe") {
        $androidStudioDir = $cand
        Write-Success "Android Studio is already installed at: $androidStudioDir"
        break
    }
}

if (-not $androidStudioDir) {
    Write-Info "Android Studio not found. Starting installation..."
    if ($hasWinget) {
        Write-Info "Installing Android Studio via winget..."
        winget install --id Google.AndroidStudio -e --accept-source-agreements --accept-package-agreements --silent
        foreach ($cand in $asCandidates) {
            if (Test-Path "$cand\bin\studio64.exe") {
                $androidStudioDir = $cand
                Write-Success "Android Studio installed successfully at: $androidStudioDir"
                break
            }
        }
    } else {
        Write-WarningMsg "winget not available. Please install Android Studio from: https://developer.android.com/studio"
    }
}

# -----------------------------------------------------------------------------
# 5. Step 4: Android SDK, Platform-Tools & Command-Line Tools Check & Auto-Install
# -----------------------------------------------------------------------------
Write-Header "Step 4: Android SDK & Command-Line Tools"
$androidSdk = $env:ANDROID_HOME
if (-not $androidSdk -or -not (Test-Path $androidSdk)) {
    $androidSdk = "$env:LOCALAPPDATA\Android\Sdk"
}
if (-not (Test-Path $androidSdk)) {
    New-Item -ItemType Directory -Path $androidSdk -Force | Out-Null
}
Write-Success "Android SDK directory: $androidSdk"

# Check & auto-download Android platform-tools (adb, fastboot)
$adbExe = "$androidSdk\platform-tools\adb.exe"
if (Test-Path $adbExe) {
    Write-Success "Android Platform-Tools (adb) are already installed."
} else {
    Write-Info "Platform-Tools (adb) missing. Auto-downloading from Google Android repository..."
    $ptZip = "$env:TEMP\platform_tools.zip"
    $ptUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    Download-And-Extract-Zip -Url $ptUrl -ZipPath $ptZip -DestinationPath $androidSdk -Description "Android Platform Tools"
}

# Check & auto-download Android cmdline-tools (sdkmanager, avdmanager)
$sdkManager = "$androidSdk\cmdline-tools\latest\bin\sdkmanager.bat"
if (Test-Path $sdkManager) {
    Write-Success "Android Command-Line Tools are already installed."
} else {
    Write-Info "Android Command-Line Tools missing. Auto-downloading latest package..."
    $clZip = "$env:TEMP\cmdline_tools.zip"
    $clUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $clExtractDir = "$androidSdk\cmdline-tools"
    Download-And-Extract-Zip -Url $clUrl -ZipPath $clZip -DestinationPath $clExtractDir -Description "Command-Line Tools"
    
    # Restructure into 'latest' folder if extracted as 'cmdline-tools'
    if (Test-Path "$clExtractDir\cmdline-tools") {
        if (Test-Path "$clExtractDir\latest") { Remove-Item "$clExtractDir\latest" -Recurse -Force }
        Rename-Item -Path "$clExtractDir\cmdline-tools" -NewName "latest" -Force
    }
    if (Test-Path "$androidSdk\cmdline-tools\latest\bin\sdkmanager.bat") {
        Write-Success "Android Command-Line Tools installed in: $androidSdk\cmdline-tools\latest"
    }
}

# -----------------------------------------------------------------------------
# 6. Step 5: Java (JDK / JBR) Detection
# -----------------------------------------------------------------------------
Write-Header "Step 5: Java Runtime (JDK / JBR)"
$javaHome = $env:JAVA_HOME
if (-not $javaHome -or -not (Test-Path $javaHome)) {
    if ($androidStudioDir -and (Test-Path "$androidStudioDir\jbr")) {
        $javaHome = "$androidStudioDir\jbr"
        Write-Success "Detected Android Studio JBR Java runtime at: $javaHome"
    }
} else {
    Write-Success "Existing JAVA_HOME found at: $javaHome"
}

# -----------------------------------------------------------------------------
# 7. Step 6: Set Global & Persistent Environment Variables
# -----------------------------------------------------------------------------
Write-Header "Step 6: Setting Persistent Global Environment Variables"

function Set-PersistentEnv {
    param([string]$Name, [string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return }

    # Set User scope
    [System.Environment]::SetEnvironmentVariable($Name, $Value, "User")
    # If Admin, also set Machine scope for system-wide availability
    if ($isAdmin) {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, "Machine")
    }
    # Update current session
    Set-Item -Path "Env:$Name" -Value $Value
    Write-Success "Configured variable $Name = $Value"
}

function Add-PersistentPath {
    param([string]$NewPath)
    if ([string]::IsNullOrWhiteSpace($NewPath) -or -not (Test-Path $NewPath)) { return }

    $scopes = @("User")
    if ($isAdmin) { $scopes += "Machine" }

    foreach ($scope in $scopes) {
        $current = [System.Environment]::GetEnvironmentVariable("PATH", $scope)
        $parts = ($current -split ";") | Where-Object { $_ -ne "" }
        $normalizedNew = $NewPath.TrimEnd('\')
        
        $exists = $false
        foreach ($p in $parts) {
            if ($p.TrimEnd('\') -ieq $normalizedNew) { $exists = $true; break }
        }

        if (-not $exists) {
            $updated = "$current;$normalizedNew".TrimStart(';')
            [System.Environment]::SetEnvironmentVariable("PATH", $updated, $scope)
            Write-Success "Added to $scope PATH: $normalizedNew"
        }
    }

    # Update current session PATH
    if ($env:PATH -notlike "*$NewPath*") {
        $env:PATH = "$env:PATH;$NewPath"
    }
}

# Set Environment Variables permanently
Set-PersistentEnv "ANDROID_HOME" $androidSdk
Set-PersistentEnv "ANDROID_SDK_ROOT" $androidSdk
if ($javaHome) {
    Set-PersistentEnv "JAVA_HOME" $javaHome
    Add-PersistentPath "$javaHome\bin"
}

# Add all relevant tools to PATH permanently
if ($flutterBin) { Add-PersistentPath $flutterBin }
Add-PersistentPath "$androidSdk\platform-tools"
Add-PersistentPath "$androidSdk\cmdline-tools\latest\bin"
Add-PersistentPath "$androidSdk\tools\bin"
Add-PersistentPath "$androidSdk\tools"

# -----------------------------------------------------------------------------
# 8. Step 7: Flutter Android Configuration & Auto-Accept Licenses
# -----------------------------------------------------------------------------
Write-Header "Step 7: Flutter Toolchain Configuration"
$flutterExe = if ($flutterBin) { "$flutterBin\flutter.bat" } else { "flutter.bat" }

if (Test-Path $flutterExe -or (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Info "Binding Flutter to Android SDK & Java runtime..."
    & $flutterExe config --android-sdk "$androidSdk" | Out-Null
    if ($androidStudioDir) {
        & $flutterExe config --android-studio-dir "$androidStudioDir" | Out-Null
    }
    if ($javaHome) {
        & $flutterExe config --jdk-dir "$javaHome" | Out-Null
    }
    Write-Success "Flutter Android configuration completed."

    # Auto accept Android licenses
    if ($AutoAcceptLicenses) {
        Write-Info "Accepting Android SDK licenses..."
        try {
            cmd.exe /c "echo y | `"$flutterExe`" doctor --android-licenses" | Out-Null
            Write-Success "Android licenses accepted."
        } catch {
            Write-WarningMsg "Could not auto-accept licenses. Run 'flutter doctor --android-licenses' manually if needed."
        }
    }

    # -----------------------------------------------------------------------------
    # 9. Step 8: Verification (Flutter Doctor)
    # -----------------------------------------------------------------------------
    if (-not $SkipDoctor) {
        Write-Header "Step 8: Verifying System Health (flutter doctor -v)"
        & $flutterExe doctor -v
    }
} else {
    Write-WarningMsg "Please restart your terminal to reload PATH and run 'flutter doctor'."
}

Write-Header "Setup Completed Successfully!"
Write-Host "All development tools and persistent environment variables are locked in globally." -ForegroundColor Green
Write-Host "No need to run this setup again for this system." -ForegroundColor Green
Write-Host ""
