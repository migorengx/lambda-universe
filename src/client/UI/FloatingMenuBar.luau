local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Lydie = require(Packages.Lydie)
local Fusion = require(Packages.Fusion)

local Components = Lydie.Components
local Modules = Lydie.Modules

local Scheme = Modules.Scheme

local StarterGui = game:GetService("StarterGui")
local Const = require(ReplicatedStorage.Shared.Const)

local windowVisible = Fusion.Value(true)

local toggleSprint = Fusion.Value(false)
local disconnectToggleSprint

local toggleLeaderboard = Fusion.Value(false)

local IconButton = Components.Controls.IconButton

local Icons = Modules.Icons

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

Scheme.SetAccent(Scheme.Color.Green)

local FloatingMenuBar = {}

function FloatingMenuBar:Main()
	-- Main function to initialize the floating menu bar
	Fusion.New("ScreenGui")({
		Parent = PlayerGui,
		[Fusion.Children] = {
			-- Components.Views.Window({
			-- 	Size = UDim2.new(0, 150, 0, 30),
			-- 	Position = UDim2.new(1, -100, 0, -25),
			-- 	Visible = windowVisible,
			-- 	ZIndex = 5,
			-- 	BackgroundTransparency = 1,
			-- 	BackgroundOpacity = 1,
			-- 	[Fusion.Children] = {
			Fusion.New("Frame")({
				BackgroundTransparency = 1,
				LayoutOrder = 1,

				Size = UDim2.new(0, 200, 0, 60),
				Position = UDim2.new(1, -5, 0, -57),
				AnchorPoint = Vector2.new(1, 0),

				[Fusion.Children] = {

					Fusion.New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0, 15),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					IconButton({
						BackgroundColor = Scheme.GetAnimated(Scheme.Accent),
						ForegroundColor = Scheme.GetAnimated(Scheme.Elevation[2]),
						Icon = Icons["person-standing"],
						BackgroundOpacity = 0.6,
						LayoutOrder = 1,
						OnClick = function()
							local isEnabled = toggleLeaderboard:get()
							StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not isEnabled)
							toggleLeaderboard:set(not isEnabled)
						end,
					}),

					IconButton({
						BackgroundColor = Scheme.GetAnimated(Scheme.Accent),
						ForegroundColor = Scheme.GetAnimated(Scheme.Elevation[2]),
						Icon = Icons["coins"],
						BackgroundOpacity = 0.6,
						LayoutOrder = 2,
						OnClick = function()
							print("IconButton Clicked")
						end,
					}),

					IconButton({
						BackgroundColor = Scheme.GetAnimated(Scheme.Accent),
						ForegroundColor = Scheme.GetAnimated(Scheme.Elevation[2]),
						Icon = Icons["gauge"],
						BackgroundOpacity = 0.6,
						LayoutOrder = 3,
						OnClick = function()
							print("IconButton Clicked")
							toggleSprint:set(not toggleSprint:get())
						end,
					}),
				},
			}),
		},
	})
	self:Connect()
end

function FloatingMenuBar:Connect()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	-- This function will run every time the player's character spawns
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")
		local observeSprint = Fusion.Observer(toggleSprint)
		disconnectToggleSprint = observeSprint:onChange(function()
			local sprint = toggleSprint:get()
			if sprint then
				-- Currently sprinting, so toggle to walk
				humanoid.WalkSpeed = Const.WalkSprint.SPRINT_SPEED
			else
				-- Currently walking, so toggle to sprint
				humanoid.WalkSpeed = Const.WalkSprint.WALK_SPEED
			end
		end)

		humanoid.Died:Connect(function()
			-- This code will run every time the local player's character dies
			disconnectToggleSprint()
			toggleSprint:set(false)
			-- You can add your custom death-related logic here,
			-- such as showing a death screen GUI.
		end)
	end

	-- Connect the function to the event
	player.CharacterAdded:Connect(onCharacterAdded)

	-- Acknowledge the current character if it already exists
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

function FloatingMenuBar:ToggleVisibility()
	-- Function to toggle the visibility of the floating menu bar
	windowVisible:set(not windowVisible:get())
end

return FloatingMenuBar
