-- Default fallback
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

local laptopDisplay = "BOE NE135A1M-NY1"
local tdSynnexMonitor = "Lenovo Group Limited P24h-2L V309TYTH"

local function monitor_matches_description(monitor, description)
  return monitor.description == description
    or monitor.description:sub(1, #description + 2) == description .. " ("
end

local function monitor_exists(description)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor_matches_description(monitor, description) then
      return true
    end
  end

  return false
end

local function move_workspace(workspace, monitor)
  hl.dispatch(hl.dsp.workspace.move({
    workspace = tostring(workspace),
    monitor = monitor
  }))
end

local function bind_workspaces(workspace_first, workspace_last, monitor, default_workspace)
  for workspace = workspace_first, workspace_last do
    hl.workspace_rule({
      workspace = tostring(workspace),
      monitor = monitor,
      default = workspace == default_workspace
    })
  end
end

local function move_workspaces(workspace_first, workspace_last, monitor)
  for workspace = workspace_first, workspace_last do
    move_workspace(workspace, monitor)
  end
end

local function apply_laptop_workspace_layout()
  local laptop = "desc:" .. laptopDisplay

  bind_workspaces(1, 10, laptop, 1)
  move_workspaces(1, 10, laptop)
end

local function apply_td_synnex_workspace_layout()
  local laptop = "desc:" .. laptopDisplay
  local tdSynnex = "desc:" .. tdSynnexMonitor

  bind_workspaces(1, 5, tdSynnex, 1)
  bind_workspaces(6, 10, laptop, 6)
  move_workspaces(1, 5, tdSynnex)
  move_workspaces(6, 10, laptop)
end

-- Internal laptop display (BOE NE135A1M-NY1) at 1.25x
hl.monitor({
  output = "desc:" .. laptopDisplay,
  mode = "2880x1920@120",
  position = "auto",
  scale = 1.25
})

-- TD Synnex workstation monitor
hl.monitor({
  output = "desc:" .. tdSynnexMonitor,
  mode = "2560x1440@74.78",
  position = "auto",
  scale = 1
})

if monitor_exists(tdSynnexMonitor) then
  apply_td_synnex_workspace_layout()
else
  apply_laptop_workspace_layout()
end

hl.on("monitor.added", function(monitor)
  if monitor_matches_description(monitor, tdSynnexMonitor) then
    apply_td_synnex_workspace_layout()
  end
end)

hl.on("monitor.removed", function(monitor)
  if monitor_matches_description(monitor, tdSynnexMonitor) then
    apply_laptop_workspace_layout()
  end
end)

-- -- External DP-6 (HP V27i G5)
-- hl.monitor({ output = "desc:DP-6", mode = "1920x1080@75", position = "auto", scale = 1 })
--
-- -- External DP-4 (Dell P2419HC)
-- hl.monitor({ output = "desc:DP-4", mode = "1920x1080@75", position = "auto", scale = 1 })
--
-- -- Workspace → monitor bindings
-- hl.workspace_rule({ workspace = "1",  monitor = "desc:BOE NE135A1M-NY1", default = true })
-- hl.workspace_rule({ workspace = "2",  monitor = "desc:BOE NE135A1M-NY1" })
-- hl.workspace_rule({ workspace = "3",  monitor = "desc:BOE NE135A1M-NY1" })
-- hl.workspace_rule({ workspace = "4",  monitor = "desc:BOE NE135A1M-NY1" })
--
-- hl.workspace_rule({ workspace = "5",  monitor = "desc:DP-6" })
-- hl.workspace_rule({ workspace = "6",  monitor = "desc:DP-6" })
-- hl.workspace_rule({ workspace = "7",  monitor = "desc:DP-6" })
--
-- hl.workspace_rule({ workspace = "8",  monitor = "desc:DP-4" })
-- hl.workspace_rule({ workspace = "9",  monitor = "desc:DP-4" })
-- hl.workspace_rule({ workspace = "10", monitor = "desc:DP-4" }
