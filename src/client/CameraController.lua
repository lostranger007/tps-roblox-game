--[[
	CameraController Module
	Handles third-person over-the-shoulder camera
	Supports aiming, camera shake, and smooth transitions
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CameraController = {}
CameraController.__index = CameraController

-- Camera configuration
local CONFIG = {
	-- Default third-person settings
	DefaultOffset = Vector3.new(1.5, 0.5, 0),  -- Over right shoulder
	DefaultDistance = 6,
	DefaultFOV = 70,

	-- Aiming settings
	AimOffset = Vector3.new(0.5, 0, 0),  -- Closer to center when aiming
	AimDistance = 3.5,
	AimFOV = 50,  -- Zoomed in when aiming

	-- Camera behavior
	MouseSensitivity = 0.003,
	MinPitch = -80,  -- Look down limit (degrees)
	MaxPitch = 80,   -- Look up limit (degrees)

	-- Smoothing
	LerpSpeed = 0.15,
	AimLerpSpeed = 0.2,
	ShakeDecay = 0.9,
}

function CameraController.new(player)
	local self = setmetatable({}, CameraController)

	self.Player = player
	self.Camera = workspace.CurrentCamera
	self.Character = player.Character or player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
	self.Head = self.Character:WaitForChild("Head")

	-- Camera state
	self.IsAiming = false
	self.CurrentOffset = CONFIG.DefaultOffset
	self.CurrentDistance = CONFIG.DefaultDistance
	self.CurrentFOV = CONFIG.DefaultFOV

	-- Rotation tracking
	self.CameraRotationX = 0  -- Yaw
	self.CameraRotationY = 0  -- Pitch

	-- Camera shake
	self.ShakeOffset = Vector3.new(0, 0, 0)
	self.ShakeIntensity = 0

	-- Lock mouse
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	self:Initialize()

	return self
end

function CameraController:Initialize()
	-- Set camera type
	self.Camera.CameraType = Enum.CameraType.Scriptable

	-- Connect input
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:HandleMouseMovement(input.Delta)
		end
	end)

	-- Connect update loop
	RunService.RenderStepped:Connect(function(deltaTime)
		self:Update(deltaTime)
	end)

	print("[CameraController] Third-person camera initialized")
end

function CameraController:HandleMouseMovement(delta)
	-- Update rotation based on mouse movement
	self.CameraRotationX = self.CameraRotationX - delta.X * CONFIG.MouseSensitivity
	self.CameraRotationY = math.clamp(
		self.CameraRotationY - delta.Y * CONFIG.MouseSensitivity,
		math.rad(CONFIG.MinPitch),
		math.rad(CONFIG.MaxPitch)
	)
end

function CameraController:SetAiming(isAiming)
	self.IsAiming = isAiming
end

function CameraController:AddCameraShake(intensity)
	self.ShakeIntensity = math.min(self.ShakeIntensity + intensity, 2)
end

function CameraController:Update(deltaTime)
	if not self.Character or not self.Character.Parent then
		return
	end

	-- Determine target values based on aiming state
	local targetOffset = self.IsAiming and CONFIG.AimOffset or CONFIG.DefaultOffset
	local targetDistance = self.IsAiming and CONFIG.AimDistance or CONFIG.DefaultDistance
	local targetFOV = self.IsAiming and CONFIG.AimFOV or CONFIG.DefaultFOV

	-- Smooth interpolation
	local lerpSpeed = self.IsAiming and CONFIG.AimLerpSpeed or CONFIG.LerpSpeed
	self.CurrentOffset = self.CurrentOffset:Lerp(targetOffset, lerpSpeed)
	self.CurrentDistance = self.CurrentDistance + (targetDistance - self.CurrentDistance) * lerpSpeed
	self.CurrentFOV = self.CurrentFOV + (targetFOV - self.CurrentFOV) * lerpSpeed

	-- Calculate camera shake
	if self.ShakeIntensity > 0.01 then
		self.ShakeOffset = Vector3.new(
			(math.random() - 0.5) * self.ShakeIntensity,
			(math.random() - 0.5) * self.ShakeIntensity,
			0
		)
		self.ShakeIntensity = self.ShakeIntensity * CONFIG.ShakeDecay
	else
		self.ShakeOffset = Vector3.new(0, 0, 0)
		self.ShakeIntensity = 0
	end

	-- Calculate camera position
	local rootPartCFrame = self.HumanoidRootPart.CFrame

	-- Create rotation from camera angles
	local cameraCFrame = CFrame.new(rootPartCFrame.Position)
		* CFrame.Angles(0, self.CameraRotationX, 0)  -- Yaw
		* CFrame.Angles(self.CameraRotationY, 0, 0)  -- Pitch

	-- Apply offset for over-the-shoulder view
	local offsetPosition = cameraCFrame:PointToWorldSpace(self.CurrentOffset)

	-- Position camera behind player
	local cameraPosition = offsetPosition + (cameraCFrame.LookVector * -self.CurrentDistance)

	-- Apply shake
	cameraPosition = cameraPosition + self.ShakeOffset

	-- Raycast to prevent camera clipping through walls
	local rayOrigin = offsetPosition
	local rayDirection = (cameraPosition - rayOrigin)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {self.Character}

	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if rayResult then
		-- Move camera closer if it would clip through a wall
		cameraPosition = rayResult.Position + (rayResult.Normal * 0.5)
	end

	-- Set camera CFrame and FOV
	self.Camera.CFrame = CFrame.new(cameraPosition, offsetPosition)
	self.Camera.FieldOfView = self.CurrentFOV

	-- Rotate character to face camera direction (for movement)
	if self.Humanoid.MoveDirection.Magnitude > 0 then
		local moveDirection = self.Humanoid.MoveDirection
		local lookDirection = Vector3.new(
			math.sin(self.CameraRotationX),
			0,
			math.cos(self.CameraRotationX)
		)

		-- Rotate character toward movement direction relative to camera
		self.HumanoidRootPart.CFrame = CFrame.new(
			self.HumanoidRootPart.Position,
			self.HumanoidRootPart.Position + lookDirection
		)
	end
end

function CameraController:GetAimDirection()
	-- Returns the direction the camera is facing (for shooting)
	return self.Camera.CFrame.LookVector
end

function CameraController:GetAimOrigin()
	-- Returns the position to shoot from
	return self.Camera.CFrame.Position
end

function CameraController:Destroy()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	self.Camera.CameraType = Enum.CameraType.Custom
end

return CameraController
