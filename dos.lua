--// ============================================================
--// ADMIN PANEL — RAYFIELD EDITION
--// Cara pasang: Paste di executor
--// ⚠️ Ganti ADMIN_NAME dengan username Roblox kamu!
--// ============================================================

local Players   = game:GetService("Players")
local player    = Players.LocalPlayer

--// ⚠️ GANTI INI
local ADMIN_NAME = "NamaKamuDisini"

if player.Name ~= ADMIN_NAME then
    warn("Bukan admin, script berhenti.")
    return
end

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Buat Window
local Window = Rayfield:CreateWindow({
    Name = "⚡ Admin Panel",
    LoadingTitle = "Admin Panel",
    LoadingSubtitle = "by " .. ADMIN_NAME,
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

-- ============================================================
-- TARGET PLAYER (disimpan di variable)
-- ============================================================
local selectedTarget = player.Name -- default diri sendiri

local function getTargetPlayer()
    return Players:FindFirstChild(selectedTarget)
end

local function getTargetChar()
    local t = getTargetPlayer()
    if t and t.Character then return t.Character end
    return nil
end

local function getHumanoid()
    local char = getTargetChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function getHRP()
    local char = getTargetChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function playerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

-- ============================================================
-- TAB 1: TARGET
-- ============================================================
local TabTarget = Window:CreateTab("👤 Target", 4483362458)

TabTarget:CreateSection("Pilih Target Player")

local targetDropdown = TabTarget:CreateDropdown({
    Name = "Target Player",
    Options = playerNames(),
    CurrentOption = {player.Name},
    MultipleOptions = false,
    Flag = "TargetPlayer",
    Callback = function(option)
        selectedTarget = option[1] or player.Name
        Rayfield:Notify({
            Title = "Target dipilih",
            Content = "Target: " .. selectedTarget,
            Duration = 2,
        })
    end,
})

-- Refresh daftar player
TabTarget:CreateButton({
    Name = "🔄 Refresh Daftar Player",
    Callback = function()
        targetDropdown:Refresh(playerNames(), {player.Name})
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Daftar player diperbarui",
            Duration = 2,
        })
    end,
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    targetDropdown:Refresh(playerNames(), {selectedTarget})
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    targetDropdown:Refresh(playerNames(), {player.Name})
    selectedTarget = player.Name
end)

-- ============================================================
-- TAB 2: PLAYER ACTIONS
-- ============================================================
local TabActions = Window:CreateTab("🎮 Actions", 4483362458)

TabActions:CreateSection("Teleport")

TabActions:CreateButton({
    Name = "📍 Teleport Target ke Aku",
    Callback = function()
        local myHRP  = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local tgtHRP = getHRP()
        if myHRP and tgtHRP then
            tgtHRP.CFrame = myHRP.CFrame + Vector3.new(3, 0, 0)
            Rayfield:Notify({ Title = "Teleport", Content = selectedTarget .. " diteleport ke kamu", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Gagal", Content = "Character tidak ditemukan", Duration = 2 })
        end
    end,
})

TabActions:CreateButton({
    Name = "🚀 Teleport Aku ke Target",
    Callback = function()
        local myHRP  = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local tgtHRP = getHRP()
        if myHRP and tgtHRP then
            myHRP.CFrame = tgtHRP.CFrame + Vector3.new(3, 0, 0)
            Rayfield:Notify({ Title = "Teleport", Content = "Kamu diteleport ke " .. selectedTarget, Duration = 2 })
        else
            Rayfield:Notify({ Title = "Gagal", Content = "Character tidak ditemukan", Duration = 2 })
        end
    end,
})

TabActions:CreateSection("Freeze & Reset")

local frozenState = false
TabActions:CreateToggle({
    Name = "🧊 Freeze Target",
    CurrentValue = false,
    Flag = "FreezeToggle",
    Callback = function(state)
        local hrp = getHRP()
        if hrp then
            hrp.Anchored = state
            frozenState = state
            Rayfield:Notify({
                Title = state and "Frozen" or "Unfrozen",
                Content = selectedTarget .. (state and " di-freeze" or " di-unfreeze"),
                Duration = 2,
            })
        end
    end,
})

TabActions:CreateButton({
    Name = "💀 Reset / Kill Target",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.Health = 0
            Rayfield:Notify({ Title = "Reset", Content = selectedTarget .. " di-reset", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Gagal", Content = "Humanoid tidak ditemukan", Duration = 2 })
        end
    end,
})

-- ============================================================
-- TAB 3: SPEED & JUMP
-- ============================================================
local TabStats = Window:CreateTab("⚡ Speed & Jump", 4483362458)

TabStats:CreateSection("WalkSpeed")

TabStats:CreateSlider({
    Name = "⚡ Speed Target",
    Range = {0, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(val)
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = val
        end
    end,
})

TabStats:CreateButton({
    Name = "🔁 Reset Speed ke Default (16)",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            Rayfield:Notify({ Title = "Reset", Content = "Speed dikembalikan ke 16", Duration = 2 })
        end
    end,
})

TabStats:CreateSection("JumpPower")

TabStats:CreateSlider({
    Name = "🦘 Jump Power Target",
    Range = {0, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(val)
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = val
        end
    end,
})

TabStats:CreateButton({
    Name = "🔁 Reset Jump ke Default (50)",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = 50
            Rayfield:Notify({ Title = "Reset", Content = "Jump dikembalikan ke 50", Duration = 2 })
        end
    end,
})

-- ============================================================
-- TAB 4: SELF (untuk diri sendiri)
-- ============================================================
local TabSelf = Window:CreateTab("🧍 Self", 4483362458)

TabSelf:CreateSection("Cheat Diri Sendiri")

TabSelf:CreateToggle({
    Name = "🌊 Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(state)
        _G.InfJump = state
        if state then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfJump then
                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end,
})

TabSelf:CreateToggle({
    Name = "🏃 Speed Boost (x3)",
    CurrentValue = false,
    Flag = "SelfSpeed",
    Callback = function(state)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state and 48 or 16
        end
    end,
})

TabSelf:CreateToggle({
    Name = "🦅 Fly Mode",
    CurrentValue = false,
    Flag = "FlyMode",
    Callback = function(state)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if state then
            hum.PlatformStand = true
            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "FlyGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 9e4
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero

            local UIS = game:GetService("UserInputService")
            local cam = workspace.CurrentCamera

            game:GetService("RunService").RenderStepped:Connect(function()
                if not _G.FlyActive then return end
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                bv.Velocity = dir * 60
                bg.CFrame = cam.CFrame
            end)
            _G.FlyActive = true
        else
            _G.FlyActive = false
            hum.PlatformStand = false
            if hrp:FindFirstChild("FlyGyro")    then hrp.FlyGyro:Destroy() end
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        end
    end,
})

TabSelf:CreateButton({
    Name = "❤️ Full Heal Diri Sendiri",
    Callback = function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            Rayfield:Notify({ Title = "Healed", Content = "HP penuh!", Duration = 2 })
        end
    end,
})

-- ============================================================
-- TAB 5: INFO
-- ============================================================
local TabInfo = Window:CreateTab("📊 Info", 4483362458)

TabInfo:CreateSection("Server Info")

TabInfo:CreateButton({
    Name = "📋 Lihat Info Server",
    Callback = function()
        local playerList = ""
        for _, p in ipairs(Players:GetPlayers()) do
            playerList = playerList .. p.Name .. ", "
        end
        Rayfield:Notify({
            Title = "Server Info",
            Content = string.format(
                "Players: %d/%d\nJob ID: %s",
                #Players:GetPlayers(),
                Players.MaxPlayers,
                game.JobId ~= "" and string.sub(game.JobId, 1, 8) .. "..." or "Studio"
            ),
            Duration = 6,
        })
    end,
})

TabInfo:CreateButton({
    Name = "📋 Lihat Semua Player",
    Callback = function()
        local list = ""
        for i, p in ipairs(Players:GetPlayers()) do
            list = list .. i .. ". " .. p.Name .. "\n"
        end
        Rayfield:Notify({
            Title = "Player List (" .. #Players:GetPlayers() .. ")",
            Content = list,
            Duration = 8,
        })
    end,
})

-- ============================================================
-- NOTIF SELAMAT DATANG
-- ============================================================
Rayfield:Notify({
    Title = "✅ Admin Panel Aktif",
    Content = "Selamat datang, " .. player.Name .. "!",
    Duration = 4,
})
