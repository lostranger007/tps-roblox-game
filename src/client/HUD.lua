--[[
	HUD Module
	Manages the player's heads-up display
	Shows health, ammo, crosshair, and other UI elements
]]

local Players = game:GetService("Players")

local HUD = {}
HUD.__index = HUD

function HUD.new(player)
	local self = setmetatable({}, HUD)

	self.Player = player
	self.ScreenGui = nil
	self.AmmoLabel = nil
	self.HealthBar = nil
	self.Crosshair = nil

	self:CreateHUD()

	return self
end

function HUD:CreateHUD()
	-- Create ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "GameHUD"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = self.Player.PlayerGui

	-- Create crosshair
	self:CreateCrosshair()

	-- Create ammo display
	self:CreateAmmoDisplay()

	-- Create health bar
	self:CreateHealthBar()

	print("[HUD] HUD created")
end

function HUD:CreateCrosshair()
	-- Center dot
	local centerDot = Instance.new("Frame")
	centerDot.Name = "CenterDot"
	centerDot.Size = UDim2.new(0, 4, 0, 4)
	centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
	centerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	centerDot.BorderSizePixel = 0
	centerDot.Parent = self.ScreenGui

	-- Top line
	local topLine = Instance.new("Frame")
	topLine.Name = "TopLine"
	topLine.Size = UDim2.new(0, 2, 0, 10)
	topLine.Position = UDim2.new(0.5, -1, 0.5, -20)
	topLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topLine.BorderSizePixel = 0
	topLine.Parent = self.ScreenGui

	-- Bottom line
	local bottomLine = Instance.new("Frame")
	bottomLine.Name = "BottomLine"
	bottomLine.Size = UDim2.new(0, 2, 0, 10)
	bottomLine.Position = UDim2.new(0.5, -1, 0.5, 10)
	bottomLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bottomLine.BorderSizePixel = 0
	bottomLine.Parent = self.ScreenGui

	-- Left line
	local leftLine = Instance.new("Frame")
	leftLine.Name = "LeftLine"
	leftLine.Size = UDim2.new(0, 10, 0, 2)
	leftLine.Position = UDim2.new(0.5, -20, 0.5, -1)
	leftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	leftLine.BorderSizePixel = 0
	leftLine.Parent = self.ScreenGui

	-- Right line
	local rightLine = Instance.new("Frame")
	rightLine.Name = "RightLine"
	rightLine.Size = UDim2.new(0, 10, 0, 2)
	rightLine.Position = UDim2.new(0.5, 10, 0.5, -1)
	rightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	rightLine.BorderSizePixel = 0
	rightLine.Parent = self.ScreenGui

	self.Crosshair = {
		CenterDot = centerDot,
		TopLine = topLine,
		BottomLine = bottomLine,
		LeftLine = leftLine,
		RightLine = rightLine,
	}
end

function HUD:CreateAmmoDisplay()
	-- Background frame
	local ammoFrame = Instance.new("Frame")
	ammoFrame.Name = "AmmoFrame"
	ammoFrame.Size = UDim2.new(0, 200, 0, 80)
	ammoFrame.Position = UDim2.new(1, -220, 1, -100)
	ammoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ammoFrame.BackgroundTransparency = 0.3
	ammoFrame.BorderSizePixel = 0
	ammoFrame.Parent = self.ScreenGui

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = ammoFrame

	-- Current ammo (large)
	local currentAmmo = Instance.new("TextLabel")
	currentAmmo.Name = "CurrentAmmo"
	currentAmmo.Size = UDim2.new(0.5, 0, 1, 0)
	currentAmmo.Position = UDim2.new(0, 10, 0, 0)
	currentAmmo.BackgroundTransparency = 1
	currentAmmo.Font = Enum.Font.GothamBold
	currentAmmo.TextSize = 48
	currentAmmo.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentAmmo.TextXAlignment = Enum.TextXAlignment.Left
	currentAmmo.Text = "30"
	currentAmmo.Parent = ammoFrame

	-- Separator
	local separator = Instance.new("TextLabel")
	separator.Name = "Separator"
	separator.Size = UDim2.new(0, 20, 1, 0)
	separator.Position = UDim2.new(0.5, -10, 0, 0)
	separator.BackgroundTransparency = 1
	separator.Font = Enum.Font.GothamBold
	separator.TextSize = 36
	separator.TextColor3 = Color3.fromRGB(150, 150, 150)
	separator.Text = "/"
	separator.Parent = ammoFrame

	-- Reserve ammo (smaller)
	local reserveAmmo = Instance.new("TextLabel")
	reserveAmmo.Name = "ReserveAmmo"
	reserveAmmo.Size = UDim2.new(0.4, 0, 1, 0)
	reserveAmmo.Position = UDim2.new(0.6, 0, 0, 0)
	reserveAmmo.BackgroundTransparency = 1
	reserveAmmo.Font = Enum.Font.Gotham
	reserveAmmo.TextSize = 28
	reserveAmmo.TextColor3 = Color3.fromRGB(200, 200, 200)
	reserveAmmo.TextXAlignment = Enum.TextXAlignment.Right
	reserveAmmo.Text = "120"
	reserveAmmo.Parent = ammoFrame

	self.AmmoLabel = {
		Frame = ammoFrame,
		Current = currentAmmo,
		Reserve = reserveAmmo,
	}
end

function HUD:CreateHealthBar()
	-- Background frame
	local healthFrame = Instance.new("Frame")
	healthFrame.Name = "HealthFrame"
	healthFrame.Size = UDim2.new(0, 300, 0, 30)
	healthFrame.Position = UDim2.new(0, 20, 1, -50)
	healthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	healthFrame.BackgroundTransparency = 0.3
	healthFrame.BorderSizePixel = 0
	healthFrame.Parent = self.ScreenGui

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = healthFrame

	-- Health bar fill
	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.new(1, -4, 1, -4)
	healthFill.Position = UDim2.new(0, 2, 0, 2)
	healthFill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthFrame

	-- Add rounded corners to fill
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = healthFill

	-- Health text
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Font = Enum.Font.GothamBold
	healthText.TextSize = 18
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.Text = "100 HP"
	healthText.Parent = healthFrame

	self.HealthBar = {
		Frame = healthFrame,
		Fill = healthFill,
		Text = healthText,
	}

	-- Update health bar when health changes
	local character = self.Player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.HealthChanged:Connect(function(health)
				self:UpdateHealth(health, humanoid.MaxHealth)
			end)
		end
	end
end

function HUD:UpdateAmmo(currentAmmo, reserveAmmo)
	if self.AmmoLabel then
		self.AmmoLabel.Current.Text = tostring(currentAmmo)
		self.AmmoLabel.Reserve.Text = tostring(reserveAmmo)

		-- Change color if low on ammo
		if currentAmmo <= 5 then
			self.AmmoLabel.Current.TextColor3 = Color3.fromRGB(255, 80, 80)
		else
			self.AmmoLabel.Current.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

function HUD:UpdateHealth(currentHealth, maxHealth)
	if self.HealthBar then
		local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)

		-- Update bar size
		self.HealthBar.Fill.Size = UDim2.new(healthPercent, -4, 1, -4)

		-- Update text
		self.HealthBar.Text.Text = math.floor(currentHealth) .. " HP"

		-- Change color based on health
		if healthPercent > 0.6 then
			self.HealthBar.Fill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
		elseif healthPercent > 0.3 then
			self.HealthBar.Fill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
		else
			self.HealthBar.Fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
	end
end

function HUD:SetCrosshairColor(color)
	if self.Crosshair then
		for _, element in pairs(self.Crosshair) do
			element.BackgroundColor3 = color
		end
	end
end

function HUD:ShowReloadingIndicator()
	if not self.AmmoLabel then return end

	local indicator = Instance.new("TextLabel")
	indicator.Name = "ReloadIndicator"
	indicator.Size = UDim2.new(1, 0, 0.3, 0)
	indicator.Position = UDim2.new(0, 0, 0, -30)
	indicator.BackgroundTransparency = 1
	indicator.Font = Enum.Font.GothamBold
	indicator.TextSize = 18
	indicator.TextColor3 = Color3.fromRGB(255, 255, 0)
	indicator.Text = "RELOADING..."
	indicator.Parent = self.AmmoLabel.Frame

	return indicator
end

function HUD:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return HUD
