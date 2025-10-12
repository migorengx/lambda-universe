local LeaderboardImplementation = {}

function LeaderboardImplementation:Connect(player)
	-- Create a new folder named "leaderstats" for the player
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Add a Checkpoint to the leaderstats folder
	local checkpoint = Instance.new("IntValue")
	checkpoint.Name = "Checkpoint"
	checkpoint.Value = 0 -- Set the starting value
	checkpoint.Parent = leaderstats

	--- Add a Summit to the leaderstats folder
	local summit = Instance.new("IntValue")
	summit.Name = "Summit"
	summit.Value = 0 -- Set the starting value
	summit.Parent = leaderstats
end

function LeaderboardImplementation:UpdateCheckpoint(player, checkpoint)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("No leaderstats found for player:", player.Name)
		return
	end

	local lcheckpoint = leaderstats:FindFirstChild("Checkpoint")
	if not lcheckpoint then
		warn("No Checkpoint stat found for player:", player.Name)
		return
	end

	lcheckpoint.Value = checkpoint.numberCheckpoint or 0

	local lsummit = leaderstats:FindFirstChild("Summit")
	if not lsummit then
		warn("No Summit stat found for player:", player.Name)
		return
	end

	lsummit.Value = checkpoint.numberSummit or 0
end

return LeaderboardImplementation
