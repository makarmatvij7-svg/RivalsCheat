local Players=game:GetService("Players") local RunService=game:GetService("RunService") local TweenService=game:GetService("TweenService") local UserInputService=game:GetService("UserInputService") local ReplicatedStorage=game:GetService("ReplicatedStorage") local HttpService=game:GetService("HttpService") local plr=Players.LocalPlayer local camera=workspace.CurrentCamera
local state={NoRecoil=false,NoSpread=false,AutoDrop=false,ESP=false,ThirdPerson=false,AntiKatana=false,NoBounds=false,JumpBug=false,AutoStrafe=false,RapidFire=false,AutoWeapon=false,InstantScope=false,AlwaysBackstab=false,RemoveKillers=false,NoFireDamage=false,AntiFreeze=false,Fly=false,Noclip=false,AntiAim=false,AutoFarm=false}
local cfg={WalkSpeed=16,JumpPower=50,StrafeIntensity=50,FlySpeed=50} local farmPos="Behind"
local gc={}
local function fac(a) if gc[a] then return end gc[a]={} for _,v in pairs(getgc(true)) do if type(v)=="table" and rawget(v,a)~=nil then table.insert(gc[a],{tbl=v,original=v[a]}) end end end
local function aa(a,v) fac(a) if type(gc[a])~="table" then return end for _,e in pairs(gc[a]) do if type(e)=="table" and e.tbl then pcall(function() e.tbl[a]=v end) end end end
local function ra(a) if not gc[a] then return end for _,e in pairs(gc[a]) do if type(e)=="table" and e.tbl then pcall(function() e.tbl[a]=e.original end) end end gc[a]=nil end
local function gco(keys) local r={} for _,v in pairs(getgc(true)) do if type(v)=="table" then for _,k in pairs(keys) do if rawget(v,k)~=nil then table.insert(r,{tbl=v,key=k,original=v[k]}) end end end end return r end

-- AutoFarm
local afConn,afTick=nil,0
local function gce() local c=plr.Character if not c then return end local r=c:FindFirstChild("HumanoidRootPart") if not r then return end local cl,cd=nil,math.huge for _,p in pairs(Players:GetPlayers()) do if p~=plr and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart") local hm=p.Character:FindFirstChild("Humanoid") if h and hm and hm.Health>0 then local d=(h.Position-r.Position).Magnitude if d<cd then cd=d cl=p end end end end return cl end
local function gfo(t) if farmPos=="Above" then return t.Position+Vector3.new(0,6,0) elseif farmPos=="Under" then return t.Position-Vector3.new(0,3,0) else return t.Position-(t.CFrame.LookVector*3)+Vector3.new(0,0.5,0) end end
local function eAF() afConn=RunService.Heartbeat:Connect(function() if not state.AutoFarm then return end local n=tick() if(n-afTick)<0.1 then return end afTick=n local c=plr.Character if not c then return end local r=c:FindFirstChild("HumanoidRootPart") if not r then return end local t=gce() if not t or not t.Character then return end local th=t.Character:FindFirstChild("HumanoidRootPart") if not th then return end local tm=t.Character:FindFirstChild("Humanoid") if not tm or tm.Health<=0 then return end if th.Position.Magnitude>10000 or th.Position.Y>2000 then return end r.CFrame=CFrame.new(gfo(th),th.Position) end) end
local function dAF() if afConn then afConn:Disconnect() afConn=nil end end

-- Fly
local fConn,fBV,fBG=nil,nil,nil
local function eFly() local c=plr.Character if not c then return end local r=c:FindFirstChild("HumanoidRootPart") local h=c:FindFirstChildOfClass("Humanoid") if not r or not h then return end h.PlatformStand=true fBV=Instance.new("BodyVelocity") fBV.Velocity=Vector3.zero fBV.MaxForce=Vector3.new(1e6,1e6,1e6) fBV.P=1e4 fBV.Parent=r fBG=Instance.new("BodyGyro") fBG.MaxTorque=Vector3.new(1e6,1e6,1e6) fBG.P=1e4 fBG.D=100 fBG.CFrame=r.CFrame fBG.Parent=r fConn=RunService.RenderStepped:Connect(function() if not state.Fly then return end local c2=plr.Character if not c2 then return end local r2=c2:FindFirstChild("HumanoidRootPart") if not r2 then return end local sp=cfg.FlySpeed local d=Vector3.zero local cf=camera.CFrame local fw=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z).Unit local rt=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z).Unit local UIS=UserInputService if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+fw end if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-fw end if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-rt end if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+rt end if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end if d.Magnitude>0 then fBV.Velocity=d.Unit*sp else fBV.Velocity=Vector3.zero end fBG.CFrame=cf end) end
local function dFly() if fConn then fConn:Disconnect() fConn=nil end if fBV then fBV:Destroy() fBV=nil end if fBG then fBG:Destroy() fBG=nil end local c=plr.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end end end

-- Noclip
local ncConn=nil
local function eNC() ncConn=RunService.Stepped:Connect(function() if not state.Noclip then return end local c=plr.Character if not c then return end for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end
local function dNC() if ncConn then ncConn:Disconnect() ncConn=nil end local c=plr.Character if not c then return end for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end

-- AntiAim
local aaConn,aaAngle=nil,0
local function eAA() aaConn=RunService.Heartbeat:Connect(function() if not state.AntiAim then return end local c=plr.Character if not c then return end local r=c:FindFirstChild("HumanoidRootPart") if not r then return end aaAngle=(aaAngle+25)%360 r.CFrame=CFrame.new(r.Position)*CFrame.Angles(math.pi,math.rad(aaAngle),0) end) end
local function dAA() if aaConn then aaConn:Disconnect() aaConn=nil end aaAngle=0 end

-- ThirdPerson
local tpConn,tpOrig=nil,nil
local function eTP() local c=plr.Character if not c then return end if not tpOrig then tpOrig=camera.CameraType end camera.CameraType=Enum.CameraType.Scriptable for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=0 end end tpConn=RunService.RenderStepped:Connect(function() if not state.ThirdPerson then return end local c2=plr.Character if not c2 then return end local r=c2:FindFirstChild("HumanoidRootPart") if not r then return end camera.CFrame=CFrame.new(r.Position-(r.CFrame.LookVector*12)+Vector3.new(0,4,0),r.Position+Vector3.new(0,2,0)) end) end
local function dTP() if tpConn then tpConn:Disconnect() tpConn=nil end if tpOrig then camera.CameraType=tpOrig tpOrig=nil end local c=plr.Character if not c then return end for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=0 end end end

-- AntiKatana
local akConn,akC={},nil
local function eAK() akC=gco({"ReflectBullets","CanReflect","IsBlocking","KatanaBlocking","KatanaActive","ParryActive","BulletReflect","Deflect","IsParrying","KatanaReflect","ReflectDamage"}) for _,e in pairs(akC) do pcall(function() e.tbl[e.key]=false end) end akConn=RunService.Heartbeat:Connect(function() if not state.AntiKatana then return end for _,e in pairs(akC) do pcall(function() e.tbl[e.key]=false end) end end) end
local function dAK() if akConn then akConn:Disconnect() akConn=nil end for _,e in pairs(akC) do pcall(function() e.tbl[e.key]=e.original end) end akC={} end

-- NoBounds
local nbConn,nbC,nbSafe={},{},nil
local function eNB() nbC=gco({"OutOfBounds","IsOutOfBounds","OOB","outOfBounds","BoundsDead","VoidKill","InVoid","FellOff","KillOnFall","DeathFloor","KillFloor"}) for _,e in pairs(nbC) do pcall(function() e.tbl[e.key]=false end) end local c=plr.Character if c then local r=c:FindFirstChild("HumanoidRootPart") if r then nbSafe=r.CFrame end end nbConn=RunService.Heartbeat:Connect(function() if not state.NoBounds then return end local c2=plr.Character if not c2 then return end local r=c2:FindFirstChild("HumanoidRootPart") if not r then return end if r.Position.Y>-10 then nbSafe=r.CFrame end if r.Position.Y<-80 and nbSafe then r.CFrame=nbSafe end for _,e in pairs(nbC) do pcall(function() e.tbl[e.key]=false end) end end) end
local function dNB() if nbConn then nbConn:Disconnect() nbConn=nil end for _,e in pairs(nbC) do pcall(function() e.tbl[e.key]=e.original end) end nbC={} nbSafe=nil end

-- JumpBug
local jbConn=nil
local function eJB() jbConn=RunService.Heartbeat:Connect(function() if not state.JumpBug then return end local c=plr.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if not h then return end if h:GetState()==Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
local function dJB() if jbConn then jbConn:Disconnect() jbConn=nil end end

-- AutoStrafe
local stConn,stDir,stTick=nil,1,0
local function eST() stConn=RunService.Heartbeat:Connect(function() if not state.AutoStrafe then return end local c=plr.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") local r=c:FindFirstChild("HumanoidRootPart") if not h or not r then return end if h:GetState()==Enum.HumanoidStateType.Freefall then local n=tick() local iv=0.3-(cfg.StrafeIntensity/100*0.25) if(n-stTick)>iv then stTick=n stDir=-stDir end local rt=r.CFrame.RightVector local v=r.AssemblyLinearVelocity r.AssemblyLinearVelocity=Vector3.new(v.X+rt.X*stDir*(cfg.StrafeIntensity/10),v.Y,v.Z+rt.Z*stDir*(cfg.StrafeIntensity/10)) end end) end
local function dST() if stConn then stConn:Disconnect() stConn=nil end end

-- RapidFire/AutoWeapon/InstantScope
local rfC,awC,isC={},{},{}
local function eRF() rfC=gco({"ShootCooldown","FireRate","Cooldown","cooldown","FireDelay"}) for _,e in pairs(rfC) do pcall(function() e.tbl[e.key]=0 end) end end
local function dRF() for _,e in pairs(rfC) do pcall(function() e.tbl[e.key]=e.original end) end rfC={} end
local function eAW() awC=gco({"IsAutomatic","AutoFire","Automatic","isAutomatic","FullAuto"}) for _,e in pairs(awC) do pcall(function() e.tbl[e.key]=true end) end end
local function dAW() for _,e in pairs(awC) do pcall(function() e.tbl[e.key]=false end) end awC={} end
local function eIS() isC=gco({"ScopeTime","AimTime","AimDelay","ScopeDelay","ZoomTime","ADSTime"}) for _,e in pairs(isC) do pcall(function() e.tbl[e.key]=0 end) end end
local function dIS() for _,e in pairs(isC) do pcall(function() e.tbl[e.key]=e.original end) end isC={} end

-- AlwaysBackstab
local bsC,bsConn={},nil
local function eBS() bsC=gco({"IsBackstab","BackstabAngle","BackstabMultiplier","CanBackstab","BackstabEnabled"}) for _,e in pairs(bsC) do pcall(function() if type(e.tbl[e.key])=="boolean" then e.tbl[e.key]=true elseif type(e.tbl[e.key])=="number" then e.tbl[e.key]=360 end end) end bsConn=RunService.Heartbeat:Connect(function() if not state.AlwaysBackstab then return end for _,e in pairs(bsC) do pcall(function() if type(e.tbl[e.key])=="boolean" then e.tbl[e.key]=true elseif type(e.tbl[e.key])=="number" then e.tbl[e.key]=360 end end) end end) end
local function dBS() if bsConn then bsConn:Disconnect() bsConn=nil end for _,e in pairs(bsC) do pcall(function() e.tbl[e.key]=e.original end) end bsC={} end

-- RemoveKillers
local rkT={}
local function eRK() for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") then local n=o.Name:lower() if n:find("kill") or n:find("void") or n:find("death") or n:find("lava") then if o.CanTouch then table.insert(rkT,{part=o,canTouch=o.CanTouch}) o.CanTouch=false end end end end end
local function dRK() for _,d in pairs(rkT) do pcall(function() d.part.CanTouch=d.canTouch end) end rkT={} end

-- NoFireDamage
local fdC,fdConn={},nil
local function eFD() fdC=gco({"FireDamage","BurnDamage","FlameDamage","HeatDamage","IgniteDamage"}) for _,e in pairs(fdC) do pcall(function() e.tbl[e.key]=0 end) end fdConn=RunService.Heartbeat:Connect(function() if not state.NoFireDamage then return end local c=plr.Character if not c then return end for _,o in pairs(c:GetDescendants()) do if o:IsA("Fire") or o:IsA("Smoke") then o.Enabled=false end end end) end
local function dFD() if fdConn then fdConn:Disconnect() fdConn=nil end for _,e in pairs(fdC) do pcall(function() e.tbl[e.key]=e.original end) end fdC={} end

-- AntiFreeze
local afzConn=nil
local function eAFZ() afzConn=RunService.Heartbeat:Connect(function() if not state.AntiFreeze then return end local c=plr.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if not h then return end if h.WalkSpeed~=cfg.WalkSpeed then h.WalkSpeed=cfg.WalkSpeed end if h.JumpPower~=cfg.JumpPower then h.JumpPower=cfg.JumpPower end local r=c:FindFirstChild("HumanoidRootPart") if r and r.Anchored then r.Anchored=false end end) end
local function dAFZ() if afzConn then afzConn:Disconnect() afzConn=nil end end

plr.CharacterAdded:Connect(function() task.wait(0.5) if state.Fly then dFly() task.wait(0.1) eFly() end end)

-- ESP
local espO={}
local function nd(t,p) local o=Drawing.new(t) for k,v in pairs(p) do o[k]=v end return o end
local function cESP(pl) if espO[pl] then return end if not Drawing then return end espO[pl]={box=nd("Square",{Visible=false,Color=Color3.fromRGB(0,255,200),Thickness=1.5,Filled=false,Transparency=1}),boxFill=nd("Square",{Visible=false,Color=Color3.fromRGB(0,200,150),Thickness=1,Filled=true,Transparency=0.9}),name=nd("Text",{Visible=false,Color=Color3.fromRGB(255,255,255),Size=13,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2}),healthBg=nd("Square",{Visible=false,Color=Color3.fromRGB(0,0,0),Thickness=1,Filled=true,Transparency=0.5}),healthBar=nd("Square",{Visible=false,Color=Color3.fromRGB(0,255,180),Thickness=1,Filled=true,Transparency=1}),distance=nd("Text",{Visible=false,Color=Color3.fromRGB(180,255,240),Size=11,Center=true,Outline=true,OutlineColor=Color3.fromRGB(0,0,0),Font=2})} end
local function rESP(p) if not espO[p] then return end for _,o in pairs(espO[p]) do o:Remove() end espO[p]=nil end
local function hESP(p) if not espO[p] then return end for _,o in pairs(espO[p]) do o.Visible=false end end
local function gcb(ch) local r=ch:FindFirstChild("HumanoidRootPart") if not r then return nil end local mnX,mnY,mxX,mxY=math.huge,math.huge,-math.huge,-math.huge local cnt=0 for _,off in pairs({Vector3.new(2,3,2),Vector3.new(-2,3,-2),Vector3.new(2,3,-2),Vector3.new(-2,3,2),Vector3.new(2,-3,2),Vector3.new(-2,-3,-2),Vector3.new(2,-3,-2),Vector3.new(-2,-3,2)}) do local sp,on=camera:WorldToViewportPoint(r.Position+off) if on then cnt+=1 mnX=math.min(mnX,sp.X) mnY=math.min(mnY,sp.Y) mxX=math.max(mxX,sp.X) mxY=math.max(mxY,sp.Y) end end if cnt==0 then return nil end return{x=mnX,y=mnY,w=mxX-mnX,h=mxY-mnY,cx=(mnX+mxX)/2} end
local function uESP(pl) local e=espO[pl] if not e then return end local ch=pl.Character if not ch then hESP(pl) return end local r=ch:FindFirstChild("HumanoidRootPart") local h=ch:FindFirstChild("Humanoid") if not r or not h then hESP(pl) return end local mc=plr.Character local mr=mc and mc:FindFirstChild("HumanoidRootPart") if not mr then hESP(pl) return end local d=(r.Position-mr.Position).Magnitude if d>1000 then hESP(pl) return end local b=gcb(ch) if not b then hESP(pl) return end e.box.Position=Vector2.new(b.x,b.y) e.box.Size=Vector2.new(b.w,b.h) e.box.Visible=true e.boxFill.Position=Vector2.new(b.x,b.y) e.boxFill.Size=Vector2.new(b.w,b.h) e.boxFill.Visible=true e.name.Text=pl.DisplayName e.name.Position=Vector2.new(b.cx,b.y-16) e.name.Visible=true e.distance.Text=math.floor(d).."m" e.distance.Position=Vector2.new(b.cx,b.y+b.h+2) e.distance.Visible=true local hp=math.clamp(h.Health/math.max(h.MaxHealth,1),0,1) local bh=b.h*hp e.healthBar.Color=Color3.new(math.clamp(2*(1-hp),0,1),math.clamp(2*hp,0,1),0) e.healthBg.Position=Vector2.new(b.x-7,b.y) e.healthBg.Size=Vector2.new(4,b.h) e.healthBg.Visible=true e.healthBar.Position=Vector2.new(b.x-7,b.y+b.h-bh) e.healthBar.Size=Vector2.new(4,bh) e.healthBar.Visible=true end
local function opa(p) if p==plr then return end cESP(p) p.CharacterAdded:Connect(function() task.wait(0.5) if not espO[p] then cESP(p) end end) end
Players.PlayerAdded:Connect(opa) Players.PlayerRemoving:Connect(rESP) for _,p in pairs(Players:GetPlayers()) do opa(p) end
RunService.RenderStepped:Connect(function() for _,p in pairs(Players:GetPlayers()) do if p~=plr then if state.ESP then uESP(p) else hESP(p) end end end end)

-- AutoDrop
local drops,lRun={},0
workspace.ChildAdded:Connect(function(o) if o.Name=="_drop" then drops[o]=true end end)
workspace.ChildRemoved:Connect(function(o) drops[o]=nil end)
for _,o in pairs(workspace:GetChildren()) do if o.Name=="_drop" then drops[o]=true end end
RunService.Heartbeat:Connect(function() if not state.AutoDrop then return end local n=tick() if(n-lRun)<0.05 then return end lRun=n local c=plr.Character if not c then return end local r=c:FindFirstChild("HumanoidRootPart") if not r then return end for o in pairs(drops) do if o.Parent then firetouchinterest(r,o,0) firetouchinterest(r,o,1) end end end)

-- UI
local C={bg=Color3.fromRGB(8,8,12),bg2=Color3.fromRGB(14,14,20),bg3=Color3.fromRGB(20,20,30),neon=Color3.fromRGB(0,255,200),neon2=Color3.fromRGB(0,180,140),border=Color3.fromRGB(30,60,50),text=Color3.fromRGB(210,255,245),dim=Color3.fromRGB(90,130,120),white=Color3.fromRGB(255,255,255),red=Color3.fromRGB(255,60,60)}
local sg=Instance.new("ScreenGui") sg.Name="🐉CyberDragon🐉" sg.ResetOnSpawn=false sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.Parent=plr:WaitForChild("PlayerGui")
local root=Instance.new("Frame") root.Size=UDim2.new(0,540,0,380) root.Position=UDim2.new(0.5,-270,0.5,-190) root.BackgroundColor3=C.bg root.BorderSizePixel=0 root.BackgroundTransparency=1 root.ClipsDescendants=true root.Parent=sg Instance.new("UICorner",root).CornerRadius=UDim.new(0,8) local rStr=Instance.new("UIStroke",root) rStr.Color=C.neon rStr.Thickness=1.5 rStr.Transparency=1
local tBar=Instance.new("Frame") tBar.Size=UDim2.new(1,0,0,36) tBar.BackgroundColor3=C.bg2 tBar.BorderSizePixel=0 tBar.Parent=root Instance.new("UICorner",tBar).CornerRadius=UDim.new(0,8) local tbF=Instance.new("Frame") tbF.Size=UDim2.new(1,0,0.5,0) tbF.Position=UDim2.new(0,0,0.5,0) tbF.BackgroundColor3=C.bg2 tbF.BorderSizePixel=0 tbF.Parent=tBar
local tAcc=Instance.new("Frame") tAcc.Size=UDim2.new(0,3,1,-10) tAcc.Position=UDim2.new(0,8,0,5) tAcc.BackgroundColor3=C.neon tAcc.BorderSizePixel=0 tAcc.Parent=tBar Instance.new("UICorner",tAcc).CornerRadius=UDim.new(1,0)
local tLbl=Instance.new("TextLabel") tLbl.Size=UDim2.new(1,-80,1,0) tLbl.Position=UDim2.new(0,18,0,0) tLbl.BackgroundTransparency=1 tLbl.Text="◈ CYBER CHEAT" tLbl.TextColor3=C.neon tLbl.TextSize=12 tLbl.Font=Enum.Font.GothamBold tLbl.TextXAlignment=Enum.TextXAlignment.Left tLbl.Parent=tBar
local cBtn=Instance.new("TextButton") cBtn.Size=UDim2.new(0,22,0,22) cBtn.Position=UDim2.new(1,-28,0.5,-11) cBtn.BackgroundColor3=C.bg3 cBtn.BorderSizePixel=0 cBtn.Text="×" cBtn.TextColor3=C.neon cBtn.TextSize=14 cBtn.Font=Enum.Font.GothamBold cBtn.Parent=tBar Instance.new("UICorner",cBtn).CornerRadius=UDim.new(0,4) Instance.new("UIStroke",cBtn).Color=C.neon
local mini=false cBtn.MouseButton1Click:Connect(function() mini=not mini TweenService:Create(root,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=mini and UDim2.new(0,540,0,36) or UDim2.new(0,540,0,380)}):Play() cBtn.Text=mini and "+" or "×" end)
local hid=false UserInputService.InputBegan:Connect(function(inp,gpe) if gpe then return end if inp.KeyCode==Enum.KeyCode.RightShift then hid=not hid if hid then TweenService:Create(root,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,-560,0.5,-190),BackgroundTransparency=1}):Play() TweenService:Create(rStr,TweenInfo.new(0.25),{Transparency=1}):Play() task.delay(0.25,function() root.Visible=false end) else root.Visible=true root.Position=UDim2.new(0,-560,0.5,-190) TweenService:Create(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-270,0.5,-190),BackgroundTransparency=0}):Play() TweenService:Create(rStr,TweenInfo.new(0.3),{Transparency=0}):Play() end end end)
local tabBar=Instance.new("Frame") tabBar.Size=UDim2.new(1,-16,0,28) tabBar.Position=UDim2.new(0,8,0,42) tabBar.BackgroundColor3=C.bg3 tabBar.BorderSizePixel=0 tabBar.Parent=root Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",tabBar).Color=C.border local tbl=Instance.new("UIListLayout",tabBar) tbl.FillDirection=Enum.FillDirection.Horizontal tbl.SortOrder=Enum.SortOrder.LayoutOrder tbl.Padding=UDim.new(0,2) local tbp=Instance.new("UIPadding",tabBar) tbp.PaddingLeft=UDim.new(0,3) tbp.PaddingRight=UDim.new(0,3) tbp.PaddingTop=UDim.new(0,3) tbp.PaddingBottom=UDim.new(0,3)
local cArea=Instance.new("Frame") cArea.Size=UDim2.new(1,-16,1,-82) cArea.Position=UDim2.new(0,8,0,76) cArea.BackgroundTransparency=1 cArea.BorderSizePixel=0 cArea.Parent=root
local pages={} local curTab=nil
local function swTab(n) if curTab==n then return end curTab=n for pN,pD in pairs(pages) do local a=(pN==n) pD.page.Visible=a TweenService:Create(pD.tab,TweenInfo.new(0.15),{BackgroundColor3=a and C.neon2 or C.bg3}):Play() pD.tabLbl.TextColor3=a and C.bg or C.dim end end
local function mkTab(n,o) local t=Instance.new("TextButton") t.Size=UDim2.new(0,0,1,0) t.AutomaticSize=Enum.AutomaticSize.X t.BackgroundColor3=C.bg3 t.BorderSizePixel=0 t.LayoutOrder=o t.Text="" t.Parent=tabBar Instance.new("UICorner",t).CornerRadius=UDim.new(0,4) local tl=Instance.new("TextLabel") tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1 tl.Text=" "..n.." " tl.TextColor3=C.dim tl.TextSize=11 tl.Font=Enum.Font.GothamBold tl.Parent=t local pg=Instance.new("Frame") pg.Size=UDim2.new(1,0,1,0) pg.BackgroundTransparency=1 pg.Visible=false pg.Parent=cArea local lS=Instance.new("ScrollingFrame") lS.Size=UDim2.new(0.5,-3,1,0) lS.BackgroundTransparency=1 lS.BorderSizePixel=0 lS.ScrollBarThickness=2 lS.ScrollBarImageColor3=C.neon lS.CanvasSize=UDim2.new(0,0,0,0) lS.AutomaticCanvasSize=Enum.AutomaticSize.Y lS.Parent=pg local ll=Instance.new("UIListLayout",lS) ll.SortOrder=Enum.SortOrder.LayoutOrder ll.Padding=UDim.new(0,4) local lp=Instance.new("UIPadding",lS) lp.PaddingRight=UDim.new(0,3) lp.PaddingBottom=UDim.new(0,4) local rS=Instance.new("ScrollingFrame") rS.Size=UDim2.new(0.5,-3,1,0) rS.Position=UDim2.new(0.5,3,0,0) rS.BackgroundTransparency=1 rS.BorderSizePixel=0 rS.ScrollBarThickness=2 rS.ScrollBarImageColor3=C.neon rS.CanvasSize=UDim2.new(0,0,0,0) rS.AutomaticCanvasSize=Enum.AutomaticSize.Y rS.Parent=pg local rl=Instance.new("UIListLayout",rS) rl.SortOrder=Enum.SortOrder.LayoutOrder rl.Padding=UDim.new(0,4) local rp=Instance.new("UIPadding",rS) rp.PaddingLeft=UDim.new(0,3) rp.PaddingBottom=UDim.new(0,4) pages[n]={tab=t,tabLbl=tl,page=pg,left=lS,right=rS} t.MouseButton1Click:Connect(function() swTab(n) end) return lS,rS end
local function mkH(p,t,o) local h=Instance.new("TextLabel") h.Size=UDim2.new(1,0,0,18) h.BackgroundTransparency=1 h.Text="▸ "..t h.TextColor3=C.neon h.TextSize=10 h.Font=Enum.Font.GothamBold h.TextXAlignment=Enum.TextXAlignment.Left h.LayoutOrder=o h.Parent=p end
local function mkT(p,lt,k,o,onE,onD) local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=C.bg2 row.BorderSizePixel=0 row.LayoutOrder=o row.Parent=p Instance.new("UICorner",row).CornerRadius=UDim.new(0,6) local rs=Instance.new("UIStroke",row) rs.Color=C.border rs.Thickness=1 local ac=Instance.new("Frame") ac.Size=UDim2.new(0,2,1,-8) ac.Position=UDim2.new(0,0,0,4) ac.BackgroundColor3=C.neon ac.BackgroundTransparency=0.6 ac.BorderSizePixel=0 ac.Parent=row Instance.new("UICorner",ac).CornerRadius=UDim.new(1,0) local lb=Instance.new("TextLabel") lb.Size=UDim2.new(1,-52,1,0) lb.Position=UDim2.new(0,9,0,0) lb.BackgroundTransparency=1 lb.Text=lt lb.TextColor3=C.text lb.TextSize=11 lb.Font=Enum.Font.GothamBold lb.TextXAlignment=Enum.TextXAlignment.Left lb.Parent=row local pb=Instance.new("Frame") pb.Size=UDim2.new(0,34,0,18) pb.Position=UDim2.new(1,-40,0.5,-9) pb.BackgroundColor3=C.bg3 pb.BorderSizePixel=0 pb.Parent=row Instance.new("UICorner",pb).CornerRadius=UDim.new(1,0) local ps=Instance.new("UIStroke",pb) ps.Color=C.neon ps.Thickness=1 ps.Transparency=0.7 local kn=Instance.new("Frame") kn.Size=UDim2.new(0,12,0,12) kn.Position=UDim2.new(0,3,0.5,-6) kn.BackgroundColor3=C.dim kn.BorderSizePixel=0 kn.Parent=pb Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0) local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.Parent=row btn.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(18,22,28)}):Play() end) btn.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.bg2}):Play() end) btn.MouseButton1Down:Connect(function() TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(0,25,20)}):Play() end) btn.MouseButton1Up:Connect(function() TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(18,22,28)}):Play() end) local function uv(on) TweenService:Create(pb,TweenInfo.new(0.18),{BackgroundColor3=on and Color3.fromRGB(0,35,28) or C.bg3}):Play() TweenService:Create(kn,TweenInfo.new(0.18,Enum.EasingStyle.Back),{Position=on and UDim2.new(0,19,0.5,-6) or UDim2.new(0,3,0.5,-6),BackgroundColor3=on and C.neon or C.dim}):Play() ps.Transparency=on and 0 or 0.7 ac.BackgroundTransparency=on and 0 or 0.6 lb.TextColor3=on and C.neon or C.text TweenService:Create(rs,TweenInfo.new(0.18),{Color=on and C.neon or C.border}):Play() end btn.MouseButton1Click:Connect(function() state[k]=not state[k] uv(state[k]) if state[k] then if onE then onE() end else if onD then onD() end end end) end
local function mkB(p,lt,o,oc) local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,0,0,30) btn.BackgroundColor3=C.bg2 btn.BorderSizePixel=0 btn.Text=lt btn.TextColor3=C.neon btn.TextSize=10 btn.Font=Enum.Font.GothamBold btn.LayoutOrder=o btn.Parent=p Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6) local bs=Instance.new("UIStroke",btn) bs.Color=C.neon bs.Thickness=1 bs.Transparency=0.5 btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(0,28,22),TextColor3=C.white}):Play() TweenService:Create(bs,TweenInfo.new(0.12),{Transparency=0}):Play() end) btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.bg2,TextColor3=C.neon}):Play() TweenService:Create(bs,TweenInfo.new(0.12),{Transparency=0.5}):Play() end) btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.08),{Size=UDim2.new(1,-4,0,28)}):Play() end) btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,30)}):Play() end) btn.MouseButton1Click:Connect(function() oc(btn,bs) end) end
local function mkP(p,o) local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=C.bg2 row.BorderSizePixel=0 row.LayoutOrder=o row.Parent=p Instance.new("UICorner",row).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",row).Color=C.border local opts={"Behind","Above","Under"} local bw=1/#opts local pbs={} for i,opt in ipairs(opts) do local pb=Instance.new("TextButton") pb.Size=UDim2.new(bw,-3,1,-6) pb.Position=UDim2.new((i-1)*bw,i==1 and 3 or 2,0,3) pb.BackgroundColor3=opt==farmPos and C.neon2 or C.bg3 pb.BorderSizePixel=0 pb.Text=opt pb.TextColor3=opt==farmPos and C.bg or C.dim pb.TextSize=10 pb.Font=Enum.Font.GothamBold pb.Parent=row Instance.new("UICorner",pb).CornerRadius=UDim.new(0,4) pbs[opt]=pb pb.MouseButton1Click:Connect(function() farmPos=opt for _,op in pairs(opts) do TweenService:Create(pbs[op],TweenInfo.new(0.15),{BackgroundColor3=op==opt and C.neon2 or C.bg3}):Play() pbs[op].TextColor3=op==opt and C.bg or C.dim end end) end end
local function mkS(p,lt,o,mn,mx,dv,sk,oc) local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,50) row.BackgroundColor3=C.bg2 row.BorderSizePixel=0 row.LayoutOrder=o row.Parent=p Instance.new("UICorner",row).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",row).Color=C.border local lb=Instance.new("TextLabel") lb.Size=UDim2.new(1,-50,0,16) lb.Position=UDim2.new(0,9,0,5) lb.BackgroundTransparency=1 lb.Text=lt lb.TextColor3=C.text lb.TextSize=11 lb.Font=Enum.Font.GothamBold lb.TextXAlignment=Enum.TextXAlignment.Left lb.Parent=row local vl=Instance.new("TextLabel") vl.Size=UDim2.new(0,44,0,16) vl.Position=UDim2.new(1,-50,0,5) vl.BackgroundTransparency=1 vl.Text=tostring(dv) vl.TextColor3=C.neon vl.TextSize=10 vl.Font=Enum.Font.GothamBold vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=row local tr=Instance.new("Frame") tr.Size=UDim2.new(1,-18,0,4) tr.Position=UDim2.new(0,9,0,30) tr.BackgroundColor3=C.bg3 tr.BorderSizePixel=0 tr.Parent=row Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0) local fl=Instance.new("Frame") fl.Size=UDim2.new((dv-mn)/(mx-mn),0,1,0) fl.BackgroundColor3=C.neon fl.BorderSizePixel=0 fl.Parent=tr Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0) local hd=Instance.new("Frame") hd.Size=UDim2.new(0,10,0,10) hd.Position=UDim2.new((dv-mn)/(mx-mn),-5,0.5,-5) hd.BackgroundColor3=C.neon hd.BorderSizePixel=0 hd.Parent=tr Instance.new("UICorner",hd).CornerRadius=UDim.new(1,0) local drag=false local sb=Instance.new("TextButton") sb.Size=UDim2.new(1,0,0,20) sb.Position=UDim2.new(0,0,0,24) sb.BackgroundTransparency=1 sb.Text="" sb.Parent=row local function us(x) local tp=tr.AbsolutePosition.X local ts=tr.AbsoluteSize.X local r=math.clamp((x-tp)/ts,0,1) local v=math.floor(mn+r*(mx-mn)) cfg[sk]=v vl.Text=tostring(v) fl.Size=UDim2.new(r,0,1,0) hd.Position=UDim2.new(r,-5,0.5,-5) if oc then oc(v) end end sb.MouseButton1Down:Connect(function() drag=true us(UserInputService:GetMouseLocation().X) end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end) UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then us(i.Position.X) end end) end

-- Build Tabs
local cL,cR=mkTab("Combat",1) mkH(cL,"Weapon",1) mkT(cL,"No Recoil","NoRecoil",2,function() aa("ShootRecoil",0) end,function() ra("ShootRecoil") end) mkT(cL,"No Spread","NoSpread",3,function() aa("ShootSpread",0) aa("ShootCooldown",0) end,function() ra("ShootSpread") ra("ShootCooldown") end) mkT(cL,"Rapid Fire","RapidFire",4,eRF,dRF) mkT(cL,"Auto Weapon","AutoWeapon",5,eAW,dAW) mkT(cL,"Instant Scope","InstantScope",6,eIS,dIS) mkT(cL,"Always Backstab","AlwaysBackstab",7,eBS,dBS) mkT(cL,"Anti Katana","AntiKatana",8,eAK,dAK)
mkH(cR,"Silent Aim",1) mkB(cR,"⚡ Load Bolts Silent Aim",2,function(btn,bs) btn.Text="⏳ Loading..." btn.TextColor3=C.dim local ok=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ThunderScriptSolutions/Misc/refs/heads/main/RivalsSilentAim"))() end) if ok then btn.Text="✓ Loaded!" btn.TextColor3=Color3.fromRGB(0,255,100) bs.Color=Color3.fromRGB(0,255,100) else btn.Text="✗ Failed" btn.TextColor3=C.red bs.Color=C.red end end) mkH(cR,"Utility",4) mkT(cR,"Auto Drop Collector","AutoDrop",5,nil,nil) mkH(cR,"Auto Farm",6) mkT(cR,"Auto Farm","AutoFarm",7,eAF,dAF) mkP(cR,8)
local mL,mR=mkTab("Movement",2) mkH(mL,"Actions",1) mkT(mL,"Jump Bug","JumpBug",2,eJB,dJB) mkT(mL,"Auto Strafe","AutoStrafe",3,eST,dST) mkH(mL,"Fly",4) mkT(mL,"Fly","Fly",5,eFly,dFly) mkH(mL,"Misc",6) mkT(mL,"Noclip","Noclip",7,eNC,dNC) mkT(mL,"Anti Aim","AntiAim",8,eAA,dAA) mkH(mL,"Strafe",9) mkS(mL,"Strafe Intensity",10,1,100,50,"StrafeIntensity",nil)
mkH(mR,"Speed & Jump",1) mkS(mR,"Walk Speed",2,1,150,16,"WalkSpeed",function(v) local c=plr.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=v end end) mkS(mR,"Jump Power",3,1,200,50,"JumpPower",function(v) local c=plr.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=v end end) mkH(mR,"Fly Speed",5) mkS(mR,"Fly Speed",6,0,1000,50,"FlySpeed",nil)
local vL,vR=mkTab("Visuals",3) mkH(vL,"Players",1) mkT(vL,"ESP","ESP",2,nil,nil) mkT(vL,"Third Person","ThirdPerson",3,eTP,dTP)
local wL,wR=mkTab("World",4) mkH(wL,"Protection",1) mkT(wL,"Prevent OOB","NoBounds",2,eNB,dNB) mkT(wL,"Remove Killers","RemoveKillers",3,eRK,dRK) mkT(wL,"No Fire Damage","NoFireDamage",4,eFD,dFD) mkT(wL,"Anti Freeze","AntiFreeze",5,eAFZ,dAFZ)
swTab("Combat")
task.spawn(function() task.wait(0.1) TweenService:Create(root,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play() TweenService:Create(rStr,TweenInfo.new(0.4),{Transparency=0}):Play() end)
local drag2,dStart,dPos=false,nil,nil tBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag2=true dStart=i.Position dPos=root.Position end end) tBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag2=false end end) UserInputService.InputChanged:Connect(function(i) if drag2 and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dStart root.Position=UDim2.new(dPos.X.Scale,dPos.X.Offset+d.X,dPos.Y.Scale,dPos.Y.Offset+d.Y) end end)

-- Skin Changer
local SL={["Assault Rifle"]={"Default","AK-47","AUG","Tommy Gun","Boneclaw Rifle","Gingerbread AUG","AKEY-47","100K Visits","10 Billion Visits","Phoenix Rifle"},["Bow"]={"Default","Compound Bow","Raven Bow","Dream Bow","Bat Bow","Frostbite Bow","Beloved Bow","Balloon Bow","Glorious Bow","Key Bow","Arch Bow"},["Burst Rifle"]={"Default","Electro Burst","Aqua Burst","FAMAS","Spectral Burst","Pine Burst"},["Crossbow"]={"Default","Pixel Crossbow","Harpoon Crossbow","Violin Crossbow","Crossbone","Frostbite Crossbow","Arch Crossbow","Glorious Crossbow"},["Distortion"]={"Default","Plasma Distortion","Magma Distortion","Cyber Distortion","Expirement D15","Sleighstortion"},["Energy Rifle"]={"Default","Hacker Rifle","Hydro Rifle","Void Rifle","Soul Rifle","New Years Energy Rifle"},["Flamethrower"]={"Default","Pixel Flamethrower","Lamethrower","Glitterthrower","Jack O' Thrower","Snowblower","Keythrower","Rainbowthrower"},["Grenade Launcher"]={"Default","Swashbuckler","Uranium Launcher","Gearnade Launcher","Skull Grenade Launcher","Snowball Launcher"},["Gunblade"]={"Default","Hyper Gunblade","Crude Gunblade","Gunsaw","Boneblade","Elf's Gunblade"},["Minigun"]={"Default","Lasergun 3000","Pixel Minigun","Fighter Jet","Pumpkin Minigun","Wrapped Minigun"},["Paintball Gun"]={"Default","Slime Gun","Boba Gun","Ketchup Gun","Brain Gun","Snowball Gun"},["RPG"]={"Default","Nuke Launcher","Spaceship Launcher","Squid Launcher","Pumpkin Launcher","Firework Launcher"},["Shotgun"]={"Default","Balloon Shotgun","Hyper Shotgun","Cactus Shotgun","Broomstick","Wrapped Shotgun"},["Sniper"]={"Default","Pixel Sniper","Hyper Sniper","Event Horizon","Eyething Sniper","Gingerbread Sniper","Keyper","Glorious Sniper"},["Daggers"]={"Default","Aces","Paper Planes","Shurikens","Bat Daggers","Cookies","Crystal Daggers","Keynais"},["Energy Pistols"]={"Default","Void Pistols","Hydro Pistols","Soul Pistols","New Years Energy Pistols"},["Exogun"]={"Default","Singularity","Raygun","Repulsor","Exogourd","Midnight Festive Exogun"},["Flare Gun"]={"Default","Firework Gun","Dynamite Gun","Banana Flare","Vexed Flare Gun","Wrapped Flare Gun"},["Handgun"]={"Default","Blaster","Hand Gun","Gumball Handgun","Pumpkin Handgun","Gingerbread Handgun"},["Revolver"]={"Default","Desert Eagle","Sheriff","Peppergun","Boneclaw Revolver","Peppermint Sheriff"},["Shorty"]={"Default","Not So Shorty","Lovely Shorty","Balloon Shorty","Demon Shorty","Wrapped Shorty"},["Slingshot"]={"Default","Stick","Goal Post","Harp","Boneshot","Reindeer Slingshot","Lucky Horseshoe"},["Spray"]={"Default","Lovely Spray","Nail Gun","Bottle Spray","Boneclaw Spray","Pine Spray","Key Spray"},["Uzi"]={"Default","Water Uzi","Electro Uzi","Money Gun","Demon Uzi","Pine Uzi"},["Warper"]={"Default","Glitter Warper","Arcane Warper","Hotel Bell","Experiment W4","Frost Warper"},["Battle Axe"]={"Default","The Shred","Ban Axe","Cerulean Axe","Mimic Axe","Nordic Axe"},["Chainsaw"]={"Default","Blobsaw","Handsaws","Mega Drill","Buzzsaw","Festive Buzzsaw"},["Fists"]={"Default","Boxing Gloves","Brass Knuckles","Fists Of Hurt","Pumpkin Claws","Festive Fists"},["Katana"]={"Default","Saber","Lightning Bolt","Stellar Katana","Evil Trident","New Years Katana","Keytana","Arch Katana","Crystal Katana","Pixel Katana","Glorious Katana"},["Knife"]={"Default","Chancla","Karambit","Balisong","Machete","Candy Cane","Keylisong","Keyrambit","Caladbolg"},["Riot Shield"]={"Default","Door","Energy Shield","Masterpiece","Tombstone Shield","Sled"},["Scythe"]={"Default","Scythe of Death","Anchor","Sakura Scythe","Bat Scythe","Cryo Scythe","Crystal Scythe","Keythe","Bug Net","Arch Scythe"},["Trowel"]={"Default","Plastic Shovel","Garden Shovel","Paintbrush","Pumpkin Carver","Snow Shovel"},["Flashbang"]={"Default","Disco Ball","Camera","Lightbulb","Skullbang","Shining Star"},["Freeze Ray"]={"Default","Temporal Ray","Bubble Ray","Gum Ray","Spider Ray","Wrapped Freeze Ray"},["Grenade"]={"Default","Whoopee Cushion","Water Balloon","Dynamite","Soul Grenade","Jingle Grenade"},["Jump Pad"]={"Default","Trampoline","Bounce House","Shady Chicken Sandwich","Spider Web","Jolly Man"},["Medkit"]={"Default","Sandwich","Laptop","Medkitty","Bucket of Candy","Milk & Cookies","Box of Chocolates","Briefcase"},["Molotov"]={"Default","Coffee","Torch","Lava Lamp","Vexed Candle","Hot Coals","Arch Molotov"},["Satchel"]={"Default","Advanced Satchel","Notebook Satchel","Bag O' Money","Potion Satchel","Suspicious Gift"},["Smoke Grenade"]={"Default","Emoji Cloud","Balance","Hourglass","Eyeball","Snowglobe"},["Subspace Tripmine"]={"Default","Don't Press","Spring","DIY Tripmine","Trick or Treat","Dev In the Box","Pot O Keys"},["War Horn"]={"Default","Trumpet","Megaphone","Air Horn","Boneclaw Horn","Mammoth Horn"},["Warpstone"]={"Default","Cyber Warpstone","Teleport Disc","Electropunk Warpstone","Warpbone","Warpstar"},["Permafrost"]={"Default","Snowman Permafrost","Ice Permafrost","Glorious Permafrost"},["Maul"]={"Default","Ban Hammer","Ice Maul","Sleigh Maul","Glorious Maul"}}
local WL={
    -- Standard
    "None","Gold","Diamond","Midas Touch","Community Wrap","Blush Wrapping","Brain","Crystalliz","Damascus","Black Damascus",".exe wrap","Groove","Hollow Wrap","Hesper","Hyperdrive","Gingerbread","Neon Lights","Hologram Arena","Sunset","Pink Lemonade","Lovely Leopard","Dawn","Spectral","Danger","Termination","Moonstone","Starfall","Black Glass","Rift Wrap","Starblaze","Maganite","Watermelon","Reptile","Water","OranGG","A5","Cheese","Nova","Supernova","Glass","Mesh","Meat Wrap","Black Dark Wrap","Cardinal","Pixel Camo","Nauseite","Sensite","Urban Camo","Invisible","Arcane","Eruption","Borealis","Mainframe Wrap","Honeycomb Wrap","Virus","Patriot","PB&J Wrap","Scribble","Net","Solar","Festive Lights","Polaris","Woven","Heartfelt","Chromatic","Dark Matter",
    -- Developer Wraps
    "Dev Wrap","Admin Wrap","Staff Wrap","Shedletsky Wrap","Telamon Wrap","Badimo Wrap","Mango Wrap","Lava Wrap","Developer","Intern Wrap","Alpha Tester","Beta Tester","Founder Wrap","Creator Wrap","Scripter Wrap","Builder Wrap",
    -- Contract / Battle Pass Wraps
    "Season 1 Wrap","Season 2 Wrap","Season 3 Wrap","Season 4 Wrap","Season 5 Wrap","Season 6 Wrap","Contract Wrap I","Contract Wrap II","Contract Wrap III","Contract Wrap IV","Contract Wrap V","Bronze Contract","Silver Contract","Gold Contract","Platinum Contract","Diamond Contract","Elite Contract","Champion Contract","Prestige Wrap","Legacy Wrap","Veteran Wrap","Anniversary Wrap","Rivals Pass Wrap","Battle Wrap","Combat Wrap","Victory Wrap","Conquest Wrap","Warpath Wrap","Dominion Wrap","Ascendant Wrap",
}
local CHL={"None","Rivals Logo","Sword","Shield","Crown","Star","Heart","Skull","Key","Flame","Ice Crystal","Lightning","Cherry Blossom","Pumpkin","Snowflake","Rainbow","Diamond Charm","Ruby","Emerald","Sapphire","Amethyst","Gold Coin","Dice","Clover","Mushroom","Flower","Butterfly","Dragon","Phoenix","Wolf","Cat","Bunny","Frog","Duck","Jellyfish","Crab","Anchor","Compass","Lantern","Gem","Pearl","Feather","Rose","Sunflower","Cactus","Sword Charm","Dagger Charm","Axe Charm","Bow Charm","Shield Charm","Bomb","Rocket","UFO","Planet","Moon","Sun","Cloud","Rainbow Star","Halloween Charm","Christmas Charm","Easter Charm","Valentine Charm","New Year Charm","Summer Charm","Winter Charm","Common Charm","Uncommon Charm","Rare Charm","Epic Charm","Legendary Charm","Mythical Charm","Dev Charm","Admin Charm","Staff Charm","Founder Charm","Alpha Charm","Beta Charm","Season 1 Charm","Season 2 Charm","Season 3 Charm","Season 4 Charm","Season 5 Charm","Contract Charm","Victory Charm","Champion Charm","Prestige Charm"}
local FNL={"None","Explosion","Electrocution","Freeze","Fire","Shatter","Disintegrate","Implosion","Void","Lightning Strike","Black Hole","Nova","Pixel","Glitch","Vaporize","Crystallize","Incinerate","Consume","Collapse","Rupture","Detonate","Scatter","Evaporate","Obliterate","Erase","Dissolve","Combust","Implode","Warp","Phase","Drain","Inferno","Blizzard","Tsunami","Earthquake","Tornado","Thunder","Shadow","Light","Aether","Void Rift","Dark Matter","Plasma","Acid","Poison","Holy","Arcane Burst","Soul Shatter","Pixel Finish","Glitch Finish","Matrix Finish","Cyber Finish","Space Finish","Ocean Finish","Forest Finish","Desert Finish","Lava Finish","Dev Finisher","Admin Finisher","Staff Finisher","Season 1 Finisher","Season 2 Finisher","Season 3 Finisher","Season 4 Finisher","Season 5 Finisher","Contract Finisher","Champion Finisher","Prestige Finisher","Victory Finisher","Legend Finisher"}
local SF="AnihaSkinConfig.json"
_G.ED=_G.ED or {} for w in pairs(SL) do if not _G.ED[w] then _G.ED[w]={Skin="Default",Wrap="None"} end end
_G.GD=_G.GD or {Charm="None",Finisher="None"}
local function scSave() pcall(function() local d={weapons={},global=_G.GD} for w,i in pairs(_G.ED) do d.weapons[w]={Skin=i.Skin or "Default",Wrap=i.Wrap or "None"} end writefile(SF,HttpService:JSONEncode(d)) end) end
local function scLoad() local ok,r=pcall(function() if isfile(SF) then return HttpService:JSONDecode(readfile(SF)) end return nil end) if ok and r then local wt=r.weapons or r for w,i in pairs(wt) do if _G.ED[w] then _G.ED[w].Skin=i.Skin or "Default" _G.ED[w].Wrap=i.Wrap or "None" end end if r.global then _G.GD.Charm=r.global.Charm or "None" _G.GD.Finisher=r.global.Finisher or "None" end return true end return false end
scLoad()
local function rreq(m) local mn=tostring(m) local si=setthreadidentity or set_thread_identity or(syn and syn.set_thread_identity) local gi=getthreadidentity or get_thread_identity or(syn and syn.get_thread_identity) if shared[mn] or _G[mn] then return shared[mn] or _G[mn] end local oi pcall(function() if gi and si then oi=gi() si(2) end end) local ok,res=pcall(require,m) if not ok and getgenv and getgenv().require then local ok2,r2=pcall(getgenv().require,m) if ok2 then ok,res=true,r2 end end pcall(function() if si and oi then si(oi) end end) if ok then return res end for _,api in pairs({getgc,getregistry,debug and debug.getregistry}) do if type(api)=="function" then local ok3,obs=pcall(api,true) if ok3 and type(obs)=="table" then for _,v in pairs(obs) do if type(v)=="table" then if mn:find("CosmeticLibrary") and(v.Cosmetics or rawget(v,"Cosmetics")) and(type(v.Equip)=="function" or type(v.GetSkins)=="function") then return v end if mn:find("ItemLibrary") and(v.ViewModels or rawget(v,"ViewModels")) then return v end if mn:find("ClientViewModel") and(v.new or rawget(v,"new")) and(v.GetWrap or rawget(v,"GetWrap")) then return v end if mn:find("ReplicatedClass") and type(v.ToEnum)=="function" then return v end end end end end end return nil end
task.spawn(function()
    task.wait(1.5)
    local SCos=rreq(ReplicatedStorage:WaitForChild("Modules",20):WaitForChild("CosmeticLibrary",20))
    local SIt=rreq(ReplicatedStorage.Modules:WaitForChild("ItemLibrary",20))
    local SRC=rreq(ReplicatedStorage.Modules:WaitForChild("ReplicatedClass",20))
    local SMod=plr.PlayerScripts:WaitForChild("Modules",15)
    local SVM=rreq(SMod:WaitForChild("ClientReplicatedClasses",15):WaitForChild("ClientFighter",15):WaitForChild("ClientItem",15):WaitForChild("ClientViewModel",15))
    if not SCos or not SIt or not SVM or not SRC then warn("[SC] Modules failed") return end

    -- Search all sub-tables of SCos for a cosmetic by name
    local function gcd(n,t)
        local base
        -- Try direct Cosmetics table first
        if SCos.Cosmetics then base=SCos.Cosmetics[n] end
        -- Fallback: search every sub-table (Charms, Finishers, Skins, etc.)
        if not base and type(SCos)=="table" then
            for _,tbl in pairs(SCos) do
                if type(tbl)=="table" and rawget(tbl,n) then base=tbl[n] break end
            end
        end
        if not base then return nil end
        local d=table.clone(base) d.Name=n d.Type=t return d
    end

    -- Try every known equip signature for charms/finishers
    local function tryEquipGlobal(typeName, itemName)
        local val = itemName ~= "None" and itemName or nil
        local cd = val and gcd(val, typeName)
        -- Try known signatures in order
        pcall(function() SCos.Equip(nil, typeName, val) end)
        pcall(function() SCos.Equip(typeName, val) end)
        if typeName=="Charm" then
            pcall(function() SCos.EquipCharm(val) end)
            pcall(function() SCos.SetCharm(val) end)
            pcall(function() SCos.SetCharm(cd) end)
        elseif typeName=="Finisher" then
            pcall(function() SCos.EquipFinisher(val) end)
            pcall(function() SCos.SetFinisher(val) end)
            pcall(function() SCos.SetFinisher(cd) end)
        end
        -- GC scan: find any function that takes a charm/finisher and call it
        for _,v in pairs(getgc(true)) do
            if type(v)=="function" then
                local n=tostring(v):lower()
                if typeName=="Charm" and (n:find("charm") or n:find("equip")) then
                    pcall(v,val) pcall(v,cd)
                elseif typeName=="Finisher" and (n:find("finish") or n:find("equip")) then
                    pcall(v,val) pcall(v,cd)
                end
            end
        end
    end

    local ogW=SVM.GetWrap SVM.GetWrap=function(self)
        local ok,r=pcall(function()
            local wn=self.ClientItem and self.ClientItem.Name
            if wn and _G.ED[wn] then
                local w=_G.ED[wn].Wrap
                if w and w~="None" then return gcd(w,"Wrap") end
            end
        end)
        if ok and r then return r end
        return ogW(self)
    end

    -- Hook GetCharm and GetFinisher the same way
    if SVM.GetCharm then
        local ogC=SVM.GetCharm SVM.GetCharm=function(self)
            if _G.GD.Charm~="None" then
                local cd=gcd(_G.GD.Charm,"Charm") if cd then return cd end
            end
            return ogC(self)
        end
    end
    if SVM.GetFinisher then
        local ogF=SVM.GetFinisher SVM.GetFinisher=function(self)
            if _G.GD.Finisher~="None" then
                local cd=gcd(_G.GD.Finisher,"Finisher") if cd then return cd end
            end
            return ogF(self)
        end
    end

    local ogN=SVM.new SVM.new=function(rd,ci)
        pcall(function()
            if not ci then return end
            local wn=ci.Name if not wn then return end
            local cf=rawget(ci,"ClientFighter") or ci.ClientFighter
            if not cf or cf.Player~=plr then return end
            local dk=SRC:ToEnum("Data")
            local skinKey=SRC:ToEnum("Skin")
            local nameKey=SRC:ToEnum("Name")
            local charmKey=pcall(function() return SRC:ToEnum("Charm") end) and SRC:ToEnum("Charm")
            local finKey=pcall(function() return SRC:ToEnum("Finisher") end) and SRC:ToEnum("Finisher")
            rd[dk]=rd[dk] or {}
            -- Inject skin
            if _G.ED[wn] then
                local sk=_G.ED[wn].Skin
                if sk and sk~="Default" then
                    local cd=gcd(sk,"Skin")
                    if cd then rd[dk][skinKey]=cd rd[dk][nameKey]=sk end
                end
            end
            -- Inject charm
            if charmKey and _G.GD.Charm~="None" then
                local cd=gcd(_G.GD.Charm,"Charm")
                if cd then rd[dk][charmKey]=cd end
            end
            -- Inject finisher
            if finKey and _G.GD.Finisher~="None" then
                local cd=gcd(_G.GD.Finisher,"Finisher")
                if cd then rd[dk][finKey]=cd end
            end
        end)
        local vm=ogN(rd,ci)
        task.delay(0.1,function()
            pcall(function() if vm and vm._UpdateWrap then vm:_UpdateWrap() end end)
            pcall(function() if vm and vm._UpdateCharm then vm:_UpdateCharm() end end)
            pcall(function() if vm and vm._UpdateFinisher then vm:_UpdateFinisher() end end)
        end)
        return vm
    end
    local scG=Instance.new("ScreenGui",plr.PlayerGui) scG.ResetOnSpawn=false scG.Name="AnihaSkinChanger"
    local scM=Instance.new("Frame",scG) scM.Size=UDim2.new(0,950,0,660) scM.Position=UDim2.new(0.5,-475,0.5,-330) scM.BackgroundColor3=Color3.fromRGB(20,20,24) scM.BorderSizePixel=0 scM.Visible=false
    local scT=Instance.new("TextLabel",scM) scT.Size=UDim2.new(1,0,0,50) scT.BackgroundColor3=Color3.fromRGB(30,30,35) scT.Text="◈ Skin Changer  •  [ K ] Toggle" scT.TextColor3=Color3.fromRGB(0,255,200) scT.Font=Enum.Font.GothamBlack scT.TextSize=20 scT.BorderSizePixel=0 scT.Active=true
    local scL=Instance.new("Frame",scM) scL.Size=UDim2.new(0,280,1,-110) scL.Position=UDim2.new(0,15,0,60) scL.BackgroundColor3=Color3.fromRGB(14,14,20) scL.BorderSizePixel=0
    local scSr=Instance.new("TextBox",scL) scSr.Size=UDim2.new(1,-20,0,35) scSr.Position=UDim2.new(0,10,0,10) scSr.PlaceholderText="Search weapon..." scSr.BackgroundColor3=Color3.fromRGB(20,20,30) scSr.TextColor3=Color3.new(1,1,1) scSr.Font=Enum.Font.Gotham scSr.TextSize=14 scSr.BorderSizePixel=0 scSr.ClearTextOnFocus=false scSr.Text=""
    local scWS=Instance.new("ScrollingFrame",scL) scWS.Size=UDim2.new(1,-20,1,-55) scWS.Position=UDim2.new(0,10,0,55) scWS.BackgroundTransparency=1 scWS.ScrollBarThickness=4 scWS.BorderSizePixel=0 local scWL=Instance.new("UIListLayout",scWS) scWL.Padding=UDim.new(0,5) scWL.SortOrder=Enum.SortOrder.Name
    local scR=Instance.new("Frame",scM) scR.Size=UDim2.new(1,-310,1,-110) scR.Position=UDim2.new(0,305,0,60) scR.BackgroundColor3=Color3.fromRGB(14,14,20) scR.BorderSizePixel=0
    local scSL=Instance.new("TextLabel",scR) scSL.Size=UDim2.new(1,-20,0,30) scSL.Position=UDim2.new(0,10,0,8) scSL.BackgroundTransparency=1 scSL.Text="Select a weapon" scSL.TextColor3=Color3.fromRGB(200,200,200) scSL.Font=Enum.Font.GothamBold scSL.TextSize=16
    local scTB=Instance.new("Frame",scR) scTB.Size=UDim2.new(1,-20,0,28) scTB.Position=UDim2.new(0,10,0,42) scTB.BackgroundColor3=Color3.fromRGB(20,20,30) scTB.BorderSizePixel=0 Instance.new("UICorner",scTB).CornerRadius=UDim.new(0,6)
    local function mkTB(tx,xs) local b=Instance.new("TextButton",scTB) b.Size=UDim2.new(0.25,-3,1,-4) b.Position=UDim2.new(xs,2,0,2) b.BackgroundColor3=Color3.fromRGB(14,14,20) b.Text=tx b.TextColor3=Color3.fromRGB(90,130,120) b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0 Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) return b end
    local skBtn=mkTB("🎨 Skins",0) local wrBtn=mkTB("🎁 Wraps",0.25) local chBtn=mkTB("🔮 Charms",0.5) local fnBtn=mkTB("⚔️ Finish",0.75)
    local skScr=Instance.new("ScrollingFrame",scR) skScr.Size=UDim2.new(1,-20,1,-80) skScr.Position=UDim2.new(0,10,0,76) skScr.BackgroundTransparency=1 skScr.ScrollBarThickness=6 skScr.BorderSizePixel=0 skScr.Visible=true local skG=Instance.new("UIGridLayout",skScr) skG.CellSize=UDim2.new(0,130,0,155) skG.CellPadding=UDim2.new(0,12,0,12)
    local wrScr=Instance.new("ScrollingFrame",scR) wrScr.Size=UDim2.new(1,-20,1,-80) wrScr.Position=UDim2.new(0,10,0,76) wrScr.BackgroundTransparency=1 wrScr.ScrollBarThickness=6 wrScr.BorderSizePixel=0 wrScr.Visible=false local wrG=Instance.new("UIGridLayout",wrScr) wrG.CellSize=UDim2.new(0,130,0,50) wrG.CellPadding=UDim2.new(0,8,0,8)
    local chScr=Instance.new("ScrollingFrame",scR) chScr.Size=UDim2.new(1,-20,1,-80) chScr.Position=UDim2.new(0,10,0,76) chScr.BackgroundTransparency=1 chScr.ScrollBarThickness=6 chScr.BorderSizePixel=0 chScr.Visible=false local chG=Instance.new("UIGridLayout",chScr) chG.CellSize=UDim2.new(0,130,0,50) chG.CellPadding=UDim2.new(0,8,0,8)
    local fnScr=Instance.new("ScrollingFrame",scR) fnScr.Size=UDim2.new(1,-20,1,-80) fnScr.Position=UDim2.new(0,10,0,76) fnScr.BackgroundTransparency=1 fnScr.ScrollBarThickness=6 fnScr.BorderSizePixel=0 fnScr.Visible=false local fnG=Instance.new("UIGridLayout",fnScr) fnG.CellSize=UDim2.new(0,130,0,50) fnG.CellPadding=UDim2.new(0,8,0,8)
    local curSCTab="Skins"
    local function setTab(t) curSCTab=t skScr.Visible=(t=="Skins") wrScr.Visible=(t=="Wraps") chScr.Visible=(t=="Charms") fnScr.Visible=(t=="Finish") local ne=Color3.fromRGB(0,255,200) local dm=Color3.fromRGB(90,130,120) local bon=Color3.fromRGB(0,60,50) local bof=Color3.fromRGB(14,14,20) for _,v in pairs({{skBtn,"Skins"},{wrBtn,"Wraps"},{chBtn,"Charms"},{fnBtn,"Finish"}}) do v[1].BackgroundColor3=t==v[2] and bon or bof v[1].TextColor3=t==v[2] and ne or dm end end setTab("Skins") skBtn.MouseButton1Click:Connect(function() setTab("Skins") end) wrBtn.MouseButton1Click:Connect(function() setTab("Wraps") end) chBtn.MouseButton1Click:Connect(function() setTab("Charms") end) fnBtn.MouseButton1Click:Connect(function() setTab("Finish") end)
    -- Pre-populate charms and finishers (global, not per-weapon)
    local function mkGList(scrl,grd,lst,gdKey,typeName)
        for _,item in ipairs(lst) do
            local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=(_G.GD[gdKey]==item) and Color3.fromRGB(0,60,50) or Color3.fromRGB(20,20,30) b.Text=item b.TextColor3=Color3.fromRGB(210,255,245) b.Font=Enum.Font.GothamSemibold b.TextSize=12 b.BorderSizePixel=0 b.Parent=scrl b.TextScaled=true Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
            b.MouseButton1Click:Connect(function()
                for _,c in pairs(scrl:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3=Color3.fromRGB(20,20,30) end end
                b.BackgroundColor3=Color3.fromRGB(0,60,50)
                _G.GD[gdKey]=item
                tryEquipGlobal(typeName, item)
                scSL.Text="✅ "..typeName..": "..item
            end)
        end
        scrl.CanvasSize=UDim2.new(0,0,0,grd.AbsoluteContentSize.Y+20)
    end
    mkGList(chScr,chG,CHL,"Charm","Charm")
    mkGList(fnScr,fnG,FNL,"Finisher","Finisher")
    local scTb2=Instance.new("Frame",scM) scTb2.Size=UDim2.new(1,0,0,48) scTb2.Position=UDim2.new(0,0,1,-48) scTb2.BackgroundColor3=Color3.fromRGB(20,20,30) scTb2.BorderSizePixel=0
    local scSt=Instance.new("TextLabel",scTb2) scSt.Size=UDim2.new(1,-310,1,0) scSt.Position=UDim2.new(0,15,0,0) scSt.BackgroundTransparency=1 scSt.Text="Ready" scSt.TextColor3=Color3.fromRGB(90,130,120) scSt.Font=Enum.Font.Gotham scSt.TextSize=13 scSt.TextXAlignment=Enum.TextXAlignment.Left
    local function scF(m,c) scSt.Text=m scSt.TextColor3=c or Color3.fromRGB(0,255,200) task.delay(3,function() scSt.Text="Ready" scSt.TextColor3=Color3.fromRGB(90,130,120) end) end
    local function mkSCBtn(tx,xo,col) local b=Instance.new("TextButton",scTb2) b.Size=UDim2.new(0,140,0,32) b.Position=UDim2.new(1,xo,0.5,-16) b.BackgroundColor3=col b.Text=tx b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=13 b.BorderSizePixel=0 Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) return b end
    local svB=mkSCBtn("💾  Save Config",-300,Color3.fromRGB(30,90,30)) local ldB=mkSCBtn("📂  Load Config",-150,Color3.fromRGB(30,60,130))
    svB.MouseButton1Click:Connect(function() scSave() scF("✅ Config saved!") end)
    ldB.MouseButton1Click:Connect(function() if scLoad() then for w,i in pairs(_G.ED) do if i.Skin~="Default" then pcall(function() SCos.Equip(w,"Skin",i.Skin) end) end end scF("✅ Config loaded!",Color3.fromRGB(100,180,255)) else scF("❌ No config found!",Color3.fromRGB(220,80,80)) end end)
    local function eqSk(w,s) _G.ED[w].Skin=s pcall(function() SCos.Equip(w,"Skin",s) end) scSL.Text="✅  "..w.."  —  "..s end
    local function eqWr(w,wr) _G.ED[w].Wrap=wr pcall(function() SCos.Equip(w,"Wrap",wr~="None" and wr or nil) end) scSL.Text="✅  "..w.."  —  Wrap: "..wr end
    local function popW(w) for _,c in pairs(wrScr:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end for _,wr in ipairs(WL) do local wb=Instance.new("TextButton") wb.Size=UDim2.new(1,0,1,0) wb.BackgroundColor3=(_G.ED[w] and _G.ED[w].Wrap==wr) and Color3.fromRGB(0,60,50) or Color3.fromRGB(20,20,30) wb.Text=wr wb.TextColor3=Color3.fromRGB(210,255,245) wb.Font=Enum.Font.GothamSemibold wb.TextSize=12 wb.BorderSizePixel=0 wb.Parent=wrScr wb.TextScaled=true Instance.new("UICorner",wb).CornerRadius=UDim.new(0,5) wb.MouseButton1Click:Connect(function() for _,c2 in pairs(wrScr:GetChildren()) do if c2:IsA("TextButton") then c2.BackgroundColor3=Color3.fromRGB(20,20,30) end end wb.BackgroundColor3=Color3.fromRGB(0,60,50) eqWr(w,wr) end) end wrScr.CanvasSize=UDim2.new(0,0,0,wrG.AbsoluteContentSize.Y+20) end
    local function mkWB(w) local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-8,0,48) btn.BackgroundColor3=Color3.fromRGB(20,20,30) btn.Text="  "..w btn.TextColor3=Color3.fromRGB(210,255,245) btn.TextXAlignment=Enum.TextXAlignment.Left btn.Font=Enum.Font.GothamSemibold btn.TextSize=14 btn.BorderSizePixel=0 btn.Parent=scWS Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5) local bd=Instance.new("TextLabel",btn) bd.Size=UDim2.new(0,60,0,15) bd.Position=UDim2.new(1,-130,0,4) bd.BackgroundColor3=Color3.fromRGB(0,180,140) bd.TextColor3=Color3.fromRGB(8,8,12) bd.Font=Enum.Font.GothamBold bd.TextSize=10 bd.BorderSizePixel=0 bd.TextScaled=true Instance.new("UICorner",bd).CornerRadius=UDim.new(0,4) local wd=Instance.new("TextLabel",btn) wd.Size=UDim2.new(0,60,0,15) wd.Position=UDim2.new(1,-65,0,4) wd.BackgroundColor3=Color3.fromRGB(80,50,180) wd.TextColor3=Color3.new(1,1,1) wd.Font=Enum.Font.GothamBold wd.TextSize=10 wd.BorderSizePixel=0 wd.TextScaled=true Instance.new("UICorner",wd).CornerRadius=UDim.new(0,4) local function ub() local sk=_G.ED[w] and _G.ED[w].Skin or "Default" local wr=_G.ED[w] and _G.ED[w].Wrap or "None" if sk~="Default" then bd.Text=sk:sub(1,7) bd.Visible=true else bd.Visible=false end if wr~="None" then wd.Text=wr:sub(1,7) wd.Visible=true else wd.Visible=false end end ub() btn.MouseButton1Click:Connect(function() for _,b in pairs(scWS:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3=Color3.fromRGB(20,20,30) end end btn.BackgroundColor3=Color3.fromRGB(0,60,50) for _,c in pairs(skScr:GetChildren()) do if c:IsA("ImageButton") then c:Destroy() end end scSL.Text=w.."  —  Choose a skin or wrap" for _,sk in ipairs(SL[w]) do local sb=Instance.new("ImageButton") sb.BackgroundColor3=(_G.ED[w] and _G.ED[w].Skin==sk) and Color3.fromRGB(0,60,50) or Color3.fromRGB(20,20,30) sb.Image="" sb.BorderSizePixel=0 sb.Parent=skScr Instance.new("UICorner",sb).CornerRadius=UDim.new(0,6) local lb2=Instance.new("TextLabel",sb) lb2.Size=UDim2.new(1,0,0,38) lb2.Position=UDim2.new(0,0,1,-38) lb2.BackgroundTransparency=0.3 lb2.BackgroundColor3=Color3.new(0,0,0) lb2.Text=sk lb2.TextColor3=Color3.new(1,1,1) lb2.Font=Enum.Font.Gotham lb2.TextScaled=true lb2.BorderSizePixel=0 Instance.new("UICorner",lb2).CornerRadius=UDim.new(0,4) sb.MouseButton1Click:Connect(function() for _,c2 in pairs(skScr:GetChildren()) do if c2:IsA("ImageButton") then c2.BackgroundColor3=Color3.fromRGB(20,20,30) end end sb.BackgroundColor3=Color3.fromRGB(0,60,50) eqSk(w,sk) ub() end) end skScr.CanvasSize=UDim2.new(0,0,0,skG.AbsoluteContentSize.Y+40) popW(w) end) end
    for w in pairs(SL) do mkWB(w) end scWS.CanvasSize=UDim2.new(0,0,0,scWL.AbsoluteContentSize.Y)
    scSr:GetPropertyChangedSignal("Text"):Connect(function() local t=scSr.Text:lower() for _,b in pairs(scWS:GetChildren()) do if b:IsA("TextButton") then local tx=b.Text:match("^%s*(.-)%s*$"):lower() b.Visible=t=="" or tx:find(t) end end end)
    do local sd,ss,sp pcall(function() scT.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true ss=i.Position sp=scM.Position end end) scT.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end) UserInputService.InputChanged:Connect(function(i) if sd and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ss scM.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) end) end
    UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.K then scM.Visible=not scM.Visible end end)
    print("[Skin Changer] Loaded — press K to open.")
end)
