--// ============================================================
--// ADMIN PANEL — FULL EDITION
--// Cara pasang: StarterGui > LocalScript
--// PENTING: Ganti ADMIN_NAME dengan username Roblox kamu!
--// ============================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// ⚠️ GANTI INI DENGAN USERNAME KAMU
local ADMIN_NAME = "NamaKamuDisini"

-- Cek apakah player adalah admin
if player.Name ~= ADMIN_NAME then return end

-- ============================================================
-- GUI SETUP
-- ============================================================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 380, 0, 540)
main.Position = UDim2.new(0.5, -190, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local border = Instance.new("UIStroke", main)
border.Color = Color3.fromRGB(255, 180, 0)
border.Thickness = 1.5

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL"
title.TextColor3 = Color3.fromRGB(255, 180, 0)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- STATUS BAR
local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0, 10, 0, 46)
status.Size = UDim2.new(1, -20, 0, 24)
status.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
status.TextColor3 = Color3.fromRGB(0, 255, 150)
status.Font = Enum.Font.Code
status.TextScaled = true
status.Text = "✔ Admin aktif: " .. player.Name
status.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 5)

-- ============================================================
-- PLAYER SELECTOR
-- ============================================================
local selectorLabel = Instance.new("TextLabel", main)
selectorLabel.Position = UDim2.new(0, 10, 0, 78)
selectorLabel.Size = UDim2.new(1, -20, 0, 22)
selectorLabel.BackgroundTransparency = 1
selectorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
selectorLabel.Font = Enum.Font.Gotham
selectorLabel.TextScaled = true
selectorLabel.Text = "Pilih Target Player:"
selectorLabel.TextXAlignment = Enum.TextXAlignment.Left

local scrollFrame = Instance.new("ScrollingFrame", main)
scrollFrame.Position = UDim2.new(0, 10, 0, 102)
scrollFrame.Size = UDim2.new(1, -20, 0, 130)
scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 180, 0)
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.Name

local selectedPlayer = nil
local playerButtons = {}

local function setStatus(msg, color)
    status.Text = msg
    status.TextColor3 = color or Color3.fromRGB(0, 255, 150)
end

local function refreshPlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    playerButtons = {}

    for _, p in ipairs(Players:GetPlayers()) do
        local btn = Instance.new("TextButton", scrollFrame)
        btn.Size = UDim2.new(1, -6, 0, 30)
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0

        if selectedPlayer == p then
            btn.BackgroundColor3 = Color3.fromRGB(60, 45, 0)
            btn.TextColor3 = Color3.fromRGB(255, 200, 0)
            btn.Text = "  ► " .. p.Name .. (p == player and " (Kamu)" or "")
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.TextColor3 = Color3.fromRGB(210, 210, 210)
            btn.Text = "    " .. p.Name .. (p == player and " (Kamu)" or "")
        end
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            selectedPlayer = p
            setStatus("Target: " .. p.Name, Color3.fromRGB(255, 200, 0))
            refreshPlayerList()
        end)

        table.insert(playerButtons, btn)
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 33)
end

refreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.1) refreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshPlayerList() end)

-- ============================================================
-- ACTION BUTTONS
-- ============================================================
local function makeBtn(text, yOff, r, g, b)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.47, 0, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yOff)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local function makeBtnRight(text, yOff, r, g, b)
    local btn = makeBtn(text, yOff, r, g, b)
    btn.Position = UDim2.new(0.52, 0, 0, yOff)
    return btn
end

local function getTarget()
    if not selectedPlayer then
        setStatus("⚠ Pilih target dulu!", Color3.fromRGB(255, 80, 80))
        return nil
    end
    if not selectedPlayer.Character then
        setStatus("⚠ Character tidak ditemukan!", Color3.fromRGB(255, 80, 80))
        return nil
    end
    return selectedPlayer
end

-- ROW 1 — Kick & Freeze
local kickBtn   = makeBtn("🚫 Kick",      245, 180, 30, 30)
local freezeBtn = makeBtnRight("🧊 Freeze", 245, 30, 80, 180)

-- ROW 2 — Unfreeze & Teleport to Me
local unfreezeBtn  = makeBtn("🔥 Unfreeze",    290, 30, 130, 60)
local tpToMeBtn    = makeBtnRight("📍 TP ke Aku", 290, 60, 60, 180)

-- ROW 3 — Teleport Me to Target & Reset
local tpToTargetBtn = makeBtn("🚀 TP ke Target", 335, 80, 60, 160)
local resetBtn      = makeBtnRight("💀 Reset",    335, 160, 60, 60)

-- ROW 4 — Speed
local speedLabel = Instance.new("TextLabel", main)
speedLabel.Position = UDim2.new(0, 10, 0, 383)
speedLabel.Size = UDim2.new(0.45, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextScaled = true
speedLabel.Text = "Speed (default: 16)"
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", main)
speedBox.Position = UDim2.new(0, 10, 0, 405)
speedBox.Size = UDim2.new(0.45, 0, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
speedBox.TextColor3 = Color3.fromRGB(255, 200, 100)
speedBox.Font = Enum.Font.Code
speedBox.TextScaled = true
speedBox.PlaceholderText = "Masukkan speed..."
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)

local setSpeedBtn = makeBtnRight("⚡ Set Speed", 405, 120, 100, 20)
setSpeedBtn.Size = UDim2.new(0.47, 0, 0, 30)

-- ROW 5 — Jump
local jumpLabel = Instance.new("TextLabel", main)
jumpLabel.Position = UDim2.new(0, 10, 0, 443)
jumpLabel.Size = UDim2.new(0.45, 0, 0, 20)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextScaled = true
jumpLabel.Text = "Jump Power (default: 50)"
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpBox = Instance.new("TextBox", main)
jumpBox.Position = UDim2.new(0, 10, 0, 465)
jumpBox.Size = UDim2.new(0.45, 0, 0, 30)
jumpBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
jumpBox.TextColor3 = Color3.fromRGB(100, 200, 255)
jumpBox.Font = Enum.Font.Code
jumpBox.TextScaled = true
jumpBox.PlaceholderText = "Masukkan jump power..."
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 5)

local setJumpBtn = makeBtnRight("🦘 Set Jump", 465, 20, 100, 140)
setJumpBtn.Size = UDim2.new(0.47, 0, 0, 30)

-- ============================================================
-- BUTTON LOGIC
-- ============================================================

-- KICK
kickBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    if t == player then
        setStatus("⚠ Tidak bisa kick diri sendiri!", Color3.fromRGB(255,80,80))
        return
    end
    -- Kick hanya bisa dilakukan dari server (Script), dari LocalScript tidak bisa
    -- Tapi bisa pakai RemoteEvent kalau setup server-side
    setStatus("⚠ Kick butuh RemoteEvent di server!", Color3.fromRGB(255,150,0))
end)

-- FREEZE
freezeBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
        setStatus("🧊 " .. t.Name .. " di-freeze!", Color3.fromRGB(100, 180, 255))
    end
end)

-- UNFREEZE
unfreezeBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        setStatus("🔥 " .. t.Name .. " di-unfreeze!", Color3.fromRGB(0, 255, 150))
    end
end)

-- TELEPORT TARGET KE PLAYER
tpToMeBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local tHRP  = t.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and tHRP then
        tHRP.CFrame = myHRP.CFrame + Vector3.new(3, 0, 0)
        setStatus("📍 " .. t.Name .. " diteleport ke kamu!", Color3.fromRGB(0, 200, 255))
    end
end)

-- TELEPORT PLAYER KE TARGET
tpToTargetBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local tHRP  = t.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and tHRP then
        myHRP.CFrame = tHRP.CFrame + Vector3.new(3, 0, 0)
        setStatus("🚀 Kamu diteleport ke " .. t.Name .. "!", Color3.fromRGB(150, 100, 255))
    end
end)

-- RESET
resetBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local hum = t.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
        setStatus("💀 " .. t.Name .. " di-reset!", Color3.fromRGB(255, 80, 80))
    end
end)

-- SET SPEED
setSpeedBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local val = tonumber(speedBox.Text)
    if not val then
        setStatus("⚠ Masukkan angka yang valid!", Color3.fromRGB(255,80,80))
        return
    end
    val = math.clamp(val, 0, 500)
    local hum = t.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = val
        setStatus("⚡ Speed " .. t.Name .. " → " .. val, Color3.fromRGB(255, 200, 0))
    end
end)

-- SET JUMP
setJumpBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if not t then return end
    local val = tonumber(jumpBox.Text)
    if not val then
        setStatus("⚠ Masukkan angka yang valid!", Color3.fromRGB(255,80,80))
        return
    end
    val = math.clamp(val, 0, 500)
    local hum = t.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = val
        setStatus("🦘 Jump " .. t.Name .. " → " .. val, Color3.fromRGB(100, 200, 255))
    end
end)
