-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

local state = {
    NoRecoil = false, NoSpread = false, AutoDrop = false, SilentAim = false
}
local cachedTables = {}

local function findAndCache(attribute)
    if cachedTables[attribute] then return end
    cachedTables[attribute] = {}
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) ~= nil then
            table.insert(cachedTables[attribute], { tbl = gcVal, original = gcVal[attribute] })
        end
    end
end

local function applyAttribute(attribute, value)
    findAndCache(attribute)
    if type(cachedTables[attribute]) ~= "table" then return end
    for _, entry in pairs(cachedTables[attribute]) do
        if type(entry) == "table" and entry.tbl then
            entry.tbl[attribute] = value
        end
    end
end

local function restoreAttribute(attribute)
    if not cachedTables[attribute] then return end
    if type(cachedTables[attribute]) ~= "table" then cachedTables[attribute] = nil return end
    for _, entry in pairs(cachedTables[attribute]) do
        if type(entry) == "table" and entry.tbl then
            entry.tbl[attribute] = entry.original
        end
    end
    cachedTables[attribute] = nil
end

local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then closestDist = dist closest = p end
                end
            end
        end
    end
    return closest
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    if state.SilentAim and self == UserInputService and key == "GetMouseLocation" then
        local target = getClosestTarget()
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    return function() return Vector2.new(screenPos.X, screenPos.Y) end
                end
            end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 60, 60)
stroke.Thickness = 1.5

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

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

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -42)
content.Position = UDim2.new(0, 10, 0, 37)
content.BackgroundTransparency = 1
content.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = content

local function createToggle(labelText, key, order, onEnable, onDisable)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", row).Color = Color3.fromRGB(50, 50, 60)

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

    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 42, 0, 22)
    pillBg.Position = UDim2.new(1, -52, 0.5, -11)
    pillBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    pillBg.BorderSizePixel = 0
    pillBg.Parent = row
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(160, 160, 170)
    knob.BorderSizePixel = 0
    knob.Parent = pillBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

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
        if state[key] then if onEnable then onEnable() end
        else if onDisable then onDisable() end end
    end)
end

createToggle("No Recoil",           "NoRecoil",  1,
    function() applyAttribute("ShootRecoil", 0) end,
    function() restoreAttribute("ShootRecoil") end)
createToggle("No Spread",           "NoSpread",  2,
    function() applyAttribute("ShootSpread", 0) applyAttribute("ShootCooldown", 0) end,
    function() restoreAttribute("ShootSpread") restoreAttribute("ShootCooldown") end)
createToggle("Auto Drop Collector", "AutoDrop",  3, nil, nil)
createToggle("Silent Aim",          "SilentAim", 4, nil, nil)

local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = frame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local drops, lastRun = {}, 0
local INTERVAL = 0.05

workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "_drop" then drops[obj] = true end
end)
workspace.ChildRemoved:Connect(function(obj) drops[obj] = nil end)
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "_drop" then drops[obj] = true end
end

RunService.Heartbeat:Connect(function()
    if not state.AutoDrop then return end
    local now = tick()
    if (now - lastRun) < INTERVAL then return end
    lastRun = now
    local char = plr.Character if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for obj in pairs(drops) do
        if obj.Parent then
            firetouchinterest(hrp, obj, 0)
            firetouchinterest(hrp, obj, 1)
        end
    end
end)
