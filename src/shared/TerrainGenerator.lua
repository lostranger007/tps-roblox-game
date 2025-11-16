--[[
	TerrainGenerator Module
	Handles procedural terrain generation using Perlin noise
	Creates realistic hills, valleys, and varied landscapes
]]

local TerrainGenerator = {}

-- Configuration
TerrainGenerator.Config = {
	-- Terrain size
	ChunkSize = 256,  -- Size of each chunk in studs
	TerrainHeight = 100,  -- Maximum terrain height
	WaterLevel = 35,  -- Water level height

	-- Noise parameters for realistic terrain
	NoiseScale = 0.01,  -- Base terrain scale (lower = larger features)
	Octaves = 4,  -- Number of noise layers for detail
	Persistence = 0.5,  -- How much each octave contributes
	Lacunarity = 2.0,  -- Frequency multiplier for each octave

	-- Detail noise for small features
	DetailScale = 0.05,
	DetailStrength = 0.3,

	-- Hill parameters
	HillScale = 0.005,  -- Large rolling hills
	HillStrength = 1.5,
}

--[[
	Generates layered Perlin noise for realistic terrain
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: Random seed for variation
	@return: Height value between 0 and 1
]]
function TerrainGenerator.GetNoiseValue(x, z, seed)
	local total = 0
	local frequency = 1
	local amplitude = 1
	local maxValue = 0

	-- Layer multiple octaves of noise
	for i = 1, TerrainGenerator.Config.Octaves do
		local sampleX = x * TerrainGenerator.Config.NoiseScale * frequency
		local sampleZ = z * TerrainGenerator.Config.NoiseScale * frequency

		local noiseValue = math.noise(sampleX, sampleZ, seed + i)
		total = total + noiseValue * amplitude

		maxValue = maxValue + amplitude
		amplitude = amplitude * TerrainGenerator.Config.Persistence
		frequency = frequency * TerrainGenerator.Config.Lacunarity
	end

	-- Normalize to 0-1 range
	return (total / maxValue + 1) / 2
end

--[[
	Adds large rolling hills to the terrain
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: Random seed
	@return: Hill contribution value
]]
function TerrainGenerator.GetHillNoise(x, z, seed)
	local hillValue = math.noise(
		x * TerrainGenerator.Config.HillScale,
		z * TerrainGenerator.Config.HillScale,
		seed + 1000
	)
	return hillValue * TerrainGenerator.Config.HillStrength
end

--[[
	Adds fine detail to terrain
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: Random seed
	@return: Detail contribution value
]]
function TerrainGenerator.GetDetailNoise(x, z, seed)
	local detail = math.noise(
		x * TerrainGenerator.Config.DetailScale,
		z * TerrainGenerator.Config.DetailScale,
		seed + 2000
	)
	return detail * TerrainGenerator.Config.DetailStrength
end

--[[
	Calculates final terrain height at a position
	@param x: X coordinate
	@param z: Z coordinate
	@param seed: Random seed
	@return: Final height in studs
]]
function TerrainGenerator.GetTerrainHeight(x, z, seed)
	-- Combine different noise layers
	local baseNoise = TerrainGenerator.GetNoiseValue(x, z, seed)
	local hillNoise = TerrainGenerator.GetHillNoise(x, z, seed)
	local detailNoise = TerrainGenerator.GetDetailNoise(x, z, seed)

	-- Combine all noise values
	local combinedNoise = baseNoise + hillNoise + detailNoise

	-- Scale to terrain height
	local height = combinedNoise * TerrainGenerator.Config.TerrainHeight

	return height
end

--[[
	Generates a chunk of terrain
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
	@param seed: World seed
	@return: Table of terrain data
]]
function TerrainGenerator.GenerateChunk(chunkX, chunkZ, seed)
	local terrain = game.Workspace.Terrain
	local region = Region3.new(
		Vector3.new(chunkX * TerrainGenerator.Config.ChunkSize, -10, chunkZ * TerrainGenerator.Config.ChunkSize),
		Vector3.new((chunkX + 1) * TerrainGenerator.Config.ChunkSize, TerrainGenerator.Config.TerrainHeight + 10, (chunkZ + 1) * TerrainGenerator.Config.ChunkSize)
	)
	region = region:ExpandToGrid(4)

	-- Clear existing terrain in this chunk
	terrain:Clear()

	local chunkData = {
		Position = Vector3.new(chunkX, 0, chunkZ),
		HeightMap = {},
		BiomeMap = {},
	}

	-- Generate heightmap for this chunk
	local resolution = 4  -- Terrain resolution (4 studs per voxel)
	local size = TerrainGenerator.Config.ChunkSize

	for x = 0, size, resolution do
		for z = 0, size, resolution do
			local worldX = chunkX * size + x
			local worldZ = chunkZ * size + z

			local height = TerrainGenerator.GetTerrainHeight(worldX, worldZ, seed)

			-- Store height data
			if not chunkData.HeightMap[x] then
				chunkData.HeightMap[x] = {}
			end
			chunkData.HeightMap[x][z] = height

			-- Generate terrain voxels
			local position = Vector3.new(worldX, height / 2, worldZ)
			local size = Vector3.new(resolution, height, resolution)

			-- Determine material based on height
			local material
			if height < TerrainGenerator.Config.WaterLevel then
				material = Enum.Material.Water
			elseif height < TerrainGenerator.Config.WaterLevel + 5 then
				material = Enum.Material.Sand
			elseif height < TerrainGenerator.Config.TerrainHeight * 0.6 then
				material = Enum.Material.Grass
			elseif height < TerrainGenerator.Config.TerrainHeight * 0.8 then
				material = Enum.Material.Rock
			else
				material = Enum.Material.Snow
			end

			-- Fill terrain
			terrain:FillBlock(
				CFrame.new(position),
				size,
				material
			)
		end
	end

	return chunkData
end

return TerrainGenerator
