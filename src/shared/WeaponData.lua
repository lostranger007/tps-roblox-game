--[[
	WeaponData Module
	Defines all weapon types and their statistics
	Configuration for different guns in the game
]]

local WeaponData = {}

WeaponData.Weapons = {
	-- PISTOLS
	Pistol = {
		Name = "Pistol",
		Type = "Pistol",
		Model = "Pistol",  -- Model name in ReplicatedStorage

		-- Damage
		Damage = 25,
		HeadshotMultiplier = 2.0,
		Range = 100,

		-- Firing
		FireRate = 0.2,  -- Time between shots (seconds)
		Automatic = false,
		BurstCount = 1,

		-- Ammo
		MagazineSize = 12,
		ReserveAmmo = 60,
		ReloadTime = 1.5,

		-- Accuracy
		Accuracy = 0.95,  -- 1.0 = perfect accuracy
		RecoilPattern = {
			Vertical = 0.3,
			Horizontal = 0.1,
			Recovery = 0.85,
		},

		-- Aiming
		AimSpeedMultiplier = 1.2,
		MovementSpeedMultiplier = 1.0,

		-- Effects
		MuzzleFlash = true,
		BulletTracer = true,
		SoundId = "rbxassetid://1234567890",  -- Replace with actual sound ID
	},

	-- ASSAULT RIFLES
	AssaultRifle = {
		Name = "Assault Rifle",
		Type = "Rifle",
		Model = "AssaultRifle",

		-- Damage
		Damage = 30,
		HeadshotMultiplier = 1.8,
		Range = 200,

		-- Firing
		FireRate = 0.1,
		Automatic = true,
		BurstCount = 1,

		-- Ammo
		MagazineSize = 30,
		ReserveAmmo = 120,
		ReloadTime = 2.0,

		-- Accuracy
		Accuracy = 0.85,
		RecoilPattern = {
			Vertical = 0.5,
			Horizontal = 0.2,
			Recovery = 0.75,
		},

		-- Aiming
		AimSpeedMultiplier = 0.8,
		MovementSpeedMultiplier = 0.85,

		-- Effects
		MuzzleFlash = true,
		BulletTracer = true,
		SoundId = "rbxassetid://1234567891",
	},

	-- SHOTGUNS
	Shotgun = {
		Name = "Shotgun",
		Type = "Shotgun",
		Model = "Shotgun",

		-- Damage
		Damage = 15,  -- Per pellet
		HeadshotMultiplier = 1.5,
		Range = 40,
		PelletCount = 8,  -- Multiple projectiles per shot

		-- Firing
		FireRate = 0.8,
		Automatic = false,
		BurstCount = 1,

		-- Ammo
		MagazineSize = 6,
		ReserveAmmo = 24,
		ReloadTime = 0.5,  -- Per shell
		ReloadType = "Individual",  -- Reload one shell at a time

		-- Accuracy
		Accuracy = 0.7,  -- Spread pattern
		RecoilPattern = {
			Vertical = 1.2,
			Horizontal = 0.3,
			Recovery = 0.6,
		},

		-- Aiming
		AimSpeedMultiplier = 0.7,
		MovementSpeedMultiplier = 0.9,

		-- Effects
		MuzzleFlash = true,
		BulletTracer = false,
		SoundId = "rbxassetid://1234567892",
	},

	-- SNIPER RIFLES
	SniperRifle = {
		Name = "Sniper Rifle",
		Type = "Sniper",
		Model = "SniperRifle",

		-- Damage
		Damage = 80,
		HeadshotMultiplier = 2.5,
		Range = 500,

		-- Firing
		FireRate = 1.5,
		Automatic = false,
		BurstCount = 1,

		-- Ammo
		MagazineSize = 5,
		ReserveAmmo = 20,
		ReloadTime = 3.0,

		-- Accuracy
		Accuracy = 0.99,
		RecoilPattern = {
			Vertical = 2.0,
			Horizontal = 0.1,
			Recovery = 0.5,
		},

		-- Aiming
		AimSpeedMultiplier = 0.5,
		MovementSpeedMultiplier = 0.7,
		ScopeZoom = 4.0,  -- FOV multiplier when scoped

		-- Effects
		MuzzleFlash = true,
		BulletTracer = true,
		SoundId = "rbxassetid://1234567893",
	},

	-- SUBMACHINE GUNS
	SMG = {
		Name = "SMG",
		Type = "SMG",
		Model = "SMG",

		-- Damage
		Damage = 20,
		HeadshotMultiplier = 1.6,
		Range = 80,

		-- Firing
		FireRate = 0.08,
		Automatic = true,
		BurstCount = 1,

		-- Ammo
		MagazineSize = 25,
		ReserveAmmo = 125,
		ReloadTime = 1.8,

		-- Accuracy
		Accuracy = 0.75,
		RecoilPattern = {
			Vertical = 0.4,
			Horizontal = 0.3,
			Recovery = 0.8,
		},

		-- Aiming
		AimSpeedMultiplier = 1.0,
		MovementSpeedMultiplier = 0.95,

		-- Effects
		MuzzleFlash = true,
		BulletTracer = true,
		SoundId = "rbxassetid://1234567894",
	},
}

--[[
	Gets weapon data by name
	@param weaponName: Name of the weapon
	@return: Weapon data table or nil
]]
function WeaponData.GetWeapon(weaponName)
	return WeaponData.Weapons[weaponName]
end

--[[
	Gets all weapons of a specific type
	@param weaponType: Type of weapon (Pistol, Rifle, etc.)
	@return: Array of weapon data
]]
function WeaponData.GetWeaponsByType(weaponType)
	local weapons = {}
	for name, data in pairs(WeaponData.Weapons) do
		if data.Type == weaponType then
			table.insert(weapons, data)
		end
	end
	return weapons
end

return WeaponData
