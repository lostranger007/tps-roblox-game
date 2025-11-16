--[[
	BiomeSystem Module
	Manages different biomes and terrain variations
	Determines vegetation, structures, and terrain features
]]

local BiomeSystem = {}

-- Biome types
BiomeSystem.BiomeTypes = {
	Plains = {
		Name = "Plains",
		Color = Color3.fromRGB(120, 180, 80),
		TreeDensity = 0.02,
		GrassDensity = 0.3,
		Materials = {
			Surface = Enum.Material.Grass,
			SubSurface = Enum.Material.Ground,
		},
		HeightMultiplier = 0.7,  -- Flatter terrain
	},

	Forest = {
		Name = "Forest",
		Color = Color3.fromRGB(60, 120, 40),
		TreeDensity = 0.15,
		GrassDensity = 0.5,
		Materials = {
			Surface = Enum.Material.Grass,
			SubSurface = Enum.Material.Ground,
		},
		HeightMultiplier = 0.9,
	},

	Mountains = {
		Name = "Mountains",
		Color = Color3.fromRGB(100, 100, 100),
		TreeDensity = 0.01,
		GrassDensity = 0.1,
		Materials = {
			Surface = Enum.Material.Rock,
			SubSurface = Enum.Material.Rock,
		},
		HeightMultiplier = 1.5,  -- Higher peaks
	},

	Desert = {
		Name = "Desert",
		Color = Color3.fromRGB(210, 180, 100),
		TreeDensity = 0,
		GrassDensity = 0,
		Materials = {
			Surface = Enum.Material.Sand,
			SubSurface = Enum.Material.Sandstone,
		},
		HeightMultiplier = 0.5,  -- Mostly flat with dunes
	},

	Tundra = {
		Name = "Tundra",
		Color = Color3.fromRGB(200, 210, 220),
		TreeDensity = 0.005,
		GrassDensity = 0.05,
		Materials = {
			Surface = Enum.Material.Snow,
			SubSurface = Enum.Material.Ice,
		},
		HeightMultiplier = 0.8,
	},
}

--[[
	Determines biome at a given position using noise
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: World seed
	@return: Biome data table
]]
function BiomeSystem.GetBiome(x, z, seed)
	-- Use noise to determine biome
	local temperature = math.noise(x * 0.001, z * 0.001, seed + 500)
	local moisture = math.noise(x * 0.001, z * 0.001, seed + 1500)
	local height = math.noise(x * 0.002, z * 0.002, seed + 2500)

	-- Normalize to 0-1
	temperature = (temperature + 1) / 2
	moisture = (moisture + 1) / 2
	height = (height + 1) / 2

	-- Determine biome based on temperature and moisture
	if height > 0.7 then
		return BiomeSystem.BiomeTypes.Mountains
	elseif temperature < 0.3 then
		return BiomeSystem.BiomeTypes.Tundra
	elseif moisture < 0.3 then
		return BiomeSystem.BiomeTypes.Desert
	elseif moisture > 0.6 and temperature > 0.4 then
		return BiomeSystem.BiomeTypes.Forest
	else
		return BiomeSystem.BiomeTypes.Plains
	end
end

--[[
	Gets the surface material for a position based on biome and height
	@param x: X coordinate
	@param z: Z coordinate
	@param height: Terrain height
	@param seed: World seed
	@return: Material enum
]]
function BiomeSystem.GetMaterial(x, z, height, seed)
	local biome = BiomeSystem.GetBiome(x, z, seed)

	-- Water
	if height < 35 then
		return Enum.Material.Water
	end

	-- Beach/shore
	if height < 40 then
		return Enum.Material.Sand
	end

	-- Use biome material
	if height < 80 then
		return biome.Materials.Surface
	end

	-- High altitude (mountains/snow)
	if height > 90 then
		return Enum.Material.Snow
	else
		return Enum.Material.Rock
	end
end

--[[
	Determines if a tree should spawn at this location
	@param x: X coordinate
	@param z: Z coordinate
	@param height: Terrain height
	@param seed: World seed
	@return: Boolean indicating if tree should spawn
]]
function BiomeSystem.ShouldSpawnTree(x, z, height, seed)
	-- Don't spawn in water or very high altitudes
	if height < 38 or height > 95 then
		return false
	end

	local biome = BiomeSystem.GetBiome(x, z, seed)

	-- Use noise to randomly place trees based on biome density
	local treeNoise = math.noise(x * 0.1, z * 0.1, seed + 3000)
	return treeNoise > (1 - biome.TreeDensity * 2)
end

--[[
	Gets biome color for visualization/debugging
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: World seed
	@return: Color3 value
]]
function BiomeSystem.GetBiomeColor(x, z, seed)
	local biome = BiomeSystem.GetBiome(x, z, seed)
	return biome.Color
end

return BiomeSystem
