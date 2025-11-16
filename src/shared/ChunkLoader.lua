--[[
	ChunkLoader Module
	Handles dynamic chunk loading/unloading based on player position
	Optimizes performance for open world
]]

local ChunkLoader = {}

ChunkLoader.Config = {
	ChunkSize = 256,  -- Must match TerrainGenerator.Config.ChunkSize
	LoadDistance = 3,  -- Chunks to load around player
	UnloadDistance = 5,  -- Chunks to unload when player is far
	UpdateInterval = 2,  -- Seconds between chunk updates
}

ChunkLoader.ActivePlayers = {}
ChunkLoader.LoadedChunks = {}

--[[
	Converts world position to chunk coordinates
	@param position: Vector3 world position
	@return: chunkX, chunkZ
]]
function ChunkLoader.WorldToChunk(position)
	local chunkX = math.floor(position.X / ChunkLoader.Config.ChunkSize)
	local chunkZ = math.floor(position.Z / ChunkLoader.Config.ChunkSize)
	return chunkX, chunkZ
end

--[[
	Gets chunk key for storage
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
	@return: String key
]]
function ChunkLoader.GetChunkKey(chunkX, chunkZ)
	return chunkX .. "," .. chunkZ
end

--[[
	Checks if a chunk should be loaded for any player
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
	@return: Boolean indicating if chunk should be loaded
]]
function ChunkLoader.ShouldLoadChunk(chunkX, chunkZ)
	for _, playerData in pairs(ChunkLoader.ActivePlayers) do
		local playerChunkX = playerData.ChunkX
		local playerChunkZ = playerData.ChunkZ

		local distance = math.sqrt(
			(chunkX - playerChunkX)^2 + (chunkZ - playerChunkZ)^2
		)

		if distance <= ChunkLoader.Config.LoadDistance then
			return true
		end
	end
	return false
end

--[[
	Checks if a chunk should be unloaded (no players nearby)
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
	@return: Boolean indicating if chunk should be unloaded
]]
function ChunkLoader.ShouldUnloadChunk(chunkX, chunkZ)
	for _, playerData in pairs(ChunkLoader.ActivePlayers) do
		local playerChunkX = playerData.ChunkX
		local playerChunkZ = playerData.ChunkZ

		local distance = math.sqrt(
			(chunkX - playerChunkX)^2 + (chunkZ - playerChunkZ)^2
		)

		if distance <= ChunkLoader.Config.UnloadDistance then
			return false
		end
	end
	return true
end

--[[
	Updates player position for chunk loading
	@param player: Player instance
	@param position: Vector3 position
]]
function ChunkLoader.UpdatePlayerPosition(player, position)
	local chunkX, chunkZ = ChunkLoader.WorldToChunk(position)

	if not ChunkLoader.ActivePlayers[player.UserId] then
		ChunkLoader.ActivePlayers[player.UserId] = {}
	end

	local playerData = ChunkLoader.ActivePlayers[player.UserId]
	playerData.ChunkX = chunkX
	playerData.ChunkZ = chunkZ
	playerData.Position = position
end

--[[
	Removes player from chunk loading system
	@param player: Player instance
]]
function ChunkLoader.RemovePlayer(player)
	ChunkLoader.ActivePlayers[player.UserId] = nil
end

--[[
	Gets list of chunks that need to be loaded
	@return: Array of {chunkX, chunkZ} tables
]]
function ChunkLoader.GetChunksToLoad()
	local chunksToLoad = {}
	local checkedChunks = {}

	for _, playerData in pairs(ChunkLoader.ActivePlayers) do
		local playerChunkX = playerData.ChunkX
		local playerChunkZ = playerData.ChunkZ

		-- Check all chunks in load distance
		for offsetX = -ChunkLoader.Config.LoadDistance, ChunkLoader.Config.LoadDistance do
			for offsetZ = -ChunkLoader.Config.LoadDistance, ChunkLoader.Config.LoadDistance do
				local chunkX = playerChunkX + offsetX
				local chunkZ = playerChunkZ + offsetZ
				local chunkKey = ChunkLoader.GetChunkKey(chunkX, chunkZ)

				-- Skip if already loaded or already checked
				if not ChunkLoader.LoadedChunks[chunkKey] and not checkedChunks[chunkKey] then
					table.insert(chunksToLoad, {X = chunkX, Z = chunkZ})
					checkedChunks[chunkKey] = true
				end
			end
		end
	end

	return chunksToLoad
end

--[[
	Gets list of chunks that should be unloaded
	@return: Array of chunk keys
]]
function ChunkLoader.GetChunksToUnload()
	local chunksToUnload = {}

	for chunkKey, chunkData in pairs(ChunkLoader.LoadedChunks) do
		if ChunkLoader.ShouldUnloadChunk(chunkData.X, chunkData.Z) then
			table.insert(chunksToUnload, chunkKey)
		end
	end

	return chunksToUnload
end

--[[
	Marks a chunk as loaded
	@param chunkX: Chunk X coordinate
	@param chunkZ: Chunk Z coordinate
]]
function ChunkLoader.MarkChunkLoaded(chunkX, chunkZ)
	local chunkKey = ChunkLoader.GetChunkKey(chunkX, chunkZ)
	ChunkLoader.LoadedChunks[chunkKey] = {
		X = chunkX,
		Z = chunkZ,
		LoadedAt = tick(),
	}
end

--[[
	Marks a chunk as unloaded
	@param chunkKey: Chunk key string
]]
function ChunkLoader.MarkChunkUnloaded(chunkKey)
	ChunkLoader.LoadedChunks[chunkKey] = nil
end

return ChunkLoader
