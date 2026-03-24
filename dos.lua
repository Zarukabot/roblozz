--// ============================================================
--// EMERGENCY ALARM SYSTEM — RAYFIELD EDITION
--// Efek suara darurat + visual alert untuk semua player
--// Cara pakai: Paste di executor
--// ⚠️ Ganti ADMIN_NAME dengan username Roblox kamu!
--// ============================================================

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local Lighting       = game:GetService("Lighting")
local player         = Players.LocalPlayer

--// ⚠️ GANTI INI
local ADMIN_NAME = "Ryuzooaja"

if player.Name ~= ADMIN_NAME then
    warn("Bukan admin, script berhenti.")
    return
end

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🚨 Emergency System",
    LoadingTitle = "Emergency Tools",
    LoadingSubtitle = "by " .. ADMIN_NAME,
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ============================================================
-- VARIABLES
-- ============================================================
local alarmActive     = false
local alarmConnection = nil
local sounds          = {}
local gui             = player:WaitForChild("PlayerGui")

-- Sound IDs Roblox built-in (bebas pakai)
local SOUND_IDS = {
    alarm    = 2865227271,  -- alarm sirine
    boom     = 130113322,   -- ledakan
    warning  = 1843198752,  -- warning beep
    siren    = 138081500,   -- sirine panjang
}

-- ============================================================
-- HELPER: BUAT SOUND DI WORKSPACE
-- ============================================================
local function playSound(id, volume, looped)
    local s = Instance.new("Sound", workspace)
    s.SoundId = "rbxassetid://" .. id
    s.Volume = volume or 0.8
    s.Looped = looped or false
    s:Play()
    table.insert(sounds, s)
    return s
end

local function stopAllSounds()
    for _, s in pairs(sounds) do
        if s and s.Parent then
            s:Stop()
            s:Destroy()
        end
    end
    sounds = {}
end

-- ============================================================
-- VISUAL ALERT (merah flash di layar)
-- ============================================================
local alertGui = nil

local function createAlertOverlay(color, text)
    if alertGui then alertGui:Destroy() end

    alertGui = Instance.new("ScreenGui", gui)
    alertGui.Name = "EmergencyOverlay"
    alertGui.ResetOnSpawn = false
    alertGui.DisplayOrder = 999

    -- Flash overlay
    local overlay = Instance.new("Frame", alertGui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = color
    overlay.BackgroundTransparency = 0.7
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 10

    -- Border tepi merah
    local border = Instance.new("Frame", alertGui)
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke", border)
    stroke.Color = color
    stroke.Thickness = 12

    -- Teks peringatan
    local label = Instance.new("TextLabel", alertGui)
    label.Size = UDim2.new(1, 0, 0, 80)
    label.Position = UDim2.new(0, 0, 0.5, -40)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.ZIndex = 11

    -- Flash animasi
    local flashing = true
    task.spawn(function()
        while flashing and alertGui and alertGui.Parent do
            TweenService:Create(overlay, TweenInfo.new(0.4), { BackgroundTransparency = 0.85 }):Play()
            task.wait(0.4)
            TweenService:Create(overlay, TweenInfo.new(0.4), { BackgroundTransparency = 0.5 }):Play()
            task.wait(0.4)
        end
    end)

    return function()
        flashing = false
        if alertGui then alertGui:Destroy() alertGui = nil end
    end
end

local stopOverlay = nil

-- ============================================================
-- TAB 1: ALARM & SIRINE
-- ============================================================
local TabAlarm = Window:CreateTab("🚨 Alarm & Sirine", 4483362458)

TabAlarm:CreateSection("Alarm Darurat")

TabAlarm:CreateToggle({
    Name = "🚨 Aktifkan Alarm Darurat (Loop)",
    CurrentValue = false,
    Flag = "AlarmToggle",
    Callback = function(state)
        if state then
            alarmActive = true
            playSound(SOUND_IDS.alarm, 0.9, true)
            stopOverlay = createAlertOverlay(Color3.fromRGB(255, 30, 30), "⚠️ DARURAT! ⚠️")
            Rayfield:Notify({ Title = "🚨 ALARM AKTIF", Content = "Alarm darurat menyala!", Duration = 3 })
        else
            alarmActive = false
            stopAllSounds()
            if stopOverlay then stopOverlay() stopOverlay = nil end
            Rayfield:Notify({ Title = "✅ Alarm Mati", Content = "Alarm dimatikan", Duration = 2 })
        end
    end,
})

TabAlarm:CreateToggle({
    Name = "🔵 Sirine Polisi (Loop)",
    CurrentValue = false,
    Flag = "SirenToggle",
    Callback = function(state)
        if state then
            playSound(SOUND_IDS.siren, 0.8, true)
            stopOverlay = createAlertOverlay(Color3.fromRGB(30, 100, 255), "🚔 SIRINE AKTIF 🚔")
            Rayfield:Notify({ Title = "🔵 Sirine", Content = "Sirine polisi menyala!", Duration = 3 })
        else
            stopAllSounds()
            if stopOverlay then stopOverlay() stopOverlay = nil end
        end
    end,
})

TabAlarm:CreateButton({
    Name = "⏹ Stop Semua Suara & Visual",
    Callback = function()
        stopAllSounds()
        if stopOverlay then stopOverlay() stopOverlay = nil end
        Rayfield:Notify({ Title = "⏹ Stopped", Content = "Semua suara dan visual dimatikan", Duration = 2 })
    end,
})

-- ============================================================
-- TAB 2: BOOM / LEDAKAN
-- ============================================================
local TabBoom = Window:CreateTab("💥 Boom", 4483362458)

TabBoom:CreateSection("Efek Ledakan")

TabBoom:CreateButton({
    Name = "💥 Boom! (Sekali)",
    Callback = function()
        playSound(SOUND_IDS.boom, 1, false)
        local stop = createAlertOverlay(Color3.fromRGB(255, 120, 0), "💥 BOOM! 💥")
        task.delay(1.5, function()
            stop()
            stopAllSounds()
        end)
        Rayfield:Notify({ Title = "💥 BOOM", Content = "Suara ledakan diputar!", Duration = 2 })
    end,
})

TabBoom:CreateButton({
    Name = "💥💥 Multi Boom (5x)",
    Callback = function()
        task.spawn(function()
            for i = 1, 5 do
                playSound(SOUND_IDS.boom, 1, false)
                local stop = createAlertOverlay(
                    Color3.fromRGB(math.random(200,255), math.random(50,150), 0),
                    "💥 BOOM " .. i .. "! 💥"
                )
                task.wait(0.3)
                stop()
                task.wait(0.5)
            end
            stopAllSounds()
        end)
        Rayfield:Notify({ Title = "💥 Multi Boom", Content = "5x ledakan!", Duration = 3 })
    end,
})

-- ============================================================
-- TAB 3: WARNING SYSTEM
-- ============================================================
local TabWarn = Window:CreateTab("⚠️ Warning", 4483362458)

TabWarn:CreateSection("Pesan Peringatan")

local warnText = "⚠️ PERINGATAN SISTEM ⚠️"

TabWarn:CreateInput({
    Name = "Teks Peringatan",
    PlaceholderText = "Masukkan teks peringatan...",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        if val ~= "" then warnText = val end
    end,
})

TabWarn:CreateButton({
    Name = "📢 Tampilkan Peringatan",
    Callback = function()
        playSound(SOUND_IDS.warning, 0.8, false)
        local stop = createAlertOverlay(Color3.fromRGB(255, 200, 0), warnText)
        task.delay(3, function()
            stop()
        end)
        Rayfield:Notify({ Title = "📢 Warning", Content = "Peringatan ditampilkan!", Duration = 2 })
    end,
})

TabWarn:CreateButton({
    Name = "🔴 Warning Merah Darurat",
    Callback = function()
        playSound(SOUND_IDS.alarm, 0.9, false)
        local stop = createAlertOverlay(Color3.fromRGB(255, 0, 0), "🔴 " .. warnText .. " 🔴")
        task.delay(4, function()
            stop()
            stopAllSounds()
        end)
    end,
})

TabWarn:CreateButton({
    Name = "🟡 Warning Kuning",
    Callback = function()
        playSound(SOUND_IDS.warning, 0.7, false)
        local stop = createAlertOverlay(Color3.fromRGB(255, 180, 0), "🟡 " .. warnText .. " 🟡")
        task.delay(3, function()
            stop()
            stopAllSounds()
        end)
    end,
})

-- ============================================================
-- TAB 4: LIGHTING EFEK
-- ============================================================
local TabLight = Window:CreateTab("💡 Lighting", 4483362458)

TabLight:CreateSection("Efek Cahaya Darurat")

local originalAmbient    = Lighting.Ambient
local originalOutdoor    = Lighting.OutdoorAmbient
local lightingActive     = false
local lightingConnection = nil

TabLight:CreateToggle({
    Name = "🔴 Red Alert Lighting",
    CurrentValue = false,
    Flag = "RedLighting",
    Callback = function(state)
        if state then
            lightingActive = true
            lightingConnection = RunService.Heartbeat:Connect(function()
                if not lightingActive then return end
                local t = tick() * 3
                local intensity = (math.sin(t) + 1) / 2
                Lighting.Ambient = Color3.fromRGB(
                    math.floor(150 * intensity), 0, 0
                )
                Lighting.OutdoorAmbient = Color3.fromRGB(
                    math.floor(100 * intensity), 0, 0
                )
            end)
        else
            lightingActive = false
            if lightingConnection then
                lightingConnection:Disconnect()
                lightingConnection = nil
            end
            Lighting.Ambient = originalAmbient
            Lighting.OutdoorAmbient = originalOutdoor
        end
    end,
})

TabLight:CreateButton({
    Name = "🔁 Reset Lighting ke Normal",
    Callback = function()
        lightingActive = false
        if lightingConnection then lightingConnection:Disconnect() lightingConnection = nil end
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoor
        Rayfield:Notify({ Title = "✅ Reset", Content = "Lighting dikembalikan normal", Duration = 2 })
    end,
})

-- ============================================================
-- WELCOME
-- ============================================================
Rayfield:Notify({
    Title = "🚨 Emergency System Aktif",
    Content = "Selamat datang, " .. player.Name,
    Duration = 4,
})
