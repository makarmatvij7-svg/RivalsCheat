-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

-- State
local state = {
    NoRecoil = false,
    NoSpread = false,
    AutoDrop = false,
}

-- ══════════════════════════════════════════
-- UI
-- ══════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OP Script"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = plr:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 60, 60)
stroke.Thickness = 1.5
stroke.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Fix bottom corners of title bar
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ CHEAT MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Content container
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -42)
content.Position = UDim2.new(0, 10, 0, 37)
content.BackgroundTransparency = 1
content.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = content

-- ══════════════════════════════════════════
-- Toggle Button Factory
-- ══════════════════════════════════════════

local function createToggle(labelText, key, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(50, 50, 60)
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Toggle pill
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 42, 0, 22)
    pillBg.Position = UDim2.new(1, -52, 0.5, -11)
    pillBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    pillBg.BorderSizePixel = 0
    pillBg.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pillBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(160, 160, 170)
    knob.BorderSizePixel = 0
    knob.Parent = pillBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = row

    local function updateVisual(on)
        TweenService:Create(pillBg, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(50, 50, 60)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = on and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
        }):Play()
        label.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
    end

    button.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        updateVisual(state[key])
    end)

    return row
end

createToggle("No Recoil", "NoRecoil", 1)
createToggle("No Spread", "NoSpread", 2)
createToggle("Auto Drop Collector", "AutoDrop", 3)

-- ══════════════════════════════════════════
-- Draggable
-- ══════════════════════════════════════════

local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════════
-- Logic: No Recoil / No Spread
-- ══════════════════════════════════════════

local function applyTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

RunService.Heartbeat:Connect(function()
    if state.NoRecoil then
        applyTableAttribute("ShootRecoil", 0)
    end
    if state.NoSpread then
        applyTableAttribute("ShootSpread", 0)
        applyTableAttribute("ShootCooldown", 0)
    end
end)

-- ══════════════════════════════════════════
-- Logic: Auto Drop Collector
-- ══════════════════════════════════════════

local drops = {}
local lastRun = 0
local INTERVAL = 0.05

workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "_drop" then drops[obj] = true end
end)
workspace.ChildRemoved:Connect(function(obj)
    drops[obj] = nil
end)
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "_drop" then drops[obj] = true end
end

RunService.Heartbeat:Connect(function()
    if not state.AutoDrop then return end
    local now = tick()
    if (now - lastRun) < INTERVAL then return end
    lastRun = now

    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for obj in pairs(drops) do
        if obj.Parent then
            firetouchinterest(hrp, obj, 0)
            firetouchinterest(hrp, obj, 1)
        end
    end
end)
