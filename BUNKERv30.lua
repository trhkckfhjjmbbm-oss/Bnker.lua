-- Barny: Бункер v34 (минимум)
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

local function P(n, s, p, c, m, par)
    local x = Instance.new("Part")
    x.Name = n
    x.Size = s
    x.Position = p
    x.Anchored = true
    x.CanCollide = true
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
    h.CFrame = CFrame.new(t)
    h.AssemblyLinearVelocity = Vector3.new(0,0,0)
end

-- ПОРТАЛ
local function Portal(parent, pos, dir, name)
    local m = Instance.new("Model")
    m.Name = name
    local cf = CFrame.lookAt(pos, pos + dir)
    local d = P("Disc", Vector3.new(0.4, 8, 8), pos, Color3.fromRGB(0,255,0), Enum.Material.Neon, m)
    d.Shape = Enum.PartType.Cylinder
    d.CFrame = cf * CFrame.Angles(0,0,math.rad(90))
    d.CanCollide = false
    d.CanTouch = true
    d.Transparency = 0.2
    local s = P("Swirl", Vector3.new(0.3, 6.5, 6.5), pos, Color3.fromRGB(50,255,50), Enum.Material.Neon, m)
    s.Shape = Enum.PartType.Cylinder
    s.CFrame = cf * CFrame.Angles(0,0,math.rad(90))
    s.CanCollide = false
    s.CanTouch = false
    s.Transparency = 0.3
    task.spawn(function()
        local sp = 0
        while s.Parent do
            sp = sp + 0.1
            s.CFrame = cf * CFrame.Angles(0,0,math.rad(90)+sp)
            RS.Heartbeat:Wait()
        end
    end)
    local l = Instance.new("PointLight")
    l.Color = Color3.fromRGB(0,255,0)
    l.Range = 20
    l.Brightness = 5
    l.Parent = d
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
    t.Name = "Пушка"
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
    local gl = Instance.new("Part")
    gl.Name = "Glow"
    gl.Size = Vector3.new(0.7, 0.7, 0.7)
    gl.Color = Color3.fromRGB(0,255,100)
    gl.Material = Enum.Material.Neon
    gl.Shape = Enum.PartType.Ball
    gl.CFrame = b.CFrame * CFrame.new(0, 0, -1.5)
    gl.Parent = t
    local w2 = Instance.new("Weld")
    w2.Part0 = h
    w2.Part1 = gl
    w2.C0 = CFrame.new(0, 0.5, -2.5)
    w2.Parent = h
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
            PortalA = Portal(workspace, hp, ld, "A")
            NextPortal = "B"
        else
            if PortalB and PortalB.Parent then PortalB:Destroy() end
            PortalB = Portal(workspace, hp, ld, "B")
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
    t.Name = "Зелье"
    t.RequiresHandle = true
    local h = Instance.new("Part")
    h.Name = "Handle"
    h.Size = Vector3.new(0.8, 1.2, 0.8)
    h.Shape = Enum.PartType.Cylinder
    h.Color = Color3.fromRGB(255,50,50)
    h.Material = Enum.Material.Glass
    h.Transparency = 0.3
    h.Parent = t
    t.Activated:Connect(function()
        local char = t.Parent
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local os = hum.WalkSpeed
        hum.WalkSpeed = 40
        task.wait(10)
        if hum then hum.WalkSpeed = os end
    end)
    return t
end

-- БУНКЕР
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

    -- Tool на столе (плоские, лежат на столе)
    local potionTool = MakePotion()
    potionTool.Parent = b
    potionTool.Handle.CFrame = CFrame.new(B + Vector3.new(-2, 3.5, -15))
    local gunTool = MakeGun()
    gunTool.Parent = b
    gunTool.Handle.CFrame = CFrame.new(B + Vector3.new(2, 3.5, -15))

    -- Взятие по Touched (подходишь — берёшь)
    local takeZone1 = P("TZ1", Vector3.new(3,3,3), B+Vector3.new(-2,4.5,-15), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, b)
    takeZone1.Transparency = 1
    takeZone1.CanCollide = false
    local taken1 = false
    takeZone1.Touched:Connect(function(h)
        if h.Parent ~= LP.Character then return end
        if taken1 then return end
        taken1 = true
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then
            potionTool.Parent = backpack
            local c = LP.Character
            if c then
                local hu = c:FindFirstChildOfClass("Humanoid")
                if hu then hu:EquipTool(potionTool) end
            end
        end
    end)

    local takeZone2 = P("TZ2", Vector3.new(4,3,4), B+Vector3.new(2,4.5,-15), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, b)
    takeZone2.Transparency = 1
    takeZone2.CanCollide = false
    local taken2 = false
    takeZone2.Touched:Connect(function(h)
        if h.Parent ~= LP.Character then return end
        if taken2 then return end
        taken2 = true
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then
            gunTool.Parent = backpack
            local c = LP.Character
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
    print("[Barny] v34 загружен")
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

print("[Barny] v34 загружен (минимум)")
