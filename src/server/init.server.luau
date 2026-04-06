--[[
    Server initialization
    Główny server script - ładuje wszystkie systemy
]]

print("=" .. string.rep("=", 50) .. "=")
print("[SERVER] MyFirstGame server starting...")
print("=" .. string.rep("=", 50) .. "=")

-- Wait for all server scripts to load
task.wait(2)

print("[SERVER] All systems loaded!")
print("[SERVER] Ready for combat!")
print("")
print("Controls:")
print("  E - Equip/Holster weapon")
print("  LMB - Attack (combo)")
print("  SHIFT+WASD - Dash")
print("  V - Camera mode")
print("  B - Weapon menu")
print("  F8 - Log window")
print("")
