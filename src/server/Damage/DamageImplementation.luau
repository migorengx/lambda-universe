----- Private Variables -----
local Const = require(game:GetService("ServerScriptService").Server.Const)
local DamageImplementation = {}

-- Track fall start position and time for each player
local fallData = {} -- { userId = { startY = number, startTime = number } }

----- Private Functions -----
local function calculateFallDamage(fallDistance: number, fallTime: number): number
	if
		fallDistance < Const.DamageTemplate.MINIMUM_FALL_DISTANCE
		or fallTime < Const.DamageTemplate.MINIMUM_FALL_TIME
	then
		return 0
	end

	local damage = (fallDistance - Const.DamageTemplate.MINIMUM_FALL_DISTANCE) * Const.DamageTemplate.DAMAGE_MULTIPLIER
	return math.min(damage, Const.DamageTemplate.MAX_FALL_DAMAGE)
end

----- Public Functions -----
function DamageImplementation:HandleFallState(
	player: Player,
	character: Model,
	oldState: Enum.HumanoidStateType,
	newState: Enum.HumanoidStateType
)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local currentY = character.HumanoidRootPart.Position.Y
	local userId = player.UserId

	-- Starting to fall
	if newState == Enum.HumanoidStateType.Freefall then
		fallData[userId] = {
			startY = currentY,
			startTime = os.clock(),
		}
		print(player.Name .. " started falling from height: " .. currentY)

	-- Ending fall
	elseif oldState == Enum.HumanoidStateType.Freefall then
		local data = fallData[userId]
		if data then
			local fallDistance = data.startY - currentY
			local fallTime = os.clock() - data.startTime

			-- Calculate and apply damage if conditions are met
			local damage = calculateFallDamage(fallDistance, fallTime)
			if damage > 0 then
				print(
					string.format(
						"%s fell %.1f studs over %.1f seconds. Taking %.0f damage",
						player.Name,
						fallDistance,
						fallTime,
						damage
					)
				)

				-- Apply camera shake or feedback
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart then
					-- Optional: Add impact effect
					local effect = Instance.new("Part")
					effect.Size = Vector3.new(1, 1, 1)
					effect.Position = humanoidRootPart.Position
					effect.Anchored = true
					effect.CanCollide = false
					effect.Transparency = 0.5
					effect.Parent = workspace
					game:GetService("Debris"):AddItem(effect, 0.5)
				end

				self:DamageCharacter(player, damage)
			end

			-- Clear fall data
			fallData[userId] = nil
		end
	end
end

function DamageImplementation:DamageCharacter(player: Player, amount: number)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	-- Apply damage
	humanoid.Health = math.max(0, humanoid.Health - amount)
end

function DamageImplementation:Initialize()
	local Players = game:GetService("Players")

	-- Clean up fall data when players leave
	Players.PlayerRemoving:Connect(function(player)
		fallData[player.UserId] = nil
	end)
end

function DamageImplementation:SetupCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	-- Set initial health
	humanoid.MaxHealth = Const.DamageTemplate.MAX_HEALTH
	humanoid.Health = Const.DamageTemplate.MAX_HEALTH

	-- Track last damage to prevent regeneration
	local lastHealth = humanoid.Health

	-- Handle damage feedback and prevent regeneration
	humanoid.HealthChanged:Connect(function(health)
		if health > lastHealth then
			-- Prevent health regeneration by resetting to last damage value
			humanoid.Health = lastHealth
		else
			-- Update last health if damage was taken
			lastHealth = health

			-- Visual feedback when taking damage
			local torso = character:FindFirstChild("HumanoidRootPart")
			if torso then
				local originalColor = torso.Color
				torso.Color = Color3.new(1, 0, 0) -- Red
				task.delay(0.2, function()
					torso.Color = originalColor
				end)
			end
		end
	end)

	-- Handle death
	humanoid.Died:Connect(function()
		-- Play death animation with retry mechanism
		if humanoid:FindFirstChild("Animator") then
			local animator = humanoid:FindFirstChild("Animator")
			local animation = Instance.new("Animation")
			-- animation.AnimationId = "rbxassetid://YOUR_DEATH_ANIMATION_ID" -- Replace with your death animation ID

			-- Retry mechanism with exponential backoff
			local function loadAnimationWithRetry(maxAttempts)
				local attempts = 0
				local baseDelay = 1 -- Base delay in seconds

				local function attempt()
					attempts = attempts + 1
					local success, result = pcall(function()
						return animator:LoadAnimation(animation)
					end)

					if success then
						return result
					elseif attempts < maxAttempts then
						local delay = baseDelay * (2 ^ (attempts - 1)) -- Exponential backoff
						print(
							"Asset load failed, retrying in "
								.. delay
								.. " seconds (Attempt "
								.. attempts
								.. "/"
								.. maxAttempts
								.. ")"
						)
						task.wait(delay)
						return attempt()
					else
						warn("Failed to load animation after " .. attempts .. " attempts")
						return nil
					end
				end

				return attempt()
			end

			local animTrack = loadAnimationWithRetry(3) -- Try up to 3 times
			if animTrack then
				animTrack:Play()
			end
		end

		print(player.Name .. " died!")
		task.wait(2) -- Wait for animation to play
		player:LoadCharacter() -- Respawn
	end)
end

return DamageImplementation
