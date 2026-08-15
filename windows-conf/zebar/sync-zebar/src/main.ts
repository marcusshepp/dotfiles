import "./style.css";
import * as zebar from "zebar";

const API = "http://127.0.0.1:9876";

/** Tiles that live in the centre ops cluster and can be switched off. */
const TILE_ORDER = ["lugia", "tailscale", "aws", "sites", "analytics"] as const;
const TILE_LABELS: Record<string, string> = {
  lugia: "Lugia workers",
  tailscale: "Tailscale",
  aws: "AWS spend",
  sites: "Site health",
  analytics: "Analytics",
};

type Tiles = Record<string, boolean>;

interface Status {
  awsCost: { today: number; month: number; forecast: number } | null;
  sites: { down: string[]; total: number; checked: number } | null;
  analytics: { users: number; sessions: number; period: string } | null;
  lugia: { workers: number; names: string[]; session: string; reachable: boolean } | null;
  tailscale: {
    connected: boolean;
    backendState: string;
    self: string;
    ip: string | null;
    exitNode: string | null;
    peersOnline: number;
  } | null;
  tiles: Tiles;
  lastUpdated: string;
  fastUpdated: string;
  errors: string[];
}

// ---------------------------------------------------------------- state

let status: Status | null = null;
let tiles: Tiles = Object.fromEntries(TILE_ORDER.map((t) => [t, true]));
let menuOpen = false;

let wm: any = null;
let date: any = null;
let cpu: any = null;
let memory: any = null;
let battery: any = null;
let audio: any = null;
let network: any = null;

const left = document.getElementById("left")!;
const center = document.getElementById("center")!;
const right = document.getElementById("right")!;

// ---------------------------------------------------------------- helpers

const esc = (s: unknown) =>
  String(s ?? "").replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

interface PillOpts {
  icon?: string;
  dot?: "up" | "down" | null;
  tone?: string;
  val?: string;
  lbl?: string;
  title?: string;
  cls?: string;
  act?: string;
  tile?: string;
}

function pill(o: PillOpts): string {
  const classes = ["pill", o.cls ?? "", o.act ? "clickable" : ""].filter(Boolean).join(" ");
  const attrs = [
    `class="${classes}"`,
    o.title ? `title="${esc(o.title)}"` : "",
    o.act ? `data-act="${o.act}"` : "",
    o.tile ? `data-tile="${o.tile}"` : "",
  ]
    .filter(Boolean)
    .join(" ");
  const body = [
    o.dot ? `<span class="dot ${o.dot}${o.dot === "up" ? "" : " pulse"}"></span>` : "",
    o.icon ? `<i class="ti ${o.icon} ${o.tone ?? ""}"></i>` : "",
    o.val ? `<span class="val ${o.tone ?? ""}">${esc(o.val)}</span>` : "",
    o.lbl ? `<span class="lbl">${esc(o.lbl)}</span>` : "",
  ]
    .filter(Boolean)
    .join("");
  return `<div ${attrs}>${body}</div>`;
}

/** Depth-first search for the focused window inside a workspace tree. */
function focusedWindow(node: any): any | null {
  if (!node) return null;
  if (node.type === "window" && node.hasFocus) return node;
  for (const child of node.children ?? []) {
    const hit = focusedWindow(child);
    if (hit) return hit;
  }
  return null;
}

// ---------------------------------------------------------------- clusters

function renderLeft(): string {
  if (!wm) return `<div class="boot"><i class="ti ti-loader-2 spin"></i><span>glazewm…</span></div>`;

  const buttons = (wm.currentWorkspaces ?? [])
    .map((ws: any) => {
      const state = ws.hasFocus ? "focused" : (ws.children ?? []).length ? "has-windows" : "";
      return `<button data-ws="${esc(ws.name)}" class="${state}">${esc(ws.displayName ?? ws.name)}</button>`;
    })
    .join("");

  const modes = (wm.bindingModes ?? [])
    .map((m: any) =>
      pill({
        icon: "ti-keyboard",
        tone: "warn",
        val: m.displayName ?? m.name,
        act: `unbind:${m.name}`,
        title: `Binding mode active — click to exit`,
      })
    )
    .join("");

  const win = focusedWindow(wm.focusedWorkspace);
  const title = win
    ? `<div class="pill"><i class="ti ti-app-window idle"></i><span class="title">${esc(win.title)}</span></div>`
    : "";

  return `
    <div class="ws">${buttons}</div>
    ${pill({
      icon: `ti-switch-${wm.tilingDirection === "vertical" ? "vertical" : "horizontal"}`,
      tone: "info",
      act: "tiling",
      title: `Tiling: ${wm.tilingDirection} — click to flip`,
    })}
    ${modes}
    ${title}
  `;
}

/**
 * The tile switcher lives inline in the centre cluster rather than in a
 * dropdown: a Zebar widget window is only as tall as the bar, so anything
 * positioned below it is clipped away.
 */
function renderTileSwitcher(): string {
  const chips = TILE_ORDER.map(
    (id) =>
      `<button class="chip ${tiles[id] ? "on" : ""}" data-tile-toggle="${id}" ` +
      `title="${esc(TILE_LABELS[id] ?? id)}"><span class="sw"></span>${esc(id)}</button>`
  ).join("");
  return (
    `<div class="switcher"><span class="lbl">tiles</span>${chips}` +
    `<button class="chip close" data-act="menu" title="Done">done</button></div>`
  );
}

function renderCenter(): string {
  if (menuOpen) return renderTileSwitcher();

  if (!status) {
    return `<div class="boot"><i class="ti ti-loader-2 spin"></i><span>status api…</span></div>`;
  }

  const parts: string[] = [];

  // --- Lugia workers -------------------------------------------------
  if (tiles.lugia) {
    const l = status.lugia;
    if (!l) {
      parts.push(
        pill({
          icon: "ti-terminal-2",
          tone: "bad",
          val: "?",
          lbl: "lugia",
          cls: "alert",
          title: "Lugia unreachable — ssh lugia@lugia failed",
          tile: "lugia",
        })
      );
    } else {
      const names = l.names.length ? l.names.map((n) => `▸ ${n}`).join("\n") : "no workers";
      parts.push(
        pill({
          icon: "ti-terminal-2",
          tone: l.workers > 0 ? "info" : "idle",
          val: String(l.workers),
          lbl: l.workers === 1 ? "worker" : "workers",
          cls: l.workers > 0 ? "live" : "",
          title: `Lugia tmux:${l.session} — ${l.workers} window${l.workers === 1 ? "" : "s"}\n${names}`,
          tile: "lugia",
        })
      );
    }
  }

  // --- Tailscale -----------------------------------------------------
  if (tiles.tailscale) {
    const t = status.tailscale;
    const up = !!t?.connected;
    const detail = t
      ? [
          `State: ${t.backendState}`,
          `Node: ${t.self}${t.ip ? ` (${t.ip})` : ""}`,
          `Peers online: ${t.peersOnline}`,
          t.exitNode ? `Exit node: ${t.exitNode}` : "",
        ]
          .filter(Boolean)
          .join("\n")
      : "tailscale status unavailable";
    // Quiet when healthy — a bare dot, with the node name in the tooltip.
    // Only shouts (text + alert border + pulse) when the tailnet is down.
    parts.push(
      pill({
        dot: up ? "up" : "down",
        tone: up ? "ok" : "bad",
        val: up ? undefined : "offline",
        lbl: up ? undefined : t?.backendState.toLowerCase(),
        cls: up ? "mini live" : "alert",
        title: detail,
        tile: "tailscale",
      })
    );
  }

  // --- AWS spend -----------------------------------------------------
  if (tiles.aws) {
    const c = status.awsCost;
    parts.push(
      pill({
        icon: "ti-currency-dollar",
        tone: c ? (c.today > 5 ? "warn" : "ok") : "idle",
        val: c ? `$${c.today.toFixed(2)}` : "—",
        lbl: "yest",
        title: c
          ? `Yesterday: $${c.today.toFixed(2)}\nMonth to date: $${c.month.toFixed(2)}\nForecast: $${c.forecast.toFixed(0)}`
          : "AWS Cost Explorer unavailable",
        tile: "aws",
      })
    );
  }

  // --- Site health ---------------------------------------------------
  if (tiles.sites) {
    const s = status.sites;
    const down = s?.down.length ?? 0;
    parts.push(
      pill({
        icon: "ti-world",
        tone: down > 0 ? "bad" : "ok",
        val: s ? (down > 0 ? String(down) : String(s.total)) : "—",
        lbl: down > 0 ? "down" : "up",
        cls: down > 0 ? "alert" : "",
        title: s ? [`${s.checked}/${s.total} checked`, "", ...(down ? s.down.map((d) => `✖ ${d}`) : ["All sites healthy"])].join("\n") : "",
        tile: "sites",
      })
    );
  }

  // --- Analytics -----------------------------------------------------
  if (tiles.analytics) {
    const an = status.analytics;
    parts.push(
      pill({
        icon: "ti-users",
        tone: "info",
        val: an ? String(an.users) : "—",
        lbl: an?.period ?? "30d",
        title: an ? `${an.users} users / ${an.sessions} sessions (${an.period})` : "analytics unavailable",
        tile: "analytics",
      })
    );
  }

  return parts.join("");
}

function renderRight(): string {
  const parts: string[] = [];

  if (cpu) {
    const usage = Math.round(cpu.usage ?? 0);
    parts.push(
      pill({ icon: "ti-cpu", tone: usage >= 80 ? "bad" : "idle", val: `${usage}%`, title: "CPU usage" })
    );
  }

  if (memory) {
    const usage = Math.round(memory.usage ?? 0);
    const used = (memory.usedMemory ?? 0) / 1073741824;
    const total = (memory.totalMemory ?? 0) / 1073741824;
    parts.push(
      pill({
        icon: "ti-server",
        tone: usage >= 80 ? "bad" : usage >= 60 ? "warn" : "idle",
        val: `${used.toFixed(1)}G`,
        lbl: `/${total.toFixed(0)}`,
        title: `Memory ${usage}% — ${used.toFixed(1)} of ${total.toFixed(0)} GB`,
      })
    );
  }

  if (battery && battery.chargePercent != null) {
    const pct = Math.round(battery.chargePercent);
    const charging = battery.state === "charging" || battery.isCharging;
    parts.push(
      pill({
        icon: charging ? "ti-battery-charging" : pct <= 20 ? "ti-battery-1" : "ti-battery-3",
        tone: pct <= 20 ? "bad" : "idle",
        val: `${pct}%`,
        title: charging ? "Charging" : "On battery",
      })
    );
  }

  const dev = audio?.defaultPlaybackDevice;
  if (dev) {
    const vol = Math.round(dev.volume ?? 0);
    parts.push(
      pill({
        icon: dev.isMuted || vol === 0 ? "ti-volume-3" : vol >= 50 ? "ti-volume" : "ti-volume-2",
        tone: "idle",
        val: `${vol}%`,
        title: dev.name,
      })
    );
  }

  const iface = network?.defaultInterface;
  if (iface) {
    const wifi = iface.type === "wifi";
    const signal = network?.defaultGateway?.signalStrength ?? 0;
    parts.push(
      pill({
        icon: wifi
          ? signal >= 75
            ? "ti-wifi"
            : signal >= 40
              ? "ti-wifi-2"
              : "ti-wifi-1"
          : "ti-network",
        tone: "idle",
        val: wifi ? (network?.defaultGateway?.ssid ?? "wifi") : "eth",
        title: `${iface.type}${wifi ? ` — ${signal}%` : ""}`,
      })
    );
  }

  if (date?.formatted) {
    parts.push(pill({ icon: "ti-clock", tone: "info", val: date.formatted, title: "System clock" }));
  }

  parts.push(
    pill({ icon: "ti-adjustments-horizontal", tone: menuOpen ? "info" : "idle", act: "menu", title: "Toggle tiles" })
  );

  return parts.join("");
}

let raf = 0;
function render() {
  cancelAnimationFrame(raf);
  raf = requestAnimationFrame(() => {
    left.innerHTML = renderLeft();
    center.innerHTML = renderCenter();
    right.innerHTML = renderRight();
  });
}

// ---------------------------------------------------------------- actions

async function setTile(id: string, action: "toggle" | "on" | "off") {
  try {
    const res = await fetch(`${API}/tiles/${id}/${action}`);
    if (res.ok) tiles = await res.json();
  } catch {
    // API down — flip locally so the bar still responds.
    if (action === "toggle") tiles = { ...tiles, [id]: !tiles[id] };
    else tiles = { ...tiles, [id]: action === "on" };
  }
  render();
}

document.addEventListener("click", (e) => {
  const target = e.target as HTMLElement;

  const toggle = target.closest("[data-tile-toggle]") as HTMLElement | null;
  if (toggle) {
    setTile(toggle.dataset.tileToggle!, "toggle");
    return;
  }

  const ws = target.closest("[data-ws]") as HTMLElement | null;
  if (ws) {
    wm?.runCommand(`focus --workspace ${ws.dataset.ws}`);
    return;
  }

  const act = (target.closest("[data-act]") as HTMLElement | null)?.dataset.act;
  if (act === "menu") {
    menuOpen = !menuOpen;
    render();
    return;
  }
  if (act === "tiling") {
    wm?.runCommand("toggle-tiling-direction");
    return;
  }
  if (act?.startsWith("unbind:")) {
    wm?.runCommand(`wm-disable-binding-mode --name ${act.slice("unbind:".length)}`);
    return;
  }
});

// Right-click any ops tile to hide it; restore it from the tiles menu.
document.addEventListener("contextmenu", (e) => {
  const tile = (e.target as HTMLElement).closest("[data-tile]") as HTMLElement | null;
  if (!tile) return;
  e.preventDefault();
  setTile(tile.dataset.tile!, "off");
});

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape" && menuOpen) {
    menuOpen = false;
    render();
  }
});

// ---------------------------------------------------------------- polling

async function poll() {
  try {
    const res = await fetch(`${API}/status?_=${Date.now()}`);
    if (res.ok) {
      status = await res.json();
      if (status?.tiles) tiles = { ...tiles, ...status.tiles };
    }
  } catch {
    // Status API is optional — the bar keeps working without it.
  }
  render();
  // Retry fast until the first success, then settle into a steady poll.
  setTimeout(poll, status ? 5_000 : 2_000);
}

const providers = zebar.createProviderGroup({
  glazewm: { type: "glazewm" },
  date: { type: "date", formatting: "h:mm a  EEE MMM d" },
  cpu: { type: "cpu" },
  memory: { type: "memory" },
  battery: { type: "battery" },
  audio: { type: "audio" },
  network: { type: "network" },
});

providers.onOutput(() => {
  const m = providers.outputMap as any;
  wm = m.glazewm;
  date = m.date;
  cpu = m.cpu;
  memory = m.memory;
  battery = m.battery;
  audio = m.audio;
  network = m.network;
  render();
});

render();
poll();
