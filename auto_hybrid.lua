-- LocalScript: Admin Gunung Auto Mendaki
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- ===============================
-- GUI MODERN
-- ===============================
if PlayerGui:FindFirstChild("AdminGunungGUI") then
    PlayerGui.AdminGunungGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminGunungGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0.7, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🌄 Admin Gunung 🌄"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 50)
button.Position = UDim2.new(0.1, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Text = "Auto Mendaki: OFF"
button.Parent = frame

-- ===============================
-- TITLE ADMIN DI ATAS KEPALA
-- ===============================
local function setAdminTitle(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        if player.Character:FindFirstChild("AdminTitle") then
            player.Character.AdminTitle:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "AdminTitle"
        billboard.Adornee = player.Character.Head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "🌄 Admin Gunung 🌄"
        textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold

        billboard.Parent = player.Character
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        setAdminTitle(player)
    end)
end)
-- untuk pemain yang sudah ada
if LocalPlayer.Character then
    setAdminTitle(LocalPlayer)
end

-- ===============================
-- AUTO TELEPORT / AUTO MENDAKI
-- ===============================
local autoMendaki = false

-- Tombol ON/OFF
button.MouseButton1Click:Connect(function()
    autoMendaki = not autoMendaki
    if autoMendaki then
        button.Text = "Auto Mendaki: ON"
    else
        button.Text = "Auto Mendaki: OFF"
    end
end)

-- Fungsi dapatkan semua checkpoint otomatis (nama part = "Checkpoint")
local function getCheckpoints()
    local checkpoints = {}
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():match("checkpoint") then
            table.insert(checkpoints, part)
        end
    end
    -- urut berdasarkan posisi Y (naik gunung)
    table.sort(checkpoints, function(a, b)
        return a.Position.Y < b.Position.Y
    end)
    return checkpoints
end

-- Fungsi Auto Teleport Smooth
local function teleportToCheckpoint(part)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = part.CFrame + Vector3.new(0,3,0)})
    tween:Play()
    tween.Completed:Wait()
end

-- Loop Auto Mendaki
RunService.RenderStepped:Connect(function()
    if autoMendaki then
        local checkpoints = getCheckpoints()
        for _, cp in ipairs(checkpoints) do
            if not autoMendaki then break end
            teleportToCheckpoint(cp)
            wait(0.3)
        end
    end
end)
