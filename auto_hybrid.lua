-- Auto Teleport GUI + Mode Fly/Reset (Fixed)
-- By Zarukabot

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Border/Frame styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.25, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"
autoBtn.Font = Enum.Font.Gotham
autoBtn.Parent = frame

local autoBtnCorner = Instance.new("UICorner")
autoBtnCorner.CornerRadius = UDim.new(0, 4)
autoBtnCorner.Parent = autoBtn

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
modeBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.TextScaled = true
modeBtn.Text = "Mode: Reset"
modeBtn.Font = Enum.Font.Gotham
modeBtn.Parent = frame

local modeBtnCorner = Instance.new("UICorner")
modeBtnCorner.CornerRadius = UDim.new(0, 4)
modeBtnCorner.Parent = modeBtn

-- Variabel
local autoEnabled = false
local mode = "Reset" -- bisa "Reset" atau "Fly"
local checkpoints = {}
local touchedCheckpoints = {}

-- Ambil semua checkpoint otomatis
local function loadCheckpoints()
    checkpoints = {}
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part:GetAttribute("CheckpointId") then
            table.insert(checkpoints, part)
            
            -- Connect touch event only once
            if not part:GetAttribute("TouchConnected") then
                part:SetAttribute("TouchConnected", true)
                part.Touched:Connect(function(hit)
                    local char = hit.Parent
                    if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
                        touchedCheckpoints[part] = true
                        print("Checkpoint "..tostring(part:GetAttribute("CheckpointId")).." tersentuh!")
                    end
                end)
            end
        end
    end
    
    -- Sort checkpoints by ID if they have numeric IDs
    table.sort(checkpoints, function(a, b)
        local idA = a:GetAttribute("CheckpointId")
        local idB = b:GetAttribute("CheckpointId")
        if tonumber(idA) and tonumber(idB) then
            return tonumber(idA) < tonumber(idB)
        end
        return tostring(idA) < tostring(idB)
    end)
    
    print("Loaded " .. #checkpoints .. " checkpoints")
end

-- Load checkpoints initially
loadCheckpoints()

-- Fungsi Fly ke checkpoint dengan kecepatan 100%
local function flyToCheckpoint(cp)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local goal = cp.Position + Vector3.new(0, 5, 0)
    local distance = (hrp.Position - goal).Magnitude
    
    -- Kecepatan 100 studs per detik
    local speed = 100
    local duration = math.max(0.1, distance / speed)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(goal)})
    
    tween:Play()
    tween.Completed:Wait()
end

-- Fungsi Reset ke checkpoint
local function resetToCheckpoint(cp)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0 -- Lebih aman daripada BreakJoints
        end
    end
    
    -- Wait for respawn
    local newChar = LocalPlayer.CharacterAdded:Wait()
    task.wait(1) -- Wait a bit longer for character to fully load
    
    if newChar then
        local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrp.CFrame = cp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- Ambil checkpoint berikutnya yang belum tersentuh
local function getNextCheckpoint()
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] then
            return cp
        end
    end
    return nil
end

-- Toggle Auto
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"
    autoBtn.BackgroundColor3 = autoEnabled and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(60, 60, 60)

    if autoEnabled then
        task.spawn(function()
            while autoEnabled do
                local nextCp = getNextCheckpoint()
                if nextCp then
                    print("Menuju checkpoint: " .. tostring(nextCp:GetAttribute("CheckpointId")))
                    
                    local success, err = pcall(function()
                        if mode == "Fly" then
                            flyToCheckpoint(nextCp)
                        else
                            resetToCheckpoint(nextCp)
                        end
                    end)
                    
                    if not success then
                        warn("Error saat teleport: " .. tostring(err))
                    end
                    
                    task.wait(1.5) -- delay biar ga lag
                else
                    print("Semua checkpoint sudah diambil ✅")
                    autoEnabled = false
                    autoBtn.Text = "Auto: OFF"
                    autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    break
                end
                task.wait(1)
            end
        end)
    end
end)

-- Ganti Mode
modeBtn.MouseButton1Click:Connect(function()
    if mode == "Reset" then
        mode = "Fly"
        modeBtn.Text = "Mode: Fly"
        modeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
    else
        mode = "Reset"
        modeBtn.Text = "Mode: Reset"
        modeBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    end
end)

-- Reload checkpoints button (optional - bisa dihapus jika tidak perlu)
local reloadBtn = Instance.new("TextButton")
reloadBtn.Size = UDim2.new(0.3, 0, 0.2, 0)
reloadBtn.Position = UDim2.new(0.65, 0, 0.05, 0)
reloadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reloadBtn.Text = "↻"
reloadBtn.TextScaled = true
reloadBtn.Font = Enum.Font.GothamBold
reloadBtn.Parent = frame

local reloadBtnCorner = Instance.new("UICorner")
reloadBtnCorner.CornerRadius = UDim.new(0, 4)
reloadBtnCorner.Parent = reloadBtn

reloadBtn.MouseButton1Click:Connect(function()
    touchedCheckpoints = {}
    loadCheckpoints()
    print("Checkpoints reloaded!")
end)

print("Auto Teleport GUI Loaded ✅")
print("Mode Fly speed: 100 studs/second")
