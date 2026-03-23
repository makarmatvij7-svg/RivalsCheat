-- ══════════════════════════════════════════
-- Key System
-- ══════════════════════════════════════════

local VALID_KEY = "RIVALS-CHEAT-2026" -- change this to whatever you want

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local keyVerified = false

-- Key UI
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeySystem"
keyGui.ResetOnSpawn = false
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.Parent = plr:WaitForChild("PlayerGui")

-- Blur background
local blur = Instance.new("Frame")
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blur.BackgroundTransparency = 0.4
blur.BorderSizePixel = 0
blur.ZIndex = 1
blur.Parent = keyGui

-- Key box
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 180)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
keyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 2
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)
local ks = Instance.new("UIStroke", keyFrame)
ks.Color = Color3.fromRGB(255, 60, 60)
ks.Thickness = 1.5

-- Title
local keyTitle = Instance.new("Frame")
keyTitle.Size = UDim2.new(1, 0, 0, 36)
keyTitle.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
keyTitle.BorderSizePixel = 0
keyTitle.ZIndex = 3
keyTitle.Parent = keyFrame
Instance.new("UICorner", keyTitle).CornerRadius = UDim.new(0, 10)

local keyTitleFix = Instance.new("Frame")
keyTitleFix.Size = UDim2.new(1, 0, 0.5, 0)
keyTitleFix.Position = UDim2.new(0, 0, 0.5, 0)
keyTitleFix.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
keyTitleFix.BorderSizePixel = 0
keyTitleFix.ZIndex = 3
keyTitleFix.Parent = keyTitle

local keyTitleLbl = Instance.new("TextLabel")
keyTitleLbl.Size = UDim2.new(1, 0, 1, 0)
keyTitleLbl.BackgroundTransparency = 1
keyTitleLbl.Text = "🔑 KEY SYSTEM"
keyTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTitleLbl.TextSize = 13
keyTitleLbl.Font = Enum.Font.GothamBold
keyTitleLbl.ZIndex = 4
keyTitleLbl.Parent = keyTitle

-- Subtitle
local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, -20, 0, 20)
subLbl.Position = UDim2.new(0, 10, 0, 44)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Enter your key to continue"
subLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
subLbl.TextSize = 11
subLbl.Font = Enum.Font.Gotham
subLbl.ZIndex = 3
subLbl.Parent = keyFrame

-- Input box
local inputBox = Instance.new("Frame")
inputBox.Size = UDim2.new(1, -20, 0, 36)
inputBox.Position = UDim2.new(0, 10, 0, 72)
inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
inputBox.BorderSizePixel = 0
inputBox.ZIndex = 3
inputBox.Parent = keyFrame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
local inputStroke = Instance.new("UIStroke", inputBox)
inputStroke.Color = Color3.fromRGB(50, 50, 65)
inputStroke.Thickness = 1

local textInput = Instance.new("TextBox")
textInput.Size = UDim2.new(1, -10, 1, 0)
textInput.Position = UDim2.new(0, 8, 0, 0)
textInput.BackgroundTransparency = 1
textInput.Text = ""
textInput.PlaceholderText = "Enter key here..."
textInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
textInput.TextColor3 = Color3.fromRGB(220, 220, 235)
textInput.TextSize = 12
textInput.Font = Enum.Font.Gotham
textInput.TextXAlignment = Enum.TextXAlignment.Left
textInput.ClearTextOnFocus = false
textInput.ZIndex = 4
textInput.Parent = inputBox

-- Status label
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -20, 0, 16)
statusLbl.Position = UDim2.new(0, 10, 0, 114)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.Gotham
statusLbl.ZIndex = 3
statusLbl.Parent = keyFrame

-- Submit button
local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -20, 0, 32)
submitBtn.Position = UDim2.new(0, 10, 0, 136)
submitBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
submitBtn.BorderSizePixel = 0
submitBtn.Text = "Verify Key"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize = 12
submitBtn.Font = Enum.Font.GothamBold
submitBtn.ZIndex = 3
submitBtn.Parent = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)

-- Hover effect
submitBtn.MouseEnter:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    }):Play()
end)
submitBtn.MouseLeave:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    }):Play()
end)

-- ══════════════════════════════════════════
-- Verify logic
-- ══════════════════════════════════════════

local function verifyKey()
    local input = textInput.Text:gsub("%s", "") -- strip spaces
    if input == VALID_KEY then
        keyVerified = true
        statusLbl.TextColor3 = Color3.fromRGB(50, 220, 100)
        statusLbl.Text = "✓ Key accepted! Loading..."
        submitBtn.Active = false

        -- Animate out
        task.wait(0.8)
        TweenService:Create(keyFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(0.5, -150, 0.5, 0)
        }):Play()
        TweenService:Create(blur, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.35)
        keyGui:Destroy()

        -- Load main script
        loadMainScript()
    else
        statusLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
        statusLbl.Text = "✗ Invalid key. Try again."
        TweenService:Create(inputStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(255, 60, 60)
        }):Play()
        task.wait(1.5)
        TweenService:Create(inputStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(50, 50, 65)
        }):Play()
    end
end

submitBtn.MouseButton1Click:Connect(verifyKey)
textInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then verifyKey() end
end)

-- ══════════════════════════════════════════
-- Main Script (loads after key verified)
-- ══════════════════════════════════════════

function loadMainScript()
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local state = {
        NoRecoil = false,
        NoSpread = false,
        AutoDrop = false,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OP Script"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = plr:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 0)
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

    -- Animate open
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 220, 0, 180)
    }):Play()

    local function createToggle(labelText, key, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.Parent = content
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Color3.fromRGB(50, 50, 60)
        rowStroke.Thickness = 1

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
        end)
    end

    createToggle("No Recoil",           "NoRecoil", 1)
    createToggle("No Spread",           "NoSpread", 2)
    createToggle("Auto Drop Collector", "AutoDrop", 3)

    -- Draggable
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

    -- No Recoil / No Spread
    local function applyTableAttribute(attribute, value)
        for _, gcVal in pairs(getgc(true)) do
            if type(gcVal) == "table" and rawget(gcVal, attribute) then
                gcVal[attribute] = value
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        if state.NoRecoil then applyTableAttribute("ShootRecoil", 0) end
        if state.NoSpread then
            applyTableAttribute("ShootSpread", 0)
            applyTableAttribute("ShootCooldown", 0)
        end
    end)

    -- Auto Drop
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
end
