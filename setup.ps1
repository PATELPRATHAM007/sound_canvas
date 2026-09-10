<#
.SYNOPSIS
    Convenience shortcut to run setup_windows.ps1
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $RemainingArgs
)

$scriptPath = Join-Path $PSScriptRoot "setup_windows.ps1"
& $scriptPath @RemainingArgs
