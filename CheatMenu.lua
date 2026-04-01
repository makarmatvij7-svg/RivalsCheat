-- ══════════════════════════════════════════
-- KEY SYSTEM – Remote (GitHub raw)
-- ══════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local keyVerified = false

-- URL to your raw text file containing the key (only the key, nothing else)
local KEY_URL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/key.txt"

-- Optional: local fallback key in case the URL fails (remove if you want strict remote)
local FALLBACK_KEY = "Rivals2025"   -- set to nil if you don't want a fallback

local function fetchKey()
    local success, response = pcall(function()
        return HttpService:GetAsync(KEY_URL)
    end)
    if success and response then
        -- Remove any trailing newlines/spaces
        return response:gsub("^%s*(.-)%s*$", "%1")
    else
        warn("[Key System] Failed to fetch key from GitHub, using fallback.")
        return FALLBACK_KEY
    end
end

local CORRECT_KEY = fetchKey()

-- If no key is available, abort
if not CORRECT_KEY or CORRECT_KEY == "" then
    print("[Key System] No valid key found. Script aborted.")
    return
end

-- Create GUI (same as before)
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeySystem"
keyGui.ResetOnSpawn = false
keyGui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", keyGui)
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 200)
stroke.Thickness = 2

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Enter License Key"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local keyBox = Instance.new("TextBox", mainFrame)
keyBox.Size = UDim2.new(0.8, 0, 0, 30)
keyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
keyBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
keyBox.Text = ""
keyBox.PlaceholderText = "Your key here"
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 4)

local submitBtn = Instance.new("TextButton", mainFrame)
submitBtn.Size = UDim2.new(0.4, 0, 0, 32)
submitBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 140)
submitBtn.Text = "Unlock"
submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 14
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 4)

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12

local function verifyKey()
    local input = keyBox.Text
    if input == CORRECT_KEY then
        keyVerified = true
        keyGui:Destroy()
    else
        statusLabel.Text = "Invalid key. Try again."
        keyBox.Text = ""
        keyBox:CaptureFocus()
    end
end

submitBtn.MouseButton1Click:Connect(verifyKey)
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then verifyKey() end
end)

repeat task.wait() until keyVerified

print("Key verified! Loading script...")
