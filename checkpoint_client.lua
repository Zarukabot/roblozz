-- Client-only Checkpoint + Dashboard (single-file)
-- Usage: loadstring(game:HttpGet("https://your-host.com/checkpoint_client.lua"))()
-- NOTE: Use only in your own game or with permission.

if not (game and game.Players) then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then return end

-- Config
local SCAN_INTERVAL = 2           -- deteksi ulang daftar checkpoint setiap N detik
local DIST_THRESHOLD = 6          -- jarak (studs) untuk dianggap "menyentuh" checkpoint
local NOTIF_TIME = 2.8            -- durasi notifikasi on-screen
local TELEPORT_OFFSET = Vector3.new(0, 3, 0) -- posisi spawn di atas part

-- State
local checkpoints = {}            -- { [id] = {pos = Vector3, name = string} }
local reached = {}                -- [id] = timestamp when reached
local lastCheckpointId = 0
local autoRespawn = true
local enabled = true              -- master switch (jika mau disable total)
local _uid = tostring(player.UserId) .. "-" .. HttpService:GenerateGUID(false)

-- Helpers
local function scanForCheckpoints()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local id = obj:GetAttribute and obj:GetAttribute("CheckpointId") or nil
            if id then
                -- allow non-unique names; keep highest precedence by id (if multiple same id, first wins)
                if not found[id] then
                    found[id] = {
                        pos = obj.Position,
                        name = obj.Name,
                    }
                end
            end
        end
    end
    checkpoints = found
end

-- initial scan
scanForCheckpoints()
spawn(function()
    while enabled do
        task.wait(SCAN_INTERVAL)
        scanForCheckpoints()
    end
end)

-- GUI
local function makeGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CheckpointClientUI_" .. _uid
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Notification label
    local label = Instance.new("TextLabel")
    label.Name = "CheckpointLabel"
    label.Parent = screenGui
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0.04, 0)
    label.Size = UDim2.new(0.36, 0, 0.06, 0)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0,0,0)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Visible = false
    label.Text = ""

    local function showNotification(txt, dur)
        label.Text = txt
        label.Visible = true
        task.delay(dur or NOTIF_TIME, function()
            if label then label.Visible = false end
        end)
    end

    -- Dashboard frame
    local frame = Instance.new("Frame")
    frame.Name = "CPDashboard"
    frame.Parent = screenGui
    frame.Size = UDim2.new(0.18, 0, 0.12, 0)
    frame.Position = UDim2.new(0.8, 0, 0.82, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0,0)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0.28,0)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Checkpoint"
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255,255,255)

    local btnAuto = Instance.new("TextButton", frame)
    btnAuto.Size = UDim2.new(1,0,0.36,0)
    btnAuto.Position = UDim2.new(0,0,0.32,0)
    btnAuto.TextScaled = true
    btnAuto.Text = "AutoRespawn: ON"
    btnAuto.Name = "BtnAuto"

    local btnReset = Instance.new("TextButton", frame)
    btnReset.Size = UDim2.new(1,0,0.36,0)
    btnReset.Position = UDim2.new(0,0,0.68,0)
    btnReset.TextScaled = true
    btnReset.Text = "Reset to Start"
    btnReset.Name = "BtnReset"

    -- Styling quick (no explicit colors required but set simple)
    btnAuto.BackgroundColor3 = Color3.fromRGB(24, 150, 24)
    btnReset.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
    title.BackgroundTransparency = 1

    -- Button behaviors
    btnAuto.MouseButton1Click:Connect(function()
        autoRespawn = not autoRespawn
        if autoRespawn then
            btnAuto.Text = "AutoRespawn: ON"
            btnAuto.BackgroundColor3 = Color3.fromRGB(24, 150, 24)
            showNotification("Auto respawn: ON", 1.6)
        else
            btnAuto.Text = "AutoRespawn: OFF"
            btnAuto.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            showNotification("Auto respawn: OFF", 1.6)
        end
    end)

    btnReset.MouseButton1Click:Connect(function()
        -- reset local checkpoint
        reached = {}
        lastCheckpointId = 0
        showNotification("Checkpoint reset to start", 1.6)
    end)

    return {
        gui = screenGui,
        notify = showNotification,
        autoButton = btnAuto,
        resetButton = btnReset,
    }
end

local UI = makeGui()

-- distance check loop
local function distance(a,b) return (a-b).Magnitude end

local playerHRP
local function getHRP()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- debounce per checkpoint id
local cpDebounce = {}

local function tryCheckProximity()
    playerHRP = getHRP()
    if not playerHRP then return end
    local pos = playerHRP.Position
    for id, info in pairs(checkpoints) do
        local idnum = tonumber(id)
        if idnum then
            local d = distance(pos, info.pos)
            if d <= DIST_THRESHOLD then
                if not reached[idnum] and not cpDebounce[idnum] then
                    cpDebounce[idnum] = true
                    task.delay(1.2, function() cpDebounce[idnum] = nil end)

                    reached[idnum] = tick()
                    if idnum > lastCheckpointId then
                        lastCheckpointId = idnum
                    end

                    UI.notify("Checkpoint "..tostring(idnum).." tercapai!", NOTIF_TIME)
                end
            end
        end
    end
end

-- run proximity check every frame (lightweight)
local heartbeatConn
heartbeatConn = RunService.Heartbeat:Connect(function(dt)
    if not enabled then return end
    -- cheap check: do proximity every 0.12s to reduce cost
    if not player.Character then return end
    tryCheckProximity()
end)

-- Teleport on respawn if auto enabled
local function onCharacterAdded(char)
    -- small wait for HRP
    task.wait(0.12)
    local hrp = char:WaitForChild("HumanoidRootPart", 2) or char:FindFirstChild("HumanoidRootPart") 
    if not hrp then return end

    if autoRespawn and lastCheckpointId and checkpoints[lastCheckpointId] then
        -- client-side teleport
        local cp = checkpoints[lastCheckpointId]
        if cp and cp.pos then
            pcall(function()
                hrp.CFrame = CFrame.new(cp.pos + TELEPORT_OFFSET)
            end)
            UI.notify("Respawn -> Checkpoint "..tostring(lastCheckpointId), 1.8)
        end
    end
end

player.CharacterAdded:Connect(onCharacterAdded)
-- if character already exists
if player.Character then
    spawn(function() onCharacterAdded(player.Character) end)
end

-- Small command: toggle UI visibility with F9 (optional)
do
    local uis = game:GetService("UserInputService")
    uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F9 then
            if UI.gui.Enabled == nil then UI.gui.Enabled = true end
            UI.gui.Enabled = not UI.gui.Enabled
            UI.notify("Dashboard "..(UI.gui.Enabled and "Shown" or "Hidden"), 1.2)
        end
    end)
end

-- Clean up when player leaves or script disabled
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        enabled = false
        if heartbeatConn then heartbeatConn:Disconnect() end
    end
end)

-- Final ready notification
UI.notify("Checkpoint client ready. AutoRespawn: "..(autoRespawn and "ON" or "OFF"), 2.6)
print("[CheckpointClient] ready - scanning workspace for parts with Attribute 'CheckpointId'")
