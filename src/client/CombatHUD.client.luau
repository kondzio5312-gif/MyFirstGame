--[[
    CombatHUD.client.lua
    HUD: HP bar, dash cooldown, combo counter
]]

print("[CombatHUD] Script started!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local CombatRemote = ReplicatedStorage:WaitForChild("CombatRemote")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- HP BAR (góra, środek)
local hpFrame = Instance.new("Frame")
hpFrame.Name = "HPFrame"
hpFrame.Size = UDim2.new(0, 400, 0, 40)
hpFrame.Position = UDim2.new(0.5, -200, 0, 20)
hpFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hpFrame.BackgroundTransparency = 0.3
hpFrame.BorderSizePixel = 0
hpFrame.Parent = screenGui

local hpFrameCorner = Instance.new("UICorner")
hpFrameCorner.CornerRadius = UDim.new(0, 8)
hpFrameCorner.Parent = hpFrame

-- HP Fill
local hpFill = Instance.new("Frame")
hpFill.Name = "Fill"
hpFill.Size = UDim2.new(1, -4, 1, -4)
hpFill.Position = UDim2.new(0, 2, 0, 2)
hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpFrame

local hpFillCorner = Instance.new("UICorner")
hpFillCorner.CornerRadius = UDim.new(0, 6)
hpFillCorner.Parent = hpFill

-- HP Text
local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Text = "1000 / 1000"
hpText.TextColor3 = Color3.new(1, 1, 1)
hpText.TextScaled = true
hpText.Font = Enum.Font.SourceSansBold
hpText.ZIndex = 2
hpText.Parent = hpFrame

-- DASH COOLDOWN BAR (pod HP)
local dashFrame = Instance.new("Frame")
dashFrame.Name = "DashFrame"
dashFrame.Size = UDim2.new(0, 400, 0, 15)
dashFrame.Position = UDim2.new(0.5, -200, 0, 70)
dashFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
dashFrame.BackgroundTransparency = 0.3
dashFrame.BorderSizePixel = 0
dashFrame.Parent = screenGui

local dashFrameCorner = Instance.new("UICorner")
dashFrameCorner.CornerRadius = UDim.new(0, 6)
dashFrameCorner.Parent = dashFrame

local dashFill = Instance.new("Frame")
dashFill.Name = "Fill"
dashFill.Size = UDim2.new(1, -2, 1, -2)
dashFill.Position = UDim2.new(0, 1, 0, 1)
dashFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
dashFill.BorderSizePixel = 0
dashFill.Parent = dashFrame

local dashFillCorner = Instance.new("UICorner")
dashFillCorner.CornerRadius = UDim.new(0, 5)
dashFillCorner.Parent = dashFill

local dashText = Instance.new("TextLabel")
dashText.Size = UDim2.new(1, 0, 1, 0)
dashText.BackgroundTransparency = 1
dashText.Text = "DASH READY"
dashText.TextColor3 = Color3.new(1, 1, 1)
dashText.TextSize = 12
dashText.Font = Enum.Font.SourceSansBold
dashText.ZIndex = 2
dashText.Parent = dashFrame

-- COMBO COUNTER (środek ekranu)
local comboLabel = Instance.new("TextLabel")
comboLabel.Name = "ComboLabel"
comboLabel.Size = UDim2.new(0, 300, 0, 80)
comboLabel.Position = UDim2.new(0.5, -150, 0.3, 0)
comboLabel.BackgroundTransparency = 1
comboLabel.Text = ""
comboLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
comboLabel.TextScaled = true
comboLabel.Font = Enum.Font.SourceSansBold
comboLabel.TextStrokeTransparency = 0.5
comboLabel.Visible = false
comboLabel.Parent = screenGui

-- COOLDOWN INDICATORS (prawy dolny)
local cooldownFrame = Instance.new("Frame")
cooldownFrame.Name = "CooldownFrame"
cooldownFrame.Size = UDim2.new(0, 200, 0, 200)
cooldownFrame.Position = UDim2.new(1, -220, 1, -220)
cooldownFrame.BackgroundTransparency = 1
cooldownFrame.Parent = screenGui

local skillKeys = {"Q", "E", "R"}
local skillIcons = {}

for i, key in ipairs(skillKeys) do
	local icon = Instance.new("Frame")
	icon.Name = key .. "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 0, 0, (i - 1) * 70)
	icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	icon.BackgroundTransparency = 0.3
	icon.BorderSizePixel = 0
	icon.Parent = cooldownFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(1, 0, 0.5, 0)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = key
	keyLabel.TextColor3 = Color3.new(1, 1, 1)
	keyLabel.TextScaled = true
	keyLabel.Font = Enum.Font.SourceSansBold
	keyLabel.Parent = icon

	local cdText = Instance.new("TextLabel")
	cdText.Name = "CDText"
	cdText.Size = UDim2.new(1, 0, 0.5, 0)
	cdText.Position = UDim2.new(0, 0, 0.5, 0)
	cdText.BackgroundTransparency = 1
	cdText.Text = "READY"
	cdText.TextColor3 = Color3.fromRGB(0, 255, 0)
	cdText.TextSize = 14
	cdText.Font = Enum.Font.SourceSans
	cdText.Parent = icon

	skillIcons[key] = {frame = icon, cdText = cdText}
end

-- Update HP
local function updateHP()
	if not humanoid or not humanoid.Parent then return end

	local health = math.floor(humanoid.Health)
	local maxHealth = humanoid.MaxHealth
	local percent = health / maxHealth

	hpFill.Size = UDim2.new(percent, -4, 1, -4)
	hpText.Text = health .. " / " .. math.floor(maxHealth)

	-- Color based on %
	if percent > 0.5 then
		hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Zielony
	elseif percent > 0.25 then
		hpFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Żółty
	else
		hpFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Czerwony
	end
end

humanoid.HealthChanged:Connect(updateHP)
updateHP()

-- Dash cooldown tracking (listen to DashSystem events)
local dashCooldown = false
local dashCooldownEnd = 0

local function updateDashBar()
	local now = tick()

	if dashCooldown and now < dashCooldownEnd then
		local remaining = dashCooldownEnd - now
		local percent = remaining / Config.Combat.Cooldowns.Dash

		dashFill.Size = UDim2.new(percent, -2, 1, -2)
		dashText.Text = string.format("%.1f", remaining)
		dashFill.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	else
		dashFill.Size = UDim2.new(1, -2, 1, -2)
		dashText.Text = "DASH READY"
		dashFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		dashCooldown = false
	end
end

RunService.RenderStepped:Connect(updateDashBar)

-- Listen for dash events (from DashSystem)
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		if not dashCooldown then
			dashCooldown = true
			dashCooldownEnd = tick() + Config.Combat.Cooldowns.Dash
		end
	end
end)

-- Combo counter (listen to CombatRemote)
local comboCount = 0
local comboTimeout = nil

CombatRemote.OnClientEvent:Connect(function(action, comboHit, damage)
	if action == "HitConfirm" then
		comboCount = comboHit

		-- Show combo
		comboLabel.Text = "COMBO x" .. comboCount .. "!"
		comboLabel.Visible = true

		-- Color based on combo
		if comboCount == 1 then
			comboLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		elseif comboCount == 2 then
			comboLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		elseif comboCount == 3 then
			comboLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
		end

		-- Clear previous timeout
		if comboTimeout then
			comboTimeout:Disconnect()
		end

		-- Hide after timeout
		comboTimeout = task.delay(1, function()
			comboLabel.Visible = false
		end)
	end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")

	humanoid.HealthChanged:Connect(updateHP)
	updateHP()
end)

print("[CombatHUD] Loaded! HUD active!")
