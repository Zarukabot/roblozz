-- Working GUI Auto Teleport - Pasti Jalan!
print("=" .. string.rep("=", 50))
print("🚀 LOADING AUTO TELEPORT GUI...")
print("=" .. string.rep("=", 50))

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Tunggu PlayerGui
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
print("✅ PlayerGui loaded")

-- Hapus GUI lama jika ada
if PlayerGui:FindFirstChild("AutoTeleportGUI") then
    PlayerGui:FindFirstChild("AutoTeleportGUI"):Destroy()
    wait(0.5)
    print("🗑️  Old GUI removed")
end

-- === CREATE GUI ===
print("🎨 Creating GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.BorderSizePixel = 0
Title.Text = "🚀 AUTO TELEPORT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Progress Label
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "Progress"
ProgressLabel.Size = UDim2.new(1, -20, 0, 25)
ProgressLabel.Position = UDim2.new(0, 10, 0, 85)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "Progress: 0/0"
ProgressLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ProgressLabel.TextSize = 13
ProgressLabel.Font = Enum.Font.Gotham
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.Parent = MainFrame

-- Start Button
local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Size = UDim2.new(0, 130, 0, 40)
StartButton.Position = UDim2.new(0, 10, 1, -50)
StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
StartButton.BorderSizePixel = 0
StartButton.Text = "▶ START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 16
StartButton.Font = Enum.Font.GothamBold
StartButton.Parent = MainFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartButton

-- Stop Button
local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(0, 130, 0, 40)
StopButton.Position = UDim2.new(1, -140, 1, -50)
StopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StopButton.BorderSizePixel = 0
StopButton.Text = "⏹ STOP"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 16
StopButton.Font = Enum.Font.GothamBold
StopButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopButton

print("✅ GUI created successfully!")

-- === VARIABLES ===
local autoEnabled = false
local checkpoints = {}
local touchedCheckpoints = {}

-- === FUNCTIONS ===

local function updateStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

local function updateProgress()
    local total = #checkpoints
    local done = total - getUntouchedCount()
    ProgressLabel.Text = "Progress: " .. done .. "/" .. total
end

function getUntouchedCount()
    local count = 0
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] then
            count = count + 1
        end
    end
    return count
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
        if hit.Parent and Players:GetPlayerFromCharacter(hit.Parent) == LocalPlayer then
            if not touchedCheckpoints[part] then
                touchedCheckpoints[part] = true
                print("✅ Touched: " .. part.Name)
                updateProgress()
            end
        end
    end)
end

local function findCheckpoints()
    print("🔍 Finding checkpoints...")
    updateStatus("Scanning checkpoints...", Color3.fromRGB(255, 200, 0))
    
    checkpoints = {}
    touchedCheckpoints = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            if name:find("checkpoint") or name:find("stage") or name:find("cp") or 
               obj:GetAttribute("CheckpointId") then
                
                if not table.find(checkpoints, obj) then
                    table.insert(checkpoints, obj)
                    setupTouch(obj)
                    print("✅ Found: " .. obj.Name)
                end
            end
        end
    end
    
    -- Sort
    table.sort(checkpoints, function(a, b)
        local idA = a:GetAttribute("CheckpointId")
        local idB = b:GetAttribute("CheckpointId")
        if idA and idB then
            return tonumber(idA) < tonumber(idB)
        end
        return a.Position.X < b.Position.X
    end)
    
    print("📊 Total checkpoints: " .. #checkpoints)
    updateProgress()
    
    if #checkpoints > 0 then
        updateStatus("Ready! Found " .. #checkpoints .. " checkpoints", Color3.fromRGB(50, 255, 50))
    else
        updateStatus("No checkpoints found!", Color3.fromRGB(255, 50, 50))
    end
end

local function teleportTo(part)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local targetPos = part.Position + Vector3.new(0, 5, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    local duration = math.max(0.8, distance / 50)
    
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {CFrame = CFrame.new(targetPos)}
    )
    
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function startAutoTeleport()
    print("🚀 Starting auto teleport...")
    updateStatus("Running...", Color3.fromRGB(50, 200, 255))
    
    spawn(function()
        while autoEnabled do
            local next = getNextUntouched()
            
            if not next then
                print("🎉 All done!")
                updateStatus("Completed all checkpoints!", Color3.fromRGB(50, 255, 50))
                autoEnabled = false
                StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                break
            end
            
            local index = table.find(checkpoints, next) or 0
            updateStatus("Teleporting to checkpoint " .. index, Color3.fromRGB(255, 200, 0))
            
            local success = teleportTo(next)
            if success then
                wait(2)
                if not touchedCheckpoints[next] then
                    touchedCheckpoints[next] = true
                end
                updateProgress()
                wait(2)
            else
                wait(3)
            end
        end
    end)
end

-- === BUTTON EVENTS ===

StartButton.MouseButton1Click:Connect(function()
    print("🖱️  Start button clicked")
    
    if not autoEnabled then
        if #checkpoints == 0 then
            findCheckpoints()
            wait(1)
        end
        
        if #checkpoints > 0 then
            autoEnabled = true
            StartButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            startAutoTeleport()
        else
            updateStatus("No checkpoints to teleport!", Color3.fromRGB(255, 50, 50))
        end
    end
end)

StopButton.MouseButton1Click:Connect(function()
    print("🖱️  Stop button clicked")
    
    if autoEnabled then
        autoEnabled = false
        StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        updateStatus("Stopped by user", Color3.fromRGB(255, 100, 0))
    end
end)

-- === INITIALIZE ===
wait(1)
print("🎮 Initializing...")

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
wait(2)

print("🔍 Auto-finding checkpoints...")
findCheckpoints()

print("=" .. string.rep("=", 50))
print("✅ GUI LOADED SUCCESSFULLY!")
print("📝 Instructions:")
print("   1. GUI is at center of screen")
print("   2. Drag GUI to move it")
print("   3. Click START button to begin")
print("   4. Click STOP button to stop")
print("=" .. string.rep("=", 50))
