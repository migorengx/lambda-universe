local Players = game:GetService("Players")

local HealthBarUI = {}

-- Constants
local BAR_WIDTH = 200
local BAR_HEIGHT = 20
local PADDING = 10

function HealthBarUI:CreateHealthBar()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HealthUI"
	screenGui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Name = "HealthBarFrame"
	frame.Size = UDim2.new(0, BAR_WIDTH, 0, BAR_HEIGHT)
	frame.Position = UDim2.new(0, PADDING, 1, -(BAR_HEIGHT + PADDING))
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local fill = Instance.new("Frame")
	fill.Name = "HealthFill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	fill.BorderSizePixel = 0
	fill.Parent = frame

	local text = Instance.new("TextLabel")
	text.Name = "HealthText"
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0
	text.TextStrokeColor3 = Color3.new(0, 0, 0)
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Parent = frame

	return screenGui
end

function HealthBarUI:UpdateHealthBar(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local gui = player.PlayerGui:FindFirstChild("HealthUI")
	if not gui then
		return
	end

	local frame = gui.HealthBarFrame
	local fill = frame.HealthFill
	local text = frame.HealthText

	-- Update health bar
	local healthPercent = humanoid.Health / humanoid.MaxHealth
	fill.Size = UDim2.new(healthPercent, 0, 1, 0)

	-- Update color based on health percentage
	local r = math.min(2 - (2 * healthPercent), 1)
	local g = math.min(2 * healthPercent, 1)
	fill.BackgroundColor3 = Color3.new(r, g, 0)

	-- Update text
	text.Text = string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
end

function HealthBarUI:Initialize()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			-- Create health bar UI
			local healthBar = self:CreateHealthBar()
			healthBar.Parent = player.PlayerGui

			-- Update health bar when health changes
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.HealthChanged:Connect(function()
				self:UpdateHealthBar(player)
			end)

			-- Initial update
			self:UpdateHealthBar(player)
		end)
	end)
end

return HealthBarUI
