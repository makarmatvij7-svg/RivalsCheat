-- ══════════════════════════════════════════
-- EXECUTOR SUPPORT CHECK
-- Required APIs → missing = kick with message
-- Optional APIs → missing = that feature disabled, no kick
-- ══════════════════════════════════════════

local function checkExecutor()
    -- ── REQUIRED: script cannot function at all without these ──
    local required = {
        ["getgc (GC scanner — needed for No Recoil, Rapid Fire, Anti Katana etc.)"] = getgc,
        ["getgenv (environment access — needed for Aimbot)"]                         = getgenv,
        ["loadstring (needed to load Silent Aim)"]                                   = loadstring,
        ["Drawing (needed for ESP)"]                                                 = Drawing,
    }

    -- ── OPTIONAL: missing = feature silently disabled, no kick ──
    local optional = {
        firetouchinterest = firetouchinterest,  -- Auto Drop Collector
        writefile         = writefile,           -- Config save
        readfile          = readfile,            -- Config load
        isfile            = isfile,              -- Config check
    }

    -- Disable optional features that are missing so they don't error
    if not optional.firetouchinterest then
        firetouchinterest = function() end   -- no-op so AutoDrop just does nothing
    end
    if not optional.writefile or not optional.readfile or not optional.isfile then
        -- Stub out file functions so Save/Load buttons show a friendly error instead of crashing
        writefile = writefile or function() error("writefile not supported") end
        readfile  = readfile  or function() error("readfile not supported") end
        isfile    = isfile    or function() return false end
    end

    -- Check required APIs
    local missing = {}
    for name, api in pairs(required) do
        if not api then
            table.insert(missing, name)
        end
    end

    if #missing > 0 then
        table.sort(missing)
        local msg = "❌ Unsupported Executor!\n\nMissing required APIs:\n• "
            .. table.concat(missing, "\n• ")
            .. "\n\nSupported executors:\nSolara, Delta, Wave, Synapse X,\nKRNL, Fluxus, Codex, Madium"

        local sg = Instance.new("ScreenGui")
        sg.ResetOnSpawn = false
        sg.Name = "UnsupportedExecutor"
        sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0,500,0,300)
        frame.Position = UDim2.new(0.5,-250,0.5,-150)
        frame.BackgroundColor3 = Color3.fromRGB(12,8,8)
        frame.BorderSizePixel = 0
        Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke",frame)
        stroke.Color = Color3.fromRGB(255,60,60) stroke.Thickness = 2

        local lbl = Instance.new("TextLabel",frame)
        lbl.Size = UDim2.new(1,-20,1,-20)
        lbl.Position = UDim2.new(0,10,0,10)
        lbl.BackgroundTransparency = 1
        lbl.Text = msg
        lbl.TextColor3 = Color3.fromRGB(255,200,200)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true

        task.wait(4)
        game:GetService("Players").LocalPlayer:Kick(
            "Unsupported executor. Missing: " .. table.concat(missing, ", ")
            .. " — Use Solara, Delta, Wave, Synapse X, KRNL, Fluxus, Codex, or Madium."
        )
        return false
    end

    return true
end

if not checkExecutor() then return end

-- ══════════════════════════════════════════
-- Services
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ══════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════

-- ── Configuration ────────────────────────
-- Set VALID_KEY to your chosen key string.
-- Set KEY_URL to wherever players get their key (Linkvertise, pastebin, etc.)
local VALID_KEY = "RX7A-91KQ-ZL2P-8XWM"
local KEY_URL   = "https://loot-link.com/s?3YVOShw2"   -- replace with your actual URL

-- ── Colours (matches main cheat UI exactly) ──
local KC = {
    bg     = Color3.fromRGB(8,   8,   12),
    bg2    = Color3.fromRGB(14,  14,  20),
    bg3    = Color3.fromRGB(20,  20,  30),
    neon   = Color3.fromRGB(0,   255, 200),
    neon2  = Color3.fromRGB(0,   180, 140),
    border = Color3.fromRGB(30,  60,  50),
    text   = Color3.fromRGB(210, 255, 245),
    dim    = Color3.fromRGB(90,  130, 120),
    red    = Color3.fromRGB(255, 70,  70),
    green  = Color3.fromRGB(0,   255, 120),
}

local keyVerified = false

do
    local kGui = Instance.new("ScreenGui")
    kGui.Name = "CyberDragonKey"
    kGui.ResetOnSpawn = false
    kGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    kGui.DisplayOrder = 999
    kGui.Parent = plr:WaitForChild("PlayerGui")

    -- ── Blur/dimmed backdrop ──────────────────
    local backdrop = Instance.new("Frame", kGui)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.45
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 1

    -- ── Main window ───────────────────────────
    local win = Instance.new("Frame", kGui)
    win.Size = UDim2.new(0, 440, 0, 320)
    win.Position = UDim2.new(0.5, -220, 0.5, -160)
    win.BackgroundColor3 = KC.bg
    win.BorderSizePixel = 0
    win.ZIndex = 2
    win.BackgroundTransparency = 1  -- start invisible, tween in
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
    local winStroke = Instance.new("UIStroke", win)
    winStroke.Color = KC.neon
    winStroke.Thickness = 1.5
    winStroke.Transparency = 1

    -- ── Title bar ─────────────────────────────
    local titleBar = Instance.new("Frame", win)
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = KC.bg2
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    local tbFix = Instance.new("Frame", titleBar)
    tbFix.Size = UDim2.new(1, 0, 0.5, 0)
    tbFix.Position = UDim2.new(0, 0, 0.5, 0)
    tbFix.BackgroundColor3 = KC.bg2
    tbFix.BorderSizePixel = 0
    tbFix.ZIndex = 3

    -- Accent bar left of title
    local accent = Instance.new("Frame", titleBar)
    accent.Size = UDim2.new(0, 3, 1, -10)
    accent.Position = UDim2.new(0, 8, 0, 5)
    accent.BackgroundColor3 = KC.neon
    accent.BorderSizePixel = 0
    accent.ZIndex = 4
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local titleLbl = Instance.new("TextLabel", titleBar)
    titleLbl.Size = UDim2.new(1, -20, 1, 0)
    titleLbl.Position = UDim2.new(0, 18, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "◈ CYBER CHEAT  •  Key System"
    titleLbl.TextColor3 = KC.neon
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4

    -- ── Body ──────────────────────────────────
    -- Dragon icon / header
    local iconLbl = Instance.new("TextLabel", win)
    iconLbl.Size = UDim2.new(1, 0, 0, 40)
    iconLbl.Position = UDim2.new(0, 0, 0, 48)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = "🐉"
    iconLbl.TextSize = 32
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center
    iconLbl.ZIndex = 3

    local headLbl = Instance.new("TextLabel", win)
    headLbl.Size = UDim2.new(1, -40, 0, 22)
    headLbl.Position = UDim2.new(0, 20, 0, 92)
    headLbl.BackgroundTransparency = 1
    headLbl.Text = "Enter your key to unlock CyberDragon"
    headLbl.TextColor3 = KC.text
    headLbl.TextSize = 13
    headLbl.Font = Enum.Font.GothamBold
    headLbl.TextXAlignment = Enum.TextXAlignment.Center
    headLbl.ZIndex = 3

    local subLbl = Instance.new("TextLabel", win)
    subLbl.Size = UDim2.new(1, -40, 0, 18)
    subLbl.Position = UDim2.new(0, 20, 0, 116)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = "Don't have a key? Click 'Get Key' below."
    subLbl.TextColor3 = KC.dim
    subLbl.TextSize = 11
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextXAlignment = Enum.TextXAlignment.Center
    subLbl.ZIndex = 3

    -- ── Key input box ─────────────────────────
    local inputFrame = Instance.new("Frame", win)
    inputFrame.Size = UDim2.new(1, -40, 0, 36)
    inputFrame.Position = UDim2.new(0, 20, 0, 146)
    inputFrame.BackgroundColor3 = KC.bg2
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 3
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)
    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = KC.border
    inputStroke.Thickness = 1

    -- Key icon inside box
    local keyIcon = Instance.new("TextLabel", inputFrame)
    keyIcon.Size = UDim2.new(0, 28, 1, 0)
    keyIcon.BackgroundTransparency = 1
    keyIcon.Text = "🔑"
    keyIcon.TextSize = 14
    keyIcon.Font = Enum.Font.GothamBold
    keyIcon.TextXAlignment = Enum.TextXAlignment.Center
    keyIcon.ZIndex = 4

    local keyInput = Instance.new("TextBox", inputFrame)
    keyInput.Size = UDim2.new(1, -36, 1, 0)
    keyInput.Position = UDim2.new(0, 28, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Paste your key here..."
    keyInput.PlaceholderColor3 = KC.dim
    keyInput.TextColor3 = KC.text
    keyInput.TextSize = 12
    keyInput.Font = Enum.Font.Gotham
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus = false
    keyInput.ZIndex = 4

    -- Focus glow on input
    keyInput.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.15), {Color=KC.neon, Transparency=0}):Play()
    end)
    keyInput.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.15), {Color=KC.border, Transparency=0}):Play()
    end)

    -- ── Status label ──────────────────────────
    local statusLbl = Instance.new("TextLabel", win)
    statusLbl.Size = UDim2.new(1, -40, 0, 18)
    statusLbl.Position = UDim2.new(0, 20, 0, 191)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = ""
    statusLbl.TextColor3 = KC.dim
    statusLbl.TextSize = 11
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.ZIndex = 3

    local function setStatus(msg, col)
        statusLbl.Text = msg
        statusLbl.TextColor3 = col or KC.dim
    end

    -- ── Buttons row ───────────────────────────
    local btnRow = Instance.new("Frame", win)
    btnRow.Size = UDim2.new(1, -40, 0, 36)
    btnRow.Position = UDim2.new(0, 20, 0, 218)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 3

    -- Helper to make a styled button
    local function makeKeyBtn(parent, text, xScale, wScale, bg, hoverBg)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(wScale, -4, 1, 0)
        btn.Position = UDim2.new(xScale, 2, 0, 0)
        btn.BackgroundColor3 = bg
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = KC.text
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 4
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = KC.neon bs.Thickness = 1 bs.Transparency = 0.6

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3=hoverBg}):Play()
            TweenService:Create(bs, TweenInfo.new(0.12), {Transparency=0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3=bg}):Play()
            TweenService:Create(bs, TweenInfo.new(0.12), {Transparency=0.6}):Play()
        end)
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {Size=UDim2.new(wScale,-6,1,-2)}):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size=UDim2.new(wScale,-4,1,0)}):Play()
        end)
        return btn, bs
    end

    -- "Get Key" button (left, 45%)
    local getKeyBtn = makeKeyBtn(btnRow, "🔗  Get Key", 0, 0.45,
        Color3.fromRGB(14,14,20), Color3.fromRGB(0,40,32))

    -- "Verify" button (right, 55%)
    local verifyBtn, verifyStroke = makeKeyBtn(btnRow, "✓  Verify Key", 0.45, 0.55,
        Color3.fromRGB(0,30,22), Color3.fromRGB(0,55,42))
    verifyStroke.Transparency = 0
    verifyStroke.Color = KC.neon

    -- ── Divider line ──────────────────────────
    local divLine = Instance.new("Frame", win)
    divLine.Size = UDim2.new(1, -40, 0, 1)
    divLine.Position = UDim2.new(0, 20, 0, 266)
    divLine.BackgroundColor3 = KC.border
    divLine.BorderSizePixel = 0
    divLine.ZIndex = 3

    -- ── Footer ────────────────────────────────
    local footerLbl = Instance.new("TextLabel", win)
    footerLbl.Size = UDim2.new(1, -40, 0, 28)
    footerLbl.Position = UDim2.new(0, 20, 0, 272)
    footerLbl.BackgroundTransparency = 1
    footerLbl.Text = "Key is reset every 24 hours  •  Never share your key"
    footerLbl.TextColor3 = Color3.fromRGB(55, 80, 72)
    footerLbl.TextSize = 10
    footerLbl.Font = Enum.Font.Gotham
    footerLbl.TextXAlignment = Enum.TextXAlignment.Center
    footerLbl.ZIndex = 3

    -- ── Button logic ──────────────────────────
    getKeyBtn.MouseButton1Click:Connect(function()
        -- Copy URL to clipboard and show feedback
        pcall(function() setclipboard(KEY_URL) end)
        setStatus("🔗  Key URL copied to clipboard!", KC.neon2)
        getKeyBtn.Text = "✓  Copied!"
        task.delay(2.5, function()
            getKeyBtn.Text = "🔗  Get Key"
            setStatus("")
        end)
    end)

    verifyBtn.MouseButton1Click:Connect(function()
        local entered = keyInput.Text:gsub("%s+","")  -- strip whitespace
        if entered == "" then
            setStatus("⚠  Please enter a key first.", KC.dim)
            TweenService:Create(inputStroke, TweenInfo.new(0.1), {Color=KC.dim}):Play()
            return
        end

        if entered == VALID_KEY then
            -- ✅ Correct
            setStatus("✅  Key accepted! Loading CyberDragon...", KC.green)
            TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(0,60,35)}):Play()
            verifyBtn.Text = "✓  Accepted!"
            verifyBtn.TextColor3 = KC.green
            TweenService:Create(inputStroke, TweenInfo.new(0.15), {Color=KC.green}):Play()
            TweenService:Create(winStroke, TweenInfo.new(0.3), {Color=KC.green}):Play()

            task.delay(1.2, function()
                -- Fade out the key window
                TweenService:Create(win, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
                TweenService:Create(winStroke, TweenInfo.new(0.4), {Transparency=1}):Play()
                TweenService:Create(backdrop, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play()
                task.delay(0.45, function()
                    kGui:Destroy()
                    keyVerified = true
                end)
            end)
        else
            -- ❌ Wrong key
            setStatus("❌  Invalid key. Try again.", KC.red)
            TweenService:Create(inputStroke, TweenInfo.new(0.1), {Color=KC.red}):Play()
            -- Shake the input box
            local origPos = inputFrame.Position
            local shakeAmts = {6, -5, 4, -3, 2, -1, 0}
            task.spawn(function()
                for _, amt in ipairs(shakeAmts) do
                    inputFrame.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + amt, origPos.Y.Scale, origPos.Y.Offset)
                    task.wait(0.04)
                end
                inputFrame.Position = origPos
                TweenService:Create(inputStroke, TweenInfo.new(0.4), {Color=KC.border}):Play()
                task.delay(2, function() setStatus("") end)
            end)
        end
    end)

    -- Also verify on Enter key press
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then verifyBtn.MouseButton1Click:Fire() end
    end)

    -- ── Entrance animation ────────────────────
    task.spawn(function()
        task.wait(0.05)
        win.Position = UDim2.new(0.5, -220, 0.5, -180)
        TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -220, 0.5, -160)
        }):Play()
        TweenService:Create(winStroke, TweenInfo.new(0.35), {Transparency=0}):Play()
    end)

    -- ── Block execution until key is verified ─
    repeat task.wait(0.05) until keyVerified
end

-- ══════════════════════════════════════════
-- State
-- ══════════════════════════════════════════

local state = {
    NoRecoil=false, NoSpread=false, AutoDrop=false, ESP=false,
    ThirdPerson=false, AntiKatana=false, NoBounds=false,
    JumpBug=false, AutoStrafe=false, RapidFire=false,
    AutoWeapon=false, InstantScope=false, AlwaysBackstab=false,
    RemoveKillers=false, NoFireDamage=false, AntiFreeze=false,
    Fly=false, Noclip=false, AntiAim=false, AutoFarm=false,
    TornadoAnim=false,
}

local settings = { WalkSpeed=16, JumpPower=50, StrafeIntensity=50, FlySpeed=50 }
local farmPosition = "Behind"

-- ══════════════════════════════════════════
-- GC Cache
-- ══════════════════════════════════════════

local cachedTables = {}

local function findAndCache(attribute)
    if cachedTables[attribute] then return end
    cachedTables[attribute] = {}
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) ~= nil then
            table.insert(cachedTables[attribute], { tbl=gcVal, original=gcVal[attribute] })
        end
    end
end

local function applyAttribute(attribute, value)
    findAndCache(attribute)
    if type(cachedTables[attribute]) ~= "table" then return end
    for _, entry in pairs(cachedTables[attribute]) do
        if type(entry) == "table" and entry.tbl then
            pcall(function() entry.tbl[attribute] = value end)
        end
    end
end

local function restoreAttribute(attribute)
    if not cachedTables[attribute] then return end
    if type(cachedTables[attribute]) ~= "table" then cachedTables[attribute]=nil return end
    for _, entry in pairs(cachedTables[attribute]) do
        if type(entry) == "table" and entry.tbl then
            pcall(function() entry.tbl[attribute] = entry.original end)
        end
    end
    cachedTables[attribute] = nil
end

local function gcCacheOnce(keys)
    local cached = {}
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" then
            for _, key in pairs(keys) do
                if rawget(gcVal, key) ~= nil then
                    table.insert(cached, {tbl=gcVal, key=key, original=gcVal[key]})
                end
            end
        end
    end
    return cached
end

-- ══════════════════════════════════════════
-- Auto Farm
-- ══════════════════════════════════════════

local autoFarmConn = nil
local autoFarmLastTick = 0

local function getClosestEnemy()
    local char = plr.Character if not char then return nil end
    local myHrp = char:FindFirstChild("HumanoidRootPart") if not myHrp then return nil end
    local closest, closestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myHrp.Position).Magnitude
                if dist < closestDist then closestDist = dist closest = p end
            end
        end
    end
    return closest
end

local function getFarmOffset(targetHrp)
    if farmPosition == "Above" then
        return targetHrp.Position + Vector3.new(0, 6, 0)
    elseif farmPosition == "Under" then
        return targetHrp.Position - Vector3.new(0, 3, 0)
    else
        local look = targetHrp.CFrame.LookVector
        return targetHrp.Position - (look * 3) + Vector3.new(0, 0.5, 0)
    end
end

local function enableAutoFarm()
    autoFarmConn = RunService.Heartbeat:Connect(function()
        if not state.AutoFarm then return end
        local now = tick()
        if (now - autoFarmLastTick) < 0.1 then return end
        autoFarmLastTick = now
        local char = plr.Character if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local target = getClosestEnemy()
        if not target or not target.Character then return end
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart") if not targetHrp then return end
        local targetHum = target.Character:FindFirstChild("Humanoid") if not targetHum then return end
        if targetHum.Health <= 0 then return end
        if targetHrp.Position.Magnitude > 10000 then return end
        if targetHrp.Position.Y > 2000 then return end
        local targetPos = getFarmOffset(targetHrp)
        hrp.CFrame = CFrame.new(targetPos, targetHrp.Position)
    end)
end

local function disableAutoFarm()
    if autoFarmConn then autoFarmConn:Disconnect() autoFarmConn=nil end
end

-- ══════════════════════════════════════════
-- Fly
-- ══════════════════════════════════════════

local flyConn, flyBodyVel, flyBodyGyro = nil, nil, nil

local function enableFly()
    local char = plr.Character if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyBodyVel.P = 1e4
    flyBodyVel.Parent = hrp
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyBodyGyro.P = 1e4
    flyBodyGyro.D = 100
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not state.Fly then return end
        local c2 = plr.Character if not c2 then return end
        local hrp2 = c2:FindFirstChild("HumanoidRootPart") if not hrp2 then return end
        local speed = settings.FlySpeed
        local dir = Vector3.zero
        local camCF = camera.CFrame
        local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0,1,0)
        end
        if dir.Magnitude > 0 then flyBodyVel.Velocity = dir.Unit * speed else flyBodyVel.Velocity = Vector3.zero end
        flyBodyGyro.CFrame = camCF
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel=nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro=nil end
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ══════════════════════════════════════════
-- Noclip
-- ══════════════════════════════════════════

local noclipConn = nil

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not state.Noclip then return end
        local char = plr.Character if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    local char = plr.Character if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- ══════════════════════════════════════════
-- Anti Aim
-- ══════════════════════════════════════════

local antiAimConn, antiAimAngle = nil, 0

local function enableAntiAim()
    antiAimConn = RunService.Heartbeat:Connect(function()
        if not state.AntiAim then return end
        local char = plr.Character if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        antiAimAngle = (antiAimAngle + 25) % 360
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.pi, math.rad(antiAimAngle), 0)
    end)
end

local function disableAntiAim()
    if antiAimConn then antiAimConn:Disconnect() antiAimConn=nil end
    antiAimAngle = 0
end

-- ══════════════════════════════════════════
-- Third Person
-- ══════════════════════════════════════════

local tpConn, originalCameraType = nil, nil

local function enableThirdPerson()
    local char = plr.Character if not char then return end
    if not originalCameraType then originalCameraType = camera.CameraType end
    camera.CameraType = Enum.CameraType.Scriptable
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=0 end
    end
    tpConn = RunService.RenderStepped:Connect(function()
        if not state.ThirdPerson then return end
        local c = plr.Character if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local camPos = hrp.Position - (hrp.CFrame.LookVector*12) + Vector3.new(0,4,0)
        camera.CFrame = CFrame.new(camPos, hrp.Position + Vector3.new(0,2,0))
    end)
end

local function disableThirdPerson()
    if tpConn then tpConn:Disconnect() tpConn=nil end
    if originalCameraType then camera.CameraType=originalCameraType originalCameraType=nil end
    local char = plr.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=0 end
        end
    end
end

-- ══════════════════════════════════════════
-- Anti Katana
-- ══════════════════════════════════════════

local antiKatanaConn, katanaCached = nil, {}

local function enableAntiKatana()
    katanaCached = gcCacheOnce({"ReflectBullets","CanReflect","IsBlocking","KatanaBlocking","KatanaActive","ParryActive","BulletReflect","Deflect","IsParrying","KatanaReflect","ReflectDamage"})
    for _, e in pairs(katanaCached) do pcall(function() e.tbl[e.key]=false end) end
    antiKatanaConn = RunService.Heartbeat:Connect(function()
        if not state.AntiKatana then return end
        for _, e in pairs(katanaCached) do pcall(function() e.tbl[e.key]=false end) end
    end)
end

local function disableAntiKatana()
    if antiKatanaConn then antiKatanaConn:Disconnect() antiKatanaConn=nil end
    for _, e in pairs(katanaCached) do pcall(function() e.tbl[e.key] = e.original end) end
    katanaCached={}
end

-- ══════════════════════════════════════════
-- No Bounds
-- ══════════════════════════════════════════

local noBoundsConn, noBoundsCached, lastSafePos = nil, {}, nil

local function enableNoBounds()
    noBoundsCached = gcCacheOnce({"OutOfBounds","IsOutOfBounds","OOB","outOfBounds","BoundsDead","VoidKill","InVoid","FellOff","KillOnFall","DeathFloor","KillFloor"})
    for _, e in pairs(noBoundsCached) do pcall(function() e.tbl[e.key]=false end) end
    local char = plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then lastSafePos = hrp.CFrame end
    end
    noBoundsConn = RunService.Heartbeat:Connect(function()
        if not state.NoBounds then return end
        local char = plr.Character if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        if hrp.Position.Y > -10 then lastSafePos = hrp.CFrame end
        if hrp.Position.Y < -80 and lastSafePos then hrp.CFrame = lastSafePos end
        for _, e in pairs(noBoundsCached) do pcall(function() e.tbl[e.key]=false end) end
    end)
end

local function disableNoBounds()
    if noBoundsConn then noBoundsConn:Disconnect() noBoundsConn=nil end
    for _, e in pairs(noBoundsCached) do pcall(function() e.tbl[e.key] = e.original end) end
    noBoundsCached={} lastSafePos=nil
end

-- ══════════════════════════════════════════
-- Jump Bug
-- ══════════════════════════════════════════

local jumpBugConn = nil

local function enableJumpBug()
    jumpBugConn = RunService.Heartbeat:Connect(function()
        if not state.JumpBug then return end
        local char = plr.Character if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
        if hum:GetState() == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function disableJumpBug()
    if jumpBugConn then jumpBugConn:Disconnect() jumpBugConn=nil end
end

-- ══════════════════════════════════════════
-- Auto Strafe
-- ══════════════════════════════════════════

local strafeConn, strafeDir, strafeTick = nil, 1, 0

local function enableAutoStrafe()
    strafeConn = RunService.Heartbeat:Connect(function()
        if not state.AutoStrafe then return end
        local char = plr.Character if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            local now = tick()
            local interval = 0.3-(settings.StrafeIntensity/100*0.25)
            if (now-strafeTick) > interval then strafeTick=now strafeDir=-strafeDir end
            local right = hrp.CFrame.RightVector
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(
                vel.X+right.X*strafeDir*(settings.StrafeIntensity/10),
                vel.Y,
                vel.Z+right.Z*strafeDir*(settings.StrafeIntensity/10)
            )
        end
    end)
end

local function disableAutoStrafe()
    if strafeConn then strafeConn:Disconnect() strafeConn=nil end
end

-- ══════════════════════════════════════════
-- Rapid Fire
-- ══════════════════════════════════════════

local rapidFireCached = {}

local function enableRapidFire()
    rapidFireCached = gcCacheOnce({"ShootCooldown","FireRate","Cooldown","cooldown","FireDelay"})
    for _, e in pairs(rapidFireCached) do pcall(function() e.tbl[e.key]=0 end) end
end

local function disableRapidFire()
    for _, e in pairs(rapidFireCached) do pcall(function() e.tbl[e.key]=e.original end) end
    rapidFireCached={}
end

-- ══════════════════════════════════════════
-- Auto Weapon
-- ══════════════════════════════════════════

local autoWeaponCached = {}

local function enableAutoWeapon()
    autoWeaponCached = gcCacheOnce({"IsAutomatic","AutoFire","Automatic","isAutomatic","FullAuto"})
    for _, e in pairs(autoWeaponCached) do pcall(function() e.tbl[e.key]=true end) end
end

local function disableAutoWeapon()
    for _, e in pairs(autoWeaponCached) do pcall(function() e.tbl[e.key]=false end) end
    autoWeaponCached={}
end

-- ══════════════════════════════════════════
-- Instant Scope
-- ══════════════════════════════════════════

local instantScopeCached = {}

local function enableInstantScope()
    instantScopeCached = gcCacheOnce({"ScopeTime","AimTime","AimDelay","ScopeDelay","ZoomTime","ADSTime"})
    for _, e in pairs(instantScopeCached) do pcall(function() e.tbl[e.key]=0 end) end
end

local function disableInstantScope()
    for _, e in pairs(instantScopeCached) do pcall(function() e.tbl[e.key]=e.original end) end
    instantScopeCached={}
end

-- ══════════════════════════════════════════
-- Always Backstab
-- ══════════════════════════════════════════

local backstabCached, backstabConn = {}, nil

local function enableAlwaysBackstab()
    backstabCached = gcCacheOnce({"IsBackstab","BackstabAngle","BackstabMultiplier","CanBackstab","BackstabEnabled"})
    for _, e in pairs(backstabCached) do pcall(function()
        if type(e.tbl[e.key])=="boolean" then e.tbl[e.key]=true
        elseif type(e.tbl[e.key])=="number" then e.tbl[e.key]=360 end
    end) end
    backstabConn = RunService.Heartbeat:Connect(function()
        if not state.AlwaysBackstab then return end
        for _, e in pairs(backstabCached) do pcall(function()
            if type(e.tbl[e.key])=="boolean" then e.tbl[e.key]=true
            elseif type(e.tbl[e.key])=="number" then e.tbl[e.key]=360 end
        end) end
    end)
end

local function disableAlwaysBackstab()
    if backstabConn then backstabConn:Disconnect() backstabConn=nil end
    for _, e in pairs(backstabCached) do pcall(function() e.tbl[e.key] = e.original end) end
    backstabCached={}
end

-- ══════════════════════════════════════════
-- Remove Killers
-- ══════════════════════════════════════════

local removedKillers = {}

local function enableRemoveKillers()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("kill") or name:find("void") or name:find("death") or name:find("lava") then
                if obj.CanTouch then
                    table.insert(removedKillers, {part=obj, canTouch=obj.CanTouch})
                    obj.CanTouch=false
                end
            end
        end
    end
end

local function disableRemoveKillers()
    for _, d in pairs(removedKillers) do pcall(function() d.part.CanTouch=d.canTouch end) end
    removedKillers={}
end

-- ══════════════════════════════════════════
-- No Fire Damage
-- ══════════════════════════════════════════

local fireDamageCached, fireDamageConn = {}, nil

local function enableNoFireDamage()
    fireDamageCached = gcCacheOnce({"FireDamage","BurnDamage","FlameDamage","HeatDamage","IgniteDamage"})
    for _, e in pairs(fireDamageCached) do pcall(function() e.tbl[e.key]=0 end) end
    fireDamageConn = RunService.Heartbeat:Connect(function()
        if not state.NoFireDamage then return end
        local char = plr.Character if not char then return end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("Fire") or obj:IsA("Smoke") then obj.Enabled=false end
        end
    end)
end

local function disableNoFireDamage()
    if fireDamageConn then fireDamageConn:Disconnect() fireDamageConn=nil end
    for _, e in pairs(fireDamageCached) do pcall(function() e.tbl[e.key] = e.original end) end
    fireDamageCached={}
end

-- ══════════════════════════════════════════
-- Anti Freeze
-- ══════════════════════════════════════════

local antiFreezeConn = nil

local function enableAntiFreeze()
    antiFreezeConn = RunService.Heartbeat:Connect(function()
        if not state.AntiFreeze then return end
        local char = plr.Character if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
        if hum.WalkSpeed ~= settings.WalkSpeed then hum.WalkSpeed = settings.WalkSpeed end
        if hum.JumpPower ~= settings.JumpPower then hum.JumpPower = settings.JumpPower end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then hrp.Anchored = false end
    end)
end

local function disableAntiFreeze()
    if antiFreezeConn then antiFreezeConn:Disconnect() antiFreezeConn=nil end
end

-- ══════════════════════════════════════════
-- Tornado Animation
-- ══════════════════════════════════════════

local tornadoAnimId   = "rbxassetid://92281817840531"
local tornadoAnimObj  = Instance.new("Animation")
tornadoAnimObj.AnimationId = tornadoAnimId
local tornadoTrack    = nil

local function anim2track(assetId)
    -- Resolve an Animation object inside a package to its AnimationId
    local ok, objs = pcall(function() return game:GetObjects(assetId) end)
    if ok and objs then
        for _, obj in ipairs(objs) do
            if obj:IsA("Animation") then return obj.AnimationId end
        end
    end
    return assetId
end

local function playTornadoAnim(character)
    local hum = character:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    -- Stop all currently playing animation tracks first
    for _, track in next, hum:GetPlayingAnimationTracks() do
        track:Stop()
    end
    local resolvedId = anim2track(tornadoAnimId)
    tornadoAnimObj.AnimationId = resolvedId
    tornadoTrack = hum:LoadAnimation(tornadoAnimObj)
    tornadoTrack.Priority = Enum.AnimationPriority.Action4
    tornadoTrack:Play()
    tornadoTrack:AdjustSpeed(3)
    -- Loop the animation
    tornadoTrack.Stopped:Connect(function()
        if state.TornadoAnim then
            playTornadoAnim(character)
        end
    end)
end

local function stopTornadoAnim()
    if tornadoTrack then
        tornadoTrack:Stop()
        tornadoTrack = nil
    end
end

local function enableTornadoAnim()
    local char = plr.Character
    if char then playTornadoAnim(char) end
end

local function disableTornadoAnim()
    stopTornadoAnim()
    -- Restore default idle by resetting the humanoid state briefly
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- ══════════════════════════════════════════
-- CharacterAdded
-- ══════════════════════════════════════════

plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if state.Fly then disableFly() task.wait(0.1) enableFly() end
    if state.TornadoAnim then
        task.wait(0.3)
        playTornadoAnim(plr.Character)
    end
    if state.ThirdPerson then
        local char = plr.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier = 0 end
            end
        end
    end
end)

-- ══════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════

local espObjects = {}

local function newDrawing(t, props)
    local obj = Drawing.new(t)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

local function createESP(player)
    if espObjects[player] then return end
    if not Drawing then return end
    espObjects[player] = {
        box      = newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,255,200),Thickness=1.5,Filled=false,Transparency=1}),
        boxFill  = newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,200,150),Thickness=1,Filled=true,Transparency=0.9}),
        name     = newDrawing("Text",  {Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2}),
        healthBg = newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true,Transparency=0.5}),
        healthBar= newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,255,180),Thickness=1,Filled=true,Transparency=1}),
        distance = newDrawing("Text",  {Visible=false,Color=Color3.fromRGB(180,255,240),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2}),
    }
end

local function removeESP(p)
    if not espObjects[p] then return end
    for _,o in pairs(espObjects[p]) do o:Remove() end
    espObjects[p]=nil
end

local function hideESP(p)
    if not espObjects[p] then return end
    for _,o in pairs(espObjects[p]) do o.Visible=false end
end

local function getCharacterBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return nil end
    local minX,minY,maxX,maxY = math.huge,math.huge,-math.huge,-math.huge
    local count = 0
    for _,offset in pairs({
        Vector3.new(2,3,2),Vector3.new(-2,3,-2),Vector3.new(2,3,-2),Vector3.new(-2,3,2),
        Vector3.new(2,-3,2),Vector3.new(-2,-3,-2),Vector3.new(2,-3,-2),Vector3.new(-2,-3,2)
    }) do
        local sp,on = camera:WorldToViewportPoint(hrp.Position+offset)
        if on then
            count+=1
            minX=math.min(minX,sp.X) minY=math.min(minY,sp.Y)
            maxX=math.max(maxX,sp.X) maxY=math.max(maxY,sp.Y)
        end
    end
    if count==0 then return nil end
    return {x=minX,y=minY,w=maxX-minX,h=maxY-minY,cx=(minX+maxX)/2}
end

local function updateESP(player)
    local esp=espObjects[player] if not esp then return end
    local char=player.Character if not char then hideESP(player) return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChild("Humanoid")
    if not hrp or not hum then hideESP(player) return end
    local myChar=plr.Character
    local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then hideESP(player) return end
    local dist=(hrp.Position-myHrp.Position).Magnitude
    if dist>1000 then hideESP(player) return end
    local b=getCharacterBounds(char) if not b then hideESP(player) return end
    esp.box.Position=Vector2.new(b.x,b.y) esp.box.Size=Vector2.new(b.w,b.h) esp.box.Visible=true
    esp.boxFill.Position=Vector2.new(b.x,b.y) esp.boxFill.Size=Vector2.new(b.w,b.h) esp.boxFill.Visible=true
    esp.name.Text=player.DisplayName esp.name.Position=Vector2.new(b.cx,b.y-16) esp.name.Visible=true
    esp.distance.Text=math.floor(dist).."m" esp.distance.Position=Vector2.new(b.cx,b.y+b.h+2) esp.distance.Visible=true
    local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    local barH=b.h*hp
    esp.healthBar.Color=Color3.new(math.clamp(2*(1-hp),0,1),math.clamp(2*hp,0,1),0)
    esp.healthBg.Position=Vector2.new(b.x-7,b.y) esp.healthBg.Size=Vector2.new(4,b.h) esp.healthBg.Visible=true
    esp.healthBar.Position=Vector2.new(b.x-7,b.y+b.h-barH) esp.healthBar.Size=Vector2.new(4,barH) esp.healthBar.Visible=true
end

local function onPlayerAdded(p)
    if p==plr then return end
    createESP(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) if not espObjects[p] then createESP(p) end end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESP)
for _,p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end

RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=plr then if state.ESP then updateESP(p) else hideESP(p) end end
    end
end)

-- ══════════════════════════════════════════
-- Auto Drop
-- ══════════════════════════════════════════

local drops, lastRun = {}, 0
workspace.ChildAdded:Connect(function(obj) if obj.Name=="_drop" then drops[obj]=true end end)
workspace.ChildRemoved:Connect(function(obj) drops[obj]=nil end)
for _,obj in pairs(workspace:GetChildren()) do if obj.Name=="_drop" then drops[obj]=true end end
RunService.Heartbeat:Connect(function()
    if not state.AutoDrop then return end
    local now=tick() if (now-lastRun)<0.05 then return end lastRun=now
    local char=plr.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for obj in pairs(drops) do
        if obj.Parent then firetouchinterest(hrp,obj,0) firetouchinterest(hrp,obj,1) end
    end
end)

-- ══════════════════════════════════════════
-- UI Colors
-- ══════════════════════════════════════════

local C = {
    bg     = Color3.fromRGB(8,   8,   12),
    bg2    = Color3.fromRGB(14,  14,  20),
    bg3    = Color3.fromRGB(20,  20,  30),
    neon   = Color3.fromRGB(0,   255, 200),
    neon2  = Color3.fromRGB(0,   180, 140),
    border = Color3.fromRGB(30,  60,  50),
    text   = Color3.fromRGB(210, 255, 245),
    dim    = Color3.fromRGB(90,  130, 120),
    white  = Color3.fromRGB(255, 255, 255),
    red    = Color3.fromRGB(255, 60,  60),
}

-- ══════════════════════════════════════════
-- Mobile detection (shared by both UIs)
-- ══════════════════════════════════════════
local isMobileMain = UserInputService.TouchEnabled
    and not UserInputService.MouseEnabled
    and not UserInputService.KeyboardEnabled

local rootW = isMobileMain and 360 or 540
local rootH = isMobileMain and 300 or 380
local rootPosX  = isMobileMain and 0   or 0.5
local rootPosXO = isMobileMain and 4   or -270
local rootPosY  = isMobileMain and 0   or 0.5
local rootPosYO = isMobileMain and 40  or -190

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "🐉CyberDragon🐉"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Size = UDim2.new(0, rootW, 0, rootH)
root.Position = UDim2.new(rootPosX, rootPosXO, rootPosY, rootPosYO)
root.BackgroundColor3 = C.bg
root.BorderSizePixel = 0
root.BackgroundTransparency = 1
root.ClipsDescendants = true
root.Parent = screenGui
Instance.new("UICorner", root).CornerRadius = UDim.new(0,8)
local rootStroke = Instance.new("UIStroke", root)
rootStroke.Color = C.neon rootStroke.Thickness = 1.5 rootStroke.Transparency = 1

local titleBarH = isMobileMain and 28 or 36
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,titleBarH)
titleBar.BackgroundColor3 = C.bg2
titleBar.BorderSizePixel = 0
titleBar.Parent = root
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,8)

local tbFix = Instance.new("Frame")
tbFix.Size=UDim2.new(1,0,0.5,0) tbFix.Position=UDim2.new(0,0,0.5,0)
tbFix.BackgroundColor3=C.bg2 tbFix.BorderSizePixel=0 tbFix.Parent=titleBar

local titleAccent = Instance.new("Frame")
titleAccent.Size=UDim2.new(0,3,1,-8) titleAccent.Position=UDim2.new(0,6,0,4)
titleAccent.BackgroundColor3=C.neon titleAccent.BorderSizePixel=0 titleAccent.Parent=titleBar
Instance.new("UICorner",titleAccent).CornerRadius=UDim.new(1,0)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-60,1,0) titleLbl.Position=UDim2.new(0,14,0,0)
titleLbl.BackgroundTransparency=1
titleLbl.Text = isMobileMain and "◈ CYBER" or "◈ CYBER CHEAT"
titleLbl.TextColor3=C.neon
titleLbl.TextSize = isMobileMain and 10 or 12
titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextXAlignment=Enum.TextXAlignment.Left titleLbl.Parent=titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,20,0,20) closeBtn.Position=UDim2.new(1,-24,0.5,-10)
closeBtn.BackgroundColor3=C.bg3 closeBtn.BorderSizePixel=0
closeBtn.Text="×" closeBtn.TextColor3=C.neon closeBtn.TextSize=13
closeBtn.Font=Enum.Font.GothamBold closeBtn.Parent=titleBar
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,4)
Instance.new("UIStroke",closeBtn).Color=C.neon

local minimized = false
closeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = minimized
            and UDim2.new(0, rootW, 0, titleBarH)
            or  UDim2.new(0, rootW, 0, rootH)
    }):Play()
    closeBtn.Text = minimized and "+" or "×"
end)

local hidden = false
if not isMobileMain then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            hidden = not hidden
            if hidden then
                TweenService:Create(root,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,-560,0.5,-190),BackgroundTransparency=1}):Play()
                TweenService:Create(rootStroke,TweenInfo.new(0.25),{Transparency=1}):Play()
                task.delay(0.25, function() root.Visible=false end)
            else
                root.Visible=true root.Position=UDim2.new(0,-560,0.5,-190)
                TweenService:Create(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(rootPosX,rootPosXO,rootPosY,rootPosYO),BackgroundTransparency=0}):Play()
                TweenService:Create(rootStroke,TweenInfo.new(0.3),{Transparency=0}):Play()
            end
        end
    end)
end

local tabBarTop = titleBarH + 6
local contentTop = tabBarTop + 34
local tabBar = Instance.new("Frame")
tabBar.Size=UDim2.new(1,-16,0,28) tabBar.Position=UDim2.new(0,8,0,tabBarTop)
tabBar.BackgroundColor3=C.bg3 tabBar.BorderSizePixel=0 tabBar.Parent=root
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",tabBar).Color=C.border
local tabList=Instance.new("UIListLayout",tabBar)
tabList.FillDirection=Enum.FillDirection.Horizontal
tabList.SortOrder=Enum.SortOrder.LayoutOrder tabList.Padding=UDim.new(0,2)
local tabPad=Instance.new("UIPadding",tabBar)
tabPad.PaddingLeft=UDim.new(0,3) tabPad.PaddingRight=UDim.new(0,3)
tabPad.PaddingTop=UDim.new(0,3) tabPad.PaddingBottom=UDim.new(0,3)

local contentArea = Instance.new("Frame")
contentArea.Size=UDim2.new(1,-16,1,-(contentTop+6)) contentArea.Position=UDim2.new(0,8,0,contentTop+6)
contentArea.BackgroundTransparency=1 contentArea.BorderSizePixel=0 contentArea.Parent=root

-- ══════════════════════════════════════════
-- Tab system
-- ══════════════════════════════════════════

local pages = {}
local currentTab = nil

local function switchTab(name)
    if currentTab==name then return end
    currentTab=name
    for pName, pData in pairs(pages) do
        local active = (pName==name)
        pData.page.Visible = active
        TweenService:Create(pData.tab,TweenInfo.new(0.15),{BackgroundColor3=active and C.neon2 or C.bg3}):Play()
        pData.tabLbl.TextColor3 = active and C.bg or C.dim
    end
end

local function createTab(name, order)
    local tab = Instance.new("TextButton")
    tab.Size=UDim2.new(0,0,1,0) tab.AutomaticSize=Enum.AutomaticSize.X
    tab.BackgroundColor3=C.bg3 tab.BorderSizePixel=0
    tab.LayoutOrder=order tab.Text="" tab.Parent=tabBar
    Instance.new("UICorner",tab).CornerRadius=UDim.new(0,4)

    local tabLbl = Instance.new("TextLabel")
    tabLbl.Size=UDim2.new(1,0,1,0) tabLbl.BackgroundTransparency=1
    tabLbl.Text=" "..name.." " tabLbl.TextColor3=C.dim
    tabLbl.TextSize=11 tabLbl.Font=Enum.Font.GothamBold tabLbl.Parent=tab

    local page = Instance.new("Frame")
    page.Size=UDim2.new(1,0,1,0) page.BackgroundTransparency=1
    page.Visible=false page.Parent=contentArea

    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Size=UDim2.new(0.5,-3,1,0) leftScroll.Position=UDim2.new(0,0,0,0)
    leftScroll.BackgroundTransparency=1 leftScroll.BorderSizePixel=0
    leftScroll.ScrollBarThickness=2 leftScroll.ScrollBarImageColor3=C.neon
    leftScroll.CanvasSize=UDim2.new(0,0,0,0) leftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    leftScroll.Parent=page
    local ll=Instance.new("UIListLayout",leftScroll)
    ll.SortOrder=Enum.SortOrder.LayoutOrder ll.Padding=UDim.new(0,4)
    local lp=Instance.new("UIPadding",leftScroll)
    lp.PaddingRight=UDim.new(0,3) lp.PaddingBottom=UDim.new(0,4)

    local rightScroll = Instance.new("ScrollingFrame")
    rightScroll.Size=UDim2.new(0.5,-3,1,0) rightScroll.Position=UDim2.new(0.5,3,0,0)
    rightScroll.BackgroundTransparency=1 rightScroll.BorderSizePixel=0
    rightScroll.ScrollBarThickness=2 rightScroll.ScrollBarImageColor3=C.neon
    rightScroll.CanvasSize=UDim2.new(0,0,0,0) rightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    rightScroll.Parent=page
    local rl=Instance.new("UIListLayout",rightScroll)
    rl.SortOrder=Enum.SortOrder.LayoutOrder rl.Padding=UDim.new(0,4)
    local rp=Instance.new("UIPadding",rightScroll)
    rp.PaddingLeft=UDim.new(0,3) rp.PaddingBottom=UDim.new(0,4)

    pages[name]={tab=tab,tabLbl=tabLbl,page=page,left=leftScroll,right=rightScroll}
    tab.MouseButton1Click:Connect(function() switchTab(name) end)
    return leftScroll, rightScroll
end

-- ══════════════════════════════════════════
-- UI Builders
-- ══════════════════════════════════════════

local function makeHeader(parent, text, order)
    local h = Instance.new("TextLabel")
    h.Size=UDim2.new(1,0,0,18) h.BackgroundTransparency=1
    h.Text="▸ "..text h.TextColor3=C.neon h.TextSize=10
    h.Font=Enum.Font.GothamBold h.TextXAlignment=Enum.TextXAlignment.Left
    h.LayoutOrder=order h.Parent=parent
end

local function makeToggle(parent, labelText, key, order, onEnable, onDisable)
    local row = Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0 row.LayoutOrder=order row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local rs=Instance.new("UIStroke",row) rs.Color=C.border rs.Thickness=1

    local accent=Instance.new("Frame")
    accent.Size=UDim2.new(0,2,1,-8) accent.Position=UDim2.new(0,0,0,4)
    accent.BackgroundColor3=C.neon accent.BackgroundTransparency=0.6
    accent.BorderSizePixel=0 accent.Parent=row
    Instance.new("UICorner",accent).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-52,1,0) lbl.Position=UDim2.new(0,9,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=labelText
    lbl.TextColor3=C.text lbl.TextSize=11 lbl.Font=Enum.Font.GothamBold
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=row

    local pillBg=Instance.new("Frame")
    pillBg.Size=UDim2.new(0,34,0,18) pillBg.Position=UDim2.new(1,-40,0.5,-9)
    pillBg.BackgroundColor3=C.bg3 pillBg.BorderSizePixel=0 pillBg.Parent=row
    Instance.new("UICorner",pillBg).CornerRadius=UDim.new(1,0)
    local ps=Instance.new("UIStroke",pillBg) ps.Color=C.neon ps.Thickness=1 ps.Transparency=0.7

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12) knob.Position=UDim2.new(0,3,0.5,-6)
    knob.BackgroundColor3=C.dim knob.BorderSizePixel=0 knob.Parent=pillBg
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.Parent=row

    btn.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(18,22,28)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.bg2}):Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(0,25,20)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(18,22,28)}):Play() end)

    local function updateVisual(on)
        TweenService:Create(pillBg,TweenInfo.new(0.18),{BackgroundColor3=on and Color3.fromRGB(0,35,28) or C.bg3}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=on and UDim2.new(0,19,0.5,-6) or UDim2.new(0,3,0.5,-6),
            BackgroundColor3=on and C.neon or C.dim
        }):Play()
        ps.Transparency=on and 0 or 0.7
        accent.BackgroundTransparency=on and 0 or 0.6
        lbl.TextColor3=on and C.neon or C.text
        TweenService:Create(rs,TweenInfo.new(0.18),{Color=on and C.neon or C.border}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        state[key]=not state[key]
        updateVisual(state[key])
        if state[key] then if onEnable then onEnable() end
        else if onDisable then onDisable() end end
    end)
end

local function makeButton(parent, labelText, order, onClick)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,30) btn.BackgroundColor3=C.bg2
    btn.BorderSizePixel=0 btn.Text=labelText btn.TextColor3=C.neon
    btn.TextSize=10 btn.Font=Enum.Font.GothamBold btn.LayoutOrder=order btn.Parent=parent
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local bs=Instance.new("UIStroke",btn) bs.Color=C.neon bs.Thickness=1 bs.Transparency=0.5

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(0,28,22),TextColor3=C.white}):Play()
        TweenService:Create(bs,TweenInfo.new(0.12),{Transparency=0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.bg2,TextColor3=C.neon}):Play()
        TweenService:Create(bs,TweenInfo.new(0.12),{Transparency=0.5}):Play()
    end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.08),{Size=UDim2.new(1,-4,0,28)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,30)}):Play() end)
    btn.MouseButton1Click:Connect(function() onClick(btn,bs) end)
end

local function makePicker(parent, order)
    local row = Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0 row.LayoutOrder=order row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",row).Color=C.border

    local options = {"Behind","Above","Under"}
    local btnWidth = (1/#options)
    local pickerBtns = {}

    for i, opt in ipairs(options) do
        local pb = Instance.new("TextButton")
        pb.Size=UDim2.new(btnWidth,-3,1,-6)
        pb.Position=UDim2.new((i-1)*btnWidth, i==1 and 3 or 2, 0, 3)
        pb.BackgroundColor3 = opt==farmPosition and C.neon2 or C.bg3
        pb.BorderSizePixel=0 pb.Text=opt
        pb.TextColor3 = opt==farmPosition and C.bg or C.dim
        pb.TextSize=10 pb.Font=Enum.Font.GothamBold pb.Parent=row
        Instance.new("UICorner",pb).CornerRadius=UDim.new(0,4)
        pickerBtns[opt] = pb

        pb.MouseButton1Click:Connect(function()
            farmPosition = opt
            for _, o in pairs(options) do
                TweenService:Create(pickerBtns[o],TweenInfo.new(0.15),{BackgroundColor3=o==opt and C.neon2 or C.bg3}):Play()
                pickerBtns[o].TextColor3 = o==opt and C.bg or C.dim
            end
        end)
    end
end

local function makeSlider(parent, labelText, order, minVal, maxVal, defaultVal, settingKey, onChange)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,50) row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0 row.LayoutOrder=order row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",row).Color=C.border

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-50,0,16) lbl.Position=UDim2.new(0,9,0,5)
    lbl.BackgroundTransparency=1 lbl.Text=labelText
    lbl.TextColor3=C.text lbl.TextSize=11 lbl.Font=Enum.Font.GothamBold
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0,44,0,16) valLbl.Position=UDim2.new(1,-50,0,5)
    valLbl.BackgroundTransparency=1 valLbl.Text=tostring(defaultVal)
    valLbl.TextColor3=C.neon valLbl.TextSize=10 valLbl.Font=Enum.Font.GothamBold
    valLbl.TextXAlignment=Enum.TextXAlignment.Right valLbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-18,0,4) track.Position=UDim2.new(0,9,0,30)
    track.BackgroundColor3=C.bg3 track.BorderSizePixel=0 track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((defaultVal-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3=C.neon fill.BorderSizePixel=0 fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local handle=Instance.new("Frame")
    handle.Size=UDim2.new(0,10,0,10)
    handle.Position=UDim2.new((defaultVal-minVal)/(maxVal-minVal),-5,0.5,-5)
    handle.BackgroundColor3=C.neon handle.BorderSizePixel=0 handle.Parent=track
    Instance.new("UICorner",handle).CornerRadius=UDim.new(1,0)

    local draggingSlider=false
    local sliderBtn=Instance.new("TextButton")
    sliderBtn.Size=UDim2.new(1,0,0,20) sliderBtn.Position=UDim2.new(0,0,0,24)
    sliderBtn.BackgroundTransparency=1 sliderBtn.Text="" sliderBtn.Parent=row

    local function updateSlider(inputX)
        local tp=track.AbsolutePosition.X
        local ts=track.AbsoluteSize.X
        local rel=math.clamp((inputX-tp)/ts,0,1)
        local val=math.floor(minVal+rel*(maxVal-minVal))
        settings[settingKey]=val
        valLbl.Text=tostring(val)
        fill.Size=UDim2.new(rel,0,1,0)
        handle.Position=UDim2.new(rel,-5,0.5,-5)
        if onChange then onChange(val) end
    end

    sliderBtn.MouseButton1Down:Connect(function()
        draggingSlider=true
        updateSlider(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSlider and i.UserInputType==Enum.UserInputType.MouseMovement then
            updateSlider(i.Position.X)
        end
    end)
end

-- ══════════════════════════════════════════
-- Build Tabs
-- ══════════════════════════════════════════

local cL, cR = createTab("Combat", 1)
makeHeader(cL,"Weapon",1)
makeToggle(cL,"No Recoil",       "NoRecoil",      2, function() applyAttribute("ShootRecoil",0) end, function() restoreAttribute("ShootRecoil") end)
makeToggle(cL,"No Spread",       "NoSpread",      3, function() applyAttribute("ShootSpread",0) applyAttribute("ShootCooldown",0) end, function() restoreAttribute("ShootSpread") restoreAttribute("ShootCooldown") end)
makeToggle(cL,"Rapid Fire",      "RapidFire",     4, enableRapidFire,      disableRapidFire)
makeToggle(cL,"Auto Weapon",     "AutoWeapon",    5, enableAutoWeapon,     disableAutoWeapon)
makeToggle(cL,"Instant Scope",   "InstantScope",  6, enableInstantScope,   disableInstantScope)
makeToggle(cL,"Always Backstab", "AlwaysBackstab",7, enableAlwaysBackstab, disableAlwaysBackstab)
makeToggle(cL,"Anti Katana",     "AntiKatana",    8, enableAntiKatana,     disableAntiKatana)

makeHeader(cR,"Silent Aim",1)
makeButton(cR,"⚡ Load Bolts Silent Aim",2,function(btn,bs)
    btn.Text="⏳ Loading..." btn.TextColor3=C.dim
    local ok=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ThunderScriptSolutions/Misc/refs/heads/main/RivalsSilentAim"))() end)
    if ok then btn.Text="✓ Loaded!" btn.TextColor3=Color3.fromRGB(0,255,100) bs.Color=Color3.fromRGB(0,255,100)
    else btn.Text="✗ Failed" btn.TextColor3=C.red bs.Color=C.red end
end)
makeHeader(cR,"Utility",4)
makeToggle(cR,"Auto Drop Collector","AutoDrop",5,nil,nil)
makeHeader(cR,"Auto Farm",6)
makeToggle(cR,"Auto Farm","AutoFarm",7,enableAutoFarm,disableAutoFarm)
makePicker(cR,8)

local mL, mR = createTab("Movement", 2)
makeHeader(mL,"Actions",1)
makeToggle(mL,"Jump Bug",    "JumpBug",    2, enableJumpBug,    disableJumpBug)
makeToggle(mL,"Auto Strafe", "AutoStrafe", 3, enableAutoStrafe, disableAutoStrafe)
makeHeader(mL,"Fly",4)
makeToggle(mL,"Fly",         "Fly",        5, enableFly,        disableFly)
makeHeader(mL,"Misc",6)
makeToggle(mL,"Noclip",           "Noclip",      7, enableNoclip,        disableNoclip)
makeToggle(mL,"Anti Aim",         "AntiAim",     8, enableAntiAim,       disableAntiAim)
makeToggle(mL,"Tornado Animation","TornadoAnim", 9, enableTornadoAnim,   disableTornadoAnim)
makeHeader(mL,"Strafe",10)
makeSlider(mL,"Strafe Intensity",11,1,100,50,"StrafeIntensity",nil)
makeHeader(mR,"Speed & Jump",1)
makeSlider(mR,"Walk Speed",2,1,150,16,"WalkSpeed",function(v)
    local char=plr.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=v end
end)
makeSlider(mR,"Jump Power",3,1,200,50,"JumpPower",function(v)
    local char=plr.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.JumpPower=v end
end)
makeHeader(mR,"Fly Speed",5)
makeSlider(mR,"Fly Speed",6,0,1000,50,"FlySpeed",nil)

local vL, vR = createTab("Visuals", 3)
makeHeader(vL,"Players",1)
makeToggle(vL,"ESP",          "ESP",         2, nil,               nil)
makeToggle(vL,"Third Person", "ThirdPerson", 3, enableThirdPerson, disableThirdPerson)

local wL, wR = createTab("World", 4)
makeHeader(wL,"Protection",1)
makeToggle(wL,"Prevent OOB",    "NoBounds",      2, enableNoBounds,      disableNoBounds)
makeToggle(wL,"Remove Killers", "RemoveKillers", 3, enableRemoveKillers, disableRemoveKillers)
makeToggle(wL,"No Fire Damage", "NoFireDamage",  4, enableNoFireDamage,  disableNoFireDamage)
makeToggle(wL,"Anti Freeze",    "AntiFreeze",    5, enableAntiFreeze,    disableAntiFreeze)

makeHeader(wR,"Config",1)
local cfgStatus = Instance.new("TextLabel")
cfgStatus.Size=UDim2.new(1,0,0,18) cfgStatus.BackgroundTransparency=1
cfgStatus.Text="💾  Save / Load your cosmetics config" cfgStatus.TextColor3=C.dim
cfgStatus.TextSize=10 cfgStatus.Font=Enum.Font.Gotham
cfgStatus.TextXAlignment=Enum.TextXAlignment.Left
cfgStatus.LayoutOrder=2 cfgStatus.Parent=wR

local function flashCfgStatus(msg, col)
    cfgStatus.Text = msg cfgStatus.TextColor3 = col or C.neon
    task.delay(3, function()
        cfgStatus.Text="💾  Save / Load your cosmetics config" cfgStatus.TextColor3=C.dim
    end)
end

makeButton(wR,"💾  Save Config Now",3,function(btn,bs)
    local ok = pcall(SC_SaveConfig)
    if ok then btn.Text="✅  Saved!" btn.TextColor3=Color3.fromRGB(0,255,100) bs.Color=Color3.fromRGB(0,255,100)
        flashCfgStatus("✅  Config saved!", Color3.fromRGB(0,255,100))
    else btn.Text="❌  Save Failed" btn.TextColor3=C.red
        flashCfgStatus("❌  Save failed.", C.red) end
    task.delay(2.5,function() btn.Text="💾  Save Config Now" btn.TextColor3=C.neon bs.Color=C.neon end)
end)

makeButton(wR,"📂  Load Config Now",4,function(btn,bs)
    local ok = SC_LoadConfig()
    if ok then btn.Text="✅  Loaded!" btn.TextColor3=Color3.fromRGB(0,180,255) bs.Color=Color3.fromRGB(0,180,255)
        flashCfgStatus("✅  Config loaded!", Color3.fromRGB(0,180,255))
    else btn.Text="❌  No Config Found" btn.TextColor3=C.red
        flashCfgStatus("❌  No config file found.", C.red) end
    task.delay(2.5,function() btn.Text="📂  Load Config Now" btn.TextColor3=C.neon bs.Color=C.neon end)
end)

switchTab("Combat")

task.spawn(function()
    task.wait(0.1)
    TweenService:Create(root,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
    TweenService:Create(rootStroke,TweenInfo.new(0.4),{Transparency=0}):Play()
end)

do
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true dragStart=input.Position startPos=root.Position end end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=input.Position-dragStart
            root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end end)
end

-- ══════════════════════════════════════════
-- SKIN CHANGER — Cosmetic Lists
-- ══════════════════════════════════════════

local SkinLists = {
    ["Assault Rifle"]   = {"Default","AK-47","AUG","Tommy Gun","Boneclaw Rifle","Gingerbread AUG","AKEY-47","100K Visits","10 Billion Visits","Phoenix Rifle"},
    ["Bow"]             = {"Default","Compound Bow","Raven Bow","Dream Bow","Bat Bow","Frostbite Bow","Beloved Bow","Balloon Bow","Glorious Bow","Key Bow","Arch Bow"},
    ["Burst Rifle"]     = {"Default","Electro Burst","Aqua Burst","FAMAS","Spectral Burst","Pine Burst"},
    ["Crossbow"]        = {"Default","Pixel Crossbow","Harpoon Crossbow","Violin Crossbow","Crossbone","Frostbite Crossbow","Arch Crossbow","Glorious Crossbow"},
    ["Distortion"]      = {"Default","Plasma Distortion","Magma Distortion","Cyber Distortion","Expirement D15","Sleighstortion"},
    ["Energy Rifle"]    = {"Default","Hacker Rifle","Hydro Rifle","Void Rifle","Soul Rifle","New Years Energy Rifle"},
    ["Flamethrower"]    = {"Default","Pixel Flamethrower","Lamethrower","Glitterthrower","Jack O' Thrower","Snowblower","Keythrower","Rainbowthrower"},
    ["Grenade Launcher"]= {"Default","Swashbuckler","Uranium Launcher","Gearnade Launcher","Skull Grenade Launcher","Snowball Launcher"},
    ["Gunblade"]        = {"Default","Hyper Gunblade","Crude Gunblade","Gunsaw","Boneblade","Elf's Gunblade"},
    ["Minigun"]         = {"Default","Lasergun 3000","Pixel Minigun","Fighter Jet","Pumpkin Minigun","Wrapped Minigun"},
    ["Paintball Gun"]   = {"Default","Slime Gun","Boba Gun","Ketchup Gun","Brain Gun","Snowball Gun"},
    ["RPG"]             = {"Default","Nuke Launcher","Spaceship Launcher","Squid Launcher","Pumpkin Launcher","Firework Launcher"},
    ["Shotgun"]         = {"Default","Balloon Shotgun","Hyper Shotgun","Cactus Shotgun","Broomstick","Wrapped Shotgun"},
    ["Sniper"]          = {"Default","Pixel Sniper","Hyper Sniper","Event Horizon","Eyething Sniper","Gingerbread Sniper","Keyper","Glorious Sniper"},
    ["Daggers"]         = {"Default","Aces","Paper Planes","Shurikens","Bat Daggers","Cookies","Crystal Daggers","Keynais"},
    ["Energy Pistols"]  = {"Default","Void Pistols","Hydro Pistols","Soul Pistols","New Years Energy Pistols"},
    ["Exogun"]          = {"Default","Singularity","Raygun","Repulsor","Exogourd","Midnight Festive Exogun"},
    ["Flare Gun"]       = {"Default","Firework Gun","Dynamite Gun","Banana Flare","Vexed Flare Gun","Wrapped Flare Gun"},
    ["Handgun"]         = {"Default","Blaster","Hand Gun","Gumball Handgun","Pumpkin Handgun","Gingerbread Handgun"},
    ["Revolver"]        = {"Default","Desert Eagle","Sheriff","Peppergun","Boneclaw Revolver","Peppermint Sheriff"},
    ["Shorty"]          = {"Default","Not So Shorty","Lovely Shorty","Balloon Shorty","Demon Shorty","Wrapped Shorty"},
    ["Slingshot"]       = {"Default","Stick","Goal Post","Harp","Boneshot","Reindeer Slingshot","Lucky Horseshoe"},
    ["Spray"]           = {"Default","Lovely Spray","Nail Gun","Bottle Spray","Boneclaw Spray","Pine Spray","Key Spray"},
    ["Uzi"]             = {"Default","Water Uzi","Electro Uzi","Money Gun","Demon Uzi","Pine Uzi"},
    ["Warper"]          = {"Default","Glitter Warper","Arcane Warper","Hotel Bell","Experiment W4","Frost Warper"},
    ["Battle Axe"]      = {"Default","The Shred","Ban Axe","Cerulean Axe","Mimic Axe","Nordic Axe"},
    ["Chainsaw"]        = {"Default","Blobsaw","Handsaws","Mega Drill","Buzzsaw","Festive Buzzsaw"},
    ["Fists"]           = {"Default","Boxing Gloves","Brass Knuckles","Fists Of Hurt","Pumpkin Claws","Festive Fists"},
    ["Katana"]          = {"Default","Saber","Lightning Bolt","Stellar Katana","Evil Trident","New Years Katana","Keytana","Arch Katana","Crystal Katana","Pixel Katana","Glorious Katana"},
    ["Knife"]           = {"Default","Chancla","Karambit","Balisong","Machete","Candy Cane","Keylisong","Keyrambit","Caladbolg"},
    ["Riot Shield"]     = {"Default","Door","Energy Shield","Masterpiece","Tombstone Shield","Sled"},
    ["Scythe"]          = {"Default","Scythe of Death","Anchor","Sakura Scythe","Bat Scythe","Cryo Scythe","Crystal Scythe","Keythe","Bug Net","Arch Scythe"},
    ["Trowel"]          = {"Default","Plastic Shovel","Garden Shovel","Paintbrush","Pumpkin Carver","Snow Shovel"},
    ["Flashbang"]       = {"Default","Disco Ball","Camera","Lightbulb","Skullbang","Shining Star"},
    ["Freeze Ray"]      = {"Default","Temporal Ray","Bubble Ray","Gum Ray","Spider Ray","Wrapped Freeze Ray"},
    ["Grenade"]         = {"Default","Whoopee Cushion","Water Balloon","Dynamite","Soul Grenade","Jingle Grenade"},
    ["Jump Pad"]        = {"Default","Trampoline","Bounce House","Shady Chicken Sandwich","Spider Web","Jolly Man"},
    ["Medkit"]          = {"Default","Sandwich","Laptop","Medkitty","Bucket of Candy","Milk & Cookies","Box of Chocolates","Briefcase"},
    ["Molotov"]         = {"Default","Coffee","Torch","Lava Lamp","Vexed Candle","Hot Coals","Arch Molotov"},
    ["Satchel"]         = {"Default","Advanced Satchel","Notebook Satchel","Bag O' Money","Potion Satchel","Suspicious Gift"},
    ["Smoke Grenade"]   = {"Default","Emoji Cloud","Balance","Hourglass","Eyeball","Snowglobe"},
    ["Subspace Tripmine"]= {"Default","Don't Press","Spring","DIY Tripmine","Trick or Treat","Dev In the Box","Pot O Keys"},
    ["War Horn"]        = {"Default","Trumpet","Megaphone","Air Horn","Boneclaw Horn","Mammoth Horn"},
    ["Warpstone"]       = {"Default","Cyber Warpstone","Teleport Disc","Electropunk Warpstone","Warpbone","Warpstar"},
    ["Permafrost"]      = {"Default","Snowman Permafrost","Ice Permafrost","Glorious Permafrost"},
    ["Maul"]            = {"Default","Ban Hammer","Ice Maul","Sleigh Maul","Glorious Maul"},
}

local WrapList = {
    -- Standard
    "None","Gold","Diamond","Midas Touch","Community Wrap","Blush Wrapping","Brain","Crystalliz",
    "Damascus","Black Damascus",".exe wrap","Groove","Hollow Wrap","Hesper","Hyperdrive",
    "Gingerbread","Neon Lights","Hologram Arena","Sunset","Pink Lemonade","Lovely Leopard",
    "Dawn","Spectral","Danger","Termination","Moonstone","Starfall","Black Glass",
    "Rift Wrap","Starblaze","Maganite","Watermelon","Reptile","Water","OranGG","A5","Cheese",
    "Nova","Supernova","Glass","Mesh","Meat Wrap","Black Dark Wrap","Cardinal","Pixel Camo",
    "Nauseite","Sensite","Urban Camo","Invisible","Arcane","Eruption","Borealis",
    "Mainframe Wrap","Honeycomb Wrap","Virus","Patriot","PB&J Wrap","Scribble",
    "Net","Solar","Festive Lights","Polaris","Woven","Heartfelt","Chromatic","Dark Matter",
    -- Developer Wraps
    "Dev Wrap","Admin Wrap","Staff Wrap","Shedletsky Wrap","Telamon Wrap","Badimo Wrap",
    "Mango Wrap","Lava Wrap","Developer","Intern Wrap","Alpha Tester","Beta Tester",
    "Founder Wrap","Creator Wrap","Scripter Wrap","Builder Wrap",
    -- Contract / Battle Pass Wraps
    "Season 1 Wrap","Season 2 Wrap","Season 3 Wrap","Season 4 Wrap","Season 5 Wrap","Season 6 Wrap",
    "Contract Wrap I","Contract Wrap II","Contract Wrap III","Contract Wrap IV","Contract Wrap V",
    "Bronze Contract","Silver Contract","Gold Contract","Platinum Contract","Diamond Contract",
    "Elite Contract","Champion Contract","Prestige Wrap","Legacy Wrap","Veteran Wrap",
    "Anniversary Wrap","Rivals Pass Wrap","Battle Wrap","Combat Wrap","Victory Wrap",
    "Conquest Wrap","Warpath Wrap","Dominion Wrap","Ascendant Wrap",
}

local CharmList = {
    "None",
    -- Standard
    "Rivals Logo","Sword","Shield","Crown","Star","Heart","Skull","Key","Flame","Ice Crystal",
    "Lightning","Cherry Blossom","Pumpkin","Snowflake","Rainbow","Diamond Charm","Ruby","Emerald",
    "Sapphire","Amethyst","Gold Coin","Dice","Clover","Mushroom","Flower","Butterfly","Dragon",
    "Phoenix","Wolf","Cat","Bunny","Frog","Duck","Jellyfish","Crab","Anchor","Compass","Lantern",
    "Gem","Pearl","Feather","Rose","Sunflower","Cactus","Sword Charm","Dagger Charm","Axe Charm",
    "Bow Charm","Shield Charm","Bomb","Rocket","UFO","Planet","Moon","Sun","Cloud","Rainbow Star",
    -- Seasonal
    "Halloween Charm","Christmas Charm","Easter Charm","Valentine Charm","New Year Charm",
    "Summer Charm","Winter Charm","Spring Charm","Fall Charm",
    -- Rarity
    "Common Charm","Uncommon Charm","Rare Charm","Epic Charm","Legendary Charm","Mythical Charm",
    -- Dev / Contract
    "Dev Charm","Admin Charm","Staff Charm","Founder Charm","Alpha Charm","Beta Charm",
    "Season 1 Charm","Season 2 Charm","Season 3 Charm","Season 4 Charm","Season 5 Charm",
    "Contract Charm","Victory Charm","Champion Charm","Prestige Charm",
}

local FinisherList = {
    "None",
    -- Default
    "Ragdoll",
    -- Common
    "Folded",
    "Very Tragic Banana Peel Accident",
    "Chalked",
    "Digitize",
    "Squawk",
    "Delete",
    "Flop",
    "Confetti",
    "Hacked",
    "Petrify",
    "Toot",
    "Yoink",
    "Spooky Confetti",
    "Bite",
    "Batsplosion",
    "Festive Confetti",
    "Wrapped",
    "Blip",
    "Chill Out",
    "Coalify",
    "Faceplant",
    "For Glory",
    "Northern Light Show",
    "Warped Away",
    -- Rare
    "Hooked",
    "Bad Mood",
    "Heavy Head",
    "Roadrunner",
    "Ascend",
    "Flick",
    "Collapse",
    "Freeze",
    "High Gravity",
    "Midas Touch",
    "Rush",
    "Splatter",
    "Tremble",
    "Reaper",
    "Lost Soul",
    "Bonesplosion",
    "Frozen",
    "Gingerbreadify",
    "Bogey",
    "Decorated Player",
    "Snowmanify",
    "Warp Sickness",
    -- Legendary
    "Balloons",
    "BONK!",
    "Boogie",
    "Darkheart",
    "Rainbow Barf",
    "Clapped",
    "Enlightened",
    "Crushed",
    "GOOAAALLLL",
    "Chark Attack",
    "Diamond Hands",
    "Electrocute",
    "Heartbeat",
    "Ignite",
    "Low Gravity",
    "OOF",
    "Opulent",
    "Orbital Strike",
    "Pixel Coins",
    "Stiff",
    "Tough Crowd",
    "Zombified",
    "RIP",
    "Disintegrate",
    "Broom Ride",
    "Snowballed",
    "Falling Icicles",
    "David",
    "Giant Ice Spike",
    "DRIP",
    "Beacon",
    "Erased",
    "Firework Show",
    "Giant Snowball",
    "Impaled",
    "Sleigh Away",
    "Spaghettified",
    "Those Who Know",
    -- Special
    "Jolly Judgement",
    "Director's Cut",
    "Elfify",
    "5B Visits",
}

-- ══════════════════════════════════════════
-- SKIN CHANGER — Save / Load
-- ══════════════════════════════════════════

local SAVE_FILE = "AnihaSkinConfig.json"

_G.EquippedData = _G.EquippedData or {}
for weapon in pairs(SkinLists) do
    if not _G.EquippedData[weapon] then
        _G.EquippedData[weapon] = {Skin="Default", Wrap="None"}
    end
end
_G.GlobalData = _G.GlobalData or {Charm="None", Finisher="None"}

local function SC_SaveConfig()
    pcall(function()
        local data = { weapons={}, global=_G.GlobalData }
        for weapon, info in pairs(_G.EquippedData) do
            data.weapons[weapon] = {Skin=info.Skin or "Default", Wrap=info.Wrap or "None"}
        end
        writefile(SAVE_FILE, HttpService:JSONEncode(data))
    end)
end

local function SC_LoadConfig()
    local ok, result = pcall(function()
        if isfile(SAVE_FILE) then return HttpService:JSONDecode(readfile(SAVE_FILE)) end
        return nil
    end)
    if ok and result then
        local wt = result.weapons or result
        for weapon, info in pairs(wt) do
            if _G.EquippedData[weapon] then
                _G.EquippedData[weapon].Skin = info.Skin or "Default"
                _G.EquippedData[weapon].Wrap = info.Wrap or "None"
            end
        end
        if result.global then
            _G.GlobalData.Charm    = result.global.Charm    or "None"
            _G.GlobalData.Finisher = result.global.Finisher or "None"
        end
        return true
    end
    return false
end
-- ══════════════════════════════════════════
-- SKIN CHANGER — Module Loader
-- ══════════════════════════════════════════

local function robust_require(module)
    local mName = tostring(module)
    local setidentity = setthreadidentity or set_thread_identity or (syn and syn.set_thread_identity) or nil
    local getidentity = getthreadidentity or get_thread_identity or (syn and syn.get_thread_identity) or nil

    if shared[mName] or _G[mName] then return shared[mName] or _G[mName] end

    local old_id
    pcall(function() if getidentity and setidentity then old_id=getidentity() setidentity(2) end end)
    local success, result = pcall(require, module)
    if not success and getgenv and getgenv().require then
        local ok2, res2 = pcall(getgenv().require, module)
        if ok2 then success, result = true, res2 end
    end
    pcall(function() if setidentity and old_id then setidentity(old_id) end end)
    if success then return result end

    for _, api in pairs({getgc, getregistry, debug and debug.getregistry}) do
        if type(api)=="function" then
            local ok3, objs = pcall(api, true)
            if ok3 and type(objs)=="table" then
                for _, v in pairs(objs) do
                    if type(v)=="table" then
                        if mName:find("CosmeticLibrary") and (v.Cosmetics or rawget(v,"Cosmetics")) and (type(v.Equip)=="function" or type(v.GetSkins)=="function") then return v end
                        if mName:find("ItemLibrary") and (v.ViewModels or rawget(v,"ViewModels")) then return v end
                        if mName:find("ClientViewModel") and (v.new or rawget(v,"new")) and (v.GetWrap or rawget(v,"GetWrap")) then return v end
                        if mName:find("ReplicatedClass") and type(v.ToEnum)=="function" then return v end
                    end
                end
            end
        end
    end
    return nil
end

-- ══════════════════════════════════════════
-- SKIN CHANGER — Main
-- ══════════════════════════════════════════

task.spawn(function()
    task.wait(1.5)
    local SC_Cosmetic  = robust_require(ReplicatedStorage:WaitForChild("Modules",20):WaitForChild("CosmeticLibrary",20))
    local SC_Item      = robust_require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary",20))
    local SC_RepClass  = robust_require(ReplicatedStorage.Modules:WaitForChild("ReplicatedClass",20))
    local SC_Modules   = plr.PlayerScripts:WaitForChild("Modules",15)
    local SC_ViewModel = robust_require(SC_Modules:WaitForChild("ClientReplicatedClasses",15):WaitForChild("ClientFighter",15):WaitForChild("ClientItem",15):WaitForChild("ClientViewModel",15))

    if not SC_Cosmetic or not SC_Item or not SC_ViewModel or not SC_RepClass then
        warn("[Skin Changer] Failed to load required modules.")
        return
    end

    -- Search all sub-tables of SC_Cosmetic for a cosmetic by name
    local function getCosmeticData(name, cType)
        local base
        if SC_Cosmetic.Cosmetics then base = SC_Cosmetic.Cosmetics[name] end
        if not base and type(SC_Cosmetic)=="table" then
            for _, tbl in pairs(SC_Cosmetic) do
                if type(tbl)=="table" and rawget(tbl, name) then
                    base = tbl[name] break
                end
            end
        end
        if not base then return nil end
        local data = table.clone(base)
        data.Name = name data.Type = cType
        return data
    end

    -- Try every known equip signature for global cosmetics (charms, finishers)
    local function tryEquipGlobal(typeName, itemName)
        local val = itemName ~= "None" and itemName or nil
        local cd  = val and getCosmeticData(val, typeName)
        pcall(function() SC_Cosmetic.Equip(nil, typeName, val) end)
        pcall(function() SC_Cosmetic.Equip(typeName, val) end)
        if typeName == "Charm" then
            pcall(function() SC_Cosmetic.EquipCharm(val) end)
            pcall(function() SC_Cosmetic.SetCharm(val) end)
            pcall(function() SC_Cosmetic.SetCharm(cd) end)
        elseif typeName == "Finisher" then
            pcall(function() SC_Cosmetic.EquipFinisher(val) end)
            pcall(function() SC_Cosmetic.SetFinisher(val) end)
            pcall(function() SC_Cosmetic.SetFinisher(cd) end)
        end
        -- GC fallback: call any function whose name suggests it handles this type
        for _, v in pairs(getgc(true)) do
            if type(v)=="function" then
                local n = tostring(v):lower()
                if typeName=="Charm" and (n:find("charm") or n:find("equip")) then
                    pcall(v, val) pcall(v, cd)
                elseif typeName=="Finisher" and (n:find("finish") or n:find("equip")) then
                    pcall(v, val) pcall(v, cd)
                end
            end
        end
    end

    -- Hook GetWrap
    local oldGetWrap = SC_ViewModel.GetWrap
    SC_ViewModel.GetWrap = function(self)
        local ok, res = pcall(function()
            local wn = self.ClientItem and self.ClientItem.Name
            if wn and _G.EquippedData[wn] then
                local wrap = _G.EquippedData[wn].Wrap
                if wrap and wrap ~= "None" then return getCosmeticData(wrap, "Wrap") end
            end
        end)
        if ok and res then return res end
        return oldGetWrap(self)
    end

    -- Hook GetCharm if it exists
    if SC_ViewModel.GetCharm then
        local oldGetCharm = SC_ViewModel.GetCharm
        SC_ViewModel.GetCharm = function(self)
            if _G.GlobalData.Charm ~= "None" then
                local cd = getCosmeticData(_G.GlobalData.Charm, "Charm")
                if cd then return cd end
            end
            return oldGetCharm(self)
        end
    end

    -- Hook GetFinisher if it exists
    if SC_ViewModel.GetFinisher then
        local oldGetFinisher = SC_ViewModel.GetFinisher
        SC_ViewModel.GetFinisher = function(self)
            if _G.GlobalData.Finisher ~= "None" then
                local cd = getCosmeticData(_G.GlobalData.Finisher, "Finisher")
                if cd then return cd end
            end
            return oldGetFinisher(self)
        end
    end

    -- Hook new — inject skin, charm, and finisher into replicatedData
    local oldNew = SC_ViewModel.new
    SC_ViewModel.new = function(replicatedData, clientItem)
        pcall(function()
            if not clientItem then return end
            local wn = clientItem.Name if not wn then return end
            local cf = rawget(clientItem,"ClientFighter") or clientItem.ClientFighter
            if not cf or cf.Player ~= plr then return end

            local dk      = SC_RepClass:ToEnum("Data")
            local skinKey = SC_RepClass:ToEnum("Skin")
            local nameKey = SC_RepClass:ToEnum("Name")
            local ok1, charmKey    = pcall(function() return SC_RepClass:ToEnum("Charm") end)
            local ok2, finisherKey = pcall(function() return SC_RepClass:ToEnum("Finisher") end)
            replicatedData[dk] = replicatedData[dk] or {}

            -- Inject skin
            if _G.EquippedData[wn] then
                local skin = _G.EquippedData[wn].Skin
                if skin and skin ~= "Default" then
                    local cd = getCosmeticData(skin, "Skin")
                    if cd then replicatedData[dk][skinKey]=cd replicatedData[dk][nameKey]=skin end
                end
            end

            -- Inject charm
            if ok1 and _G.GlobalData.Charm ~= "None" then
                local cd = getCosmeticData(_G.GlobalData.Charm, "Charm")
                if cd then replicatedData[dk][charmKey] = cd end
            end

            -- Inject finisher
            if ok2 and _G.GlobalData.Finisher ~= "None" then
                local cd = getCosmeticData(_G.GlobalData.Finisher, "Finisher")
                if cd then replicatedData[dk][finisherKey] = cd end
            end
        end)
        local vm = oldNew(replicatedData, clientItem)
        task.delay(0.1, function()
            pcall(function() if vm and vm._UpdateWrap     then vm:_UpdateWrap()     end end)
            pcall(function() if vm and vm._UpdateCharm    then vm:_UpdateCharm()    end end)
            pcall(function() if vm and vm._UpdateFinisher then vm:_UpdateFinisher() end end)
        end)
        return vm
    end

    -- ══════════════════════════════════════════
    -- SKIN CHANGER — GUI
    -- ══════════════════════════════════════════

    local SC_Gui = Instance.new("ScreenGui", plr.PlayerGui)
    SC_Gui.ResetOnSpawn = false
    SC_Gui.Name = "AnihaSkinChanger"

    -- Reuse the mobile detection from the main UI
    local isMobile = isMobileMain

    -- Mobile uses a smaller window that fits a phone/tablet screen
    local mainW = isMobile and 620 or 950
    local mainH = isMobile and 480 or 660

    local SC_Main = Instance.new("Frame", SC_Gui)
    SC_Main.Size = UDim2.new(0, mainW, 0, mainH)
    SC_Main.Position = UDim2.new(0.5, -mainW/2, 0.5, -mainH/2)
    SC_Main.BackgroundColor3 = Color3.fromRGB(20,20,24)
    SC_Main.BorderSizePixel = 0
    SC_Main.Visible = false

    -- ── Mobile open button (bottom-right, only shown on mobile) ──
    if isMobile then
        local mobileBtn = Instance.new("TextButton", SC_Gui)
        mobileBtn.Size = UDim2.new(0,70,0,70)
        mobileBtn.Position = UDim2.new(1,-85,1,-155)  -- bottom-right, above jump button
        mobileBtn.BackgroundColor3 = Color3.fromRGB(0,180,140)
        mobileBtn.BorderSizePixel = 0
        mobileBtn.Text = "👗"
        mobileBtn.TextSize = 30
        mobileBtn.Font = Enum.Font.GothamBold
        mobileBtn.ZIndex = 10
        Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(1,0)
        local mStroke = Instance.new("UIStroke", mobileBtn)
        mStroke.Color = Color3.fromRGB(0,255,200)
        mStroke.Thickness = 2

        -- Pulse animation so players can find it easily
        task.spawn(function()
            while mobileBtn.Parent do
                TweenService:Create(mobileBtn, TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundColor3=Color3.fromRGB(0,120,100)}):Play()
                task.wait(0.7)
                TweenService:Create(mobileBtn, TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundColor3=Color3.fromRGB(0,180,140)}):Play()
                task.wait(0.7)
            end
        end)

        mobileBtn.MouseButton1Click:Connect(function()
            SC_Main.Visible = not SC_Main.Visible
        end)
    end

    local SC_Title = Instance.new("TextLabel", SC_Main)
    SC_Title.Size = UDim2.new(1,0,0, isMobile and 40 or 50)
    SC_Title.BackgroundColor3 = Color3.fromRGB(30,30,35)
    SC_Title.Text = isMobile and "◈ Skin Changer" or "◈ Skin Changer  •  [ K ] Toggle"
    SC_Title.TextColor3 = Color3.fromRGB(0,255,200)
    SC_Title.Font = Enum.Font.GothamBlack
    SC_Title.TextSize = isMobile and 16 or 20
    SC_Title.BorderSizePixel = 0
    SC_Title.Active = true

    local SC_Left = Instance.new("Frame", SC_Main)
    local leftW = isMobile and 180 or 280
    SC_Left.Size = UDim2.new(0, leftW, 1, -110)
    SC_Left.Position = UDim2.new(0,10,0,isMobile and 45 or 60)
    SC_Left.BackgroundColor3 = Color3.fromRGB(14,14,20)
    SC_Left.BorderSizePixel = 0

    local SC_Search = Instance.new("TextBox", SC_Left)
    SC_Search.Size = UDim2.new(1,-20,0,35)
    SC_Search.Position = UDim2.new(0,10,0,10)
    SC_Search.PlaceholderText = "Search weapon..."
    SC_Search.BackgroundColor3 = Color3.fromRGB(20,20,30)
    SC_Search.TextColor3 = Color3.new(1,1,1)
    SC_Search.Font = Enum.Font.Gotham
    SC_Search.TextSize = 14
    SC_Search.BorderSizePixel = 0
    SC_Search.ClearTextOnFocus = false
    SC_Search.Text = ""

    local SC_WeaponScroll = Instance.new("ScrollingFrame", SC_Left)
    SC_WeaponScroll.Size = UDim2.new(1,-20,1,-55)
    SC_WeaponScroll.Position = UDim2.new(0,10,0,55)
    SC_WeaponScroll.BackgroundTransparency = 1
    SC_WeaponScroll.ScrollBarThickness = isMobile and 2 or 4
    SC_WeaponScroll.BorderSizePixel = 0
    SC_WeaponScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    local SC_WLayout = Instance.new("UIListLayout", SC_WeaponScroll)
    SC_WLayout.Padding = UDim.new(0,5)
    SC_WLayout.SortOrder = Enum.SortOrder.Name

    local rightX = isMobile and (leftW + 20) or 305
    local rightW = isMobile and (mainW - leftW - 30) or (mainW - 310)
    local SC_Right = Instance.new("Frame", SC_Main)
    SC_Right.Size = UDim2.new(0, rightW, 1, -110)
    SC_Right.Position = UDim2.new(0, rightX, 0, isMobile and 45 or 60)
    SC_Right.BackgroundColor3 = Color3.fromRGB(14,14,20)
    SC_Right.BorderSizePixel = 0

    local SC_SelLabel = Instance.new("TextLabel", SC_Right)
    SC_SelLabel.Size = UDim2.new(1,-20,0,30)
    SC_SelLabel.Position = UDim2.new(0,10,0,8)
    SC_SelLabel.BackgroundTransparency = 1
    SC_SelLabel.Text = "Select a weapon"
    SC_SelLabel.TextColor3 = Color3.fromRGB(200,200,200)
    SC_SelLabel.Font = Enum.Font.GothamBold
    SC_SelLabel.TextSize = 16

    -- 4-tab bar: Skins | Wraps | Charms | Finishers
    local SC_TabBar = Instance.new("Frame", SC_Right)
    SC_TabBar.Size = UDim2.new(1,-20,0,28)
    SC_TabBar.Position = UDim2.new(0,10,0,42)
    SC_TabBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
    SC_TabBar.BorderSizePixel = 0
    Instance.new("UICorner",SC_TabBar).CornerRadius = UDim.new(0,6)

    local function SC_MakeTabBtn(text, xScale)
        local b = Instance.new("TextButton", SC_TabBar)
        b.Size = UDim2.new(0.25,-3,1,-4)
        b.Position = UDim2.new(xScale,2,0,2)
        b.BackgroundColor3 = Color3.fromRGB(14,14,20)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(90,130,120)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BorderSizePixel = 0
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
        return b
    end

    local SkinsTabBtn    = SC_MakeTabBtn("🎨 Skins",    0)
    local WrapsTabBtn    = SC_MakeTabBtn("🎁 Wraps",    0.25)
    local CharmsTabBtn   = SC_MakeTabBtn("🔮 Charms",   0.5)
    local FinishTabBtn   = SC_MakeTabBtn("⚔️ Finish",   0.75)

    local function makeContentScroll(cellW, cellH)
        -- On mobile shrink cells so more fit on the smaller screen
        local cw = isMobile and math.floor(cellW * 0.75) or cellW
        local ch = isMobile and math.floor(cellH * 0.75) or cellH
        local sf = Instance.new("ScrollingFrame", SC_Right)
        sf.Size = UDim2.new(1,-20,1,-80)
        sf.Position = UDim2.new(0,10,0,76)
        sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = isMobile and 2 or 6
        sf.BorderSizePixel = 0
        sf.Visible = false
        sf.ScrollingDirection = Enum.ScrollingDirection.Y
        local g = Instance.new("UIGridLayout", sf)
        g.CellSize = UDim2.new(0,cw,0,ch)
        g.CellPadding = UDim2.new(0,8,0,8)
        return sf, g
    end

    local SC_SkinScroll,    SC_SkinGrid    = makeContentScroll(130, 155)
    local SC_WrapScroll,    SC_WrapGrid    = makeContentScroll(130, 50)
    local SC_CharmScroll,   SC_CharmGrid   = makeContentScroll(130, 50)
    local SC_FinishScroll,  SC_FinishGrid  = makeContentScroll(130, 50)
    SC_SkinScroll.Visible = true

    local SC_ActiveTab = "Skins"

    local function SC_SetTab(tab)
        SC_ActiveTab = tab
        SC_SkinScroll.Visible   = (tab == "Skins")
        SC_WrapScroll.Visible   = (tab == "Wraps")
        SC_CharmScroll.Visible  = (tab == "Charms")
        SC_FinishScroll.Visible = (tab == "Finish")
        local neon = Color3.fromRGB(0,255,200)
        local dim  = Color3.fromRGB(90,130,120)
        local bon  = Color3.fromRGB(0,60,50)
        local boff = Color3.fromRGB(14,14,20)
        for _, pair in pairs({
            {SkinsTabBtn,  "Skins"},
            {WrapsTabBtn,  "Wraps"},
            {CharmsTabBtn, "Charms"},
            {FinishTabBtn, "Finish"},
        }) do
            pair[1].BackgroundColor3 = tab==pair[2] and bon or boff
            pair[1].TextColor3       = tab==pair[2] and neon or dim
        end
    end
    SC_SetTab("Skins")

    SkinsTabBtn.MouseButton1Click:Connect(function()  SC_SetTab("Skins")  end)
    WrapsTabBtn.MouseButton1Click:Connect(function()  SC_SetTab("Wraps")  end)
    CharmsTabBtn.MouseButton1Click:Connect(function()  SC_SetTab("Charms") end)
    FinishTabBtn.MouseButton1Click:Connect(function()  SC_SetTab("Finish") end)

    -- Toolbar
    local SC_Toolbar = Instance.new("Frame", SC_Main)
    SC_Toolbar.Size = UDim2.new(1,0,0,48)
    SC_Toolbar.Position = UDim2.new(0,0,1,-48)
    SC_Toolbar.BackgroundColor3 = Color3.fromRGB(20,20,30)
    SC_Toolbar.BorderSizePixel = 0

    local SC_Status = Instance.new("TextLabel", SC_Toolbar)
    SC_Status.Size = UDim2.new(1,-310,1,0)
    SC_Status.Position = UDim2.new(0,15,0,0)
    SC_Status.BackgroundTransparency = 1
    SC_Status.Text = "Ready"
    SC_Status.TextColor3 = Color3.fromRGB(90,130,120)
    SC_Status.Font = Enum.Font.Gotham
    SC_Status.TextSize = 13
    SC_Status.TextXAlignment = Enum.TextXAlignment.Left

    local function SC_Flash(msg, col)
        SC_Status.Text = msg
        SC_Status.TextColor3 = col or Color3.fromRGB(0,255,200)
        task.delay(3, function()
            SC_Status.Text = "Ready"
            SC_Status.TextColor3 = Color3.fromRGB(90,130,120)
        end)
    end

    local function SC_MakeBtn(text, xOff, col)
        local b = Instance.new("TextButton", SC_Toolbar)
        b.Size = UDim2.new(0,140,0,32)
        b.Position = UDim2.new(1,xOff,0.5,-16)
        b.BackgroundColor3 = col
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.BorderSizePixel = 0
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
        return b
    end

    local SC_SaveBtn = SC_MakeBtn("💾  Save Config", -300, Color3.fromRGB(30,90,30))
    local SC_LoadBtn = SC_MakeBtn("📂  Load Config", -150, Color3.fromRGB(30,60,130))

    SC_SaveBtn.MouseButton1Click:Connect(function()
        SC_SaveConfig()
        SC_Flash("✅ Config saved!")
    end)
    SC_LoadBtn.MouseButton1Click:Connect(function()
        if SC_LoadConfig() then
            for weapon, info in pairs(_G.EquippedData) do
                if info.Skin ~= "Default" then
                    pcall(function() SC_Cosmetic.Equip(weapon, "Skin", info.Skin) end)
                end
            end
            SC_Flash("✅ Config loaded!", Color3.fromRGB(100,180,255))
        else
            SC_Flash("❌ No config found!", Color3.fromRGB(220,80,80))
        end
    end)

    -- Equip helpers
    local function SC_EquipSkin(weapon, skin)
        _G.EquippedData[weapon].Skin = skin
        pcall(function() SC_Cosmetic.Equip(weapon, "Skin", skin) end)
        SC_SelLabel.Text = "✅  " .. weapon .. "  —  " .. skin
    end

    local function SC_EquipWrap(weapon, wrap)
        _G.EquippedData[weapon].Wrap = wrap
        pcall(function() SC_Cosmetic.Equip(weapon, "Wrap", wrap ~= "None" and wrap or nil) end)
        SC_SelLabel.Text = "✅  " .. weapon .. "  —  Wrap: " .. wrap
    end

    -- Build a generic list scroll (for wraps per-weapon, charms, finishers)
    local function buildListScroll(scroll, grid, list, getSelected, onSelect)
        for _, c in pairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, item in ipairs(list) do
            local wb = Instance.new("TextButton")
            wb.Size = UDim2.new(1,0,1,0)
            wb.BackgroundColor3 = getSelected()==item and Color3.fromRGB(0,60,50) or Color3.fromRGB(20,20,30)
            wb.Text = item
            wb.TextColor3 = Color3.fromRGB(210,255,245)
            wb.Font = Enum.Font.GothamSemibold
            wb.TextSize = 12
            wb.BorderSizePixel = 0
            wb.Parent = scroll
            wb.TextScaled = true
            Instance.new("UICorner",wb).CornerRadius = UDim.new(0,5)
            wb.MouseButton1Click:Connect(function()
                for _, c2 in pairs(scroll:GetChildren()) do
                    if c2:IsA("TextButton") then c2.BackgroundColor3=Color3.fromRGB(20,20,30) end
                end
                wb.BackgroundColor3 = Color3.fromRGB(0,60,50)
                onSelect(item)
            end)
        end
        scroll.CanvasSize = UDim2.new(0,0,0,grid.AbsoluteContentSize.Y+20)
    end

    -- Pre-populate charms and finishers (global, not per-weapon)
    buildListScroll(SC_CharmScroll, SC_CharmGrid, CharmList,
        function() return _G.GlobalData.Charm end,
        function(item)
            _G.GlobalData.Charm = item
            tryEquipGlobal("Charm", item)
            SC_SelLabel.Text = "✅  Charm: " .. item
        end
    )

    buildListScroll(SC_FinishScroll, SC_FinishGrid, FinisherList,
        function() return _G.GlobalData.Finisher end,
        function(item)
            _G.GlobalData.Finisher = item
            tryEquipGlobal("Finisher", item)
            SC_SelLabel.Text = "✅  Finisher: " .. item
        end
    )

    -- Weapon buttons
    local function SC_MakeWeaponBtn(weapon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-8, 0, isMobile and 36 or 48)
        btn.BackgroundColor3 = Color3.fromRGB(20,20,30)
        btn.Text = "  " .. weapon
        btn.TextColor3 = Color3.fromRGB(210,255,245)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = isMobile and 11 or 14
        btn.BorderSizePixel = 0
        btn.Parent = SC_WeaponScroll
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)

        -- Skin badge (teal)
        local skinBadge = Instance.new("TextLabel", btn)
        skinBadge.Size = UDim2.new(0,60,0,15)
        skinBadge.Position = UDim2.new(1,-130,0,4)
        skinBadge.BackgroundColor3 = Color3.fromRGB(0,180,140)
        skinBadge.TextColor3 = Color3.fromRGB(8,8,12)
        skinBadge.Font = Enum.Font.GothamBold
        skinBadge.TextSize = 10
        skinBadge.BorderSizePixel = 0
        skinBadge.TextScaled = true
        Instance.new("UICorner",skinBadge).CornerRadius = UDim.new(0,4)

        -- Wrap badge (purple)
        local wrapBadge = Instance.new("TextLabel", btn)
        wrapBadge.Size = UDim2.new(0,60,0,15)
        wrapBadge.Position = UDim2.new(1,-65,0,4)
        wrapBadge.BackgroundColor3 = Color3.fromRGB(80,50,180)
        wrapBadge.TextColor3 = Color3.new(1,1,1)
        wrapBadge.Font = Enum.Font.GothamBold
        wrapBadge.TextSize = 10
        wrapBadge.BorderSizePixel = 0
        wrapBadge.TextScaled = true
        Instance.new("UICorner",wrapBadge).CornerRadius = UDim.new(0,4)

        local function UpdateBadges()
            local skin = _G.EquippedData[weapon] and _G.EquippedData[weapon].Skin or "Default"
            local wrap = _G.EquippedData[weapon] and _G.EquippedData[weapon].Wrap or "None"
            if skin ~= "Default" then skinBadge.Text=skin:sub(1,7) skinBadge.Visible=true
            else skinBadge.Visible=false end
            if wrap ~= "None" then wrapBadge.Text=wrap:sub(1,7) wrapBadge.Visible=true
            else wrapBadge.Visible=false end
        end
        UpdateBadges()

        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(SC_WeaponScroll:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(20,20,30) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0,60,50)
            SC_SelLabel.Text = weapon .. "  —  Choose a skin or wrap"

            -- Populate skins
            for _, c in pairs(SC_SkinScroll:GetChildren()) do
                if c:IsA("ImageButton") then c:Destroy() end
            end
            for _, skin in ipairs(SkinLists[weapon]) do
                local sb = Instance.new("ImageButton")
                sb.BackgroundColor3 = (_G.EquippedData[weapon] and _G.EquippedData[weapon].Skin==skin)
                    and Color3.fromRGB(0,60,50) or Color3.fromRGB(20,20,30)
                sb.Image = "" sb.BorderSizePixel = 0 sb.Parent = SC_SkinScroll
                Instance.new("UICorner",sb).CornerRadius = UDim.new(0,6)
                local lbl = Instance.new("TextLabel", sb)
                lbl.Size = UDim2.new(1,0,0,38) lbl.Position = UDim2.new(0,0,1,-38)
                lbl.BackgroundTransparency = 0.3 lbl.BackgroundColor3 = Color3.new(0,0,0)
                lbl.Text = skin lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.Gotham lbl.TextScaled = true lbl.BorderSizePixel = 0
                Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,4)
                sb.MouseButton1Click:Connect(function()
                    for _, c2 in pairs(SC_SkinScroll:GetChildren()) do
                        if c2:IsA("ImageButton") then c2.BackgroundColor3=Color3.fromRGB(20,20,30) end
                    end
                    sb.BackgroundColor3 = Color3.fromRGB(0,60,50)
                    SC_EquipSkin(weapon, skin)
                    UpdateBadges()
                end)
            end
            SC_SkinScroll.CanvasSize = UDim2.new(0,0,0,SC_SkinGrid.AbsoluteContentSize.Y+40)

            -- Populate wraps for this weapon
            buildListScroll(SC_WrapScroll, SC_WrapGrid, WrapList,
                function() return _G.EquippedData[weapon] and _G.EquippedData[weapon].Wrap or "None" end,
                function(item)
                    SC_EquipWrap(weapon, item)
                    UpdateBadges()
                end
            )
        end)
    end

    for weapon in pairs(SkinLists) do SC_MakeWeaponBtn(weapon) end
    SC_WeaponScroll.CanvasSize = UDim2.new(0,0,0,SC_WLayout.AbsoluteContentSize.Y)

    SC_Search:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = SC_Search.Text:lower()
        for _, btn in pairs(SC_WeaponScroll:GetChildren()) do
            if btn:IsA("TextButton") then
                local t = btn.Text:match("^%s*(.-)%s*$"):lower()
                btn.Visible = txt=="" or t:find(txt)
            end
        end
    end)

    -- Draggable title bar
    do
        local sc_dragging, sc_dragStart, sc_startPos
        SC_Title.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                sc_dragging=true sc_dragStart=input.Position sc_startPos=SC_Main.Position
            end
        end)
        SC_Title.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then sc_dragging=false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sc_dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                local d = input.Position - sc_dragStart
                SC_Main.Position = UDim2.new(sc_startPos.X.Scale, sc_startPos.X.Offset+d.X, sc_startPos.Y.Scale, sc_startPos.Y.Offset+d.Y)
            end
        end)
    end

    -- K to toggle (keyboard/PC only — mobile uses the on-screen button)
    if not isMobile then
        UserInputService.InputBegan:Connect(function(i, g)
            if not g and i.KeyCode==Enum.KeyCode.K then
                SC_Main.Visible = not SC_Main.Visible
            end
        end)
    end

    print("[Skin Changer] Loaded —", isMobile and "tap the 👗 button to open." or "press K to open.")
end)
