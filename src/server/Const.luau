local Const = {}

Const.DefaultPosition = Vector3.new(-1024, -13.5, 105)

Const.CheckpointTemplate = {
	currentCheckpoint = "default",
	numberCheckpoint = 0,
	numberSummit = 0,
	numberDeath = 0,
}

Const.ProfileTemplate = {
	Cash = 0,
	Level = 1,
	Experience = 0,
	Inventory = {},
	checkpoints = {},
	Donations = 0,
	IsDonor = false,
	LogInTimes = 0,
}

Const.DamageTemplate = {
	MINIMUM_FALL_DISTANCE = 20, -- minimum Y distance for fall damage
	MINIMUM_FALL_TIME = 1, -- minimum time in seconds for fall damage
	DAMAGE_MULTIPLIER = 0.75, -- damage multiplier per unit of fall distance
	MAX_FALL_DAMAGE = 60, -- maximum possible fall damage
	MAX_HEALTH = 100, -- maximum health
}

return Const
