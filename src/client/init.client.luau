-- local HealthBarUI = require(script.Parent.Client.UI.HealthBarUI)
local HealthBarUIv2 = require(script.Parent.Client.UI.HealthBarUIv2)
local AppTabBar = require(script.UI.AppTabBar)
local FloatingMenuBar = require(script.UI.FloatingMenuBar)

print("Initializing client...")

HealthBarUIv2:Main()
AppTabBar:Main()
FloatingMenuBar:Main()
