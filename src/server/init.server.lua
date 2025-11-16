--[[
	Server Initialization Script
	Main entry point for server-side code
]]

print("===========================================")
print("  Open World Shooter - Server Starting")
print("===========================================")

-- Initialize WorldManager (this will generate the world)
local WorldManager = require(script.Parent.WorldManager)

print("[Server] Server initialization complete!")
print("[Server] Players can now join the game")
