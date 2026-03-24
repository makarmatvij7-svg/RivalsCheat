-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
-- Auto Farm (FIX: strict alive + sanity checks)
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
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
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

        -- FIX: strict alive checks before teleporting
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart") if not targetHrp then return end
        local targetHum = target.Character:FindFirstChild("Humanoid") if not targetHum then return end
        if targetHum.Health <= 0 then return end

        -- FIX: sanity check — skip if target position is insane (dead/ragdolling away)
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

local flyConn = nil
local flyBodyVel = nil
local flyBodyGyro = nil

local function enableFly()
    local char = plr.Character
    if not char then return end
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
        local char2 = plr.Character if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart") if not hrp2 then return end

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

        if dir.Magnitude > 0 then
            flyBodyVel.Velocity = dir.Unit * speed
        else
            flyBodyVel.Velocity = Vector3.zero
        end
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

local antiAimConn = nil
local antiAimAngle = 0

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
-- CharacterAdded
-- ══════════════════════════════════════════

plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if state.Fly then disableFly() task.wait(0.1) enableFly() end
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
        box=newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,255,200),Thickness=1.5,Filled=false,Transparency=1}),
        boxFill=newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,200,150),Thickness=1,Filled=true,Transparency=0.9}),
        name=newDrawing("Text",{Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2}),
        healthBg=newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true,Transparency=0.5}),
        healthBar=newDrawing("Square",{Visible=false,Color=Color3.fromRGB(0,255,180),Thickness=1,Filled=true,Transparency=1}),
        distance=newDrawing("Text",{Visible=false,Color=Color3.fromRGB(180,255,240),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2}),
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "🐉CyberDragon🐉"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = plr:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Size = UDim2.new(0,540,0,380)
root.Position = UDim2.new(0.5,-270,0.5,-190)
root.BackgroundColor3 = C.bg
root.BorderSizePixel = 0
root.BackgroundTransparency = 1
root.ClipsDescendants = true
root.Parent = screenGui
Instance.new("UICorner", root).CornerRadius = UDim.new(0,8)
local rootStroke = Instance.new("UIStroke", root)
rootStroke.Color = C.neon rootStroke.Thickness = 1.5 rootStroke.Transparency = 1

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundColor3 = C.bg2
titleBar.BorderSizePixel = 0
titleBar.Parent = root
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,8)

local tbFix = Instance.new("Frame")
tbFix.Size=UDim2.new(1,0,0.5,0) tbFix.Position=UDim2.new(0,0,0.5,0)
tbFix.BackgroundColor3=C.bg2 tbFix.BorderSizePixel=0 tbFix.Parent=titleBar

local titleAccent = Instance.new("Frame")
titleAccent.Size=UDim2.new(0,3,1,-10) titleAccent.Position=UDim2.new(0,8,0,5)
titleAccent.BackgroundColor3=C.neon titleAccent.BorderSizePixel=0 titleAccent.Parent=titleBar
Instance.new("UICorner",titleAccent).CornerRadius=UDim.new(1,0)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-80,1,0) titleLbl.Position=UDim2.new(0,18,0,0)
titleLbl.BackgroundTransparency=1 titleLbl.Text="🐉CyberDragon🐉"
titleLbl.TextColor3=C.neon titleLbl.TextSize=12 titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextXAlignment=Enum.TextXAlignment.Left titleLbl.Parent=titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,22,0,22) closeBtn.Position=UDim2.new(1,-28,0.5,-11)
closeBtn.BackgroundColor3=C.bg3 closeBtn.BorderSizePixel=0
closeBtn.Text="×" closeBtn.TextColor3=C.neon closeBtn.TextSize=14
closeBtn.Font=Enum.Font.GothamBold closeBtn.Parent=titleBar
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,4)
Instance.new("UIStroke",closeBtn).Color=C.neon

local minimized = false
closeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0,540,0,36) or UDim2.new(0,540,0,380)
    }):Play()
    closeBtn.Text = minimized and "+" or "×"
end)

local hidden = false
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
            TweenService:Create(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-270,0.5,-190),BackgroundTransparency=0}):Play()
            TweenService:Create(rootStroke,TweenInfo.new(0.3),{Transparency=0}):Play()
        end
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size=UDim2.new(1,-16,0,28) tabBar.Position=UDim2.new(0,8,0,42)
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
contentArea.Size=UDim2.new(1,-16,1,-82) contentArea.Position=UDim2.new(0,8,0,76)
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
        TweenService:Create(pData.tab,TweenInfo.new(0.15),{
            BackgroundColor3=active and C.neon2 or C.bg3
        }):Play()
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
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1
    btn.Text="" btn.Parent=row

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
        pb.BorderSizePixel=0
        pb.Text=opt
        pb.TextColor3 = opt==farmPosition and C.bg or C.dim
        pb.TextSize=10
        pb.Font=Enum.Font.GothamBold
        pb.Parent=row
        Instance.new("UICorner",pb).CornerRadius=UDim.new(0,4)
        pickerBtns[opt] = pb

        pb.MouseButton1Click:Connect(function()
            farmPosition = opt
            for _, o in pairs(options) do
                TweenService:Create(pickerBtns[o],TweenInfo.new(0.15),{
                    BackgroundColor3 = o==opt and C.neon2 or C.bg3
                }):Play()
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
makeToggle(mL,"Noclip",      "Noclip",     7, enableNoclip,     disableNoclip)
makeToggle(mL,"Anti Aim",    "AntiAim",    8, enableAntiAim,    disableAntiAim)
makeHeader(mL,"Strafe",9)
makeSlider(mL,"Strafe Intensity",10,1,100,50,"StrafeIntensity",nil)
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
makeToggle(vL,"ESP",         "ESP",         2, nil,               nil)
makeToggle(vL,"Third Person","ThirdPerson", 3, enableThirdPerson, disableThirdPerson)

local wL, wR = createTab("World", 4)
makeHeader(wL,"Protection",1)
makeToggle(wL,"Prevent OOB",    "NoBounds",      2, enableNoBounds,      disableNoBounds)
makeToggle(wL,"Remove Killers", "RemoveKillers", 3, enableRemoveKillers, disableRemoveKillers)
makeToggle(wL,"No Fire Damage", "NoFireDamage",  4, enableNoFireDamage,  disableNoFireDamage)
makeToggle(wL,"Anti Freeze",    "AntiFreeze",    5, enableAntiFreeze,    disableAntiFreeze)

switchTab("Combat")

-- Open animation
task.spawn(function()
    task.wait(0.1)
    TweenService:Create(root,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
    TweenService:Create(rootStroke,TweenInfo.new(0.4),{Transparency=0}):Play()
end)

-- Draggable
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=input.Position startPos=root.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-dragStart
        root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
