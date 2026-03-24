--// ============================================================
--// FREEZE TOOL — EXECUTOR EDITION
--// Pure LocalScript, tidak butuh library external
--// ⚠️ Hanya bekerja di game MILIK KAMU SENDIRI
--//    yang sudah ada FreezeHandler ServerScript-nya
--// ============================================================

local Players    = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local player     = Players.LocalPlayer

-- Cek RemoteEvents
local remotes = RepStorage:FindFirstChild("AdminRemotes")
if not remotes then
    warn("[FreezeGUI] AdminRemotes tidak ditemukan! Pastikan ServerScript sudah dipasang.")
    return
end

local FreezePlayer   = remotes:FindFirstChild("FreezePlayer")
local UnfreezePlayer = remotes:FindFirstChild("UnfreezePlayer")
local FreezeAll      = remotes:FindFirstChild("FreezeAll")
local UnfreezeAll    = remotes:FindFirstChild("UnfreezeAll")
local GetFrozenList  = remotes:FindFirstChild("GetFrozenList")

if not FreezePlayer then
    warn("[FreezeGUI] RemoteEvents tidak lengkap!")
    return
end

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FreezeExecutor"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 180, 255)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🧊 FREEZE TOOL"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- STATUS
local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0, 8, 0, 42)
status.Size = UDim2.new(1, -16, 0, 22)
status.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
status.TextColor3 = Color3.fromRGB(0, 255, 150)
status.Font = Enum.Font.Code
status.TextScaled = true
status.Text = "Siap"
status.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 4)

local function setStatus(msg, color)
    status.Text = "  " .. msg
    status.TextColor3 = color or Color3.fromRGB(0, 255, 150)
end

-- ============================================================
-- PLAYER LIST
-- ============================================================
local listLabel = Instance.new("TextLabel", main)
listLabel.Position = UDim2.new(0, 8, 0, 68)
listLabel.Size = UDim2.new(1, -16, 0, 20)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Pilih Target:"
listLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
listLabel.Font = Enum.Font.Gotham
listLabel.TextScaled = true
listLabel.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0, 8, 0, 90)
scroll.Size = UDim2.new(1, -16, 0, 140)
scroll.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 3)

local selectedTarget = nil
local playerRows = {}

local function refreshList()
    for _, r in pairs(playerRows) do r:Destroy() end
    playerRows = {}

    local all = Players:GetPlayers()
    for _, p in ipairs(all) do
        if p ~= player then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -6, 0, 28)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0

            if selectedTarget == p then
                btn.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
                btn.TextColor3 = Color3.fromRGB(0, 220, 255)
                btn.Text = "  ► " .. p.Name
            else
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
                btn.TextColor3 = Color3.fromRGB(210, 210, 210)
                btn.Text = "    " .. p.Name
            end
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                selectedTarget = p
                setStatus("Target: " .. p.Name, Color3.fromRGB(0, 220, 255))
                refreshList()
            end)

            table.insert(playerRows, btn)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #playerRows * 31)
end

refreshList()
Players.PlayerAdded:Connect(function() task.wait(0.3) refreshList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.3) refreshList() selectedTarget = nil end)

-- ============================================================
-- TOMBOL AKSI
-- ============================================================
local function makeBtn(text, y, r, g, b, w)
    local btn = Instance.new("TextButton", main)
    btn.Size = w or UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Freeze / Unfreeze target (2 tombol sejajar)
local freezeBtn   = makeBtn("🧊 Freeze Target",   240, 20, 80, 160, UDim2.new(0.47, 0, 0, 34))
local unfreezeBtn = makeBtn("🔥 Unfreeze Target", 240, 160, 60, 20, UDim2.new(0.47, 0, 0, 34))
unfreezeBtn.Position = UDim2.new(0.52, 0, 0, 240)

-- Freeze All / Unfreeze All (2 tombol sejajar)
local freezeAllBtn   = makeBtn("❄️ Freeze ALL",   284, 10, 60, 120, UDim2.new(0.47, 0, 0, 34))
local unfreezeAllBtn = makeBtn("🔥 Unfreeze ALL", 284, 140, 40, 20, UDim2.new(0.47, 0, 0, 34))
unfreezeAllBtn.Position = UDim2.new(0.52, 0, 0, 284)

-- Lihat frozen list & Refresh
local frozenListBtn = makeBtn("📋 Siapa yang Frozen?", 328, 40, 40, 80)
local refreshBtn    = makeBtn("🔄 Refresh Daftar",     370, 30, 30, 30)

-- ============================================================
-- BUTTON LOGIC
-- ============================================================

freezeBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        setStatus("⚠ Pilih target dulu!", Color3.fromRGB(255, 80, 80))
        return
    end
    FreezePlayer:FireServer(selectedTarget.Name)
    setStatus("🧊 " .. selectedTarget.Name .. " di-freeze!", Color3.fromRGB(0, 200, 255))
end)

unfreezeBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        setStatus("⚠ Pilih target dulu!", Color3.fromRGB(255, 80, 80))
        return
    end
    UnfreezePlayer:FireServer(selectedTarget.Name)
    setStatus("🔥 " .. selectedTarget.Name .. " di-unfreeze!", Color3.fromRGB(0, 255, 150))
end)

freezeAllBtn.MouseButton1Click:Connect(function()
    FreezeAll:FireServer()
    setStatus("❄️ Semua player di-freeze!", Color3.fromRGB(0, 200, 255))
end)

unfreezeAllBtn.MouseButton1Click:Connect(function()
    UnfreezeAll:FireServer()
    setStatus("🔥 Semua player di-unfreeze!", Color3.fromRGB(0, 255, 150))
end)

frozenListBtn.MouseButton1Click:Connect(function()
    if not GetFrozenList then
        setStatus("⚠ GetFrozenList tidak ada!", Color3.fromRGB(255,80,80))
        return
    end
    local list = GetFrozenList:InvokeServer()
    if #list == 0 then
        setStatus("Tidak ada yang frozen", Color3.fromRGB(180,180,180))
    else
        setStatus("Frozen: " .. table.concat(list, ", "), Color3.fromRGB(0, 200, 255))
    end
end)

refreshBtn.MouseButton1Click:Connect(function()
    selectedTarget = nil
    refreshList()
    setStatus("Daftar diperbarui", Color3.fromRGB(0, 255, 150))
end)
