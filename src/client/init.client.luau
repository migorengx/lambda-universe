local HealthBarUIv2 = require(script.Parent.Client.UI.HealthBarUIv2)
local AppTabBar = require(script.UI.AppTabBar)
local FloatingMenuBar = require(script.UI.FloatingMenuBar)
local FloatingDonationWindow = require(script.UI.FloatingDonationWindow)

print("Initializing client...")

HealthBarUIv2:Main()
AppTabBar:Main()
FloatingMenuBar:Main()
FloatingDonationWindow:Main()
