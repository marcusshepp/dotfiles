# sync-zebar

Marcus's own Zebar bar. Plain TypeScript + Vite — no framework — so it stays
small and hackable. Lives alongside `neobrutal-zebar`; `zbar use <pack>` swaps
which one Zebar launches.

```
~/.glzr/zebar/sync-zebar  ->  ~/p/dotfiles/windows-conf/zebar/sync-zebar   (symlink)
```

## Layout

| Cluster | Contents |
|---------|----------|
| Left    | GlazeWM workspaces (click to focus), tiling-direction toggle, binding modes, focused window title (live selected-tab title for Windows Terminal) |
| Centre  | Ops tiles — Lugia workers, Iron Tower workers, Tailscale, site health, analytics |
| Right   | CPU, memory, battery, volume, network, clock, tile switcher |

## Ops tiles

Everything in the centre comes from the local status API
(`~/.glzr/zebar/zebar-api/server.ts`, port 9876). The bar only reads that one
cached endpoint, so a slow or dead upstream can never stall the bar.

| Tile | Source | Refresh |
|------|--------|---------|
| `lugia` | `ssh lugia@lugia tmux list-windows -t main` — one worker per tmux window | 15s |
| `iron-tower` | `ssh marcusshep@iron-tower tmux list-sessions` — one Agent Deck worker per tmux session | 15s |
| `tailscale` | `tailscale status --json` → `BackendState == "Running"` | 15s |
| `sites` | HEAD sweep of the monitored client sites | 5min |
| `analytics` | `platform-api.syncgr.com/v1/analytics?portalId=sync&days=30` (GA4 + GSC) | 5min |

Note the analytics host: the legacy `portal-api.syncgr.com/admin/*` gateway
routes are gone and answer 404. Admin surfaces live on the Hono platform API
under `/v1/*`.

Hover any tile for detail — the Lugia tooltip lists every tmux window by name.

For Windows Terminal, the GlazeWM provider can retain a stale title after an internal tab switch. The local status API reads the real foreground HWND/title from Windows and the bar uses it when that handle matches the focused Terminal window, so the label follows the selected tab.

`tailscale` is deliberately quiet: a bare dot while the tailnet is up, with the
node name and peer count in the tooltip. It only grows text (`offline`, alert
border, pulsing dot) when the connection drops.

## Toggling tiles

Three equivalent ways; all persist to `zebar-api/tiles.json` and apply to
**both** bar implementations:

- Click the sliders icon at the far right, then click a chip. `done` closes it.
- Right-click a tile to hide it. Restore it from the switcher.
- `zbar tile sites off` / `zbar tile sites on` / `zbar tile` to list.

The switcher is inline rather than a dropdown on purpose: a Zebar widget window
is exactly as tall as the bar, so anything drawn below it is clipped away.

## When a tile shows `—`

`zbar api why` — per-source ok/FAIL plus the reason. The status API runs
headless via `start.vbs` so its console goes nowhere; every fetch records why
it failed into `lastError`, which rides along in `GET /status` and lands in the
tile's own tooltip. Check that before editing bar code.

## Building

```
zbar build sync-zebar     # npm install + vite build -> build/
zbar use sync-zebar       # point settings.json here and restart Zebar
zbar use neobrutal-zebar  # go back
```

`build/` is gitignored. Regenerate it on a fresh machine before `zbar use`.

Build at the real dotfiles path, never through the `~/.glzr` symlink — Rollup
cannot resolve `node_modules` across the link. `zbar build` handles this.
