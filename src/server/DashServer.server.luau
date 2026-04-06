--[[
    DashServer.server.lua
    Server-side dash logic (i-frame)
]]

print("[DashServer] Script starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CREATE DASHREMOTE FIRST
local DashRemote = Instance.new("RemoteEvent")
DashRemote.Name = "DashRemote"
DashRemote.Parent = ReplicatedStorage
print("[DashServer] DashRemote created!")

task.wait(0.2)

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local playerIFrames = {}

local function isInvincible(player)
	return playerIFrames[player] == true
end

_G.IsPlayerInvincible = isInvincible

DashRemote.OnServerEvent:Connect(function(player, action)
	if action == "DashStart" then
		playerIFrames[player] = true

		task.delay(Config.Combat.IFrameDuration + 0.1, function()
			if playerIFrames[player] then
				playerIFrames[player] = false
			end
		end)

	elseif action == "DashEnd" then
		playerIFrames[player] = false
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	playerIFrames[player] = nil
end)

print("[DashServer] Loaded!")
