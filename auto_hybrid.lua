-- Simple Test Version - Auto Teleport GUI
print("🚀 Loading Simple Auto Teleport...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus GUI lama jika ada
if PlayerGui:FindFirstChild("AutoTeleportGUI") then
    PlayerGui.AutoTeleportGUI:Destroy()
end

print("✅ Creating GUI...")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 AUTO TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0.25, 0)
status.Position = UDim2.new(0, 0, 0.2, 0)
status.BackgroundTransparency = 1
status.Text = "Status: Loading..."
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.Parent = frame

-- Auto Button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "🔴 AUTO: OFF"
autoBtn.Font = Enum.Font.GothamBold
autoBtn.Parent = frame

local autoBtnCorner = Instance.new("UICorner")
autoBtnCorner.CornerRadius = UDim.new(0, 5)
autoBtnCorner.Parent = autoBtn

-- Mode Button  
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
modeBtn.Position = UDim2.new(0.1, 0, 0.78, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.TextScaled = true
modeBtn.Text = "✈️ MODE: FLY"
modeBtn.Font = Enum.Font.Gotham
modeBtn.Parent = frame

local modeBtnCorner = Instance.new("UICorner")
modeBtnCorner.CornerRadius = UDim.new(0, 5)
modeBtnCorner.Parent = modeBtn

print("✅ GUI Created!")

-- Variables
local autoEnabled = false
local mode = "Fly"
local checkpoints = {}
local currentIndex = 1

-- Find checkpoints
local function findCheckpoints()
    print("🔍 Searching for checkpoints...")
    checkpoints = {}
    
    -- Cari dengan berbagai cara
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            -- Cari berdasarkan nama
            if name:find("checkpoint") or name:find("stage") or name:find("cp") or 
               name:find("teleport") or name:find("spawn") then
                table.insert(checkpoints, obj)
                print("📍 Found: " .. obj.Name .. " at " .. tostring(obj.Position))
            end
            
            -- Atau berdasarkan attribute
            if obj:GetAttribute("CheckpointId") then
                if not table.find(checkpoints, obj) then
                    table.insert(checkpoints, obj)
                    print("📍 Found (by ID): " .. obj.Name .. " ID:" .. tostring(obj:GetAttribute("CheckpointId")))
                end
            end
        end
    end
    
    print("📊 Total found: " .. #checkpoints)
    
    if #checkpoints > 0 then
        status.Text = "Ready! Found " .. #checkpoints .. " checkpoints"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        status.Text = "❌ No checkpoints found!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    return #checkpoints > 0
end

-- Teleport function
local function teleportTo(part)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    print("🚀 Teleporting to: " .. part.Name)
    
    if mode == "Fly" then
        -- Fly mode - smooth movement
        local targetPos = part.Position + Vector3.new(0, 5, 0)
        local distance = (hrp.Position - targetPos).Magnitude
        local duration = distance / 100 -- 100 speed
        
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Quad),
            {CFrame = CFrame.new(targetPos)}
        )
        
        tween:Play()
        tween.Completed:Wait()
    else
        -- Reset mode
        char.Humanoid.Health = 0
        LocalPlayer.CharacterAdded:Wait()
        task.wait(1)
        local newChar = LocalPlayer.Character
        if newChar and newChar:FindFirstChild("HumanoidRootPart") then
            newChar.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        end
    end
    
    return true
end

-- Auto loop
local function startAuto()
    print("🚀 Starting auto teleport...")
    task.spawn(function()
        while autoEnabled and #checkpoints > 0 do
            if currentIndex > #checkpoints then
                currentIndex = 1 -- Loop back
            end
            
            local target = checkpoints[currentIndex]
            if target and target.Parent then
                local success = teleportTo(target)
                if success then
                    status.Text = "Teleported to " .. target.Name .. " (" .. currentIndex .. "/" .. #checkpoints .. ")"
                    currentIndex = currentIndex + 1
                end
            else
                currentIndex = currentIndex + 1
            end
            
            task.wait(2) -- Wait 2 seconds between teleports
        end
        
        if autoEnabled then
            print("✅ Auto teleport completed!")
            status.Text = "Completed all checkpoints!"
            autoEnabled = false
            autoBtn.Text = "🔴 AUTO: OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end

-- Button events
autoBtn.MouseButton1Click:Connect(function()
    print("🖱️ Auto button clicked!")
    
    if not autoEnabled then
        -- Start auto
        if #checkpoints == 0 then
            findCheckpoints()
        end
        
        if #checkpoints > 0 then
            autoEnabled = true
            autoBtn.Text = "🟢 AUTO: ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            currentIndex = 1
            startAuto()
        else
            status.Text = "❌ No checkpoints found!"
            print("❌ No checkpoints to teleport to!")
        end
    else
        -- Stop auto
        autoEnabled = false
        autoBtn.Text = "🔴 AUTO: OFF" 
        autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        status.Text = "Stopped"
        print("🛑 Auto teleport stopped")
    end
end)

modeBtn.MouseButton1Click:Connect(function()
    if mode == "Fly" then
        mode = "Reset"
        modeBtn.Text = "💀 MODE: RESET"
        modeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    else
        mode = "Fly"
        modeBtn.Text = "✈️ MODE: FLY"
        modeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    end
    print("🔄 Mode changed to: " .. mode)
end)

-- Auto-find checkpoints on load
findCheckpoints()

print("✅ Simple Auto Teleport GUI loaded!")
print("📝 Instructions:")
print("   1. Click 'AUTO: OFF' to start")  
print("   2. Click 'MODE' to change Fly/Reset")
print("   3. Drag the GUI to move it")
print("   4. Check console for debug info")
