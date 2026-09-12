-- Barny: Бункер v33 (полный, доделанный)
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local B = Vector3.new(0, -500, 0)
local SavedPos = nil
local PortalA = nil
local PortalB = nil
local NextPortal = "A"
local LastTP = 0

local function P(n, s, p, c, m, par, coll)
    local x = Instance.new("Part")
    x.Name = n
    x.Size = s
    x.Position = p
    x.Anchored = true
    x.CanCollide = coll ~= false
    x.Color = c
    x.Material = m or Enum.Material.SmoothPlastic
    x.Parent = par
    return x
end

local function TP(t)
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(0,255,0)
    f.BackgroundTransparency = 1
    f.ZIndex = 999
    f.Parent = LP:WaitForChild("PlayerGui")
    TS:Create(f, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    task.wait(0.5)
    h.CFrame = CFrame.new(t)
    h.AssemblyLinearVelocity = Vector3.new(0,0,0)
    task.wait(0.3)
    TS:Create(f, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    f:Destroy()
end

-- ПОРТАЛ
local function CreatePortal(parent, pos, dir, name)
    local m = Instance.new("Model")
    m.Name = name
    local cf = CFrame.lookAt(pos, pos + dir)
    local d = P("Disc", Vector3.new(0.4, 8, 8), pos, Color3.fromRGB(20,80,20), Enum.Material.Neon, m)
    d.Shape = Enum.PartType.Cylinder
    d.CFrame = cf * CFrame.Angles(0,0,math.rad(90))
    d.CanCollide = false
    d.CanTouch = true
    d.Transparency = 0.1
    local s = P("Swirl", Vector3.new(0.3, 6.5, 6.5), pos, Color3.fromRGB(50,255,50), Enum.Material.Neon, m)
    s.Shape = Enum.PartType.Cylinder
    s.CFrame = cf * CFrame.Angles(0,0,math.rad(90))
    s.CanCollide = false
    s.CanTouch = false
    s.Transparency = 0.2
    task.spawn(function()
        local sp = 0
        while s.Parent do
            sp = sp + 0.08
            s.CFrame = cf * CFrame.Angles(0,0,math.rad(90)+sp)
            RS.Heartbeat:Wait()
        end
    end)
    local l = Instance.new("PointLight")
    l.Color = Color3.fromRGB(0,255,0)
    l.Range = 20
    l.Brightness = 5
    l.Parent = d
    local r = P("Ring", Vector3.new(0.5, 9, 9), pos, Color3.fromRGB(0,200,0), Enum.Material.Neon, m)
    r.Shape = Enum.PartType.Cylinder
    r.CFrame = cf * CFrame.Angles(0,0,math.rad(90))
    r.CanCollide = false
    r.CanTouch = false
    r.Transparency = 0.3
    m.PrimaryPart = d
    m.Parent = parent
    return m, d
end

local function TPSetup(portal, target)
    local d = portal:FindFirstChild("Disc")
    if not d then return end
    d.Touched:Connect(function(hit)
        local char = hit.Parent
        if not char then return end
        if char ~= LP.Character then return end
        local now = os.clock()
        if now - LastTP < 2 then return end
        LastTP = now
        local td = target and target:FindFirstChild("Disc")
        if not td then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = td.CFrame * CFrame.new(0, 0, -4)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end)
end

-- ПУШКА
local function MakeGun()
    local t = Instance.new("Tool")
    t.Name = "ПортальнаяПушка"
    t.RequiresHandle = true
    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(0.4, 1, 0.4)
    h.Color = Color3.fromRGB(200,200,200)
    h.Material = Enum.Material.Metal
    h.Parent = t
    local b = Instance.new("Part")
    b.Name = "Body"
    b.Size = Vector3.new(0.6, 0.7, 2)
    b.Color = Color3.fromRGB(180,180,180)
    b.Material = Enum.Material.Metal
    b.CFrame = h.CFrame * CFrame.new(0, 0.5, -1)
    b.Parent = t
    local w1 = Instance.new("Weld")
    w1.Part0 = h
    w1.Part1 = b
    w1.C0 = CFrame.new(0, 0.5, -1)
    w1.Parent = h
    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.5, 0.5, 1)
    barrel.Color = Color3.fromRGB(150,150,150)
    barrel.Material = Enum.Material.Metal
    barrel.CFrame = b.CFrame * CFrame.new(0, 0, -1.5)
    barrel.Parent = t
    local w2 = Instance.new("Weld")
    w2.Part0 = h
    w2.Part1 = barrel
    w2.C0 = CFrame.new(0, 0.5, -2.5)
    w2.Parent = h
    local gl = Instance.new("Part")
    gl.Name = "Glow"
    gl.Size = Vector3.new(0.7, 0.7, 0.7)
    gl.Color = Color3.fromRGB(0,255,100)
    gl.Material = Enum.Material.Neon
    gl.Shape = Enum.PartType.Ball
    gl.CFrame = barrel.CFrame * CFrame.new(0, 0, -0.7)
    gl.Parent = t
    local w3 = Instance.new("Weld")
    w3.Part0 = h
    w3.Part1 = gl
    w3.C0 = CFrame.new(0, 0.5, -3.2)
    w3.Parent = h
    local glt = Instance.new("PointLight")
    glt.Color = Color3.fromRGB(0,255,100)
    glt.Range = 8
    glt.Brightness = 2
    glt.Parent = gl
    t.Activated:Connect(function()
        local char = t.Parent
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local dir = hrp.CFrame.LookVector * 50
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {char}
        local res = workspace:Raycast(origin, dir, rp)
        if not res then return end
        local hp = res.Position
        local ld = (hrp.Position - hp).Unit
        if NextPortal == "A" then
            if PortalA and PortalA.Parent then PortalA:Destroy() end
            PortalA = CreatePortal(workspace, hp, ld, "A")
            NextPortal = "B"
        else
            if PortalB and PortalB.Parent then PortalB:Destroy() end
            PortalB = CreatePortal(workspace, hp, ld, "B")
            NextPortal = "A"
        end
        if PortalA and PortalB then
            TPSetup(PortalA, PortalB)
            TPSetup(PortalB, PortalA)
        end
    end)
    return t
end

-- ЗЕЛЬЕ
local function MakePotion()
    local t = Instance.new("Tool")
    t.Name = "ЗельеБезумия"
    t.RequiresHandle = true
    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(0.8, 1.2, 0.8)
    h.Shape = Enum.PartType.Cylinder
    h.Color = Color3.fromRGB(255,50,50)
    h.Material = Enum.Material.Glass
    h.Transparency = 0.3
    h.Parent = t
    local n = Instance.new("Part")
    n.Name = "Neck"
    n.Size = Vector3.new(0.4, 0.6, 0.4)
    n.Color = Color3.fromRGB(255,50,50)
    n.Material = Enum.Material.Glass
    n.Transparency = 0.3
    n.CFrame = h.CFrame * CFrame.new(0, 1, 0)
    n.Parent = t
    local w = Instance.new("Weld")
    w.Part0 = h
    w.Part1 = n
    w.C0 = CFrame.new(0, 1, 0)
    w.Parent = h
    local cap = Instance.new("Part")
    cap.Name = "Cap"
    cap.Size = Vector3.new(0.5, 0.3, 0.5)
    cap.Color = Color3.fromRGB(80,50,20)
    cap.Material = Enum.Material.Wood
    cap.CFrame = n.CFrame * CFrame.new(0, 0.5, 0)
    cap.Parent = t
    local w2 = Instance.new("Weld")
    w2.Part0 = h
    w2.Part1 = cap
    w2.C0 = CFrame.new(0, 1.5, 0)
    w2.Parent = h
    t.Activated:Connect(function()
        local char = t.Parent
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local old = hum.WalkSpeed
        hum.WalkSpeed = 40
        task.wait(10)
        if hum then hum.WalkSpeed = old end
    end)
    return t
end

-- ДИСПЛЕИ (модели, которые лежат на столе)
local function MakePotionDisplay(parent, pos)
    local m = Instance.new("Model")
    m.Name = "PotionDisplay"
    local flask = P("Flask", Vector3.new(0.8, 1.2, 0.8), pos, Color3.fromRGB(255,50,50), Enum.Material.Glass, m)
    flask.Shape = Enum.PartType.Cylinder
    flask.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    flask.Transparency = 0.3
    flask.CanCollide = false
    local cap = P("Cap", Vector3.new(0.5, 0.3, 0.5), pos + Vector3.new(0, 1, 0), Color3.fromRGB(80,50,20), Enum.Material.Wood, m)
    cap.CanCollide = false
    m.Parent = parent
    return m
end

local function MakeGunDisplay(parent, pos)
    local m = Instance.new("Model")
    m.Name = "GunDisplay"
    local handle = P("Handle", Vector3.new(0.4, 1, 0.4), pos, Color3.fromRGB(200,200,200), Enum.Material.Metal, m)
    handle.CanCollide = false
    local body = P("Body", Vector3.new(0.6, 0.7, 2), pos + Vector3.new(0, 0.5, -1), Color3.fromRGB(180,180,180), Enum.Material.Metal, m)
    body.CanCollide = false
    local barrel = P("Barrel", Vector3.new(0.5, 0.5, 1), pos + Vector3.new(0, 0.5, -2.5), Color3.fromRGB(150,150,150), Enum.Material.Metal, m)
    barrel.CanCollide = false
    local glow = P("Glow", Vector3.new(0.7, 0.7, 0.7), pos + Vector3.new(0, 0.5, -3.2), Color3.fromRGB(0,255,100), Enum.Material.Neon, m)
    glow.Shape = Enum.PartType.Ball
    glow.CanCollide = false
    m.Parent = parent
    return m
end

-- МОНИТОР С ПОДСТАВКОЙ
local function CreateMonitor(parent, bp)
    local pole = P("MonPole", Vector3.new(0.5, 5, 0.5), bp + Vector3.new(-15, 2.5, -18), Color3.fromRGB(40,40,40), Enum.Material.Metal, parent)
    local base = P("MonBase", Vector3.new(2, 0.3, 2), bp + Vector3.new(-15, 0.15, -18), Color3.fromRGB(30,30,30), Enum.Material.Metal, parent)
    local mp = bp + Vector3.new(-15, 6, -18)
    local m = P("Mon", Vector3.new(4,3,0.4), mp, Color3.fromRGB(20,20,20), Enum.Material.SmoothPlastic, parent)
    m.CanCollide = false
    local sg = Instance.new("SurfaceGui")
    sg.Face = Enum.NormalId.Front
    sg.PixelsPerStud = 150
    sg.Parent = m
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1,0,1,0)
    fr.BackgroundColor3 = Color3.fromRGB(0,150,0)
    fr.Parent = sg
    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1,0,0.25,0)
    ti.BackgroundTransparency = 0.5
    ti.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ti.Text = "STATUS"
    ti.TextColor3 = Color3.fromRGB(0,255,0)
    ti.Font = Enum.Font.Code
    ti.TextScaled = true
    ti.Parent = fr
    local inf = Instance.new("TextLabel")
    inf.Size = UDim2.new(1,0,0.5,0)
    inf.Position = UDim2.new(0,0,0.27,0)
    inf.BackgroundTransparency = 1
    inf.Text = "PLAYERS: "..#Players:GetPlayers().."\nTOOLS: 2"
    inf.TextColor3 = Color3.fromRGB(0,255,0)
    inf.Font = Enum.Font.Code
    inf.TextSize = 40
    inf.TextWrapped = true
    inf.Parent = fr
    local ci = 1
    local screens = {
        {n="STATUS", c=Color3.fromRGB(0,150,0), i="PLAYERS: "..#Players:GetPlayers().."\nTOOLS: 2"},
        {n="MAP", c=Color3.fromRGB(0,50,150), i="X:0 Y:0\nZ:0"},
        {n="PORTAL", c=Color3.fromRGB(150,0,150), i="PORTAL A: OK\nPORTAL B: OK"},
        {n="OFFLINE", c=Color3.fromRGB(20,20,20), i="OFFLINE"},
    }
    task.spawn(function()
        while fr.Parent do
            inf.Text = screens[ci].i
            task.wait(0.5)
        end
    end)
    for b = 1, 3 do
        local bg = Instance.new("TextButton")
        bg.Size = UDim2.new(0.25,0,0.15,0)
        bg.Position = UDim2.new(0.05+(b-1)*0.3, 0, 0.8, 0)
        bg.BackgroundColor3 = Color3.fromRGB(60,60,60)
        bg.Text = ({"▲","▼","OK"})[b]
        bg.TextColor3 = Color3.fromRGB(0,255,0)
        bg.Font = Enum.Font.Code
        bg.TextScaled = true
        bg.Parent = fr
        bg.MouseButton1Click:Connect(function()
            if b == 1 then ci = ci + 1 if ci > #screens then ci = 1 end
            elseif b == 2 then ci = ci - 1 if ci < 1 then ci = #screens end
            else ci = math.random(1, #screens) end
            fr.BackgroundColor3 = screens[ci].c
            ti.Text = screens[ci].n
            inf.Text = screens[ci].i
        end)
    end
end

local function Create()
    if workspace:FindFirstChild("RickBunker") then workspace.RickBunker:Destroy() end
    if PortalA then PortalA:Destroy() PortalA = nil end
    if PortalB then PortalB:Destroy() PortalB = nil end
    NextPortal = "A"

    local b = Instance.new("Model")
    b.Name = "RickBunker"

    P("Floor", Vector3.new(60,1,60), B, Color3.fromRGB(60,60,60), Enum.Material.Concrete, b)
    P("Ceil", Vector3.new(60,1,60), B+Vector3.new(0,20,0), Color3.fromRGB(40,40,40), Enum.Material.Metal, b)
    P("W1", Vector3.new(60,20,1), B+Vector3.new(0,10,-30), Color3.fromRGB(50,50,50), Enum.Material.Concrete, b)
    P("W2", Vector3.new(60,20,1), B+Vector3.new(0,10,30), Color3.fromRGB(50,50,50), Enum.Material.Concrete, b)
    P("W3", Vector3.new(1,20,60), B+Vector3.new(-30,10,0), Color3.fromRGB(50,50,50), Enum.Material.Concrete, b)
    P("W4", Vector3.new(1,20,60), B+Vector3.new(30,10,0), Color3.fromRGB(50,50,50), Enum.Material.Concrete, b)

    for x = -1, 1, 2 do
        for z = -1, 1, 2 do
            local lp = P("L", Vector3.new(3,0.3,3), B+Vector3.new(x*20,19,z*20), Color3.fromRGB(255,250,220), Enum.Material.Neon, b)
            lp.CanCollide = false
            local l = Instance.new("PointLight")
            l.Range = 30
            l.Brightness = 1.5
            l.Parent = lp
        end
    end

    local table1 = P("Table", Vector3.new(12,0.4,5), B+Vector3.new(0,3,-15), Color3.fromRGB(80,60,40), Enum.Material.Wood, b)
    P("T1", Vector3.new(0.5,3,0.5), B+Vector3.new(-5,1.5,-16.5), Color3.fromRGB(60,40,20), Enum.Material.Wood, b)
    P("T2", Vector3.new(0.5,3,0.5), B+Vector3.new(5,1.5,-16.5), Color3.fromRGB(60,40,20), Enum.Material.Wood, b)
    P("T3", Vector3.new(0.5,3,0.5), B+Vector3.new(-5,1.5,-13.5), Color3.fromRGB(60,40,20), Enum.Material.Wood, b)
    P("T4", Vector3.new(0.5,3,0.5), B+Vector3.new(5,1.5,-13.5), Color3.fromRGB(60,40,20), Enum.Material.Wood, b)

    -- ДИСПЛЕИ
    MakePotionDisplay(b, B + Vector3.new(-2, 3.5, -15))
    MakeGunDisplay(b, B + Vector3.new(2, 3.5, -15))

    -- ClickDetector для взятия
    local potionStand = P("PotionStand", Vector3.new(1.5, 2, 1.5), B+Vector3.new(-2, 4, -15), Color3.fromRGB(100,100,100), Enum.Material.SmoothPlastic, b)
    potionStand.Transparency = 1
    potionStand.CanCollide = false
    local potionClick = Instance.new("ClickDetector")
    potionClick.MaxActivationDistance = 12
    potionClick.Parent = potionStand
    local potionTool = MakePotion()
    potionTool.Parent = b
    potionTool.Handle.CFrame = CFrame.new(0, -1000, 0)
    potionClick.MouseClick:Connect(function(player)
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            potionTool.Parent = backpack
            local c = player.Character
            if c then
                local hu = c:FindFirstChildOfClass("Humanoid")
                if hu then hu:EquipTool(potionTool) end
            end
        end
    end)

    local gunStand = P("GunStand", Vector3.new(2.5, 2, 4), B+Vector3.new(2, 4, -15), Color3.fromRGB(100,100,100), Enum.Material.SmoothPlastic, b)
    gunStand.Transparency = 1
    gunStand.CanCollide = false
    local gunClick = Instance.new("ClickDetector")
    gunClick.MaxActivationDistance = 12
    gunClick.Parent = gunStand
    local gunTool = MakeGun()
    gunTool.Parent = b
    gunTool.Handle.CFrame = CFrame.new(0, -1000, 0)
    gunClick.MouseClick:Connect(function(player)
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            gunTool.Parent = backpack
            local c = player.Character
            if c then
                local hu = c:FindFirstChildOfClass("Humanoid")
                if hu then hu:EquipTool(gunTool) end
            end
        end
    end)

    local tpBtn = P("TPButton", Vector3.new(3,1,3), B+Vector3.new(10,1,10), Color3.fromRGB(0,100,0), Enum.Material.Neon, b)
    local tpClick = Instance.new("ClickDetector")
    tpClick.MaxActivationDistance = 10
    tpClick.Parent = tpBtn
    tpClick.MouseClick:Connect(function(player)
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(B+Vector3.new(0,5,0)) end
        end
    end)

    local fr = P("Fridge", Vector3.new(2.5,6,3), B+Vector3.new(20,3,15), Color3.fromRGB(200,200,200), Enum.Material.Metal, b)
    local frOpened = false
    fr.Touched:Connect(function(h)
        if h.Parent ~= LP.Character then return end
        if frOpened then return end
        frOpened = true
        local c = LP.Character
        if c then
            local hu = c:FindFirstChildOfClass("Humanoid")
            if hu then hu.Health = math.min(hu.Health+50, hu.MaxHealth) end
        end
        task.wait(3)
        frOpened = false
    end)

    local bed = P("Bed", Vector3.new(3,0.5,6), B+Vector3.new(-20,1.5,15), Color3.fromRGB(80,60,40), Enum.Material.Wood, b)
    P("Mattress", Vector3.new(2.8,0.6,5.8), B+Vector3.new(-20,2,15), Color3.fromRGB(240,240,240), Enum.Material.Fabric, b)
    local bedTrigger = P("BedTrigger", Vector3.new(4,3,7), bed.Position+Vector3.new(0,2,0), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, b)
    bedTrigger.Transparency = 1
    bedTrigger.CanCollide = false
    local sleeping = false
    bedTrigger.Touched:Connect(function(h)
        if h.Parent ~= LP.Character then return end
        if sleeping then return end
        sleeping = true
        local c = LP.Character
        if c then
            local hu = c:FindFirstChildOfClass("Humanoid")
            if hu then hu.Health = hu.MaxHealth end
        end
        task.wait(3)
        sleeping = false
    end)

    CreateMonitor(b, B)

    local exitPortal = P("ExitPortal", Vector3.new(0.4,10,10), B+Vector3.new(25,5,25), Color3.fromRGB(0,255,0), Enum.Material.Neon, b)
    exitPortal.Shape = Enum.PartType.Cylinder
    exitPortal.CFrame = CFrame.new(B+Vector3.new(25,5,25))*CFrame.Angles(0,0,math.rad(90))
    exitPortal.CanCollide = false
    exitPortal.CanTouch = true
    exitPortal.Touched:Connect(function(h)
        if h.Parent == LP.Character then
            local c = LP.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(SavedPos or Vector3.new(0,5,0)) end
        end
    end)

    b.Parent = workspace
    print("[Barny] Бункер v33 загружен")
end

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.B then
        local c = LP.Character
        if not c then return end
        local hr = c:FindFirstChild("HumanoidRootPart")
        if not hr then return end
        SavedPos = hr.Position
        Create()
        TP(B+Vector3.new(0,5,0))
    end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "BG"
sg.ResetOnSpawn = false
sg.Parent = LP:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,130,0,35)
btn.Position = UDim2.new(0,5,0,50)
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.Text = "БУНКЕР [B]"
btn.TextColor3 = Color3.fromRGB(0,255,0)
btn.Font = Enum.Font.Code
btn.TextSize = 12
btn.Parent = sg
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0,8)
c.Parent = btn
btn.MouseButton1Click:Connect(function()
    local ch = LP.Character
    if not ch then return end
    local hr = ch:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    SavedPos = hr.Position
    Create()
    TP(B+Vector3.new(0,5,0))
end)

print("[Barny] v33 загружен (полный)")
