<#
.SYNOPSIS
  Switch between Zebar bar implementations and toggle bar tiles.

.DESCRIPTION
  Zebar decides which bar to launch from `startupConfigs` in
  ~/.glzr/zebar/settings.json. This script rewrites that array, restarts
  Zebar, and talks to the local status API (port 9876) for tile visibility.

.EXAMPLE
  zbar list
  zbar use sync-zebar
  zbar use neobrutal-zebar
  zbar tile aws off
  zbar restart
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'current', 'use', 'restart', 'build', 'tile', 'api', 'help')]
    [string]$Command = 'current',

    [Parameter(Position = 1)] [string]$Arg1,
    [Parameter(Position = 2)] [string]$Arg2
)

$ErrorActionPreference = 'Stop'

$ZebarRoot    = Join-Path $env:USERPROFILE '.glzr\zebar'
$SettingsPath = Join-Path $ZebarRoot 'settings.json'
$ZebarExe     = 'C:\Program Files\glzr.io\Zebar\zebar.exe'
$ApiDir       = Join-Path $ZebarRoot 'zebar-api'
$ApiBase      = 'http://127.0.0.1:9876'

function Get-Packs {
    Get-ChildItem $ZebarRoot -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'zpack.json') } |
        ForEach-Object {
            $zpack = Get-Content (Join-Path $_.FullName 'zpack.json') -Raw | ConvertFrom-Json
            [pscustomobject]@{
                Pack    = $_.Name
                Widgets = @($zpack.widgets.name)
                Presets = @($zpack.widgets[0].presets.name)
                Built   = Test-Path (Join-Path $_.FullName 'build\index.html')
                Desc    = $zpack.description
            }
        }
}

function Get-Current {
    $s = Get-Content $SettingsPath -Raw | ConvertFrom-Json
    @($s.startupConfigs)
}

function Restart-Zebar {
    Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Milliseconds 600
    Start-Process $ZebarExe -WindowStyle Hidden
    Write-Host "  zebar restarted" -ForegroundColor DarkGray
}

switch ($Command) {

    'list' {
        $current = (Get-Current)[0].pack
        Write-Host ''
        foreach ($p in Get-Packs) {
            $marker = if ($p.Pack -eq $current) { '*' } else { ' ' }
            $color  = if ($p.Pack -eq $current) { 'Green' } else { 'Gray' }
            $built  = if ($p.Built) { 'built' } else { 'NOT BUILT' }
            Write-Host ("{0} {1,-20} {2,-10} widgets: {3}" -f $marker, $p.Pack, $built, ($p.Widgets -join ',')) -ForegroundColor $color
            if ($p.Desc) { Write-Host ("    {0}" -f $p.Desc) -ForegroundColor DarkGray }
        }
        Write-Host ''
    }

    'current' {
        $c = Get-Current
        Write-Host ''
        foreach ($cfg in $c) {
            Write-Host ("  {0} / {1} / {2}" -f $cfg.pack, $cfg.widget, $cfg.preset) -ForegroundColor Green
        }
        $running = Get-Process zebar -ErrorAction SilentlyContinue
        Write-Host ("  zebar: {0}" -f $(if ($running) { "running (pid $($running.Id -join ','))" } else { 'not running' })) -ForegroundColor DarkGray
        try {
            Invoke-RestMethod "$ApiBase/tiles" -TimeoutSec 3 | Out-Null
            Write-Host '  status api: up' -ForegroundColor DarkGray
        } catch {
            Write-Host '  status api: DOWN  (zbar api start)' -ForegroundColor Yellow
        }
        Write-Host ''
    }

    'use' {
        if (-not $Arg1) { throw "usage: zbar use <pack> [preset]" }
        $pack = (Get-Packs | Where-Object { $_.Pack -eq $Arg1 -or $_.Pack -like "$Arg1*" } | Select-Object -First 1)
        if (-not $pack) { throw "no pack matching '$Arg1'. Try: zbar list" }
        if (-not $pack.Built) { throw "$($pack.Pack) has no build/index.html. Run: zbar build $($pack.Pack)" }

        $preset = if ($Arg2) { $Arg2 } else { $pack.Presets[0] }
        if ($pack.Presets -notcontains $preset) { throw "preset '$preset' not in $($pack.Presets -join ',')" }

        $settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
        $settings.startupConfigs = @(
            [pscustomobject]@{ pack = $pack.Pack; widget = $pack.Widgets[0]; preset = $preset }
        )
        $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath -Encoding utf8

        Write-Host "  -> $($pack.Pack) / $($pack.Widgets[0]) / $preset" -ForegroundColor Green
        Restart-Zebar
    }

    'restart' { Restart-Zebar }

    'build' {
        $name = if ($Arg1) { $Arg1 } else { (Get-Current)[0].pack }
        $dir  = Join-Path $ZebarRoot $name
        if (-not (Test-Path $dir)) { throw "no pack directory: $dir" }
        # Packs are symlinked in from ~/p/dotfiles. Rollup cannot resolve
        # node_modules through the link, so always build at the real path.
        $item = Get-Item $dir -Force
        if ($item.LinkType -eq 'SymbolicLink') { $dir = $item.Target }
        Push-Location $dir
        try {
            if (-not (Test-Path 'node_modules')) { npm install }
            npm run build
        } finally { Pop-Location }
        Write-Host "  built $name" -ForegroundColor Green
    }

    'tile' {
        if (-not $Arg1) {
            $t = Invoke-RestMethod "$ApiBase/tiles" -TimeoutSec 5
            Write-Host ''
            foreach ($p in $t.PSObject.Properties) {
                $state = if ($p.Value) { 'on ' } else { 'off' }
                Write-Host ("  {0,-4} {1}" -f $state, $p.Name) -ForegroundColor $(if ($p.Value) { 'Green' } else { 'DarkGray' })
            }
            Write-Host ''
            break
        }
        $action = if ($Arg2) { $Arg2.ToLower() } else { 'toggle' }
        if ($action -notin @('on', 'off', 'toggle')) { throw "usage: zbar tile <name> [on|off|toggle]" }
        $t = Invoke-RestMethod "$ApiBase/tiles/$Arg1/$action" -TimeoutSec 5
        Write-Host ("  {0} -> {1}" -f $Arg1, $(if ($t.$Arg1) { 'on' } else { 'off' })) -ForegroundColor Green
    }

    'api' {
        switch ($Arg1) {
            'stop' {
                Get-CimInstance Win32_Process -Filter "Name='bun.exe'" |
                    Where-Object { $_.CommandLine -like '*server.ts*' } |
                    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
                Write-Host '  api stopped' -ForegroundColor Green
            }
            'log' { Invoke-RestMethod "$ApiBase/status" -TimeoutSec 8 | ConvertTo-Json -Depth 6 }
            'why' {
                # Which sources are failing, and why. A headless server logs to
                # nowhere, so /status carries the reason for each dead tile.
                $s = Invoke-RestMethod "$ApiBase/status" -TimeoutSec 8
                Write-Host ''
                foreach ($src in 'awsCost', 'sites', 'analytics', 'lugia', 'tailscale') {
                    $err = $s.lastError.$src
                    if ($err) { Write-Host ("  FAIL  {0,-11} {1}" -f $src, $err) -ForegroundColor Red }
                    else      { Write-Host ("  ok    {0}" -f $src) -ForegroundColor DarkGray }
                }
                Write-Host ("`n  slow poll: {0}`n  fast poll: {1}`n" -f $s.lastUpdated, $s.fastUpdated) -ForegroundColor DarkGray
            }
            default { Start-Process wscript.exe (Join-Path $ApiDir 'start.vbs') -WindowStyle Hidden; Write-Host '  api started on 9876' -ForegroundColor Green }
        }
    }

    default {
        Write-Host @'

  zbar — Zebar bar implementation switcher

    zbar list                    packs on disk, * = active
    zbar current                 active bar + zebar/api health
    zbar use <pack> [preset]     switch bar and restart zebar
    zbar build [pack]            npm install + npm run build
    zbar restart                 restart zebar only
    zbar tile                    list tile visibility
    zbar tile <name> [on|off]    toggle an ops tile (default: toggle)
    zbar api [start|stop|log]    the status API on port 9876
    zbar api why                 which sources are failing, and why

'@ -ForegroundColor Gray
    }
}
