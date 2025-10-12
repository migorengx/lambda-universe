local ServerScriptService = game:GetService("ServerScriptService")
local HumanoidStateImplementation = require(script.HumanoidState.HumanoidStateImplementation)
local ProfileImplementation = require(ServerScriptService.Server.Profile.ProfileImplementation)
local CheckpointImplementation = require(ServerScriptService.Server.Checkpoint.CheckpointImplementation)

-- Stop Autoload
game.Players.CharacterAutoLoads = false

-- bind events
CheckpointImplementation:DisableAllSpawns()
CheckpointImplementation:SyncTouchSpawner()

local function onPlayerConnect(player)
	print(player.Name .. " has connected to the game.")

	task.wait(2)

	-- Handle character spawning
	local function handleCharacterAdded(character)
		print("Character added for " .. player.Name)
		-- Small delay to ensure character is fully loaded

		-- check essentials
		character:waitForChild("HumanoidRootPart")
		character:waitForChild("Humanoid")

		-- Teleport to checkpoint
		CheckpointImplementation:TeleportToCheckpoint(player, character)

		-- Monitor humanoid state changes
		HumanoidStateImplementation:ConnectStateChanged(player, character, function(oldState, newState)
			print("Humanoid state changed from", oldState, "to", newState)
		end)
	end

	-- Connect character added event
	player.CharacterAdded:Connect(handleCharacterAdded)

	-- Initial character load
	task.spawn(function()
		player:LoadCharacter()
	end)
end

local function onPlayerDisconnect(player)
	print(player.Name .. " has disconnected from the game.")
end

ProfileImplementation:Initialize(onPlayerConnect, onPlayerDisconnect)
