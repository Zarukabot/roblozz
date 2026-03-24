--// ============================================================
--// STRESS LAB — FULL BRUTAL EDITION
--// Cara pasang: StarterGui > ScreenGui > LocalScript (tempel script ini)
--// Atau: StarterPlayerScripts > LocalScript
--// ============================================================

--// SERVICES
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Stats       = game:GetService("Stats")

local player = Players.LocalPlayer

--// WAIT FOR CHARACTER ROOT
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- ============================================================
-- MAIN GUI (STRESS LAB)
-- ============================================================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "StressLab"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 100) -- tinggi dinamis
main.Position = UDim2.new(0, 10, 0.5, -300)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local mainBorder = Instance.new("UIStroke", main)
mainBorder.Color = Color3.fromRGB(255, 60, 60)
mainBorder.Thickness = 1.5

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 44)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "💀 CLIENT STRESS LAB — BRUTAL"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 60, 60)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- STATS MONITOR
local monitor = Instance.new("TextLabel", main)
monitor.Position = UDim2.new(0, 10, 0, 46)
monitor.Size = UDim2.new(1, -20, 0, 26)
monitor.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
monitor.TextColor3 = Color3.fromRGB(0, 255, 150)
monitor.Font = Enum.Font.Code
monitor.TextScaled = true
monitor.Text = "FPS: -- | MEM: -- MB | HB: -- ms"
monitor.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

-- ============================================================
-- VARIABLES
-- ============================================================
local guiCount        = 0
local partCount       = 0
local renderIntensity = 0
local soundCount      = 0
local particleCount   = 0
local lightCount      = 0
local physicsCount    = 0
local memoryFlood     = 0
local running         = false
local createdObjects  = {}
local memoryTables    = {}
local renderConnection

-- ============================================================
-- UTILITY: CREATE SLIDER INPUT
-- ============================================================
local function createSlider(text, yPos, min, max, callback)
    local label = Instance.new("TextLabel", main)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.Size = UDim2.new(1, -20, 0, 22)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Text = text .. ": 0"
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", main)
    box.Position = UDim2.new(0, 10, 0, yPos + 24)
    box.Size = UDim2.new(1, -20, 0, 26)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    box.TextColor3 = Color3.fromRGB(255, 100, 100)
    box.Font = Enum.Font.Code
    box.TextScaled = true
    box.PlaceholderText = "Masukkan angka (" .. min .. "-" .. max .. ")"
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(60, 60, 60)

    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            val = math.clamp(val, min, max)
            label.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

-- ============================================================
-- SLIDERS
-- ============================================================
local Y = 80
createSlider("2D GUI Labels",          Y, 0, 10000, function(v) guiCount        = v end) Y += 56
createSlider("3D Parts (anchored)",    Y, 0,  3000, function(v) partCount        = v end) Y += 56
createSlider("Render Loop Intensity",  Y, 0, 50000, function(v) renderIntensity  = v end) Y += 56
createSlider("Sound Instances",        Y, 0,   500, function(v) soundCount       = v end) Y += 56
createSlider("Particle Emitters/Part", Y, 0,    50, function(v) particleCount    = v end) Y += 56
createSlider("PointLights/Part",       Y, 0,    50, function(v) lightCount       = v end) Y += 56
createSlider("Physics Parts (loose)",  Y, 0,   500, function(v) physicsCount     = v end) Y += 56
createSlider("Memory Flood (MB est)",  Y, 0,   500, function(v) memoryFlood      = v end) Y += 56

-- ============================================================
-- BUTTONS
-- ============================================================
local function makeBtn(text, yOff, r, g, b)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOff)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local btnY = Y + 4
local startBtn = makeBtn("▶ START STRESS",   btnY, 160, 30, 30)  btnY += 44
local nukeBtn  = makeBtn("☢ NUKE (MAX ALL)", btnY, 200, 60,  0)  btnY += 44
local stopBtn  = makeBtn("⏹ STOP & CLEAN",   btnY,  30,120, 30)  btnY += 10

-- Sesuaikan tinggi frame
main.Size = UDim2.new(0, 360, 0, btnY + 10)

-- ============================================================
-- STRESS FUNCTIONS
-- ============================================================

local function spawnGUI()
    for i = 1, guiCount do
        local lbl = Instance.new("TextLabel", gui)
        lbl.Size = UDim2.new(0, math.random(30,80), 0, math.random(16,30))
        lbl.Position = UDim2.new(math.random(), 0, math.random(), 0)
        lbl.Text = tostring(i)
        lbl.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        lbl.TextColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        lbl.BorderSizePixel = 0
        table.insert(createdObjects, lbl)
    end
end

local function spawnParts()
    local root = getRoot()
    for i = 1, partCount do
        local part = Instance.new("Part")
        part.Size = Vector3.new(math.random(1,6), math.random(1,6), math.random(1,6))
        part.Position = root.Position + Vector3.new(
            math.random(-80,80), math.random(0,60), math.random(-80,80)
        )
        part.Anchored = true
        part.BrickColor = BrickColor.Random()
        part.Material = Enum.Material.Neon

        for _ = 1, particleCount do
            local pe = Instance.new("ParticleEmitter", part)
            pe.Rate = 200
            pe.Lifetime = NumberRange.new(1, 3)
            pe.Speed = NumberRange.new(10, 30)
            pe.Color = ColorSequence.new(
                Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            )
        end

        for _ = 1, lightCount do
            local light = Instance.new("PointLight", part)
            light.Brightness = math.random(2, 10)
            light.Range = math.random(10, 50)
            light.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        end

        part.Parent = workspace
        table.insert(createdObjects, part)
    end
end

local function spawnPhysicsParts()
    local root = getRoot()
    for i = 1, physicsCount do
        local part = Instance.new("Part")
        part.Size = Vector3.new(2, 2, 2)
        part.Position = root.Position + Vector3.new(
            math.random(-30,30), math.random(5,30), math.random(-30,30)
        )
        part.Anchored = false
        part.Velocity = Vector3.new(
            math.random(-80,80), math.random(20,100), math.random(-80,80)
        )
        part.BrickColor = BrickColor.Random()
        part.Parent = workspace
        table.insert(createdObjects, part)
    end
end

local function spawnSounds()
    local ids = {138081500, 1837867, 258057783, 130113322, 1843198752}
    for i = 1, soundCount do
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://" .. ids[math.random(1, #ids)]
        s.Volume = 0.1
        s.Looped = true
        s:Play()
        table.insert(createdObjects, s)
    end
end

local function floodMemory()
    memoryTables = {}
    local chunk = string.rep("X", 1024)
    for i = 1, memoryFlood * 1024 do
        table.insert(memoryTables, chunk .. tostring(i))
    end
end

local function startStress()
    if running then return end
    running = true
    spawnGUI()
    spawnParts()
    spawnPhysicsParts()
    spawnSounds()
    if memoryFlood > 0 then
        task.spawn(floodMemory)
    end
    renderConnection = RunService.RenderStepped:Connect(function()
        for i = 1, renderIntensity do
            local _ = math.sqrt(i) * math.sin(i) * math.cos(i)
        end
    end)
end

local function stopStress()
    running = false
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    for _, obj in pairs(createdObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    createdObjects = {}
    memoryTables = {}
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================
startBtn.MouseButton1Click:Connect(startStress)

nukeBtn.MouseButton1Click:Connect(function()
    guiCount        = 10000
    partCount       = 3000
    renderIntensity = 50000
    soundCount      = 500
    particleCount   = 20
    lightCount      = 20
    physicsCount    = 500
    memoryFlood     = 300
    startStress()
end)

stopBtn.MouseButton1Click:Connect(stopStress)

-- ============================================================
-- FPS + STATS MONITOR
-- ============================================================
local last   = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        local fps  = frames
        local mem  = math.floor(Stats:GetTotalMemoryUsageMb())
        local hb   = math.floor(Stats.HeartbeatTimeMs * 100) / 100
        monitor.Text = string.format("FPS: %d  |  MEM: %d MB  |  HB: %.2f ms", fps, mem, hb)
        frames = 0
        last = tick()
    end
end)

-- ============================================================
-- PLAYER MONITOR PANEL
-- ============================================================
local pFrame = Instance.new("Frame", gui)
pFrame.Size = UDim2.new(0, 230, 0, 320)
pFrame.Position = UDim2.new(1, -240, 0.5, -160)
pFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
pFrame.Active = true
pFrame.Draggable = true
Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 12)
local pBorder = Instance.new("UIStroke", pFrame)
pBorder.Color = Color3.fromRGB(0, 200, 255)
pBorder.Thickness = 1.5

local pTitle = Instance.new("TextLabel", pFrame)
pTitle.Size = UDim2.new(1, 0, 0, 36)
pTitle.BackgroundTransparency = 1
pTitle.Text = "👥 PLAYERS IN SERVER"
pTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
pTitle.Font = Enum.Font.GothamBold
pTitle.TextScaled = true

local pCount = Instance.new("TextLabel", pFrame)
pCount.Size = UDim2.new(1, -10, 0, 22)
pCount.Position = UDim2.new(0, 8, 0, 36)
pCount.BackgroundTransparency = 1
pCount.TextColor3 = Color3.fromRGB(150, 150, 150)
pCount.Font = Enum.Font.Gotham
pCount.TextScaled = true
pCount.Text = "Total: 0"
pCount.TextXAlignment = Enum.TextXAlignment.Left

local scrollFrame = Instance.new("ScrollingFrame", pFrame)
scrollFrame.Position = UDim2.new(0, 5, 0, 62)
scrollFrame.Size = UDim2.new(1, -10, 1, -70)
scrollFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 3)

local playerRows = {}

local function refreshPlayers()
    for _, row in pairs(playerRows) do row:Destroy() end
    playerRows = {}

    local allPlayers = Players:GetPlayers()
    pCount.Text = "Total: " .. #allPlayers .. " / " .. Players.MaxPlayers

    for _, p in ipairs(allPlayers) do
        local row = Instance.new("Frame", scrollFrame)
        row.Size = UDim2.new(1, -6, 0, 30)
        row.BackgroundColor3 = (p == player)
            and Color3.fromRGB(0, 60, 80)
            or  Color3.fromRGB(22, 22, 22)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0.75, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = (p == player and "★ " or "") .. p.Name
        nameLabel.TextColor3 = (p == player)
            and Color3.fromRGB(0, 220, 255)
            or  Color3.fromRGB(220, 220, 220)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- Ping hanya untuk player lokal
        local pingLabel = Instance.new("TextLabel", row)
        pingLabel.Size = UDim2.new(0.25, -4, 1, 0)
        pingLabel.Position = UDim2.new(0.75, 0, 0, 0)
        pingLabel.BackgroundTransparency = 1
        pingLabel.Font = Enum.Font.Code
        pingLabel.TextScaled = true
        pingLabel.TextXAlignment = Enum.TextXAlignment.Right

        if p == player then
            local ok, ping = pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if ok then
                pingLabel.Text = ping .. "ms"
                pingLabel.TextColor3 = ping < 80
                    and Color3.fromRGB(0, 255, 100)
                    or  ping < 150
                        and Color3.fromRGB(255, 200, 0)
                        or  Color3.fromRGB(255, 60, 60)
            else
                pingLabel.Text = "?ms"
                pingLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        else
            pingLabel.Text = ""
        end

        table.insert(playerRows, row)
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #allPlayers * 33)
end

-- Auto refresh tiap 2 detik
refreshPlayers()
task.spawn(function()
    while true do
        task.wait(2)
        refreshPlayers()
    end
end)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    refreshPlayers()
end)
