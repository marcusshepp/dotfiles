<script lang="ts">
  import Group from "./Group.svelte";

  interface LugiaInfo {
    workers: number;
    names: string[];
    session: string;
    reachable: boolean;
  }

  interface TailscaleInfo {
    connected: boolean;
    backendState: string;
    self: string;
    ip: string | null;
    exitNode: string | null;
    peersOnline: number;
  }

  interface StatusData {
    sites: { down: string[]; total: number; checked: number } | null;
    analytics: { users: number; sessions: number; period: string } | null;
    lugia: LugiaInfo | null;
    ironTower: LugiaInfo | null;
    tailscale: TailscaleInfo | null;
    tiles: Record<string, boolean>;
    lastUpdated: string;
    errors: string[];
  }

  let status = $state<StatusData | null>(null);

  // Tile visibility comes from the status API so `zbar tile <name> off`
  // applies to both bar implementations. Unknown tiles default to visible.
  function shown(id: string): boolean {
    return status?.tiles?.[id] !== false;
  }

  function lugiaTooltip(lugia: LugiaInfo | null): string {
    if (!lugia) return "Lugia unreachable — ssh lugia@lugia failed";
    const lines = [
      `tmux:${lugia.session} — ${lugia.workers} window${lugia.workers === 1 ? "" : "s"}`,
    ];
    lines.push("");
    lines.push(...(lugia.names.length ? lugia.names.map((n) => `▶ ${n}`) : ["no workers"]));
    return lines.join("\n");
  }

  function tailscaleTooltip(ts: TailscaleInfo | null): string {
    if (!ts) return "tailscale status unavailable";
    return [
      `State: ${ts.backendState}`,
      `Node: ${ts.self}${ts.ip ? ` (${ts.ip})` : ""}`,
      `Peers online: ${ts.peersOnline}`,
      ts.exitNode ? `Exit node: ${ts.exitNode}` : "",
    ]
      .filter(Boolean)
      .join("\n");
  }

  function siteTooltip(sites: StatusData["sites"]): string {
    if (!sites) return "";
    const lines = [`${sites.checked}/${sites.total} checked`];
    if (sites.down.length > 0) {
      lines.push("");
      for (const s of sites.down) {
        lines.push(`✖ ${s}`);
      }
    } else {
      lines.push("All sites healthy");
    }
    return lines.join("\n");
  }

  let timeout: ReturnType<typeof setTimeout> | null = null;

  async function fetchStatus() {
    try {
      const res = await fetch(`http://127.0.0.1:9876/status?_=${Date.now()}`);
      if (res.ok) status = await res.json();
    } catch {}
    // Fast retry (2s) until first success, then slow poll (30s).
    timeout = setTimeout(fetchStatus, status ? 30_000 : 2_000);
  }

  $effect(() => {
    fetchStatus();
    return () => {
      if (timeout) clearTimeout(timeout);
    };
  });
</script>

{#if status}
  <div class="flex items-center gap-3">
    <!-- Lugia Workers (tmux windows in session `main`) -->
    {#if shown("lugia")}
      <Group class="shrink-0">
        <div
          class="flex items-center gap-1 text-sm cursor-default"
          title={lugiaTooltip(status.lugia)}
        >
          <i class="ti ti-terminal-2 {status.lugia?.workers ? 'text-violet-400' : 'text-zinc-500'}"></i>
          {#if status.lugia}
            <span class="font-mono font-bold">{status.lugia.workers}</span>
            <span class="text-xs opacity-50">
              lugia
            </span>
          {:else}
            <span class="font-mono opacity-50">?</span>
            <span class="text-xs opacity-50">lugia</span>
          {/if}
        </div>
      </Group>
    {/if}

    <!-- Iron Tower Workers (Agent Deck tmux sessions) -->
    {#if shown("iron-tower")}
      <Group class="shrink-0">
        <div
          class="flex items-center gap-1 text-sm cursor-default"
          title={status.ironTower ? `Agent Deck — ${status.ironTower.workers} sessions\n\n${status.ironTower.names.map((n) => `▶ ${n}`).join("\n") || "no workers"}` : "Iron Tower unreachable — ssh marcusshep@iron-tower failed"}
        >
          <i class="ti ti-server-2 {status.ironTower?.workers ? 'text-violet-400' : 'text-zinc-500'}"></i>
          {#if status.ironTower}
            <span class="font-mono font-bold">{status.ironTower.workers}</span>
            <span class="text-xs opacity-50">iron tower</span>
          {:else}
            <span class="font-mono opacity-50">?</span>
            <span class="text-xs opacity-50">iron tower</span>
          {/if}
        </div>
      </Group>
    {/if}

    <!-- Tailscale -->
    {#if shown("tailscale")}
      <Group class="shrink-0">
        <div
          class="flex items-center gap-1 text-sm cursor-default"
          title={tailscaleTooltip(status.tailscale)}
        >
          <!-- Quiet when healthy — icon only, node name in the tooltip. -->
          <i class="ti {status.tailscale?.connected ? 'ti-shield-check text-emerald-400' : 'ti-shield-off text-zinc-500'}"></i>
          {#if !status.tailscale?.connected}
            <span class="font-mono opacity-50">offline</span>
            <span class="text-xs opacity-50">
              {status.tailscale?.backendState.toLowerCase() ?? "—"}
            </span>
          {/if}
        </div>
      </Group>
    {/if}

    <!-- Sites Down -->
    {#if shown("sites")}
      <Group class="shrink-0">
        <div
          class="flex items-center gap-1 text-sm cursor-default"
          title={siteTooltip(status.sites)}
        >
          <i class="ti ti-world {status.sites && status.sites.down.length > 0 ? 'text-zinc-500' : 'text-emerald-400'}"></i>
          {#if status.sites}
            {#if status.sites.down.length > 0}
              <span class="font-mono opacity-50">{status.sites.down.length}</span>
              <span class="text-xs opacity-50">down</span>
            {:else}
              <span class="font-mono font-bold text-emerald-400">{status.sites.total}</span>
              <span class="text-xs opacity-50">up</span>
            {/if}
          {:else}
            <span class="font-mono opacity-40">—</span>
          {/if}
        </div>
      </Group>
    {/if}

    <!-- Active Users -->
    {#if shown("analytics")}
      <Group class="shrink-0">
        <div
          class="flex items-center gap-1 text-sm cursor-default"
          title={status.analytics ? `${status.analytics.users} users / ${status.analytics.sessions} sessions (${status.analytics.period})` : ""}
        >
          <i class="ti ti-users text-violet-400"></i>
          {#if status.analytics}
            <span class="font-mono font-bold">{status.analytics.users}</span>
            <span class="text-xs opacity-50">{status.analytics.period}</span>
          {:else}
            <span class="font-mono opacity-40">—</span>
          {/if}
        </div>
      </Group>
    {/if}
  </div>
{:else}
  <div class="flex items-center gap-1 text-sm opacity-40">
    <i class="ti ti-loader-2 animate-spin"></i>
    <span>connecting...</span>
  </div>
{/if}
