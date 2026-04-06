--[[
    CombatServer.server.lua
    Combat z Combo + I-frame support
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatRemote = Instance.new("RemoteEvent")
CombatRemote.Name = "CombatRemote"
CombatRemote.Parent = ReplicatedStorage

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local playerCombos = {}

local COMBO_DAMAGE = {
	[1] = 10,
	[2] = 15,
	[3] = 25
}

local function performHitDetection(player, weaponStyle, comboHit)
	local character = player.Character
	if not character then return false end

	local weaponName = weaponStyle .. "Weapon"
	local weapon = character:FindFirstChild(weaponName)
	if not weapon then return false end

	local blade = weapon:FindFirstChild("Blade")
	local tipAttachment = blade and blade:FindFirstChild("TipAttachment")
	if not tipAttachment then return false end

	local origin = tipAttachment.WorldPosition
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local direction = hrp.CFrame.LookVector * Config.Combat.RaycastDistance

	raycastParams.FilterDescendantsInstances = {character}

	local rayResult = workspace:Raycast(origin, direction, raycastParams)

	if rayResult then
		local hitPart = rayResult.Instance
		local hitModel = hitPart.Parent

		if hitModel and hitModel:FindFirstChild("Humanoid") then
			-- I-frame check
			local targetPlayer = game.Players:GetPlayerFromCharacter(hitModel)
			if targetPlayer and _G.IsPlayerInvincible and _G.IsPlayerInvincible(targetPlayer) then
				print("[CombatServer] I-FRAME BLOCK!")

				hitPart.Color = Color3.fromRGB(100, 200, 255)
				task.wait(0.1)
				hitPart.Color = hitPart.BrickColor.Color

				return false
			end

			local damage = COMBO_DAMAGE[comboHit] or 10
			hitModel.Humanoid:TakeDamage(damage)

			print("[CombatServer] HIT! Combo", comboHit, "Damage:", damage)

			local originalColor = hitPart.Color
			hitPart.Color = Color3.new(1, 1, 1)
			task.wait(0.1)
			hitPart.Color = originalColor

			CombatRemote:FireClient(player, "HitConfirm", comboHit, damage)

			return true
		end
	end

	return false
end

CombatRemote.OnServerEvent:Connect(function(player, action, ...)
	if action == "Attack" then
		local weaponStyle = ...

		if not playerCombos[player] then
			playerCombos[player] = { count = 0, lastHitTime = 0 }
		end

		local comboData = playerCombos[player]
		local currentTime = tick()

		if currentTime - comboData.lastHitTime > Config.Combat.ComboTimeout then
			comboData.count = 0
		end

		comboData.count = comboData.count + 1

		if comboData.count > Config.Combat.MaxComboHits then
			comboData.count = 1
		end

		comboData.lastHitTime = currentTime

		performHitDetection(player, weaponStyle, comboData.count)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	playerCombos[player] = nil
end)

print("[CombatServer] Loaded with I-frame support!")
