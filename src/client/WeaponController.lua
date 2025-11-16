--[[
	WeaponController Module
	Handles weapon mechanics: shooting, reloading, aiming
	Client-side weapon management
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponData = require(ReplicatedStorage.Shared.WeaponData)

local WeaponController = {}
WeaponController.__index = WeaponController

function WeaponController.new(player, cameraController, hud)
	local self = setmetatable({}, WeaponController)

	self.Player = player
	self.Character = player.Character or player.CharacterAdded:Wait()
	self.CameraController = cameraController
	self.HUD = hud

	-- Current weapon state
	self.CurrentWeapon = nil
	self.CurrentWeaponData = nil
	self.WeaponModel = nil

	-- Ammo tracking
	self.CurrentAmmo = 0
	self.ReserveAmmo = 0

	-- State flags
	self.IsAiming = false
	self.IsReloading = false
	self.CanShoot = true
	self.IsShooting = false

	-- Recoil tracking
	self.RecoilAmount = Vector2.new(0, 0)

	-- Input setup
	self:SetupInput()

	-- Equip default weapon
	self:EquipWeapon("Pistol")

	print("[WeaponController] Weapon system initialized")

	return self
end

function WeaponController:SetupInput()
	-- Mouse button for shooting
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:StartShooting()
		elseif input.KeyCode == Enum.KeyCode.R then
			self:Reload()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:StartAiming()
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:StopShooting()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:StopAiming()
		end
	end)

	-- Update loop for automatic fire
	RunService.Heartbeat:Connect(function()
		if self.IsShooting and self.CanShoot and not self.IsReloading then
			if self.CurrentWeaponData.Automatic then
				self:Shoot()
			end
		end

		-- Recover recoil
		if self.CurrentWeaponData then
			self.RecoilAmount = self.RecoilAmount * self.CurrentWeaponData.RecoilPattern.Recovery
		end
	end)
end

function WeaponController:EquipWeapon(weaponName)
	local weaponData = WeaponData.GetWeapon(weaponName)
	if not weaponData then
		warn("[WeaponController] Weapon not found:", weaponName)
		return
	end

	-- Remove old weapon
	if self.WeaponModel then
		self.WeaponModel:Destroy()
	end

	-- Set new weapon
	self.CurrentWeapon = weaponName
	self.CurrentWeaponData = weaponData
	self.CurrentAmmo = weaponData.MagazineSize
	self.ReserveAmmo = weaponData.ReserveAmmo

	-- Create weapon model (placeholder)
	self:CreateWeaponModel()

	print("[WeaponController] Equipped:", weaponName)
	self:UpdateAmmoUI()
end

function WeaponController:CreateWeaponModel()
	-- Create a simple placeholder weapon model
	-- In production, you would load an actual weapon model from ReplicatedStorage

	local weaponModel = Instance.new("Model")
	weaponModel.Name = self.CurrentWeapon
	weaponModel.Parent = self.Character

	-- Weapon body (placeholder)
	local weaponPart = Instance.new("Part")
	weaponPart.Name = "Handle"
	weaponPart.Size = Vector3.new(0.3, 0.3, 1.5)
	weaponPart.Color = Color3.fromRGB(60, 60, 60)
	weaponPart.Material = Enum.Material.Metal
	weaponPart.CanCollide = false
	weaponPart.Parent = weaponModel

	-- Attach to right hand
	local rightHand = self.Character:FindFirstChild("RightHand") or self.Character:FindFirstChild("Right Arm")
	if rightHand then
		local weld = Instance.new("Weld")
		weld.Part0 = rightHand
		weld.Part1 = weaponPart
		weld.C0 = CFrame.new(0, -0.5, -0.2) * CFrame.Angles(math.rad(-90), 0, 0)
		weld.Parent = weaponPart
	end

	self.WeaponModel = weaponModel
	self.WeaponHandle = weaponPart
end

function WeaponController:StartShooting()
	self.IsShooting = true

	if not self.CurrentWeaponData.Automatic then
		self:Shoot()
	end
end

function WeaponController:StopShooting()
	self.IsShooting = false
end

function WeaponController:Shoot()
	if not self.CanShoot or self.IsReloading or self.CurrentAmmo <= 0 then
		if self.CurrentAmmo <= 0 and not self.IsReloading then
			-- Auto reload when out of ammo
			self:Reload()
		end
		return
	end

	-- Consume ammo
	self.CurrentAmmo = self.CurrentAmmo - 1
	self:UpdateAmmoUI()

	-- Fire cooldown
	self.CanShoot = false
	task.delay(self.CurrentWeaponData.FireRate, function()
		self.CanShoot = true
	end)

	-- Handle shotgun pellets
	local shotsToFire = self.CurrentWeaponData.PelletCount or 1

	for i = 1, shotsToFire do
		self:FireRaycast()
	end

	-- Apply recoil
	self:ApplyRecoil()

	-- Visual effects
	self:PlayMuzzleFlash()
	self:PlayShootSound()

	-- Camera shake
	if self.CameraController then
		self.CameraController:AddCameraShake(0.1)
	end
end

function WeaponController:FireRaycast()
	local origin = self.CameraController:GetAimOrigin()
	local direction = self.CameraController:GetAimDirection()

	-- Apply accuracy spread
	local spread = (1 - self.CurrentWeaponData.Accuracy) * 0.1
	if self.IsAiming then
		spread = spread * 0.5  -- Better accuracy when aiming
	end

	direction = direction + Vector3.new(
		(math.random() - 0.5) * spread,
		(math.random() - 0.5) * spread,
		(math.random() - 0.5) * spread
	)
	direction = direction.Unit

	-- Raycast parameters
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {self.Character}

	-- Perform raycast
	local rayResult = workspace:Raycast(origin, direction * self.CurrentWeaponData.Range, raycastParams)

	if rayResult then
		-- Hit something
		self:HandleHit(rayResult)

		-- Create bullet tracer
		if self.CurrentWeaponData.BulletTracer then
			self:CreateBulletTracer(origin, rayResult.Position)
		end

		-- Hit effect
		self:CreateHitEffect(rayResult.Position, rayResult.Normal)
	else
		-- Missed - still create tracer
		if self.CurrentWeaponData.BulletTracer then
			self:CreateBulletTracer(origin, origin + direction * self.CurrentWeaponData.Range)
		end
	end
end

function WeaponController:HandleHit(rayResult)
	local hitPart = rayResult.Instance
	local hitPosition = rayResult.Position

	-- Check if we hit a player
	local hitCharacter = hitPart.Parent
	local hitHumanoid = hitCharacter and hitCharacter:FindFirstChild("Humanoid")

	if hitHumanoid then
		-- Calculate damage
		local damage = self.CurrentWeaponData.Damage

		-- Check for headshot
		if hitPart.Name == "Head" then
			damage = damage * self.CurrentWeaponData.HeadshotMultiplier
			print("[WeaponController] HEADSHOT! Damage:", damage)
		else
			print("[WeaponController] Hit! Damage:", damage)
		end

		-- Apply damage (in a real game, this should be server-validated)
		hitHumanoid:TakeDamage(damage)
	else
		print("[WeaponController] Hit object:", hitPart.Name)
	end
end

function WeaponController:CreateBulletTracer(startPos, endPos)
	local tracer = Instance.new("Part")
	tracer.Name = "BulletTracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
	tracer.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
	tracer.Material = Enum.Material.Neon
	tracer.Color = Color3.fromRGB(255, 255, 100)
	tracer.Transparency = 0.5
	tracer.Parent = workspace.CurrentCamera

	-- Fade out and remove
	task.delay(0.1, function()
		tracer:Destroy()
	end)
end

function WeaponController:CreateHitEffect(position, normal)
	local hitEffect = Instance.new("Part")
	hitEffect.Name = "HitEffect"
	hitEffect.Anchored = true
	hitEffect.CanCollide = false
	hitEffect.Size = Vector3.new(0.3, 0.3, 0.3)
	hitEffect.CFrame = CFrame.new(position, position + normal)
	hitEffect.Material = Enum.Material.Neon
	hitEffect.Color = Color3.fromRGB(255, 200, 0)
	hitEffect.Shape = Enum.PartType.Ball
	hitEffect.Parent = workspace

	-- Expand and fade
	local size = hitEffect.Size
	for i = 1, 10 do
		hitEffect.Size = hitEffect.Size * 1.2
		hitEffect.Transparency = i / 10
		task.wait(0.02)
	end
	hitEffect:Destroy()
end

function WeaponController:PlayMuzzleFlash()
	if not self.CurrentWeaponData.MuzzleFlash or not self.WeaponHandle then
		return
	end

	local muzzleFlash = Instance.new("PointLight")
	muzzleFlash.Brightness = 5
	muzzleFlash.Color = Color3.fromRGB(255, 200, 100)
	muzzleFlash.Range = 10
	muzzleFlash.Parent = self.WeaponHandle

	task.delay(0.05, function()
		muzzleFlash:Destroy()
	end)
end

function WeaponController:PlayShootSound()
	-- Placeholder - in production, use actual sound IDs
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	sound.Volume = 0.5
	sound.Parent = self.WeaponHandle or self.Character.Head
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function WeaponController:ApplyRecoil()
	local recoil = self.CurrentWeaponData.RecoilPattern

	self.RecoilAmount = self.RecoilAmount + Vector2.new(
		(math.random() - 0.5) * recoil.Horizontal,
		recoil.Vertical
	)

	-- Apply recoil to camera
	if self.CameraController then
		self.CameraController:AddCameraShake(recoil.Vertical * 0.5)
	end
end

function WeaponController:StartAiming()
	self.IsAiming = true
	if self.CameraController then
		self.CameraController:SetAiming(true)
	end
end

function WeaponController:StopAiming()
	self.IsAiming = false
	if self.CameraController then
		self.CameraController:SetAiming(false)
	end
end

function WeaponController:Reload()
	if self.IsReloading then return end
	if self.CurrentAmmo >= self.CurrentWeaponData.MagazineSize then return end
	if self.ReserveAmmo <= 0 then
		print("[WeaponController] No ammo to reload!")
		return
	end

	self.IsReloading = true
	print("[WeaponController] Reloading...")

	task.wait(self.CurrentWeaponData.ReloadTime)

	-- Calculate ammo to reload
	local ammoNeeded = self.CurrentWeaponData.MagazineSize - self.CurrentAmmo
	local ammoToAdd = math.min(ammoNeeded, self.ReserveAmmo)

	self.CurrentAmmo = self.CurrentAmmo + ammoToAdd
	self.ReserveAmmo = self.ReserveAmmo - ammoToAdd

	self.IsReloading = false
	print("[WeaponController] Reload complete!")
	self:UpdateAmmoUI()
end

function WeaponController:UpdateAmmoUI()
	if self.HUD then
		self.HUD:UpdateAmmo(self.CurrentAmmo, self.ReserveAmmo)
	end
end

return WeaponController
