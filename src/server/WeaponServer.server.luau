--[[
    WeaponServer.server.lua
    Server tworzy i zarządza bronią
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponModels = require(ReplicatedStorage:WaitForChild("WeaponModels"))

-- RemoteEvent
local WeaponRemote = Instance.new("RemoteEvent")
WeaponRemote.Name = "WeaponRemote"
WeaponRemote.Parent = ReplicatedStorage
print("[WeaponServer] WeaponRemote created!")

-- Tracking weapons
local playerWeapons = {}

-- Spawn weapon dla gracza
local function spawnWeaponForPlayer(player, weaponStyle)
	print("[WeaponServer] Spawning weapon for:", player.Name, "Style:", weaponStyle)

	local character = player.Character
	if not character then 
		warn("[WeaponServer] No character!")
		return 
	end

	-- Usuń starą broń
	if playerWeapons[player] then
		playerWeapons[player]:Destroy()
		playerWeapons[player] = nil
	end

	-- Stwórz nową
	local weapon = WeaponModels.CreateWeapon(weaponStyle)
	print("[WeaponServer] Weapon created:", weapon.Name)

	local rootPart = character:WaitForChild("HumanoidRootPart")
	local weaponHandle = weapon.PrimaryPart

	-- Unanchor wszystko
	for _, part in pairs(weapon:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	-- Weld
	local weld = Instance.new("Motor6D")
	weld.Name = "WeaponWeld"
	weld.Part0 = rootPart
	weld.Part1 = weaponHandle
	weld.C1 = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(-45), 0, 0) -- Holstered
	weld.Parent = weaponHandle

	weapon.Parent = character

	playerWeapons[player] = weapon

	print("[WeaponServer] Weapon parented to character!")

	-- Confirm to client
	WeaponRemote:FireClient(player, "WeaponSpawned", weaponStyle)
end

-- Player join
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		wait(1)
		spawnWeaponForPlayer(player, "Balanced") -- Default weapon
	end)
end)

-- Handle client requests
WeaponRemote.OnServerEvent:Connect(function(player, action, ...)
	print("[WeaponServer] Request from client:", action)

	if action == "SpawnWeapon" then
		local weaponStyle = ...
		spawnWeaponForPlayer(player, weaponStyle)

	elseif action == "EquipToggle" then
		-- Client handled, just acknowledge
		print("[WeaponServer] Equip toggle for:", player.Name)
	end
end)

-- Set player HP to 1000
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = 1000
		humanoid.Health = 1000
		print("[WeaponServer] Player HP set to 1000 for:", player.Name)
	end)
end)

print("[WeaponServer] Loaded!")
