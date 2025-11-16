# Setup Guide - Open World Shooter

This guide will help you set up and test your open-world shooter game in Roblox Studio **without using Rojo**.

## Quick Start (Manual Setup)

### 1. Open Roblox Studio
- Launch Roblox Studio
- Create a new Baseplate or empty place

### 2. Set Up the Folder Structure

Create the following folder structure in your game:

```
Workspace
  └── (game world will generate here)

ReplicatedStorage
  └── Shared (Folder)
      ├── TerrainGenerator (ModuleScript)
      ├── BiomeSystem (ModuleScript)
      ├── StructureGenerator (ModuleScript)
      ├── ChunkLoader (ModuleScript)
      └── WeaponData (ModuleScript)

ServerScriptService
  └── Server (Folder)
      ├── init (Script)
      └── WorldManager (Script)

StarterPlayer
  └── StarterPlayerScripts
      └── Client (Folder)
          ├── init (LocalScript)
          ├── CameraController (ModuleScript)
          ├── WeaponController (ModuleScript)
          └── HUD (ModuleScript)
```

### 3. Copy the Code

#### ReplicatedStorage → Shared Modules:

**TerrainGenerator** (ModuleScript):
- Copy contents from: `src/shared/TerrainGenerator.lua`

**BiomeSystem** (ModuleScript):
- Copy contents from: `src/shared/BiomeSystem.lua`

**StructureGenerator** (ModuleScript):
- Copy contents from: `src/shared/StructureGenerator.lua`

**ChunkLoader** (ModuleScript):
- Copy contents from: `src/shared/ChunkLoader.lua`

**WeaponData** (ModuleScript):
- Copy contents from: `src/shared/WeaponData.lua`

#### ServerScriptService → Server Scripts:

**init** (Script):
- Copy contents from: `src/server/init.server.lua`

**WorldManager** (Script):
- Copy contents from: `src/server/WorldManager.server.lua`

#### StarterPlayer → StarterPlayerScripts → Client:

**init** (LocalScript):
- Copy contents from: `src/client/init.client.lua`

**CameraController** (ModuleScript):
- Copy contents from: `src/client/CameraController.lua`

**WeaponController** (ModuleScript):
- Copy contents from: `src/client/WeaponController.lua`

**HUD** (ModuleScript):
- Copy contents from: `src/client/HUD.lua`

### 4. Test Your Game

1. Click the **Play** button in Roblox Studio
2. Wait a few seconds for the world to generate
3. You should see:
   - Procedurally generated terrain with hills
   - Different biomes (plains, forests, mountains)
   - Towns with buildings and roads
   - Trees scattered across the landscape

### 5. Test the Shooting System

Once spawned in the game:

**Controls:**
- **Mouse Movement**: Look around
- **WASD**: Move
- **Left Click**: Shoot
- **Right Click**: Aim Down Sights
- **R**: Reload

**HUD Elements:**
- **Center**: Crosshair
- **Bottom Right**: Ammo counter (current/reserve)
- **Bottom Left**: Health bar

## Troubleshooting

### World Not Generating?
1. Check the Output window for errors
2. Make sure all modules are in the correct locations
3. Verify that ServerScriptService → Server → init is a **Script** (not LocalScript)

### Camera Not Working?
1. Ensure CameraController is a **ModuleScript**
2. Check that init.client.lua is a **LocalScript**
3. Look for errors in the Output window

### Shooting Not Working?
1. Make sure WeaponController is a **ModuleScript**
2. Verify WeaponData is in ReplicatedStorage/Shared
3. Check that the HUD module is properly loaded

### Can't See HUD?
1. Verify HUD.lua is a **ModuleScript** in the Client folder
2. Check that it's being required by init.client.lua
3. Look for any UI-related errors in Output

## Customization

### Change World Seed
In `WorldManager.server.lua`, line 12:
```lua
WorldManager.Seed = 12345  -- Change this number
```

### Modify Weapon Stats
Edit `WeaponData.lua` to change:
- Damage values
- Fire rates
- Magazine sizes
- Recoil patterns
- And more!

### Adjust Camera Settings
In `CameraController.lua`, modify the `CONFIG` table:
```lua
local CONFIG = {
    DefaultDistance = 6,  -- Camera distance
    DefaultFOV = 70,      -- Field of view
    MouseSensitivity = 0.003,  -- Mouse sensitivity
    -- etc.
}
```

## Features Implemented

### ✅ World Generation
- Multi-octave Perlin noise terrain
- 5 distinct biomes
- Procedural town generation
- Dynamic vegetation spawning
- Chunk-based system (ready for expansion)

### ✅ Third-Person Shooting
- Over-the-shoulder camera
- Aim-down-sights system
- 5 weapon types (Pistol, Rifle, Shotgun, Sniper, SMG)
- Realistic recoil patterns
- Raycast hit detection
- Headshot damage multipliers
- Visual effects (tracers, muzzle flash, hit markers)

### ✅ HUD System
- Dynamic crosshair
- Ammo counter with warnings
- Health bar with color coding
- Professional game-style UI

## Next Steps

Want to add more features? Here are some ideas:

1. **Weapon Switching**: Add multiple weapons and hotkeys to switch
2. **Enemy AI**: Create NPCs that patrol and engage in combat
3. **Inventory System**: Add items, pickups, and equipment
4. **Multiplayer**: Server-side hit validation for PvP
5. **More Biomes**: Add jungles, swamps, ice fields
6. **Quests**: Town-based mission system
7. **Building System**: Let players construct bases
8. **Vehicles**: Cars, helicopters, etc.

## Project Structure

```
tps-roblox-game/
├── src/
│   ├── client/              # Client-side code
│   │   ├── init.client.lua
│   │   ├── CameraController.lua
│   │   ├── WeaponController.lua
│   │   └── HUD.lua
│   ├── server/              # Server-side code
│   │   ├── init.server.lua
│   │   └── WorldManager.server.lua
│   └── shared/              # Shared modules
│       ├── TerrainGenerator.lua
│       ├── BiomeSystem.lua
│       ├── StructureGenerator.lua
│       ├── ChunkLoader.lua
│       └── WeaponData.lua
├── README.md
├── SETUP_GUIDE.md
└── default.project.json     # For Rojo (optional)
```

## Need Help?

If you encounter issues:
1. Check the Output window in Roblox Studio for error messages
2. Ensure all scripts are in the correct locations
3. Verify that Scripts vs LocalScripts vs ModuleScripts are correct
4. Make sure all required modules exist in ReplicatedStorage/Shared

## Have Fun!

You now have a fully functional open-world shooter! Explore the procedurally generated world, test out different weapons, and customize it to make it your own!
