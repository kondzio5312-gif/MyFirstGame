--[[
    DashSystem.client.lua
    Dash bez obracania postaci + dowolna kolejność klawiszy
]]

print("[DashSystem] Script started!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local DashRemote = ReplicatedStorage:WaitForChild("DashRemote")

local isDashing = false
local dashCooldown = false
local lastDashTime = 0

-- Trail VFX
local function createTrail()
	local trail = Instance.new("Trail")
	trail.Lifetime = 0.3
	trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.WidthScale = NumberSequence.new(1)

	local attach0 = Instance.new("Attachment")
	attach0.Position = Vector3.new(0, -1, 0)
	attach0.Parent = rootPart

	local attach1 = Instance.new("Attachment")
	attach1.Position = Vector3.new(0, 1, 0)
	attach1.Parent = rootPart

	trail.Attachment0 = attach0
	trail.Attachment1 = attach1
	trail.Parent = rootPart

	return trail, attach0, attach1
end

-- Sprawdź który kierunek jest trzymany
local function getCurrentDirection()
	local forward = rootPart.CFrame.LookVector
	local right = rootPart.CFrame.RightVector

	local w = UserInputService:IsKeyDown(Enum.KeyCode.W)
	local a = UserInputService:IsKeyDown(Enum.KeyCode.A)
	local s = UserInputService:IsKeyDown(Enum.KeyCode.S)
	local d = UserInputService:IsKeyDown(Enum.KeyCode.D)

	if w then
		print("[DashSystem] Direction: FORWARD (W)")
		return forward
	elseif s then
		print("[DashSystem] Direction: BACK (S)")
		return -forward
	elseif a then
		print("[DashSystem] Direction: LEFT (A)")
		return -right
	elseif d then
		print("[DashSystem] Direction: RIGHT (D)")
		return right
	else
		print("[DashSystem] Direction: FORWARD (default)")
		return forward
	end
end

-- Dash
local function performDash()
	if isDashing then return end

	if dashCooldown then 
		local timeSince = tick() - lastDashTime
		local remaining = Config.Combat.Cooldowns.Dash - timeSince
		return 
	end

	print("[DashSystem] DASH!")

	isDashing = true
	dashCooldown = true
	lastDashTime = tick()

	-- ZAPISZ obecny obrót postaci (żeby zachować)
	local originalCFrame = rootPart.CFrame
	local originalRotation = originalCFrame - originalCFrame.Position

	-- Pobierz kierunek dash
	local moveDirection = getCurrentDirection()

	-- Raycast check
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local dashDistance = 20
	local rayResult = workspace:Raycast(rootPart.Position, moveDirection * dashDistance, rayParams)

	if rayResult then
		dashDistance = (rayResult.Position - rootPart.Position).Magnitude - 2
	end

	-- Trail
	local trail, attach0, attach1 = createTrail()

	-- WAŻNE: AlignOrientation - blokuje obracanie podczas dash
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = Instance.new("Attachment", rootPart)
	alignOrientation.RigidityEnabled = true
	alignOrientation.CFrame = originalRotation
	alignOrientation.Parent = rootPart

	-- Velocity (NIE zmienia rotacji!)
	local dashVelocity = Instance.new("BodyVelocity")
	dashVelocity.MaxForce = Vector3.new(100000, 0, 100000)
	dashVelocity.Velocity = moveDirection * Config.Player.DashSpeed
	dashVelocity.Parent = rootPart

	DashRemote:FireServer("DashStart")

	-- PODCZAS dash - lockuj rotację
	local lockConnection
	lockConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if rootPart and rootPart.Parent then
			-- Zachowaj pozycję, ale przywróć oryginalną rotację
			local currentPosition = rootPart.Position
			rootPart.CFrame = CFrame.new(currentPosition) * originalRotation
		end
	end)

	task.wait(Config.Player.DashDuration)

	-- Cleanup
	lockConnection:Disconnect()
	dashVelocity:Destroy()
	alignOrientation:Destroy()
	isDashing = false

	DashRemote:FireServer("DashEnd")

	task.wait(0.3)
	trail:Destroy()
	attach0:Destroy()
	attach1:Destroy()

	print("[DashSystem] Dash complete!")

	-- Cooldown
	task.wait(Config.Combat.Cooldowns.Dash - Config.Player.DashDuration)
	dashCooldown = false
	print("[DashSystem] Dash ready!")
end

-- Input - SHIFT (lub W/A/S/D + SHIFT w dowolnej kolejności)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- SHIFT wciśnięty
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		performDash()
	end

	-- W/A/S/D wciśnięte + SHIFT trzymany
	if input.KeyCode == Enum.KeyCode.W or 
		input.KeyCode == Enum.KeyCode.A or 
		input.KeyCode == Enum.KeyCode.S or 
		input.KeyCode == Enum.KeyCode.D then

		-- Sprawdź czy SHIFT jest trzymany
		local shiftHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
			UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		if shiftHeld then
			performDash()
		end
	end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	isDashing = false
	dashCooldown = false
end)

print("[DashSystem] Loaded! SHIFT+WASD (any order) to dash!")
