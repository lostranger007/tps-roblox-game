--[[
	WorldManager Server Script
	Main server-side controller for world generation
	Coordinates terrain, biomes, and structure generation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load modules
local TerrainGenerator = require(ReplicatedStorage.Shared.TerrainGenerator)
local BiomeSystem = require(ReplicatedStorage.Shared.BiomeSystem)
local StructureGenerator = require(ReplicatedStorage.Shared.StructureGenerator)

local WorldManager = {}
WorldManager.Seed = 12345  -- Default world seed (can be randomized)
WorldManager.GeneratedChunks = {}
WorldManager.Towns = {}

-- World configuration
WorldManager.Config = {
	InitialChunks = 3,  -- Number of chunks to generate initially in each direction
	ViewDistance = 2,   -- Chunks to keep loaded around players
	AutoGenerate = true,  -- Automatically generate chunks as needed
}

--[[
	Initializes the world manager and generates initial world
]]
function WorldManager.Initialize()
	print("[WorldManager] Initializing world generation...")
	print("[WorldManager] World Seed:", WorldManager.Seed)

	-- Create world container
	local worldFolder = Instance.new("Folder")
	worldFolder.Name = "GeneratedWorld"
	worldFolder.Parent = game.Workspace

	-- Create structures container
	local structuresFolder = Instance.new("Folder")
	structuresFolder.Name = "Structures"
	structuresFolder.Parent = worldFolder

	WorldManager.WorldFolder = worldFolder
	WorldManager.StructuresFolder = structuresFolder

	-- Generate initial world area
	WorldManager.GenerateInitialWorld()

	print("[WorldManager] World generation complete!")
	print("[WorldManager] Generated", #WorldManager.Towns, "towns")
end

--[[
	Generates the initial world area around spawn
]]
function WorldManager.GenerateInitialWorld()
	local startTime = tick()
	local chunksGenerated = 0

	-- Generate chunks in a grid around spawn (0, 0)
	for chunkX = -WorldManager.Config.InitialChunks, WorldManager.Config.InitialChunks do
		for chunkZ = -WorldManager.Config.InitialChunks, WorldManager.Config.InitialChunks do
			WorldManager.GenerateChunk(chunkX, chunkZ)
			chunksGenerated = chunksGenerated + 1
		end
	end

	-- Generate towns in suitable locations
	WorldManager.GenerateTowns()

	local elapsed = tick() - startTime
	print(string.format("[WorldManager] Generated %d chunks in %.2f seconds", chunksGenerated, elapsed))
end

--[[
	Generates a single chunk of terrain
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
]]
function WorldManager.GenerateChunk(chunkX, chunkZ)
	local chunkKey = chunkX .. "," .. chunkZ

	-- Skip if already generated
	if WorldManager.GeneratedChunks[chunkKey] then
		return
	end

	-- Generate terrain for this chunk
	local terrain = game.Workspace.Terrain
	local chunkSize = TerrainGenerator.Config.ChunkSize
	local resolution = 4

	-- Generate terrain with biomes
	for x = 0, chunkSize, resolution do
		for z = 0, chunkSize, resolution do
			local worldX = chunkX * chunkSize + x
			local worldZ = chunkZ * chunkSize + z

			-- Get height from terrain generator
			local height = TerrainGenerator.GetTerrainHeight(worldX, worldZ, WorldManager.Seed)

			-- Get biome and material
			local material = BiomeSystem.GetMaterial(worldX, worldZ, height, WorldManager.Seed)

			-- Create terrain voxels
			local position = Vector3.new(worldX, height / 2, worldZ)
			local size = Vector3.new(resolution, height, resolution)

			terrain:FillBlock(
				CFrame.new(position),
				size,
				material
			)

			-- Add vegetation (trees) based on biome
			if BiomeSystem.ShouldSpawnTree(worldX, worldZ, height, WorldManager.Seed) then
				WorldManager.SpawnTree(Vector3.new(worldX, height, worldZ))
			end
		end
	end

	-- Mark chunk as generated
	WorldManager.GeneratedChunks[chunkKey] = {
		X = chunkX,
		Z = chunkZ,
		Generated = true,
	}
end

--[[
	Spawns a simple tree at a position
	@param position: Vector3 position for the tree
]]
function WorldManager.SpawnTree(position)
	local tree = Instance.new("Model")
	tree.Name = "Tree"
	tree.Parent = WorldManager.WorldFolder

	-- Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(2, 8, 2)
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Anchored = true
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(100, 70, 40)
	trunk.Parent = tree

	-- Foliage
	local foliage = Instance.new("Part")
	foliage.Name = "Foliage"
	foliage.Size = Vector3.new(8, 8, 8)
	foliage.Shape = Enum.PartType.Ball
	foliage.Position = position + Vector3.new(0, 10, 0)
	foliage.Anchored = true
	foliage.Material = Enum.Material.Grass
	foliage.Color = Color3.fromRGB(40, 120, 40)
	foliage.Parent = tree
end

--[[
	Generates towns across the world
]]
function WorldManager.GenerateTowns()
	print("[WorldManager] Generating towns...")

	local chunkSize = TerrainGenerator.Config.ChunkSize
	local townCount = 0

	-- Scan generated chunks for suitable town locations
	for chunkX = -WorldManager.Config.InitialChunks, WorldManager.Config.InitialChunks do
		for chunkZ = -WorldManager.Config.InitialChunks, WorldManager.Config.InitialChunks do
			-- Skip edge chunks
			if math.abs(chunkX) < WorldManager.Config.InitialChunks and
			   math.abs(chunkZ) < WorldManager.Config.InitialChunks then

				-- Random chance for town spawn
				local townNoise = math.noise(chunkX * 0.1, chunkZ * 0.1, WorldManager.Seed + 5000)
				if townNoise > 0.5 then
					local centerX = chunkX * chunkSize + chunkSize / 2
					local centerZ = chunkZ * chunkSize + chunkSize / 2

					-- Get terrain info
					local height = TerrainGenerator.GetTerrainHeight(centerX, centerZ, WorldManager.Seed)
					local biome = BiomeSystem.GetBiome(centerX, centerZ, WorldManager.Seed)

					-- Check if suitable for town
					if StructureGenerator.IsSuitableForTown(centerX, centerZ, height, biome) then
						if StructureGenerator.IsValidTownPosition(centerX, centerZ, WorldManager.Towns) then
							-- Generate the town
							local town = StructureGenerator.GenerateTown(
								centerX,
								centerZ,
								height,
								WorldManager.Seed,
								WorldManager.StructuresFolder
							)
							table.insert(WorldManager.Towns, town)
							townCount = townCount + 1
							print(string.format("[WorldManager] Town #%d generated at (%d, %d)", townCount, centerX, centerZ))
						end
					end
				end
			end
		end
	end
end

--[[
	Clears terrain and structures (for regeneration)
]]
function WorldManager.ClearWorld()
	game.Workspace.Terrain:Clear()
	if WorldManager.WorldFolder then
		WorldManager.WorldFolder:Destroy()
	end
	WorldManager.GeneratedChunks = {}
	WorldManager.Towns = {}
end

-- Initialize on server start
WorldManager.Initialize()

-- Make WorldManager accessible globally for debugging
_G.WorldManager = WorldManager

return WorldManager
