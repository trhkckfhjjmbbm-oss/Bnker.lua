-- Barny: Бункер v29 (без Рика и стола)
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
local PortalCooldown = false

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

local function CreatePortalVisual(parent, position, normal, name)
    local portal = Instance.new("Model")
    portal.Name = name
    local lookCF = CFrame.lookAt(position, position + normal)
    local disc = P("Disc", Vector3.new(0.4, 8, 8), position, Color3.fromRGB(20, 80, 20), Enum.Material.Neon, portal)
    disc.Shape = Enum.PartType.Cylinder
    disc.CFrame = lookCF * CFrame.Angles(0, 0, math.rad(90))
    disc.CanCollide = false
    disc.CanTouch = true
    disc.Transparency = 0.1
    local swirl = P("Swirl", Vector3.new(0.3, 6.5, 6.5), position, Color3.fromRGB(50, 255, 50), Enum.Material.Neon, portal)
    swirl.Shape = Enum.PartType.Cylinder
    swirl.CFrame = disc.CFrame
    swirl.CanCollide = false
    swirl.CanTouch = false
    swirl.Transparency = 0.2
    task.spawn(function()
        local spin = 0
        while swirl.Parent do
            spin = spin + 0.08
            swirl.CFrame = disc.CFrame * CFrame.Angles(0, 0, spin)
            RS.Heartbeat:Wait()
        end
    end)
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(0, 255, 0)
    light.Range = 20
    light.Brightness = 5
    light.Parent = disc
    local ring = P("Ring", Vector3.new(0.5, 9, 9), position, Color3.fromRGB(0, 200, 0), Enum.Material.Neon, portal)
    ring.Shape = Enum.PartType.Cylinder
    ring.CFrame = lookCF * CFrame.Angles(0, 0, math.rad(90))
    ring.CanCollide = false
    ring.CanTouch = false
    ring.Transparency = 0.3
    portal.PrimaryPart = disc
    portal.Parent = parent
    return portal, disc
end

local function SetupTeleport(portal, targetPortal)
    local disc = portal:FindFirstChild("Disc")
    if not disc then return end
    disc.Touched:Connect(function(hit)
        local char = hit.Parent
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if char ~= LP.Character then return end
        local targetDisc = targetPortal and targetPortal:FindFirstChild("Disc")
        if not targetDisc then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = targetDisc.CFrame * CFrame.new(0, 0, -4)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end)
end

local function MakePortalGunTool()
    local tool = Instance.new("Tool")
    tool.Name = "ПортальнаяПушка"
    tool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 1, 0.4)
    handle.Color = Color3.fromRGB(200, 200, 200)
    handle.Material = Enum.Material.Metal
    handle.Parent = tool
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(0.6, 0.7, 2)
    body.Color = Color3.fromRGB(180, 180, 180)
    body.Material = Enum.Material.Metal
    body.CFrame = handle.CFrame * CFrame.new(0, 0.5, -1)
    body.Parent = tool
    local w1 = Instance.new("Weld")
    w1.Part0 = handle
    w1.Part1 = body
    w1.C0 = CFrame.new(0, 0.5, -1)
    w1.Parent = handle
    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.5, 0.5, 1)
    barrel.Color = Color3.fromRGB(150, 150, 150)
    barrel.Material = Enum.Material.Metal
    barrel.CFrame = body.CFrame * CFrame.new(0, 0, -1.5)
    barrel.Parent = tool
    local w2 = Instance.new("Weld")
    w2.Part0 = handle
    w2.Part1 = barrel
    w2.C0 = CFrame.new(0, 0.5, -2.5)
    w2.Parent = handle
    local glow = Instance.new("Part")
    glow.Name = "Glow"
    glow.Size = Vector3.new(0.7, 0.7, 0.7)
    glow.Color = Color3.fromRGB(0, 255, 100)
    glow.Material = Enum.Material.Neon
    glow.Shape = Enum.PartType.Ball
    glow.CFrame = barrel.CFrame * CFrame.new(0, 0, -0.7)
    glow.Parent = tool
    local w3 = Instance.new("Weld")
    w3.Part0 = handle
    w3.Part1 = glow
    w3.C0 = CFrame.new(0, 0.5, -3.2)
    w3.Parent = handle
    local gl = Instance.new("PointLight")
    gl.Color = Color3.fromRGB(0, 255, 100)
    gl.Range = 8
    gl.Brightness = 2
    gl.Parent = glow
    tool.Activated:Connect(function()
        if PortalCooldown then return end
        PortalCooldown = true
        local char = tool.Parent
        if not char then PortalCooldown = false return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then PortalCooldown = false return end
        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local direction = hrp.CFrame.LookVector * 50
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        local result = workspace:Raycast(origin, direction, params)
        if not result then PortalCooldown = false return end
        local hitPos = result.Position
        local hitNormal = result.Normal
        if NextPortal == "A" then
            if PortalA and PortalA.Parent then PortalA:Destroy() end
            PortalA = CreatePortalVisual(workspace, hitPos, hitNormal, "PortalA")
            NextPortal = "B"
        else
            if PortalB and PortalB.Parent then PortalB:Destroy() end
            PortalB = CreatePortalVisual(workspace, hitPos, hitNormal, "PortalB")
            NextPortal = "A"
        end
        if PortalA and PortalB then
            SetupTeleport(PortalA, PortalB)
            SetupTeleport(PortalB, PortalA)
        end
        task.wait(1.5)
        PortalCooldown = false
    end)
    return tool
end

local function MakePotionTool()
    local tool = Instance.new("Tool")
    tool.Name = "ЗельеБезумия"
    tool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.8, 1.2, 0.8)
    handle.Shape = Enum.PartType.Cylinder
    handle.Color = Color3.fromRGB(255, 50, 50)
    handle.Material = Enum.Material.Glass
    handle.Transparency = 0.3
    handle.Parent = tool
    local neck = Instance.new("Part")
    neck.Name = "Neck"
    neck.Size = Vector3.new(0.4, 0.6, 0.4)
    neck.Color = Color3.fromRGB(255, 50, 50)
    neck.Material = Enum.Material.Glass
    neck.Transparency = 0.3
    neck.CFrame = handle.CFrame * CFrame.new(0, 1, 0)
    neck.Parent = tool
    local w = Instance.new("Weld")
    w.Part0 = handle
    w.Part1 = neck
    w.C0 = CFrame.new(0, 1, 0)
    w.Parent = handle
    local cap = Instance.new("Part")
    cap.Name = "Cap"
    cap.Size = Vector3.new(0.5, 0.3, 0.5)
    cap.Color = Color3.fromRGB(80, 50, 20)
    cap.Material = Enum.Material.Wood
    cap.CFrame = neck.CFrame * CFrame.new(0, 0.5, 0)
    cap.Parent = tool
    local w2 = Instance.new("Weld")
    w2.Part0 = handle
    w2.Part1 = cap
    w2.C0 = CFrame.new(0, 1.5, 0)
    w2.Parent = handle
    tool.Activated:Connect(function()
        local char = tool.Parent
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local oldSpeed = hum.WalkSpeed
        local oldJump = hum.JumpPower
        hum.WalkSpeed = 40
        hum.JumpPower = 100
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local glow = Instance.new("PointLight")
            glow.Color = Color3.fromRGB(255, 100, 255)
            glow.Range = 15
            glow.Brightness = 3
            glow.Parent = hrp
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="🧪 ЗЕЛЬЕ", Text="Скорость + Прыжок (10 сек)", Duration=3})
            task.wait(10)
            if hum then
                hum.WalkSpeed = oldSpeed
                hum.JumpPower = oldJump
            end
            if glow then glow:Destroy() end
        end
    end)
    return tool
end

local Screens = {
    {n="STATUS", c=Color3.fromRGB(0,150,0)},
    {n="MAP", c=Color3.fromRGB(0,50,150)},
    {n="PORTAL", c=Color3.fromRGB(150,0,150)},
    {n="OFFLINE", c=Color3.fromRGB(20,20,20)},
}

local function GetInfo(n)
    if n == "STATUS" then return "PLAYERS: "..#Players:GetPlayers().."\nTOOLS: 2"
    elseif n == "MAP" then
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local p = c.HumanoidRootPart.Position
            return string.format("X:%.0f Y:%.0f\nZ:%.0f", p.X, p.Y, p.Z)
        end
        return "NO SIGNAL"
    elseif n == "PORTAL" then return "PORTAL A: "..(PortalA and "OK" or "NO").."\nPORTAL B: "..(PortalB and "OK" or "NO")
    else return "OFFLINE" end
end

local function CreateMonitor(parent, bp)
    local mp = bp + Vector3.new(-15, 5, -18)
    local m = P("Mon", Vector3.new(4,3,0.4), mp, Color3.fromRGB(20,20,20), Enum.Material.SmoothPlastic, parent)
    m.CanCollide = false
    P("St", Vector3.new(0.5,1,0.5), mp+Vector3.new(0,-2,0), Color3.fromRGB(40,40,40), Enum.Material.Metal, parent)
    local sg = Instance.new("SurfaceGui")
    sg.Face = Enum.NormalId.Front
    sg.PixelsPerStud = 150
    sg.Parent = m
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1,0,1,0)
    fr.BackgroundColor3 = Screens[1].c
    fr.Parent = sg
    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1,0,0.25,0)
    ti.BackgroundTransparency = 0.5
    ti.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ti.Text = Screens[1].n
    ti.TextColor3 = Color3.fromRGB(0,255,0)
    ti.Font = Enum.Font.Code
    ti.TextScaled = true
    ti.Parent = fr
    local inf = Instance.new("TextLabel")
    inf.Size = UDim2.new(1,0,0.5,0)
    inf.Position = UDim2.new(0,0,0.27,0)
    inf.BackgroundTransparency = 1
    inf.Text = GetInfo(Screens[1].n)
    inf.TextColor3 = Color3.fromRGB(0,255,0)
    inf.Font = Enum.Font.Code
    inf.TextSize = 40
    inf.TextWrapped = true
    inf.Parent = fr
    local ci = 1
    task.spawn(function()
        while fr.Parent do
            inf.Text = GetInfo(Screens[ci].n)
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
            if b == 1 then ci = ci + 1 if ci > #Screens then ci = 1 end
            elseif b == 2 then ci = ci - 1 if ci < 1 then ci = #Screens end
            else ci = math.random(1, #Screens) end
            fr.BackgroundColor3 = Screens[ci].c
            ti.Text = Screens[ci].n
            inf.Text = GetInfo(Screens[ci].n)
        end)
    end
end

local function Create()
    if workspace:FindFirstChild("RickBunker") then workspace.RickBunker:Destroy() end
    if PortalA then PortalA:Destroy() PortalA = nil end
    if PortalB then PortalB:Destroy() PortalB = nil end
    NextPortal = "A"
    PortalCooldown = false
    
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
    
    -- 2 Tool на подставках (БЕЗ СТОЛА)
    local tools = {
        {tool = MakePotionTool(), pos = B + Vector3.new(-5, 4, -15)},
        {tool = MakePortalGunTool(), pos = B + Vector3.new(5, 4, -15)},
    }
    for _, data in ipairs(tools) do
        local stand = P("Stand_"..data.tool.Name, Vector3.new(1.2,1.2,1.2), data.pos, Color3.fromRGB(100,100,100), Enum.Material.SmoothPlastic, b)
        stand.CanCollide = false
        data.tool.Parent = b
        data.tool.Handle.CFrame = CFrame.new(stand.Position + Vector3.new(0,1.5,0))
        local click = Instance.new("ClickDetector")
        click.MaxActivationDistance = 12
        click.Parent = stand
        click.MouseClick:Connect(function(player)
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                data.tool.Parent = backpack
                stand.Transparency = 1
                stand.CanCollide = false
                stand.CanTouch = false
                local c = player.Character
                if c then
                    local hu = c:FindFirstChildOfClass("Humanoid")
                    if hu then hu:EquipTool(data.tool) end
                end
            end
        end)
    end
    
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
    print("[Barny] Бункер v29 загружен")
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

print("[Barny] v29 загружен")
