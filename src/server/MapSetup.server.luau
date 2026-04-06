--[[
    MapSetup.server.lua
    Tworzy testową arenę
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Czekaj na Config
wait(1)
local Config = ReplicatedStorage:WaitForChild("Config")
if Config:IsA("ModuleScript") then
    Config = require(Config)
else
    warn("[MapSetup] Config nie jest ModuleScript!")
    return
end

-- Usuń baseplate
if workspace:FindFirstChild("Baseplate") then
    workspace.Baseplate:Destroy()
end

-- Stwórz arenę
local arena = Instance.new("Part")
arena.Name = "Arena"
arena.Size = Vector3.new(Config.Arena.Size, 1, Config.Arena.Size)
arena.Position = Vector3.new(0, 0, 0)
arena.Anchored = true
arena.Color = Color3.fromRGB(60, 60, 60)
arena.Material = Enum.Material.SmoothPlastic
arena.Parent = workspace

-- Spawn points
local function createSpawnPoint(name, position)
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = name
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = position
    spawn.Anchored = true
    spawn.CanCollide = false
    spawn.Transparency = 0.5
    spawn.BrickColor = BrickColor.new("Bright green")
    spawn.Parent = workspace
end

createSpawnPoint("PlayerSpawn1", Vector3.new(-30, Config.Arena.SpawnHeight, 0))
createSpawnPoint("PlayerSpawn2", Vector3.new(30, Config.Arena.SpawnHeight, 0))

-- Oświetlenie
local lighting = game:GetService("Lighting")
lighting.Brightness = 2
lighting.Ambient = Color3.fromRGB(100, 100, 100)
lighting.TimeOfDay = "14:00:00"

print("[MapSetup] Arena created successfully!")
