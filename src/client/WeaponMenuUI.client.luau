--[[
    WeaponMenuUI.client.lua
    Menu wyboru broni (B = otwórz)
]]

print("[WeaponMenuUI] Script started!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local WeaponRemote = ReplicatedStorage:WaitForChild("WeaponRemote", 10)
if not WeaponRemote then
	warn("[WeaponMenuUI] WeaponRemote not found!")
	return
end

local menuOpen = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponMenuUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 250, 0, 400)
menuFrame.Position = UDim2.new(0, 20, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BackgroundTransparency = 0.2
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = menuFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "WEAPON STYLE"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = menuFrame

local weaponStyles = {"Speed", "Balanced", "Heavy"}
local weaponDescriptions = {
	Speed = "Fast attacks\nLow damage",
	Balanced = "Balanced stats",
	Heavy = "Slow attacks\nHigh damage"
}

local buttonColors = {
	Speed = Color3.fromRGB(100, 200, 255),
	Balanced = Color3.fromRGB(200, 200, 200),
	Heavy = Color3.fromRGB(255, 100, 100)
}

for i, style in ipairs(weaponStyles) do
	local button = Instance.new("TextButton")
	button.Name = style .. "Button"
	button.Size = UDim2.new(0.9, 0, 0, 80)
	button.Position = UDim2.new(0.05, 0, 0, 80 + (i - 1) * 100)
	button.BackgroundColor3 = buttonColors[style]
	button.BackgroundTransparency = 0.3
	button.BorderSizePixel = 0
	button.Text = style:upper()
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.SourceSansBold
	button.Parent = menuFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = button

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -10, 0.5, 0)
	desc.Position = UDim2.new(0, 5, 0.5, 0)
	desc.BackgroundTransparency = 1
	desc.Text = weaponDescriptions[style]
	desc.TextColor3 = Color3.new(1, 1, 1)
	desc.TextSize = 12
	desc.Font = Enum.Font.SourceSans
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.Parent = button

	button.MouseButton1Click:Connect(function()
		print("[WeaponMenuUI] Selected:", style)

		for _, btn in pairs(menuFrame:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundTransparency = 0.3
			end
		end
		button.BackgroundTransparency = 0

		WeaponRemote:FireServer("SpawnWeapon", style)

		menuFrame.Visible = false
		menuOpen = false
	end)
end

-- ZMIANA: TAB → B
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.B then  -- ZMIENIONE Z TAB
		menuOpen = not menuOpen
		menuFrame.Visible = menuOpen
		print("[WeaponMenuUI] Menu:", menuOpen and "OPEN" or "CLOSED")
	end
end)

print("[WeaponMenuUI] Loaded! Press B to open weapon menu!")  -- ZMIENIONE
