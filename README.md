# Open World Shooter - Roblox Game

An open-world third-person shooter game for Roblox featuring:
- Procedurally generated terrain with hills and valleys
- AI-generated towns and structures
- Third-person over-the-shoulder shooting mechanics
- Weapon system

## Project Structure

```
src/
├── server/          # Server-side scripts
│   ├── WorldManager.server.lua
│   └── init.server.lua
├── client/          # Client-side scripts
│   └── init.client.lua
└── shared/          # Shared modules
    ├── TerrainGenerator.lua
    ├── BiomeSystem.lua
    └── StructureGenerator.lua
```

## Development

This project uses [Rojo](https://rojo.space/) for syncing code to Roblox Studio.

1. Install Rojo
2. Run `rojo serve` to start the development server
3. In Roblox Studio, connect to the Rojo server

## Features

### World Generation
- Perlin noise-based terrain generation
- Multiple biomes (grasslands, forests, mountains)
- Procedural town placement
- Chunk-based loading for performance

### Combat System (Coming Soon)
- Third-person camera
- Weapon system
- Aiming mechanics
