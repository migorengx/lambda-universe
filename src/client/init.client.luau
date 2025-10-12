local HealthBarUI = require(script.Parent.Client.UI.HealthBarUI)
local AppTabBar = require(script.UI.AppTabBar)
local FloatingMenuBar = require(script.UI.FloatingMenuBar)

print("Initializing client...")
HealthBarUI:Initialize()

AppTabBar:Main()
FloatingMenuBar:Main()
