local ServerScriptService = game:GetService("ServerScriptService")
local DamageImplementation = require(ServerScriptService.Server.Damage.DamageImplementation)

local HumanoidStateImplementation = {}

local HumanState = {
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.RunningNoPhysics,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.Freefall,
} -- public function --

function HumanoidStateImplementation:GetHumanoidState(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid:GetState()
	end
	return Enum.HumanoidStateType.Physics
end

function HumanoidStateImplementation:SetHumanoidState(character, state)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:SetState(state)
	end
end

function HumanoidStateImplementation:IsHumanoidState(character, state)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid:GetState() == state
	end
	return false
end

-- disconnect state when character is removed
function HumanoidStateImplementation:ConnectStateChanged(player, character, callback)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		DamageImplementation:SetupCharacter(player, humanoid, character)
		humanoid.StateChanged:Connect(function(oldState, newState)
			print("Humanoid state changed from", oldState, "to", newState)

			-- Handle fall damage through DamageImplementation
			DamageImplementation:HandleFallState(player, character, humanoid, oldState, newState)

			callback(oldState, newState)
		end)
	end
end

return HumanoidStateImplementation
