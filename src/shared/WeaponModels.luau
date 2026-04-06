--[[
    WeaponModels.lua
    Definicje 3 stylów broni
]]

local WeaponModels = {}

function WeaponModels.CreateWeapon(style)
	print("[WeaponModels] CreateWeapon called with style:", style)

	local weapon = Instance.new("Model")
	weapon.Name = style .. "Weapon"

	-- Blade (ostrze)
	local blade = Instance.new("Part")
	blade.Name = "Blade"
	blade.Size = Vector3.new(0.3, 4, 0.8)
	blade.Material = Enum.Material.SmoothPlastic
	blade.CanCollide = false

	-- Handle (rękojeść)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 1.2, 0.3)
	handle.Material = Enum.Material.SmoothPlastic
	handle.CanCollide = false
	handle.Color = Color3.fromRGB(50, 50, 50)

	-- Attachment na czubku ostrza (do raycast)
	local tipAttachment = Instance.new("Attachment")
	tipAttachment.Name = "TipAttachment"
	tipAttachment.Position = Vector3.new(0, 2, 0)
	tipAttachment.Parent = blade

	-- Weld blade do handle
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = blade
	weld.Parent = handle

	blade.Position = handle.Position + Vector3.new(0, 2.6, 0)

	blade.Parent = weapon
	handle.Parent = weapon

	-- Style-specific properties
	if style == "Speed" then
		blade.Color = Color3.fromRGB(100, 200, 255)
		blade.Size = Vector3.new(0.2, 3.5, 0.6)
		weapon:SetAttribute("Style", "Speed")
		weapon:SetAttribute("AttackSpeed", 1.3)
		weapon:SetAttribute("Damage", 8)

	elseif style == "Balanced" then
		blade.Color = Color3.fromRGB(200, 200, 200)
		blade.Size = Vector3.new(0.3, 4, 0.8)
		weapon:SetAttribute("Style", "Balanced")
		weapon:SetAttribute("AttackSpeed", 1.0)
		weapon:SetAttribute("Damage", 10)

	elseif style == "Heavy" then
		blade.Color = Color3.fromRGB(255, 100, 100)
		blade.Size = Vector3.new(0.4, 5, 1.0)
		weapon:SetAttribute("Style", "Heavy")
		weapon:SetAttribute("AttackSpeed", 0.7)
		weapon:SetAttribute("Damage", 14)
	end

	weapon.PrimaryPart = handle

	print("[WeaponModels] Created weapon:", weapon.Name, "Damage:", weapon:GetAttribute("Damage"))

	return weapon
end

return WeaponModels
