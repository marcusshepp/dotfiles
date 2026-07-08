local wezterm = require 'wezterm'

local config = {}

-- Weighted random background image based on time of day
local img_dir = "C:\\Users\\marcu\\p\\dotfiles\\img\\"
local images = {
    --                                          night  morning  afternoon  evening
    --                                         22-6    6-12     12-18      18-22

    -- === SPACE ===
    { file = "space-nebula-2-dark.jpg",         weights = {  8,  8,  2,  4 } },
    { file = "space-nebula-3-dark.jpg",         weights = {  8,  8,  2,  4 } },

    -- === ANIME ===
    { file = "aot-levi-dark.jpg",               weights = {  5,  8,  5,  5 } },
    { file = "anime-dark-4-dark.jpg",           weights = {  5,  8,  5,  5 } },

    -- === CARTOON: Invader Zim ===
    { file = "zim-1-dark.jpg",                  weights = {  4,  6,  6,  4 } },

    -- === ART ===
    { file = "art-buddha-4-dark.jpg",           weights = {  5,  8,  4,  6 } },

    -- === SOLID ===
    { file = "black-dark.jpg",                  weights = {  2,  1,  1,  2 } },

    -- === LEGACY ===
    { file = "dragon-ball3.jpg",                weights = {  2,  5,  8,  3 } },
}

local function pick_background()
    local hour = tonumber(os.date("%H"))
    local slot
    if hour >= 22 or hour < 6 then
        slot = 1  -- night
    elseif hour < 12 then
        slot = 2  -- morning
    elseif hour < 18 then
        slot = 3  -- afternoon
    else
        slot = 4  -- evening
    end

    -- Build cumulative weights
    local total = 0
    for _, img in ipairs(images) do
        total = total + img.weights[slot]
    end

    math.randomseed(os.time() + os.clock() * 1000)
    local roll = math.random() * total
    local cumulative = 0
    for _, img in ipairs(images) do
        cumulative = cumulative + img.weights[slot]
        if roll <= cumulative then
            return img_dir .. img.file
        end
    end
    return img_dir .. images[1].file
end

config.font_size = 12.0
config.font = wezterm.font("Cascadia Code")
config.color_scheme = "Dracula"
config.enable_tab_bar = false
config.audible_bell = "Disabled"
config.window_background_opacity = 1
config.window_background_image = pick_background()

-- Dim inactive panes so the active one pops
config.inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.5,
}

-- Bolder split line between panes + bright red cursor on the active pane
config.colors = {
    split = "#bd93f9",  -- Dracula purple
    cursor_bg = "#ff0033",
    cursor_fg = "#ffffff",
    cursor_border = "#ff0033",
}

config.default_prog = { "pwsh" }

-- === STABILITY UNDER A LARGE FLEET (twine) — added 2026-06-03 after the freeze ===
-- All twine-spawned agent windows live in ONE wezterm-gui process and one
-- single-threaded scheduler ("wezterm cli spawn --new-window" injects into the
-- running GUI/mux, it does NOT start a new process). With ~15 continuously
-- redrawing Claude Code TUIs, that single process's render/scheduler work piles
-- up until the whole GUI stops responding after a few hours — the 2026-06-03
-- cascade where every window went "Not responding" one by one while RAM was fine.
-- These settings pin the stable Windows front-end and cut the per-window idle
-- render cost that gets multiplied across every open window. They do not change
-- the single-process topology (twine depends on it for cross-window addressing) —
-- they raise the ceiling. Postmortem + guidance:
-- ~/o/business/projects/internal/twine/freeze-postmortem.md
config.front_end = "OpenGL"      -- pin the stable Windows default; avoid the WebGpu hang class
config.max_fps = 30              -- halve the frame budget — terminal TUIs don't need 60fps
config.animation_fps = 1         -- near-disable animation re-renders (idle cost is paid per window)
config.cursor_blink_rate = 0     -- stop the blinking cursor's continuous repaint (cost × every window)
-- Belt-and-suspenders: force a steady cursor even if an app inside (Claude Code TUI,
-- PSReadLine) sends a DECSCUSR "blinking" style. default_cursor_style only governs the
-- default, but pairing it with rate=0 is the documented "never blink" combo. The
-- Constant easings disable the fade animation so that, at animation_fps=1, no half-faded
-- frame can read as a slow flicker. WezTerm auto-reloads this file so it should apply
-- live; if a long-lived twine gui keeps blinking, fully quit + relaunch that gui process.
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Let ALT keys pass through to the OS (for GlazeWM keybinds)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Build wallpaper picker choices from the images table
local picker_choices = {}
for _, img in ipairs(images) do
    -- Clean up filename for display: remove -dark suffix and extension
    local label = img.file:gsub("%-dark%.", "."):gsub("%.[^.]+$", ""):gsub("%-", " ")
    table.insert(picker_choices, { id = img_dir .. img.file, label = label })
end
-- Add "Random" and "No background" options at the top
table.insert(picker_choices, 1, { id = "none", label = "No background" })
table.insert(picker_choices, 1, { id = "random", label = "Random (time-weighted)" })

-- === WORKSPACE LAYOUTS ===
-- Each layout defines a grid and commands per pane.
-- Panes are numbered left-to-right, top-to-bottom:
--   1x1: [pane=1] (single pane — current window, no splits)
--   2x2: [top-left=1, top-right=2, bottom-left=3, bottom-right=4]
--   2x1: [left=1, right=2]
--   1x2: [top=1, bottom=2]
--   2x2-br2: 2x2 with bottom-right split vertically into 2 sub-panes
--            [top-left=1, top-right=2, bot-left=3, bot-right-left=4, bot-right-right=5]
--   1+2x2:   top row spans full width, bottom is 2x2
--            [top-full=1, mid-left=2, mid-right=3, bot-left=4, bot-right=5]
--   2+2x2:   top row split L/R, bottom is 2x2
--            [top-left=1, top-right=2, mid-left=3, mid-right=4, bot-left=5, bot-right=6]
-- Optional `extra_windows` spawns additional standalone wezterm windows
-- (separate from the main grid) each with its own cwd + command.
local layouts = {
    {
        label = "Portal Local Dev UI (prod API/DB)",
        grid = "1x1",
        panes = {
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/portal-local-dev-ui.md)\"\r",
        },
        extra_windows = {
            {
                cwd = "C:\\Users\\marcu\\p\\i\\p\\apps\\portal",
                cmd = "bun run dev\r",
            },
        },
    },
    {
        label = "Runner Development",
        grid = "2x2",
        row_split = 0.2,
        panes = {
            "cd ~/p/i/p; claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/runner-dev-planning.md)\"\r",
            "cd ~/p/i/p; claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/runner-monitor-loop.md)\"\r",
            "cd ~/p/i/p/packages/runner\r",
            "cd ~/p/i/p/packages/runner; bun run dev\r",
        },
    },
    {
        label = "Platinum Roofing - Monthly Ops",
        grid = "2+2x2",
        row_split = 0.7,  -- 70% bottom (2x2 scrape grid), 30% top (orchestrator + blog/social)
        panes = {
            -- All panes start in ~/o (PowerShell profile default) — no cd needed.
            -- 1: top-left — workspace orchestrator Claude.
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/platinum-roof/workspace.md)\"\r",
            -- 2: top-right — blog post + social media drafter (writes Next.js post, deploys via sync-cli, saves social drafts to KB).
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/platinum-roof/blog-and-social.md)\"\r",
            -- 3: mid-left — Google Business Profile scraper (headless plat-gmb-gmb).
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/platinum-roof/gmb-collection.md)\"\r",
            -- 4: mid-right — Google Search Console scraper (headless plat-gmb-gsc).
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/platinum-roof/gsc-collection.md)\"\r",
            -- 5: bot-left — Google Analytics via the analytics MCP (no browser).
            "& $HOME/p/_agent-workspace/portal/launch-claude-mcp.ps1 platinum-roofing analytics $HOME/o/business/knowledge/development/workspace-prompts/platinum-roof/ga-collection.md\r",
            -- 6: bot-right — Google Ads scraper (headless plat-gmb-ads).
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/platinum-roof/ads-collection.md)\"\r",
        },
    },
    {
        label = "Magnify Local Dev",
        grid = "1x1",
        panes = {
            "claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/magnify-local-dev.md)\"\r",
        },
    },
    {
        label = "Senate - Eva/LegBone",
        grid = "2x1",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "cd ~/p/leb\r",
        },
    },
    {
        label = "Senate - Eva Side-by-Side (Upgrade 4200 + Baseline 4201)",
        grid = "2x2-br2",
        panes = {
            -- 1: top-left — Claude at ~/o with an injected setup prompt
            -- (docker, evadb, VS). See the prompt file for the exact steps.
            "cd ~/o\rclaude --dangerously-skip-permissions \"$(cat ~/o/senate/knowledge/workspace-prompts/eva-side-by-side.md)\"\r",
            -- 2: top-right — second Claude instance at the default ~/o vault.
            "cd ~/o\rclaude --dangerously-skip-permissions\r",
            -- 3: bot-left — pi instance at the spinach-pi repo.
            "cd ~/p/spinach-pi; pi\r",
            -- 4: bot-right-left — ng serve on port 4200 (upgrade).
            "cd C:\\Users\\marcu\\p\\leb\\Eva\rnpm start\r",
            -- 5: bot-right-right — ng serve on port 4201 (baseline).
            "cd C:\\Users\\marcu\\p\\leb-baseline\\Eva\rnpm start -- --port 4201\r",
        },
    },
    {
        label = "Senate - Public Site",
        grid = "2x1",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "cd ~/p/senate-public-site-cms\r",
        },
    },
    {
        label = "Dual Claude",
        grid = "2x1",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "claude --dangerously-skip-permissions\r",
        },
    },
    {
        label = "Quad Claude",
        grid = "2x2",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "claude --dangerously-skip-permissions\r",
            "claude --dangerously-skip-permissions\r",
            "claude --dangerously-skip-permissions\r",
        },
    },
    {
        label = "Claude x2 + Codex + Pi",
        grid = "2x2",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "claude --dangerously-skip-permissions\r",
            "codex --yolo\r",
            "cd ~/p/spinach-pi; pi\r",
        },
    },
    {
        label = "Infra (Terraform + CLI)",
        grid = "2x2",
        panes = {
            "claude --dangerously-skip-permissions\r",
            "cd ~/p/i/p/infra\r",
            "cd ~/p/i/p/bin/sync-cli\r",
            "\r",
        },
    },
    {
        label = "Local Dev Env (dotfiles)",
        grid = "1x1",
        panes = {
            "cd ~/p/dotfiles; claude --dangerously-skip-permissions \"$(cat ~/o/business/knowledge/development/workspace-prompts/local-dev-env.md)\"\r",
        },
    },
    {
        -- Subagent observability dashboard (disler/claude-code-hooks-multi-agent-observability).
        -- Hooks in ~/.claude/hooks/observability/ post events to the server on :4000;
        -- the Vue client at :6173 visualizes them. Leave this layout running in its own
        -- wezterm window — every other Claude Code session will stream into it automatically.
        --
        -- Port note: vite's default 5173 falls inside Windows' reserved port range
        -- (5141–5240) on this machine and produces EACCES at bind time, so we pin
        -- VITE_PORT=6173 which is outside every reserved block.
        label = "Subagent Observability (server + dashboard)",
        grid = "1x2",
        row_split = 0.5,
        panes = {
            -- Top: Bun server (HTTP :4000 + WebSocket /stream, SQLite at apps/server/events.db)
            "cd ~/p/tools/claude-code-hooks-multi-agent-observability/apps/server; bun install; bun run dev\r",
            -- Bottom: Vite dev server for the Vue dashboard. Open http://localhost:6173 once it boots.
            "cd ~/p/tools/claude-code-hooks-multi-agent-observability/apps/client; $env:VITE_PORT=6173; bun install; bun run dev\r",
        },
    },
}

local layout_choices = {}
for i, layout in ipairs(layouts) do
    table.insert(layout_choices, { id = tostring(i), label = layout.label .. "  (" .. layout.grid .. ")" })
end

-- === ACTION MENU ===
-- Ctrl+. opens a palette of quick actions. Add entries here; each needs a
-- `label` and a `run(window, pane)` function.
local actions = {
    {
        label = "Open newest .md in ~/o (new tab)",
        run = function(window, pane)
            window:perform_action(
                wezterm.action.SpawnCommandInNewTab {
                    args = {
                        'pwsh', '-NoProfile', '-Command',
                        [[$f = Get-ChildItem -Path $HOME\o -Recurse -File -Filter *.md -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\\.(obsidian|git|trash)\\' -and $_.FullName -notmatch '\\node_modules\\' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if ($f) { nvim $f.FullName } else { Write-Host 'No markdown files found in ~/o'; Start-Sleep 2 }]],
                    },
                },
                pane
            )
        end,
    },
}

local action_choices = {}
for i, a in ipairs(actions) do
    table.insert(action_choices, { id = tostring(i), label = a.label })
end

local function spawn_layout(window, pane, layout)
    local panes = {}
    -- col_split: width of right column (default 0.5)
    -- row_split: height of bottom row (default 0.5)
    local cs = layout.col_split or 0.5
    local rs = layout.row_split or 0.5

    if layout.grid == "1x1" then
        panes = { pane }

    elseif layout.grid == "2x2" then
        local right = pane:split({ direction = "Right", size = cs })
        local bottom_left = pane:split({ direction = "Bottom", size = rs })
        local bottom_right = right:split({ direction = "Bottom", size = rs })
        panes = { pane, right, bottom_left, bottom_right }

    elseif layout.grid == "2x1" then
        local right = pane:split({ direction = "Right", size = cs })
        panes = { pane, right }

    elseif layout.grid == "1x2" then
        local bottom = pane:split({ direction = "Bottom", size = rs })
        panes = { pane, bottom }

    elseif layout.grid == "2x2-br2" then
        -- 2x2 layout with bottom-right cell further split vertically into 2.
        -- Panes (L→R, T→B): top-left, top-right, bot-left, bot-right-left, bot-right-right
        local right = pane:split({ direction = "Right", size = cs })
        local bot_left = pane:split({ direction = "Bottom", size = rs })
        local bot_right = right:split({ direction = "Bottom", size = rs })
        local bot_right_right = bot_right:split({ direction = "Right", size = 0.5 })
        panes = { pane, right, bot_left, bot_right, bot_right_right }

    elseif layout.grid == "1+2x2" then
        -- Top row: single pane spanning full width.
        -- Bottom: 2x2 grid (mid-left, mid-right, bot-left, bot-right).
        -- row_split = size of the lower region (the 2x2). Default 0.7 (70% bottom, 30% top).
        -- Panes (T→B, L→R): top-full, mid-left, mid-right, bot-left, bot-right
        local lower_size = layout.row_split or 0.7
        local mid_left = pane:split({ direction = "Bottom", size = lower_size })
        local mid_right = mid_left:split({ direction = "Right", size = 0.5 })
        local bot_left = mid_left:split({ direction = "Bottom", size = 0.5 })
        local bot_right = mid_right:split({ direction = "Bottom", size = 0.5 })
        panes = { pane, mid_left, mid_right, bot_left, bot_right }

    elseif layout.grid == "2+2x2" then
        -- Top row: 2 panes side by side. Bottom: 2x2 grid (4 panes).
        -- row_split = size of the lower region. Default 0.7 (70% bottom, 30% top).
        -- Panes (T→B, L→R): top-left, top-right, mid-left, mid-right, bot-left, bot-right
        --
        -- Split order matters: do the horizontal (Bottom) split FIRST so it spans
        -- the full window, then split top + bottom regions independently.
        -- Doing the Right split first would leave the right column full-height
        -- and the Bottom split would only carve the left column.
        local lower_size = layout.row_split or 0.7
        local mid_left = pane:split({ direction = "Bottom", size = lower_size })
        local top_right = pane:split({ direction = "Right", size = 0.5 })
        local mid_right = mid_left:split({ direction = "Right", size = 0.5 })
        local bot_left = mid_left:split({ direction = "Bottom", size = 0.5 })
        local bot_right = mid_right:split({ direction = "Bottom", size = 0.5 })
        panes = { pane, top_right, mid_left, mid_right, bot_left, bot_right }
    end

    -- Send commands to each pane
    for i, p in ipairs(panes) do
        if layout.panes[i] and layout.panes[i] ~= "" then
            p:send_text(layout.panes[i])
        end
    end

    -- Spawn any extra standalone windows (separate from the main grid).
    -- Note: passing `cwd` to spawn_window is unreliable on Windows — the
    -- user's PowerShell profile runs Set-Location on boot and overrides it.
    -- Same gotcha documented in ~/.claude/skills/wezterm/SKILL.md and worked
    -- around in scripts/new-window.ps1 (which sleeps ~2s after spawn before
    -- sending the cd). We replicate that here with wezterm.time.call_after:
    -- send the cd 2s after spawn (after the profile has finished loading
    -- and stopped consuming keystrokes), then send the cmd 400ms later.
    if layout.extra_windows then
        for _, w in ipairs(layout.extra_windows) do
            local _tab, new_pane, _win = wezterm.mux.spawn_window({
                cwd = w.cwd,
            })
            if new_pane then
                wezterm.time.call_after(2, function()
                    if w.cwd and w.cwd ~= "" then
                        new_pane:send_text('cd "' .. w.cwd .. '"\r')
                    end
                    wezterm.time.call_after(0.4, function()
                        if w.cmd and w.cmd ~= "" then
                            new_pane:send_text(w.cmd)
                        end
                        if w.split_right then
                            local right = new_pane:split({ direction = "Right", size = 0.5 })
                            right:send_text(w.split_right)
                        end
                    end)
                end)
            end
        end
    end
end

-- === AGENT PLAN LAUNCHER ===
-- Spawns a new tab with a pi orchestrator agent.
-- The orchestrator manages all subagent panes via wezterm cli.

local agent_plan_dir = "C:\\Users\\marcu\\p\\spinach-pi\\plans\\personal"

-- Scan for orchestrator.md files in plan directories
local function scan_agent_plans()
    local plans = {}
    local handle = io.popen('dir /b "' .. agent_plan_dir .. '" 2>nul')
    if handle then
        for dir in handle:lines() do
            local orch_path = agent_plan_dir .. "\\" .. dir .. "\\orchestrator.md"
            local f = io.open(orch_path, "r")
            if f then
                f:close()
                table.insert(plans, {
                    id = dir,
                    label = dir:gsub("%-", " "),
                    path = orch_path,
                })
            end
        end
        handle:close()
    end
    return plans
end

local function launch_agent_plan(window, pane, plan)
    pane:send_text(
        "$Host.UI.RawUI.WindowTitle = 'orchestrator'\r\n"
        .. "pi (Get-Content '" .. plan.path .. "' -Raw)\r\n"
    )
end

config.keys = {
    -- Ctrl+Shift+B: wallpaper picker
    {
        key = 'B',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.InputSelector {
            title = "Select Wallpaper",
            choices = picker_choices,
            action = wezterm.action_callback(function(window, pane, id, label)
                if id == nil then return end
                if id == "none" then
                    window:set_config_overrides({ window_background_image = "" })
                    return
                end
                local path
                if id == "random" then
                    path = pick_background()
                else
                    path = id
                end
                window:set_config_overrides({ window_background_image = path })
            end),
        },
    },

    -- Ctrl+Shift+P: agent plan launcher (scans spinach-pi/plans/personal/*/orchestrator.md)
    {
        key = 'P',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            local plans = scan_agent_plans()
            if #plans == 0 then
                wezterm.log_info("[wez-agent] No agent plans found")
                return
            end
            local choices = {}
            for i, p in ipairs(plans) do
                table.insert(choices, { id = tostring(i), label = p.label })
            end
            window:perform_action(
                wezterm.action.InputSelector {
                    title = "Launch Agent Plan",
                    choices = choices,
                    action = wezterm.action_callback(function(win, pn, id, label)
                        if id == nil then return end
                        launch_agent_plan(win, pn, plans[tonumber(id)])
                    end),
                },
                pane
            )
        end),
    },

    -- Ctrl+Shift+L: workspace layout launcher
    {
        key = 'L',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.InputSelector {
            title = "Launch Workspace",
            choices = layout_choices,
            action = wezterm.action_callback(function(window, pane, id, label)
                if id == nil then return end
                spawn_layout(window, pane, layouts[tonumber(id)])
            end),
        },
    },

    -- Ctrl+. : action menu (extensible palette of quick commands)
    {
        key = '.',
        mods = 'CTRL',
        action = wezterm.action.InputSelector {
            title = "Actions",
            choices = action_choices,
            fuzzy = true,
            action = wezterm.action_callback(function(window, pane, id, label)
                if id == nil then return end
                actions[tonumber(id)].run(window, pane)
            end),
        },
    },

    {
        key = 'q',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },

    -- Ctrl+U intentionally NOT bound here: a SendKey{Escape} remap broke
    -- Ctrl+U scroll-up inside nvim. Clear-line at the pwsh prompt is handled
    -- by PSReadLine (Set-PSReadLineKeyHandler Ctrl+u RevertLine) in $PROFILE.

    {
        key = 'M',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(-1),
    },

    {
        key = 'D',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(1),
    },

    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Left"),
    },

    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Right"),
    },

    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Down"),
    },

    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Up"),
    },

}

return config
