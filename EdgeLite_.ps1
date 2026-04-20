# =================================================================
# Edge Lite - Full Optimization Script
# Run as Administrator
# =================================================================

$regBase = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$regUser = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"

foreach ($path in @($regBase, $regUser)) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "      Edge Lite - Full Optimization     " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ── 1. Telemetry & Diagnostics ───────────────────────────────────────────────
Write-Host "  [1/7] Telemetry..." -ForegroundColor Magenta
$telemetry = @{
    "DiagnosticData"                  = 0
    "MetricsReportingEnabled"         = 0
    "SendSiteInfoToImproveServices"   = 0
    "PersonalizationReportingEnabled" = 0
    "EdgeShoppingAssistantEnabled"    = 0
    "EdgeFollowEnabled"               = 0
    "ShowRecommendationsEnabled"      = 0
}
foreach ($key in $telemetry.Keys) {
    Set-ItemProperty -Path $regBase -Name $key -Value $telemetry[$key] -Type DWord -Force
    Write-Host "  [+] $key" -ForegroundColor Green
}

# ── 2. Privacy & Tracking ────────────────────────────────────────────────────
Write-Host "`n  [2/7] Privacy & Tracking..." -ForegroundColor Magenta
$privacy = @{
    "TrackingPrevention"                             = 3  # Strict
    "BlockThirdPartyCookies"                         = 0  # Keep for site functionality
    "UserFeedbackAllowed"                            = 0
    "SearchSuggestEnabled"                           = 1  # Keep for convenience
    "AddressBarMicrosoftSearchInBingProviderEnabled" = 0
    "SignedHTTPExchangeEnabled"                      = 0
    "PaymentMethodQueryEnabled"                      = 0  # Hide saved payments from sites
    "SharedClipboardEnabled"                         = 0  # No clipboard sharing with phone
    "EdgeEnhanceImagesEnabled"                       = 0  # Don't send images to Microsoft
}
foreach ($key in $privacy.Keys) {
    Set-ItemProperty -Path $regBase -Name $key -Value $privacy[$key] -Type DWord -Force
    Write-Host "  [+] $key = $($privacy[$key])" -ForegroundColor Green
}

# ── 3. Performance ───────────────────────────────────────────────────────────
Write-Host "`n  [3/7] Performance..." -ForegroundColor Magenta
$performance = @{
    "BackgroundModeEnabled"      = 0    # Don't run in background
    "StartupBoostEnabled"        = 0    # Save RAM on startup
    "SleepingTabsEnabled"        = 1    # Sleep inactive tabs
    "SleepingTabsTimeout"        = 300  # Sleep after 5 minutes
    "EfficiencyMode"             = 1    # Enable efficiency mode
    "NewTabPagePrerenderEnabled" = 0    # Don't prerender new tab (saves ~160MB)
    "AllowPrelaunch"             = 0    # Don't prelaunch Edge
}
foreach ($key in $performance.Keys) {
    Set-ItemProperty -Path $regBase -Name $key -Value $performance[$key] -Type DWord -Force
    Write-Host "  [+] $key = $($performance[$key])" -ForegroundColor Green
}

# ── 4. Bloatware Removal ─────────────────────────────────────────────────────
Write-Host "`n  [4/7] Bloatware..." -ForegroundColor Magenta
$bloat = @{
    "HubsSidebarEnabled"             = 0
    "EdgeWalletEnabled"              = 0
    "NewTabPageContentEnabled"       = 0
    "NewTabPageQuickLinksEnabled"    = 0
    "MicrosoftEditorProofingEnabled" = 1  # Keep spellcheck
    "EdgeCollectionsEnabled"         = 1  # Keep for productivity
    "BingAdsSuppression"             = 1
    "ShowMicrosoftRewards"           = 0
    "MSAWebSiteSSOEnabled"           = 0
}
foreach ($key in $bloat.Keys) {
    Set-ItemProperty -Path $regBase -Name $key -Value $bloat[$key] -Type DWord -Force
    Write-Host "  [+] $key = $($bloat[$key])" -ForegroundColor Yellow
}

# ── 5. Security ──────────────────────────────────────────────────────────────
Write-Host "`n  [5/7] Security..." -ForegroundColor Magenta
$security = @{
    "SSLErrorOverrideAllowed" = 0  # No bypassing SSL errors
    "EnhanceSecurityMode"     = 2  # Enhanced security mode
    "DefaultSensorsSetting"   = 2  # Block motion/orientation sensors (fingerprinting)
}
foreach ($key in $security.Keys) {
    Set-ItemProperty -Path $regBase -Name $key -Value $security[$key] -Type DWord -Force
    Write-Host "  [+] $key = $($security[$key])" -ForegroundColor Cyan
}

# ── 6. WebRTC & DNS over HTTPS ───────────────────────────────────────────────
Write-Host "`n  [6/7] WebRTC & DNS over HTTPS..." -ForegroundColor Magenta

Set-ItemProperty -Path $regBase -Name "WebRtcIPHandling" -Value "disable_non_proxied_udp" -Type String -Force
Write-Host "  [+] WebRTC: IP leak blocked" -ForegroundColor Green

Set-ItemProperty -Path $regBase -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $regBase -Name "DnsOverHttpsTemplates" -Value "https://dns.google/dns-query{?dns}" -Type String -Force
Write-Host "  [+] DNS over HTTPS: Enabled (Google DNS)" -ForegroundColor Green

# ── 7. Background Tasks ──────────────────────────────────────────────────────
Write-Host "`n  [7/7] Background Tasks..." -ForegroundColor Magenta
$tasks = @(
    "MicrosoftEdgeUpdateTaskMachineCore",
    "MicrosoftEdgeUpdateTaskMachineUA",
    "MicrosoftEdgeShadowStack"
)
foreach ($task in $tasks) {
    $t = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($t) {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  [+] Disabled: $task" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   [Done] Edge is optimized!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Restart Edge to apply all changes." -ForegroundColor White
