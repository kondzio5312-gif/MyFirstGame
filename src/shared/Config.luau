--[[
    Config.lua
]]

local Config = {}

Config.Combat = {
	BaseDamage = {
		Light = 10,
		Medium = 15,
		Heavy = 25
	},

	Cooldowns = {
		LightAttack = 0.5,
		HeavyAttack = 1.2,
		Dash = 2.0
	},

	ComboTimeout = 0.8,
	MaxComboHits = 3,
	IFrameDuration = 0.2,

	RaycastDistance = 8,
	HitboxUpdateRate = 0.03
}

Config.Player = {
	BaseHealth = 1000,
	BaseMoveSpeed = 16,
	DashSpeed = 50,         -- 2x długość postaci (~10 studs)
	DashDuration = 0.2
}

Config.WeaponStyles = {
	Speed = {
		Name = "Speed Style",
		DamageMultiplier = 0.8,
		AttackSpeed = 1.3,
		Range = 6
	},
	Balanced = {
		Name = "Balanced Style",
		DamageMultiplier = 1.0,
		AttackSpeed = 1.0,
		Range = 8
	},
	Heavy = {
		Name = "Heavy Style",
		DamageMultiplier = 1.4,
		AttackSpeed = 0.7,
		Range = 10
	}
}

Config.Arena = {
	Size = 100,
	SpawnHeight = 5,
	DummySpawnPosition = Vector3.new(0, 5, 20)
}

return Config
