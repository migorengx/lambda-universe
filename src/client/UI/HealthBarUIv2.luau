local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Lydie = require(Packages.Lydie)
local Fusion = require(Packages.Fusion)

local Components = Lydie.Components
local Modules = Lydie.Modules

local Scheme = Modules.Scheme

local frameTransparency = Fusion.Value(0.3)

local HealthBarUIv2 = {}

function HealthBarUIv2:Main()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

	-- Place this LocalScript in StarterPlayerScripts
	local LocalPlayer = Players.LocalPlayer

	-- Check if LocalPlayer is available before proceeding
	if LocalPlayer then
		print("-- detect ui -- ")
		self:Create() -- Call your UI creation function

		-- Use the CharacterAdded event to handle respawns
		local function onCharacterAdded(character)
			-- Update health bar when health changes
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.HealthChanged:Connect(function()
				HealthBarUIv2:Update(LocalPlayer)
			end)
			-- Initial update
			HealthBarUIv2:Update(LocalPlayer)
		end

		-- Connect the event for future character spawns
		LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

		-- Call the function immediately if the character already exists
		if LocalPlayer.Character then
			onCharacterAdded(LocalPlayer.Character)
		end
	end
end

function HealthBarUIv2:Create()
	Fusion.New("ScreenGui")({
		Name = "HealthGUI",
		ResetOnSpawn = false,
		Parent = PlayerGui,
		[Fusion.Children] = {
			Fusion.New("Frame")({
				Name = "HealthFrame",
				BackgroundTransparency = frameTransparency,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 100, 0, 5),
				Position = UDim2.new(0.5, 0, 0.825, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				[Fusion.Children] = {
					Fusion.New("Frame")({
						Name = "HealthBar",
						BackgroundTransparency = frameTransparency,
						BackgroundColor3 = Color3.fromRGB(204, 255, 202),
						Size = UDim2.new(1, 0, 1, 0),
					}),
				},
			}),
		},
	})
end

function HealthBarUIv2:Update(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local gui = player.PlayerGui:FindFirstChild("HealthGUI")
	if not gui then
		return
	end

	local frame = gui.HealthFrame
	local fill = frame.HealthBar

	-- Update health bar
	local healthPercent = humanoid.Health / humanoid.MaxHealth

	fill.Size = UDim2.new(healthPercent, 0, 1, 0)

	-- Update color based on health percentage
	local r = math.min(2 - (2 * healthPercent), 1)
	local g = math.min(2 * healthPercent, 1)
	fill.BackgroundColor3 = Color3.new(r, g, 0)

	-- Update text
	-- text.Text = string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
end

return HealthBarUIv2
