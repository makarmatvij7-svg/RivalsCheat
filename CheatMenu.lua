-- Key System
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local KEY_URL = "https://raw.githubusercontent.com/makarmatvij7-svg/RivalsCheat/main/keys.txt"

local validKeys = {}
local fetchSuccess = true

local ok, result = pcall(function()
    local data = game:HttpGet(KEY_URL, true)
    for line in data:gmatch("[^\r\n]+") do
        local trimmed = line:gsub("%s", "")
        if trimmed ~= "" then validKeys[trimmed] = true end
    end
    fetchSuccess = true
end)

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeySystem"
keyGui.ResetOnSpawn = false
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.Parent = plr:WaitForChild("PlayerGui")

local blur = Instance.new("Frame")
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blur.BackgroundTransparency = 0.4
blur.BorderSizePixel = 0
blur.ZIndex = 1
blur.Parent = keyGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 195)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -97)
keyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 2
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)
local ks = Instance.new("UIStroke", keyFrame)
ks.Color = Color3.fromRGB(255, 60, 60)
ks.Thickness = 1.5

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

local fetchLbl = Instance.new("TextLabel")
fetchLbl.Size = UDim2.new(1, -20, 0, 16)
fetchLbl.Position = UDim2.new(0, 10, 0, 42)
fetchLbl.BackgroundTransparency = 1
fetchLbl.TextSize = 10
fetchLbl.Font = Enum.Font.Gotham
fetchLbl.ZIndex = 3
fetchLbl.Parent = keyFrame

if fetchSuccess then
    fetchLbl.Text = "✓ Connected to key server"
    fetchLbl.TextColor3 = Color3.fromRGB(50, 220, 100)
else
    fetchLbl.Text = "✗ Could not reach key server"
    fetchLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
end

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, -20, 0, 16)
subLbl.Position = UDim2.new(0, 10, 0, 60)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Enter your key to continue"
subLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
subLbl.TextSize = 11
subLbl.Font = Enum.Font.Gotham
subLbl.ZIndex = 3
subLbl.Parent = keyFrame

local inputBox = Instance.new("Frame")
inputBox.Size = UDim2.new(1, -20, 0, 36)
inputBox.Position = UDim2.new(0, 10, 0, 82)
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

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -20, 0, 16)
statusLbl.Position = UDim2.new(0, 10, 0, 124)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.Gotham
statusLbl.ZIndex = 3
statusLbl.Parent = keyFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -20, 0, 32)
submitBtn.Position = UDim2.new(0, 10, 0, 150)
submitBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
submitBtn.BorderSizePixel = 0
submitBtn.Text = "Verify Key"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize = 12
submitBtn.Font = Enum.Font.GothamBold
submitBtn.ZIndex = 3
submitBtn.Parent = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)

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

local function verifyKey()
    local input = textInput.Text:gsub("%s", "")
    if not fetchSuccess then
        statusLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
        statusLbl.Text = "✗ Key server unreachable."
        return
    end
    if validKeys[input] then
        statusLbl.TextColor3 = Color3.fromRGB(50, 220, 100)
        statusLbl.Text = "✓ Key accepted! Loading..."
        submitBtn.Active = false
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
        loadstring(game:HttpGet("https://raw.githubusercontent.com/makarmatvij7-svg/RivalsCheat/main/Main.lua", true))()
        
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
