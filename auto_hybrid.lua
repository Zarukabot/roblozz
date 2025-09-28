-- Auto Checkpoint Teleport (Fly / Reset Mode)
-- By Zarukabot

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "CheckpointGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.Active, frame.Draggable = true, true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.BackgroundTransparency = 1
title.Text = "Auto Checkpoint"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0.8,0,0.25,0)
autoBtn.Position = UDim2.new(0.1,0,0.3,0)
autoBtn.Text = "Auto: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.TextScaled = true

local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.new(0.8,0,0.25,0)
modeBtn.Position = UDim2.new(0.1,0,0.6,0)
modeBtn.Text = "Mode: Fly"
modeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.TextScaled = true

-- Variabel
local autoEnabled = false
local flyMode = true -- default Fly
local checkpoints, visited = {}, {}

-- Cari checkpoint otomatis
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:GetAttribute("CheckpointId")) then
        table.insert(checkpoints, obj)
    end
end
table.sort(checkpoints, function(a,b) return a.Position.Magnitude < b.Position.Magnitude end)

-- Fungsi teleport (Reset)
local function resetTeleport(cp)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cp.CFrame + Vector3.new(0,3,0)
end

-- Fungsi Fly (Tween ke checkpoint)
local function flyTeleport(cp)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local distance = (hrp.Position - cp.Position).Magnitude
    local speed = 100 -- studs per second
    local time = distance / speed

    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = cp.CFrame + Vector3.new(0,3,0)
    })
    tween:Play()
    tween.Completed:Wait()
end

-- Auto loop
local function autoLoop()
    task.spawn(function()
        while autoEnabled do
            for _, cp in ipairs(checkpoints) do
                if not visited[cp] then
                    if flyMode then
                        flyTeleport(cp)
                    else
                        resetTeleport(cp)
                    end
                    visited[cp] = true
                    task.wait(1) -- delay biar ga lag
                end
            end
            task.wait(1)
        end
    end)
end

-- Tombol
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"
    if autoEnabled then autoLoop() end
end)

modeBtn.MouseButton1Click:Connect(function()
    flyMode = not flyMode
    modeBtn.Text = flyMode and "Mode: Fly" or "Mode: Reset"
end)

print("✅ Auto Checkpoint GUI Loaded (Fly / Reset)")
