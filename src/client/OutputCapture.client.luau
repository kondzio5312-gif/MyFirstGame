--[[
    OutputCapture.client.lua
    Kopiowalne logi!
]]

local LogService = game:GetService("LogService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LogCapture"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 400)
frame.Position = UDim2.new(1, -620, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui

-- ScrollingFrame (kopiowalne!)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.Parent = frame

-- TextBox (DA SIĘ KOPIOWAĆ!)
local logBox = Instance.new("TextBox")
logBox.Size = UDim2.new(1, 0, 1, 0)
logBox.BackgroundTransparency = 1
logBox.TextColor3 = Color3.new(1, 1, 1)
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.Font = Enum.Font.Code
logBox.TextSize = 14
logBox.Text = "[LogCapture] Ready...\n"
logBox.TextEditable = false
logBox.ClearTextOnFocus = false
logBox.MultiLine = true
logBox.Parent = scroll

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "LOGS (Ctrl+A, Ctrl+C to copy)"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(1, -90, 0, 5)
closeBtn.Text = "CLOSE"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- Capture logs
local logBuffer = {}

LogService.MessageOut:Connect(function(message, messageType)
	local timestamp = os.date("%H:%M:%S")
	local prefix = "INFO"

	if messageType == Enum.MessageType.MessageWarning then
		prefix = "WARN"
	elseif messageType == Enum.MessageType.MessageError then
		prefix = "ERROR"
	end

	local logLine = string.format("[%s] %s: %s\n", timestamp, prefix, message)
	table.insert(logBuffer, logLine)

	-- Update TextBox
	logBox.Text = table.concat(logBuffer)

	-- Auto-scroll
	scroll.CanvasPosition = Vector2.new(0, logBox.TextBounds.Y)
end)

-- Toggle with F8
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F8 then
		frame.Visible = not frame.Visible
	end
end)

print("[OutputCapture] Loaded! Press F8 to open log window. Use Ctrl+A, Ctrl+C to copy!")
