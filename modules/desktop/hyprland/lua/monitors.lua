-- Default fallback
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Internal laptop display (BOE NE135A1M-NY1) at 1.25x
hl.monitor({ output = "desc:BOE NE135A1M-NY1", mode = "2880x1920@120", position = "auto", scale = 1.25 })

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
-- hl.workspace_rule({ workspace = "10", monitor = "desc:DP-4" })
