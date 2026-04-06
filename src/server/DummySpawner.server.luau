--[[
    DummySpawner.server.lua
    Spawnuje dummy NPC do testów
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(1)
local Config = ReplicatedStorage:WaitForChild("Config")
if Config:IsA("ModuleScript") then
    Config = require(Config)
else
    warn("[DummySpawner] Config nie jest ModuleScript!")
    return
end

local function createDummy()
    local dummy = Instance.new("Model")
    dummy.Name = "TrainingDummy"
    
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = Config.Player.BaseHealth
    humanoid.Health = Config.Player.BaseHealth
    humanoid.WalkSpeed = 0
    humanoid.Parent = dummy
    
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Position = Config.Arena.DummySpawnPosition
    torso.Anchored = true
    torso.BrickColor = BrickColor.new("Bright red")
    torso.Material = Enum.Material.SmoothPlastic
    torso.Parent = dummy
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Position = torso.Position + Vector3.new(0, 1.5, 0)
    head.Anchored = true
    head.BrickColor = BrickColor.new("Bright red")
    head.Material = Enum.Material.SmoothPlastic
    head.Parent = dummy
    
    local face = Instance.new("Decal")
    face.Texture = "rbxasset://textures/face.png"
    face.Face = Enum.NormalId.Front
    face.Parent = head
    
    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2, 2, 1)
    hrp.Position = torso.Position
    hrp.Transparency = 1
    hrp.Anchored = true
    hrp.CanCollide = false
    hrp.Parent = dummy
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, 0, 1, 0)
    hpText.BackgroundTransparency = 1
    hpText.Text = "HP: " .. humanoid.Health
    hpText.TextColor3 = Color3.new(1, 1, 1)
    hpText.TextScaled = true
    hpText.Font = Enum.Font.SourceSansBold
    hpText.Parent = billboard
    
    humanoid.HealthChanged:Connect(function(health)
        hpText.Text = "HP: " .. math.floor(health)
    end)
    
    humanoid.Died:Connect(function()
        wait(3)
        dummy:Destroy()
        createDummy()
    end)
    
    dummy.Parent = workspace
    print("[DummySpawner] Training dummy spawned!")
end

createDummy()
