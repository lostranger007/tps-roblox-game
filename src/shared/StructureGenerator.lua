--[[
	StructureGenerator Module
	Generates towns, buildings, and other structures
	Places them intelligently in the world
]]

local StructureGenerator = {}

-- Configuration
StructureGenerator.Config = {
	-- Town generation
	TownMinDistance = 500,  -- Minimum distance between towns
	TownSpawnChance = 0.15,  -- Chance per suitable chunk

	-- Building sizes
	MinBuildingSize = Vector3.new(10, 8, 10),
	MaxBuildingSize = Vector3.new(20, 15, 20),

	-- Town layout
	BuildingsPerTown = {Min = 5, Max = 15},
	TownRadius = 80,
	RoadWidth = 8,
}

--[[
	Determines if a location is suitable for a town
	@param x: X coordinate
	@param z: Z coordinate
	@param height: Terrain height
	@param biome: Biome data
	@return: Boolean indicating suitability
]]
function StructureGenerator.IsSuitableForTown(x, z, height, biome)
	-- Towns should be on relatively flat ground, not in water or mountains
	if height < 40 or height > 80 then
		return false
	end

	-- Avoid deserts and tundra for towns (can be adjusted)
	if biome.Name == "Desert" or biome.Name == "Tundra" or biome.Name == "Mountains" then
		return false
	end

	return true
end

--[[
	Checks if position is too close to existing towns
	@param x: X coordinate
	@param z: Z coordinate
	@param existingTowns: Array of town positions
	@return: Boolean indicating if position is valid
]]
function StructureGenerator.IsValidTownPosition(x, z, existingTowns)
	for _, town in ipairs(existingTowns) do
		local distance = math.sqrt((x - town.X)^2 + (z - town.Z)^2)
		if distance < StructureGenerator.Config.TownMinDistance then
			return false
		end
	end
	return true
end

--[[
	Generates a simple building structure
	@param position: Vector3 position for building
	@param size: Vector3 size of building
	@param parent: Parent folder for building parts
	@return: Model of the building
]]
function StructureGenerator.CreateBuilding(position, size, parent)
	local building = Instance.new("Model")
	building.Name = "Building"
	building.Parent = parent

	-- Foundation
	local foundation = Instance.new("Part")
	foundation.Name = "Foundation"
	foundation.Size = Vector3.new(size.X, 1, size.Z)
	foundation.Position = position
	foundation.Anchored = true
	foundation.Material = Enum.Material.Concrete
	foundation.Color = Color3.fromRGB(180, 180, 180)
	foundation.Parent = building

	-- Walls
	local wallHeight = size.Y - 1
	local wallThickness = 0.5

	-- Front wall
	local frontWall = Instance.new("Part")
	frontWall.Name = "FrontWall"
	frontWall.Size = Vector3.new(size.X, wallHeight, wallThickness)
	frontWall.Position = position + Vector3.new(0, wallHeight / 2, size.Z / 2)
	frontWall.Anchored = true
	frontWall.Material = Enum.Material.Brick
	frontWall.Color = Color3.fromRGB(150, 120, 90)
	frontWall.Parent = building

	-- Back wall
	local backWall = frontWall:Clone()
	backWall.Name = "BackWall"
	backWall.Position = position + Vector3.new(0, wallHeight / 2, -size.Z / 2)
	backWall.Parent = building

	-- Left wall
	local leftWall = Instance.new("Part")
	leftWall.Name = "LeftWall"
	leftWall.Size = Vector3.new(wallThickness, wallHeight, size.Z)
	leftWall.Position = position + Vector3.new(-size.X / 2, wallHeight / 2, 0)
	leftWall.Anchored = true
	leftWall.Material = Enum.Material.Brick
	leftWall.Color = Color3.fromRGB(150, 120, 90)
	leftWall.Parent = building

	-- Right wall
	local rightWall = leftWall:Clone()
	rightWall.Name = "RightWall"
	rightWall.Position = position + Vector3.new(size.X / 2, wallHeight / 2, 0)
	rightWall.Parent = building

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(size.X + 2, 0.5, size.Z + 2)
	roof.Position = position + Vector3.new(0, size.Y, 0)
	roof.Anchored = true
	roof.Material = Enum.Material.Slate
	roof.Color = Color3.fromRGB(80, 50, 50)
	roof.Parent = building

	-- Door (opening in front wall)
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(4, 6, wallThickness + 0.1)
	door.Position = frontWall.Position
	door.Anchored = true
	door.Material = Enum.Material.Wood
	door.Color = Color3.fromRGB(100, 60, 30)
	door.Parent = building

	return building
end

--[[
	Creates a road segment
	@param startPos: Vector3 start position
	@param endPos: Vector3 end position
	@param parent: Parent folder
]]
function StructureGenerator.CreateRoad(startPos, endPos, parent)
	local direction = (endPos - startPos)
	local distance = direction.Magnitude
	local midpoint = startPos + direction / 2

	local road = Instance.new("Part")
	road.Name = "Road"
	road.Size = Vector3.new(StructureGenerator.Config.RoadWidth, 0.2, distance)
	road.CFrame = CFrame.new(midpoint, endPos)
	road.Anchored = true
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(60, 60, 60)
	road.Parent = parent

	return road
end

--[[
	Generates a complete town with buildings and roads
	@param centerX: Town center X coordinate
	@param centerZ: Town center Z coordinate
	@param groundHeight: Height of the ground
	@param seed: Random seed
	@param parent: Parent folder
	@return: Town data
]]
function StructureGenerator.GenerateTown(centerX, centerZ, groundHeight, seed, parent)
	local townFolder = Instance.new("Folder")
	townFolder.Name = "Town_" .. centerX .. "_" .. centerZ
	townFolder.Parent = parent

	local buildingsFolder = Instance.new("Folder")
	buildingsFolder.Name = "Buildings"
	buildingsFolder.Parent = townFolder

	local roadsFolder = Instance.new("Folder")
	roadsFolder.Name = "Roads"
	roadsFolder.Parent = townFolder

	-- Determine number of buildings
	local random = Random.new(seed + centerX + centerZ)
	local numBuildings = random:NextInteger(
		StructureGenerator.Config.BuildingsPerTown.Min,
		StructureGenerator.Config.BuildingsPerTown.Max
	)

	local buildings = {}
	local townCenter = Vector3.new(centerX, groundHeight, centerZ)

	-- Generate buildings in a circular pattern
	for i = 1, numBuildings do
		local angle = (i / numBuildings) * math.pi * 2
		local radius = random:NextNumber(20, StructureGenerator.Config.TownRadius)

		local buildingX = centerX + math.cos(angle) * radius
		local buildingZ = centerZ + math.sin(angle) * radius

		-- Random building size
		local sizeX = random:NextNumber(
			StructureGenerator.Config.MinBuildingSize.X,
			StructureGenerator.Config.MaxBuildingSize.X
		)
		local sizeY = random:NextNumber(
			StructureGenerator.Config.MinBuildingSize.Y,
			StructureGenerator.Config.MaxBuildingSize.Y
		)
		local sizeZ = random:NextNumber(
			StructureGenerator.Config.MinBuildingSize.Z,
			StructureGenerator.Config.MaxBuildingSize.Z
		)

		local buildingSize = Vector3.new(sizeX, sizeY, sizeZ)
		local buildingPos = Vector3.new(buildingX, groundHeight + sizeY / 2, buildingZ)

		local building = StructureGenerator.CreateBuilding(buildingPos, buildingSize, buildingsFolder)
		table.insert(buildings, {Position = buildingPos, Model = building})

		-- Create road from town center to building
		if i % 3 == 0 then  -- Not every building needs a road
			StructureGenerator.CreateRoad(
				townCenter + Vector3.new(0, 0.1, 0),
				Vector3.new(buildingX, groundHeight + 0.1, buildingZ),
				roadsFolder
			)
		end
	end

	-- Create main roads (cross pattern)
	StructureGenerator.CreateRoad(
		townCenter + Vector3.new(-StructureGenerator.Config.TownRadius, 0.1, 0),
		townCenter + Vector3.new(StructureGenerator.Config.TownRadius, 0.1, 0),
		roadsFolder
	)
	StructureGenerator.CreateRoad(
		townCenter + Vector3.new(0, 0.1, -StructureGenerator.Config.TownRadius),
		townCenter + Vector3.new(0, 0.1, StructureGenerator.Config.TownRadius),
		roadsFolder
	)

	return {
		X = centerX,
		Z = centerZ,
		Buildings = buildings,
		Folder = townFolder,
	}
end

return StructureGenerator
