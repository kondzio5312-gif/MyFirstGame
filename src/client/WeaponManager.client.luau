--[[
    WeaponManager.client.lua
    CLIENT z Combo tracking
]]

print("[WeaponManager] Script started!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local WeaponRemote = ReplicatedStorage:WaitForChild("WeaponRemote")
local CombatRemote = ReplicatedStorage:WaitForChild("CombatRemote")

local equippedStyle = "Balanced"
local isEquipped = false
local isAttacking = false

-- Combo tracking (client-side for UI later)
local comboCount = 0
local lastAttackTime = 0

local EQUIPPED_OFFSET = CFrame.new(1.5, 0, -0.5) * CFrame.Angles(0, math.rad(90), math.rad(-45))
local HOLSTERED_OFFSET = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(-45), 0, 0)

local function toggleEquip()
	local weapon = character:FindFirstChild(equippedStyle .. "Weapon")
	if not weapon then return end

	local weaponHandle = weapon.PrimaryPart
	local weld = weaponHandle:FindFirstChild("WeaponWeld")
	if not weld then return end

	isEquipped = not isEquipped

	local targetCFrame = isEquipped and EQUIPPED_OFFSET or HOLSTERED_OFFSET

	local tween = TweenService:Create(weld, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		C1 = targetCFrame
	})
	tween:Play()

	print("[WeaponManager]", isEquipped and "EQUIPPED" or "HOLSTERED")
end

local function attack()
	if not isEquipped or isAttacking then return end

	local weapon = character:FindFirstChild(equippedStyle .. "Weapon")
	if not weapon then return end

	isAttacking = true

	-- Check combo timeout
	local currentTime = tick()
	if currentTime - lastAttackTime > 0.8 then
		comboCount = 0
	end

	comboCount = comboCount + 1
	if comboCount > 3 then
		comboCount = 1
	end

	lastAttackTime = currentTime

	print("[WeaponManager] Combo hit:", comboCount, "/3")

	local weaponHandle = weapon.PrimaryPart
	local weld = weaponHandle:FindFirstChild("WeaponWeld")
	if not weld then 
		isAttacking = false
		return 
	end

	-- Different swing angles per combo
	local swingAngles = {
		[1] = 60,   -- Light swing
		[2] = 90,   -- Medium swing
		[3] = 120   -- Heavy finisher
	}

	local swingAngle = swingAngles[comboCount] or 90

	-- Swing animation
	local originalC1 = weld.C1
	local swingC1 = originalC1 * CFrame.Angles(0, 0, math.rad(swingAngle))

	-- Faster for combo 1, slower for combo 3
	local animSpeed = comboCount == 3 and 0.2 or 0.15

	local swingTween = TweenService:Create(weld, TweenInfo.new(animSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		C1 = swingC1
	})

	swingTween:Play()
	swingTween.Completed:Wait()

	-- Fire server
	CombatRemote:FireServer("Attack", equippedStyle)

	-- Return
	local returnTween = TweenService:Create(weld, TweenInfo.new(animSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		C1 = originalC1
	})

	returnTween:Play()
	returnTween.Completed:Wait()

	isAttacking = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		toggleEquip()

	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		attack()
	end
end)

-- Listen for hit confirms
CombatRemote.OnClientEvent:Connect(function(action, comboHit, damage)
	if action == "HitConfirm" then
		print("[WeaponManager] HIT CONFIRMED! Combo:", comboHit, "Damage:", damage)
		-- TODO: VFX, sound, UI update
	end
end)

WeaponRemote.OnClientEvent:Connect(function(action, weaponStyle)
	if action == "WeaponSpawned" then
		equippedStyle = weaponStyle
	end
end)

print("[WeaponManager] Loaded with Combo System! Press E to equip, LMB spam for combo!")
