----- Private Variables -----

local ServerScriptService = game:GetService("ServerScriptService")
local Const = require(ServerScriptService.Server.Const)
local ProfileImplementation = require(ServerScriptService.Server.Profile.ProfileImplementation)
local LeaderboardImplementation = require(ServerScriptService.Server.Leaderboard.LeaderboardImplementation)
local CheckpointImplementation = {}
local placeId = game.PlaceId
local stringPlaceId = tostring(placeId)

----- Public Functions -----
function CheckpointImplementation:TeleportToCheckpoint(player, character)
	print("Teleporting player to checkpoint...")

	-- Wait for character to load if not already loaded
	if character:FindFirstChild("HumanoidRootPart") then
		print("Waiting for character and HumanoidRootPart to load...")
		repeat
			task.wait()
		until character and character:FindFirstChild("HumanoidRootPart")
	end

	local profile = ProfileImplementation:GetProfile(player)

	if profile == nil or profile.Data.checkpoints[stringPlaceId] == nil then
		warn("No checkpoint data for player: " .. player.Name)
		player.Character.HumanoidRootPart.CFrame = CFrame.new(Const.DefaultPosition)
		return
	end

	local checkpointData = profile.Data.checkpoints[stringPlaceId]
	print("Checkpoint data for player: ", checkpointData)
	local checkpointName = checkpointData.currentCheckpoint
	print("Player's checkpoint name: " .. checkpointName)

	-- validate if checkpoint exist
	local checkpoint = workspace.Checkpoint:FindFirstChild(checkpointName)
	if not checkpoint then
		warn("Checkpoint '" .. checkpointName .. "' not found in workspace for player: " .. player.Name)
		player.Character.HumanoidRootPart.CFrame = CFrame.new(Const.DefaultPosition)
		print("Teleported player to default checkpoint")
		return
	end

	-- leaderboard update
	LeaderboardImplementation:Connect(player)
	LeaderboardImplementation:UpdateCheckpoint(player, checkpointData)

	print("Found checkpoint in workspace:", checkpoint:GetFullName())
	-- teleport player to checkpoint
	local targetCFrame = checkpoint.CFrame + Vector3.new(0, 5, 0) -- add offset to avoid spawn inside the ground
	player.Character.HumanoidRootPart.CFrame = targetCFrame
	print("Teleported " .. player.Name .. " to checkpoint: " .. checkpoint.Name)
end

function CheckpointImplementation:GetPlayerCheckpointByProfile(profile)
	print("Retrieved profile for player: ", profile)
	if profile == nil then
		return nil
	end

	local checkpoint = profile.Data.checkpoints[stringPlaceId]

	-- if checkpoint for this placeId not exist, return nil
	if checkpoint == nil then
		return nil
	end

	print("Retrieved checkpoint data for player: ", checkpoint.currentCheckpoint)

	return checkpoint.currentCheckpoint
end

function CheckpointImplementation:GetPlayerCheckpoint(player)
	local profile = ProfileImplementation:GetProfile(player)
	print("Retrieved profile for player: ", profile)
	if profile == nil then
		warn("Profile not found for player: " .. player.Name)
		return nil
	end

	local checkpoint = profile.Data.checkpoints[stringPlaceId]

	-- if checkpoint for this placeId not exist, return nil
	if checkpoint == nil then
		warn("No checkpoint data for player: " .. player.Name)
		return nil
	end

	print("Retrieved checkpoint data for player: ", checkpoint.currentCheckpoint)

	return checkpoint.currentCheckpoint
end

function CheckpointImplementation:UpdatePlayerCheckpoint(profile, checkpointName, callbackFn)
	-- local profile = ProfileImplementation:GetProfile(player)
	if profile == nil then
		warn("Profile not found ")
		return
	end
	-- print("Found profile:", profile)

	local checkpoint = profile.Data.checkpoints[stringPlaceId]

	-- if checkpoint for this placeId not exist, create new one using from template in Const
	if checkpoint == nil then
		checkpoint = table.clone(Const.CheckpointTemplate)
		checkpoint.currentCheckpoint = checkpointName
		checkpoint.numberCheckpoint = self:GenerateNumberCheckpoint(checkpointName)
		if checkpointName == "summit" then
			checkpoint.currentCheckpoint = "default"
			checkpoint.numberCheckpoint = 0
			checkpoint.numberSummit = checkpoint.numberSummit + 1
		end
		profile.Data.checkpoints[stringPlaceId] = checkpoint
	else
		if checkpoint.currentCheckpoint ~= checkpointName then
			print("Updating existing checkpoint from", checkpoint.currentCheckpoint, "to", checkpointName)
			checkpoint.currentCheckpoint = checkpointName
			checkpoint.numberCheckpoint = self:GenerateNumberCheckpoint(checkpointName)
			if checkpointName == "summit" then
				checkpoint.currentCheckpoint = "default"
				checkpoint.numberCheckpoint = 0
				checkpoint.numberSummit = checkpoint.numberSummit + 1
			end
			profile.Data.checkpoints[stringPlaceId] = checkpoint
		else
			print("Checkpoint already set to", checkpointName, "- no update needed")
			return
		end
	end

	-- save profile data
	print("Saving profile data...")
	profile:Save()
	if callbackFn then
		callbackFn(checkpoint)
	end
	print("Successfully updated checkpoint to: " .. checkpointName)
end

function CheckpointImplementation:GenerateNumberCheckpoint(checkpointName)
	if not checkpointName:find("cp") then
		return 0
	end
	local cpNumber = tonumber(string.match(checkpointName, "cp(%d+)"))
	return cpNumber
end

function CheckpointImplementation:DisableAllSpawns()
	for _, obj in pairs(workspace.Checkpoint:GetDescendants()) do
		if obj:IsA("SpawnLocation") then
			-- Disable all spawn locations
			obj.Enabled = false
		end
	end
end

function CheckpointImplementation:SyncTouchSpawner()
	for _, checkpoint in pairs(workspace.Checkpoint:GetChildren()) do
		if checkpoint:IsA("SpawnLocation") then
			-- connect touch event with debounce event
			checkpoint.Touched:Connect(function(hit)
				-- print("Checkpoint touched:", checkpoint.Name, "by", hit.Name)
				-- check only if human character
				local hitP = hit.Parent
				-- check if hit is a character
				if not hitP:IsA("Model") then
					-- print("Hit parent is not a Model:", hitP.Name)
					return
				end
				-- check if hit is a character
				if not hitP:FindFirstChild("Humanoid") then
					-- print("No Humanoid found for character:", hitP.Name)
					return
				end
				-- check if hit is a character
				if not hitP:FindFirstChild("HumanoidRootPart") then
					-- print("No HumanoidRootPart found for character:", hitP.Name)
					return
				end
				local player = game.Players:GetPlayerFromCharacter(hitP)
				-- check if player type is not human is stop
				if not player then
					-- print("No player found for character:", hitP.Name)
					return
				end

				local profile = ProfileImplementation:GetProfile(player)

				local cp = CheckpointImplementation:GetPlayerCheckpointByProfile(profile)

				if cp == checkpoint.Name then
					return
				end
				-- update player checkpoint data
				CheckpointImplementation:UpdatePlayerCheckpoint(profile, checkpoint.Name, function(updatedCheckpoint)
					print("Checkpoint updated callback:", updatedCheckpoint)
					LeaderboardImplementation:UpdateCheckpoint(player, updatedCheckpoint)
				end)
			end)
		end
	end
end

return CheckpointImplementation
