<script lang="ts">
  import Group from "./Group.svelte";

  interface AgentInfo {
    agentId: string;
    name: string;
    status: string;
    portalId: string;
    progressCounters?: {
      total: number;
      completed: number;
      failed: number;
      pending: number;
    };
  }

  interface StatusData {
    awsCost: { today: number; month: number; forecast: number } | null;
    agents: { running: AgentInfo[]; total: number; failed: number } | null;
    sites: { down: string[]; total: number; checked: number } | null;
    analytics: { users: number; sessions: number; period: string } | null;
    lastUpdated: string;
    errors: string[];
  }

  let status = $state<StatusData | null>(null);

  function costTooltip(cost: StatusData["awsCost"]): string {
    if (!cost) return "";
    return `Yesterday: $${cost.today.toFixed(2)}\nMTD: $${cost.month.toFixed(2)}\nForecast: $${cost.forecast.toFixed(0)}`;
  }

  function agentTooltip(agents: StatusData["agents"]): string {
    if (!agents) return "";
    const lines = [`${agents.total} total agents, ${agents.failed} failed`];
    if (agents.running.length > 0) {
      lines.push("");
      for (const a of agents.running) {
        const progress = a.progressCounters
          ? ` (${a.progressCounters.completed}/${a.progressCounters.total})`
          : "";
        lines.push(`▶ ${a.name} [${a.portalId}]${progress}`);
      }
    } else {
      lines.push("No active agents");
    }
    return lines.join("\n");
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
    <!-- AWS Daily Spend -->
    <Group class="shrink-0">
      <div
        class="flex items-center gap-1 text-sm cursor-default"
        title={costTooltip(status.awsCost)}
      >
        <i class="ti ti-currency-dollar {status.awsCost && status.awsCost.today > 5 ? 'text-red-400' : 'text-emerald-400'}"></i>
        {#if status.awsCost}
          <span class="font-mono font-bold">${status.awsCost.today.toFixed(2)}</span>
          <span class="text-xs opacity-50">today</span>
        {:else}
          <span class="font-mono opacity-40">—</span>
        {/if}
      </div>
    </Group>

    <!-- Agent Runner Status -->
    <Group class="shrink-0">
      <div
        class="flex items-center gap-1 text-sm cursor-default"
        title={agentTooltip(status.agents)}
      >
        <i class="ti ti-robot {status.agents && status.agents.running.length > 0 ? 'text-blue-400' : status.agents && status.agents.failed > 0 ? 'text-red-400' : 'text-zinc-500'}"></i>
        {#if status.agents}
          <span class="font-mono font-bold">{status.agents.running.length}</span>
          <span class="text-xs opacity-50">running</span>
          {#if status.agents.failed > 0}
            <span class="font-mono text-red-400 font-bold ml-1">{status.agents.failed}!</span>
          {/if}
        {:else}
          <span class="font-mono opacity-40">—</span>
        {/if}
      </div>
    </Group>

    <!-- Sites Down -->
    <Group class="shrink-0">
      <div
        class="flex items-center gap-1 text-sm cursor-default"
        title={siteTooltip(status.sites)}
      >
        <i class="ti ti-world {status.sites && status.sites.down.length > 0 ? 'text-red-400' : 'text-emerald-400'}"></i>
        {#if status.sites}
          {#if status.sites.down.length > 0}
            <span class="font-mono font-bold text-red-400">{status.sites.down.length}</span>
            <span class="text-xs text-red-400">down</span>
          {:else}
            <span class="font-mono font-bold text-emerald-400">{status.sites.total}</span>
            <span class="text-xs opacity-50">up</span>
          {/if}
        {:else}
          <span class="font-mono opacity-40">—</span>
        {/if}
      </div>
    </Group>

    <!-- Active Users -->
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
  </div>
{:else}
  <div class="flex items-center gap-1 text-sm opacity-40">
    <i class="ti ti-loader-2 animate-spin"></i>
    <span>connecting...</span>
  </div>
{/if}
