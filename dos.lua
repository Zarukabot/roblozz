--// ============================================================
--// TP ALL PLAYERS — RAYFIELD EDITION
--// Cara pakai: Paste di executor
--// ⚠️ Ganti ADMIN_NAME dengan username Roblox kamu!
--// ============================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer

--// ⚠️ GANTI INI
local ADMIN_NAME = "Ryuzooaja"

if player.Name ~= ADMIN_NAME then
    warn("Bukan admin, script berhenti.")
    return
end

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "📍 TP All Players",
    LoadingTitle = "TP Tools",
    LoadingSubtitle = "by " .. ADMIN_NAME,
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ============================================================
-- HELPER
-- ============================================================
local function getMyHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function tpPlayerTo(target, cframe)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframe
    end
end

-- ============================================================
-- TAB: TP ALL
-- ============================================================
local Tab = Window:CreateTab("📍 TP All Players", 4483362458)

Tab:CreateSection("Teleport Semua Player")

-- TP semua ke posisi kamu
Tab:CreateButton({
    Name = "👥 TP Semua Player ke Posisiku",
    Callback = function()
        local myHRP = getMyHRP()
        if not myHRP then
            Rayfield:Notify({ Title = "Gagal", Content = "Character kamu tidak ditemukan", Duration = 3 })
            return
        end
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                tpPlayerTo(p, myHRP.CFrame + offset)
                count += 1
            end
        end
        Rayfield:Notify({
            Title = "✅ Selesai",
            Content = count .. " player diteleport ke posisimu",
            Duration = 3,
        })
    end,
})

-- TP semua ke koordinat custom
Tab:CreateSection("TP ke Koordinat Custom")

local inputX, inputY, inputZ = 0, 0, 0

Tab:CreateInput({
    Name = "X",
    PlaceholderText = "Masukkan X (contoh: 100)",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        inputX = tonumber(val) or 0
    end,
})

Tab:CreateInput({
    Name = "Y",
    PlaceholderText = "Masukkan Y (contoh: 10)",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        inputY = tonumber(val) or 0
    end,
})

Tab:CreateInput({
    Name = "Z",
    PlaceholderText = "Masukkan Z (contoh: 200)",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        inputZ = tonumber(val) or 0
    end,
})

Tab:CreateButton({
    Name = "🚀 TP Semua ke Koordinat ini",
    Callback = function()
        local targetCFrame = CFrame.new(inputX, inputY, inputZ)
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            tpPlayerTo(p, targetCFrame + offset)
            count += 1
        end
        Rayfield:Notify({
            Title = "✅ Selesai",
            Content = count .. " player diteleport ke (" .. inputX .. ", " .. inputY .. ", " .. inputZ .. ")",
            Duration = 4,
        })
    end,
})

-- TP semua ke SpawnLocation
Tab:CreateSection("TP ke Spawn")

Tab:CreateButton({
    Name = "🏁 TP Semua ke SpawnLocation",
    Callback = function()
        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        if not spawn then
            Rayfield:Notify({ Title = "Gagal", Content = "SpawnLocation tidak ditemukan di workspace", Duration = 3 })
            return
        end
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            local offset = Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
            tpPlayerTo(p, spawn.CFrame + offset + Vector3.new(0, 3, 0))
            count += 1
        end
        Rayfield:Notify({
            Title = "✅ Selesai",
            Content = count .. " player diteleport ke Spawn",
            Duration = 3,
        })
    end,
})

-- TP semua saling scatter (random di area luas)
Tab:CreateSection("Scatter / Acak")

Tab:CreateButton({
    Name = "💥 Scatter Semua Player (Random)",
    Callback = function()
        local myHRP = getMyHRP()
        local base = myHRP and myHRP.Position or Vector3.new(0, 10, 0)
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            local randomOffset = Vector3.new(
                math.random(-200, 200),
                math.random(5, 30),
                math.random(-200, 200)
            )
            tpPlayerTo(p, CFrame.new(base + randomOffset))
            count += 1
        end
        Rayfield:Notify({
            Title = "💥 Scattered!",
            Content = count .. " player dilempar ke random posisi",
            Duration = 3,
        })
    end,
})

-- TP semua ke satu titik persis (tumpuk)
Tab:CreateButton({
    Name = "📦 Tumpuk Semua Player (1 Titik)",
    Callback = function()
        local myHRP = getMyHRP()
        local base = myHRP and myHRP.CFrame or CFrame.new(0, 10, 0)
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            tpPlayerTo(p, base)
            count += 1
        end
        Rayfield:Notify({
            Title = "📦 Ditumpuk!",
            Content = count .. " player ditumpuk di satu titik",
            Duration = 3,
        })
    end,
})

-- ============================================================
-- TAB: TP SATU PLAYER
-- ============================================================
local TabSingle = Window:CreateTab("👤 TP Single Player", 4483362458)

TabSingle:CreateSection("Pilih Target")

local selectedTarget = player.Name

local function playerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

local dropdown = TabSingle:CreateDropdown({
    Name = "Target Player",
    Options = playerNames(),
    CurrentOption = {player.Name},
    MultipleOptions = false,
    Flag = "SingleTarget",
    Callback = function(option)
        selectedTarget = option[1] or player.Name
    end,
})

TabSingle:CreateButton({
    Name = "🔄 Refresh Daftar",
    Callback = function()
        dropdown:Refresh(playerNames(), {selectedTarget})
        Rayfield:Notify({ Title = "Refreshed", Content = "Daftar diperbarui", Duration = 2 })
    end,
})

TabSingle:CreateSection("Aksi")

TabSingle:CreateButton({
    Name = "📍 TP Target ke Posisiku",
    Callback = function()
        local myHRP = getMyHRP()
        local t = Players:FindFirstChild(selectedTarget)
        if not myHRP or not t then
            Rayfield:Notify({ Title = "Gagal", Content = "Character tidak ditemukan", Duration = 2 })
            return
        end
        tpPlayerTo(t, myHRP.CFrame + Vector3.new(3, 0, 0))
        Rayfield:Notify({ Title = "✅ TP", Content = selectedTarget .. " diteleport ke kamu", Duration = 2 })
    end,
})

TabSingle:CreateButton({
    Name = "🚀 TP Aku ke Target",
    Callback = function()
        local myHRP = getMyHRP()
        local t = Players:FindFirstChild(selectedTarget)
        local tHRP = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP or not tHRP then
            Rayfield:Notify({ Title = "Gagal", Content = "Character tidak ditemukan", Duration = 2 })
            return
        end
        myHRP.CFrame = tHRP.CFrame + Vector3.new(3, 0, 0)
        Rayfield:Notify({ Title = "✅ TP", Content = "Kamu diteleport ke " .. selectedTarget, Duration = 2 })
    end,
})

-- ============================================================
-- WELCOME NOTIF
-- ============================================================
Rayfield:Notify({
    Title = "✅ TP Tools Aktif",
    Content = "Selamat datang, " .. player.Name,
    Duration = 4,
})
