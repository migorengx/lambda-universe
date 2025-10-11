----- Private Variables -----
local ServerScriptService = game:GetService("ServerScriptService")
local Promise = require(game:GetService("ReplicatedStorage").Packages.Promise)

local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)

local ProfileTemplate = require(ServerScriptService.Server.Const).ProfileTemplate
local CheckpointTemplate = require(ServerScriptService.Server.Const).CheckpointTemplate

local Players = game:GetService("Players")

local placeId = game.PlaceId

local ProfileImplementation = {}

function DefaultInitCheckpoint(mapId, checkpointTemplate)
	ProfileTemplate.checkpoints[mapId] = checkpointTemplate
	return ProfileTemplate
end

local GameProfileStore =
	ProfileService.GetProfileStore("PlayerData", DefaultInitCheckpoint(placeId, CheckpointTemplate))

local Profiles = {} -- [player] = profile

----- Private Functions -----

function InitializeUnexpectedPlayer()
	-- In case Players have joined the server earlier than this script ran:
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PlayersAdded, player)
	end
end
function PlayersAdded(player)
	return Promise.new(function(resolve, reject)
		local success, err = pcall(function()
			local profile = GameProfileStore:LoadProfileAsync("Player_" .. player.UserId)
			print("Loaded profile for ", profile)
			-- if player is new on this place, init their checkpoint data
			if profile ~= nil then
				profile:AddUserId(player.UserId) -- GDPR compliance
				profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
				profile:ListenToRelease(function()
					Profiles[player] = nil
					-- The profile could've been loaded on another Roblox server:
					player:Kick()
				end)
				if player:IsDescendantOf(Players) == true then
					Profiles[player] = profile
					-- A profile has been successfully loaded:
				else
					-- Player left before the profile loaded:
					profile:Release()
					warn("Player left before the profile loaded")
				end
			else
				-- The profile couldn't be loaded possibly due to other
				--   Roblox servers trying to load this profile at the same time:
				player:Kick()
				warn("Profile couldn't be loaded")
			end
		end)
		if not success then
			reject(err)
		end
		resolve(player)
	end)
end

----- Public Functions -----

function ProfileImplementation:Initialize(connectFn, disconnectFn)
	InitializeUnexpectedPlayer()
	-- load profile previously saved data
	ProfileImplementation:Connect(connectFn, disconnectFn)
end

function ProfileImplementation:GetProfile(player)
	return Profiles[player]
end

function ProfileImplementation:UpdateProfile(player: Player, data: { [string]: any })
	local profile = self:GetProfile(player)
	if profile then
		for key, value in pairs(data) do
			profile.Data[key] = value
		end
	end
end

function ProfileImplementation:Connect(connectFn, disconnectFn)
	Players.PlayerAdded:Connect(function(a0: Player)
		PlayersAdded(a0):andThen(function(player)
			warn("success to load profile for ", player.Name)
			if connectFn then
				connectFn(player)
			end
		end):catch(function(err)
			warn("Failed to load profile for ", a0.Name)
			warn(err)
			if disconnectFn then
				disconnectFn(a0)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:Release()
			disconnectFn(player)
		end
	end)
end

return ProfileImplementation
