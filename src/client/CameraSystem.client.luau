--[[
    CameraSystem.client.lua
    3 tryby kamery - FIXED ORDER
]]

print("[CameraSystem] Script started!")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local CAMERA_MODES = {"Standard", "Action", "FirstPerson"}
local currentModeIndex = 1
local currentMode = CAMERA_MODES[currentModeIndex]

local rotationConnection = nil
local moveConnection = nil

-- DEFINE FUNCTIONS FIRST (before calling them!)

local function startInstantRotation()
	if rotationConnection then return end

	rotationConnection = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end
		if not rootPart or not rootPart.Parent then return end

		local cameraLook = camera.CFrame.LookVector
		local horizontalLook = Vector3.new(cameraLook.X, 0, cameraLook.Z)

		if horizontalLook.Magnitude > 0 then
			horizontalLook = horizontalLook.Unit
			local targetCFrame = CFrame.new(rootPart.Position, rootPart.Position + horizontalLook)
			rootPart.CFrame = CFrame.new(rootPart.Position) * (targetCFrame - targetCFrame.Position)
		end
	end)
end

local function enableCustomMovement()
	local function updateMovement()
		if not character or not character.Parent then return end
		if not humanoid or not humanoid.Parent then return end

		local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
		local backward = UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
		local left = UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
		local right = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0

		local cameraCFrame = camera.CFrame
		local cameraForward = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit
		local cameraRight = Vector3.new(cameraCFrame.RightVector.X, 0, cameraCFrame.RightVector.Z).Unit

		local moveDirection = (cameraForward * (forward - backward)) + (cameraRight * (right - left))

		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end

		humanoid:Move(moveDirection, false)
	end

	moveConnection = RunService.RenderStepped:Connect(updateMovement)
end

local function applyCameraMode()
	if not character or not character.Parent then
		character = player.Character or player.CharacterAdded:Wait()
		humanoid = character:WaitForChild("Humanoid")
		rootPart = character:WaitForChild("HumanoidRootPart")
	end

	if rotationConnection then
		rotationConnection:Disconnect()
		rotationConnection = nil
	end

	if moveConnection then
		moveConnection:Disconnect()
		moveConnection = nil
	end

	if currentMode == "Standard" then
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMaxZoomDistance = 20
		player.CameraMinZoomDistance = 5
		humanoid.AutoRotate = true
		camera.CameraSubject = humanoid

		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		print("[CameraSystem] Mode: STANDARD")

	elseif currentMode == "Action" then
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMaxZoomDistance = 20
		player.CameraMinZoomDistance = 5
		humanoid.AutoRotate = false
		camera.CameraSubject = humanoid

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		startInstantRotation()
		enableCustomMovement()

		print("[CameraSystem] Mode: ACTION")

	elseif currentMode == "FirstPerson" then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		player.CameraMaxZoomDistance = 0.5
		player.CameraMinZoomDistance = 0.5
		humanoid.AutoRotate = false
		camera.CameraSubject = humanoid

		local head = character:FindFirstChild("Head")
		if head then
			camera.CameraSubject = head
		end

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		startInstantRotation()
		enableCustomMovement()

		print("[CameraSystem] Mode: FIRST PERSON")
	end
end

local function toggleCameraMode()
	local previousMode = currentMode

	currentModeIndex = currentModeIndex + 1
	if currentModeIndex > #CAMERA_MODES then
		currentModeIndex = 1
	end

	currentMode = CAMERA_MODES[currentModeIndex]
	applyCameraMode()

	if previousMode == "FirstPerson" and currentMode ~= "FirstPerson" then
		task.wait(0.1)

		if humanoid and humanoid.Parent then
			camera.CameraSubject = humanoid
		end

		local head = character and character:FindFirstChild("Head")
		if head and rootPart and rootPart.Parent then
			local lookDirection = rootPart.CFrame.LookVector
			local cameraPosition = head.Position - (lookDirection * 10) + Vector3.new(0, 2, 0)
			camera.CFrame = CFrame.lookAt(cameraPosition, head.Position)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.V then
		toggleCameraMode()
	end
end)

player.CharacterAdded:Connect(function(newChar)
	if rotationConnection then
		rotationConnection:Disconnect()
		rotationConnection = nil
	end

	if moveConnection then
		moveConnection:Disconnect()
		moveConnection = nil
	end

	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	applyCameraMode()
end)

applyCameraMode()

print("[CameraSystem] Loaded! Press V!")
