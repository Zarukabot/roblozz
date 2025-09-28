-- 🚀 Modern GUI Auto Teleport - Manual & Auto Mode
print("===============================================")
print("🚀 LOADING MODERN AUTO TELEPORT GUI...")
print("===============================================")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
print("✅ PlayerGui loaded")

-- Hapus GUI lama
if PlayerGui:FindFirstChild("AutoTeleportGUI") then
    PlayerGui.AutoTeleportGUI:Destroy()
    wait(0.5)
    print("🗑️  Old GUI removed")
end

-- === CREATE GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Shadow Effect
local MainShadow = Instance.new("Frame")
MainShadow.Size = UDim2.new(1, 0, 1, 0)
MainShadow.Position = UDim2.new(0, 0, 0, 0)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.7
MainShadow.ZIndex = 0
MainShadow.Parent = MainFrame
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 15)
ShadowCorner.Parent = MainShadow

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Title.BorderSizePixel = 0
Title.Text = "🚀 Modern Auto Teleport"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Progress Label
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Size = UDim2.new(1, -20, 0, 25)
ProgressLabel.Position = UDim2.new(0, 10, 0, 85)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "Progress: 0/0"
ProgressLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
ProgressLabel.TextSize = 13
ProgressLabel.Font = Enum.Font.Gotham
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.Parent = MainFrame

-- Mode Button
local ModeButton = Instance.new("TextButton")
ModeButton.Size = UDim2.new(0, 300, 0, 30)
ModeButton.Position = UDim2.new(0, 10, 0, 115)
ModeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.Text = "Mode: Auto"
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 14
ModeButton.Parent = MainFrame

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 8)
ModeCorner.Parent = ModeButton

-- Start Button
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0, 140, 0, 40)
StartButton.Position = UDim2.new(0, 10, 1, -60)
StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
StartButton.Text = "▶ START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16
StartButton.Parent = MainFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartButton

-- Stop Button
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0, 140, 0, 40)
StopButton.Position = UDim2.new(1, -150, 1, -60)
StopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StopButton.Text = "⏹ STOP"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 16
StopButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopButton

-- === VARIABLES ===
local autoEnabled = false
local manualMode = false
local checkpoints = {}
local touchedCheckpoints = {}

-- === FUNCTIONS ===
local function updateStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

local function getUntouchedCount()
    local count = 0
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] then
            count = count + 1
        end
    end
    return count
end

local function updateProgress()
    ProgressLabel.Text = "Progress: " .. (#checkpoints - getUntouchedCount()) .. "/" .. #checkpoints
end

local function getNextUntouched()
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] and cp.Parent then
            return cp
        end
    end
    return nil
end

local function setupTouch(part)
    if part:GetAttribute("TouchSetup") then return end
    part:SetAttribute("TouchSetup", true)
    
    part.Touched:Connect(function(hit)
        if hit.Parent == LocalPlayer.Character then
            if manualMode then
                if not table.find(checkpoints, part) then
                    table.insert(checkpoints, part)
                    touchedCheckpoints[part] = false
                    print("✅ Manual checkpoint added: " .. part.Name)
                    updateProgress()
                end
            end
        end
    end)
end

local function findCheckpoints()
    if manualMode then
        updateStatus("Manual mode: touch checkpoints to register", Color3.fromRGB(255, 200, 0))
        return
    end

    updateStatus("Auto scanning checkpoints...", Color3.fromRGB(255, 200, 0))
    checkpoints = {}
    touchedCheckpoints = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("checkpoint") or name:find("stage") or name:find("pad") then
                table.insert(checkpoints, obj)
                touchedCheckpoints[obj] = false
                setupTouch(obj)
                print("✅ Auto checkpoint detected: " .. obj.Name)
            end
        end
    end

    updateProgress()
    updateStatus("Auto scan complete: " .. #checkpoints .. " checkpoints", Color3.fromRGB(50, 255, 50))
end

local function teleportTo(part)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetPos = part.Position + Vector3.new(0,5,0)
    local distance = (hrp.Position - targetPos).Magnitude
    local duration = math.max(0.8, distance/50)

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function startAutoTeleport()
    updateStatus("Teleporting...", Color3.fromRGB(50,200,255))
    spawn(function()
        while autoEnabled do
            local nextCp = getNextUntouched()
            if not nextCp then
                updateStatus("Completed all checkpoints!", Color3.fromRGB(50,255,50))
                autoEnabled = false
                StartButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
                break
            end

            updateStatus("Teleporting to: " .. nextCp.Name, Color3.fromRGB(255,200,0))
            local success = teleportTo(nextCp)
            if success then
                touchedCheckpoints[nextCp] = true
                updateProgress()
                wait(1)
            else
                wait(2)
            end
        end
    end)
end

-- === BUTTON EVENTS ===
StartButton.MouseButton1Click:Connect(function()
    if not autoEnabled then
        if #checkpoints == 0 then findCheckpoints() end
        if #checkpoints > 0 then
            autoEnabled = true
            StartButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
            startAutoTeleport()
        else
            updateStatus("No checkpoints to teleport!", Color3.fromRGB(255,50,50))
        end
    end
end)

StopButton.MouseButton1Click:Connect(function()
    if autoEnabled then
        autoEnabled = false
        StartButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
        updateStatus("Stopped by user", Color3.fromRGB(255,100,0))
    end
end)

ModeButton.MouseButton1Click:Connect(function()
    manualMode = not manualMode
    if manualMode then
        ModeButton.Text = "Mode: Manual"
        updateStatus("Manual mode: touch checkpoints to register", Color3.fromRGB(255,200,0))
    else
        ModeButton.Text = "Mode: Auto"
        updateStatus("Auto mode: ready to teleport", Color3.fromRGB(50,200,255))
    end
end)

-- INITIALIZE
wait(1)
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
wait(1)
findCheckpoints()
updateStatus("Ready!", Color3.fromRGB(50,200,255))
print("✅ GUI LOADED SUCCESSFULLY!")
