--[[
	Client Initialization Script
	Main entry point for client-side code
	Handles player setup and UI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load client modules
local CameraController = require(script.Parent.CameraController)
local WeaponController = require(script.Parent.WeaponController)
local HUD = require(script.Parent.HUD)

local player = Players.LocalPlayer

print("===========================================")
print("  Open World Shooter - Client Starting")
print("  Player:", player.Name)
print("===========================================")

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

print("[Client] Character loaded successfully")

-- Initialize HUD
local hud = HUD.new(player)

-- Initialize third-person camera system
local cameraController = CameraController.new(player)

-- Initialize weapon system
local weaponController = WeaponController.new(player, cameraController, hud)

-- Store controllers globally for debugging
_G.CameraController = cameraController
_G.WeaponController = weaponController
_G.HUD = hud

-- Basic spawn message
local function showWelcomeMessage()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WelcomeUI"
	screenGui.Parent = player.PlayerGui

	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
	welcomeLabel.Position = UDim2.new(0.2, 0, 0.4, 0)
	welcomeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	welcomeLabel.BackgroundTransparency = 0.5
	welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	welcomeLabel.TextScaled = true
	welcomeLabel.Font = Enum.Font.GothamBold
	welcomeLabel.Text = "Welcome to the Open World!\n[Right Click] Aim | [Left Click] Shoot | [R] Reload"
	welcomeLabel.Parent = screenGui

	-- Fade out after 5 seconds
	task.wait(5)
	welcomeLabel:TweenSize(
		UDim2.new(0.6, 0, 0, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.5,
		true
	)
	task.wait(0.5)
	screenGui:Destroy()
end

-- Show welcome message
showWelcomeMessage()

print("[Client] Client initialization complete!")
