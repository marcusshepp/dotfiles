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
| Left    | GlazeWM workspaces (click to focus), tiling-direction toggle, binding modes, focused window title |
| Centre  | Ops tiles — Lugia workers, Tailscale, AWS spend, site health, analytics |
| Right   | CPU, memory, battery, volume, network, clock, tile switcher |

## Ops tiles

Everything in the centre comes from the local status API
(`~/.glzr/zebar/zebar-api/server.ts`, port 9876). The bar never talks to AWS or
Lugia directly — it only reads that one cached endpoint, so a slow or dead
upstream can never stall the bar.

| Tile | Source | Refresh |
|------|--------|---------|
| `lugia` | `ssh lugia@lugia tmux list-windows -t main` — one worker per tmux window | 15s |
| `tailscale` | `tailscale status --json` → `BackendState == "Running"` | 15s |
| `aws` | Cost Explorer, yesterday's blended cost | 5min |
| `sites` | HEAD sweep of the monitored client sites | 5min |
| `analytics` | GA4 via portal-api | 5min |

Hover any tile for detail — the Lugia tooltip lists every tmux window by name.

`tailscale` is deliberately quiet: a bare dot while the tailnet is up, with the
node name and peer count in the tooltip. It only grows text (`offline`, alert
border, pulsing dot) when the connection drops.

## Toggling tiles

Three equivalent ways; all persist to `zebar-api/tiles.json` and apply to
**both** bar implementations:

- Click the sliders icon at the far right, then click a chip. `done` closes it.
- Right-click a tile to hide it. Restore it from the switcher.
- `zbar tile aws off` / `zbar tile aws on` / `zbar tile` to list.

The switcher is inline rather than a dropdown on purpose: a Zebar widget window
is exactly as tall as the bar, so anything drawn below it is clipped away.

## Building

```
zbar build sync-zebar     # npm install + vite build -> build/
zbar use sync-zebar       # point settings.json here and restart Zebar
zbar use neobrutal-zebar  # go back
```

`build/` is gitignored. Regenerate it on a fresh machine before `zbar use`.

Build at the real dotfiles path, never through the `~/.glzr` symlink — Rollup
cannot resolve `node_modules` across the link. `zbar build` handles this.
