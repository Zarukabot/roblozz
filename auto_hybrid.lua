-- Anti-Lag Auto Teleport - Smooth Performance
-- Otomatis teleport ke checkpoint yang belum disentuh

print("🚀 Loading Anti-Lag Auto Teleport...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local autoEnabled = true
local checkpoints = {}
local touchedCheckpoints = {}

-- Setup touch detection (optimized)
local function setupTouchDetection(part)
    if part:GetAttribute("TouchSetup") then return end
    part:SetAttribute("TouchSetup", true)
    
    part.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and Players:GetPlayerFromCharacter(character) == LocalPlayer then
            if not touchedCheckpoints[part] then
                touchedCheckpoints[part] = true
                print("✅ Checkpoint completed: " .. part.Name)
                print("🎯 Remaining: " .. getUntouchedCount())
            end
        end
    end)
end

-- Count untouched checkpoints
local function getUntouchedCount()
    local count = 0
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] then
            count = count + 1
        end
    end
    return count
end

-- Get next untouched checkpoint
local function getNextUntouchedCheckpoint()
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] and cp.Parent then
            return cp
        end
    end
    return nil
end

-- Find checkpoints (Performance Optimized)
local function findCheckpoints()
    print("🔍 Scanning workspace (performance mode)...")
    checkpoints = {}
    touchedCheckpoints = {}
    
    local scannedCount = 0
    local maxScan = 800
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if scannedCount >= maxScan then
            print("⚠️  Scan limited for performance")
            break
        end
        scannedCount = scannedCount + 1
        
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            if name:find("checkpoint") or name:find("stage") or name:find("cp") then
                table.insert(checkpoints, obj)
                print("✅ Found: " .. obj.Name)
                setupTouchDetection(obj)
            end
            
            if obj:GetAttribute("CheckpointId") then
                if not table.find(checkpoints, obj) then
                    table.insert(checkpoints, obj)
                    print("✅ Found (ID): " .. obj.Name)
                    setupTouchDetection(obj)
                end
            end
        end
        
        if scannedCount % 30 == 0 then
            RunService.Heartbeat:Wait()
        end
    end
    
    table.sort(checkpoints, function(a, b)
        local idA = a:GetAttribute("CheckpointId")
        local idB = b:GetAttribute("CheckpointId")
        
        if idA and idB then
            return tonumber(idA) < tonumber(idB)
        else
            return a.Position.X < b.Position.X
        end
    end)
    
    print("📊 Found " .. #checkpoints .. " checkpoints")
    return checkpoints
end

-- Smooth teleport function (Anti-Lag)
local function smoothTeleport(part)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    print("✈️ Smooth flying to: " .. part.Name)
    
    local targetPos = part.Position + Vector3.new(0, 6, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    
    local speed = 40
    local duration = math.max(1, distance / speed)
    
    print("🛸 Distance: " .. math.floor(distance) .. " studs | Time: " .. math.floor(duration*10)/10 .. "s")
    
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {CFrame = CFrame.new(targetPos)}
    )
    
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Main auto loop (Ultra Anti-Lag)
local function startSmoothTeleport()
    print("🎯 SMOOTH AUTO TELEPORT STARTED!")
    print("🐌 Ultra-smooth mode: 40 studs/sec")
    
    spawn(function()
        while autoEnabled do
            local nextCheckpoint = getNextUntouchedCheckpoint()
            
            if not nextCheckpoint then
                print("🎉 MISSION COMPLETE!")
                autoEnabled = false
                break
            end
            
            local index = table.find(checkpoints, nextCheckpoint) or 0
            local remaining = getUntouchedCount()
            
            print("🎯 Next: " .. nextCheckpoint.Name .. " (" .. index .. "/" .. #checkpoints .. ")")
            print("📊 Progress: " .. (#checkpoints - remaining) .. "/" .. #checkpoints)
            
            local success = smoothTeleport(nextCheckpoint)
            
            if success then
                wait(2.5)
                
                if not touchedCheckpoints[nextCheckpoint] then
                    touchedCheckpoints[nextCheckpoint] = true
                end
                
                print("⏳ Waiting 4 seconds...")
                wait(4)
            else
                wait(6)
            end
            
            RunService.Heartbeat:Wait()
        end
        
        print("🏁 Completed!")
    end)
end

-- Wait for character
local function waitForCharacter()
    print("⏳ Waiting for character...")
    local timeOut = 0
    
    while not LocalPlayer.Character and timeOut < 30 do
        wait(0.5)
        timeOut = timeOut + 0.5
    end
    
    if LocalPlayer.Character then
        wait(3)
        print("✅ Character ready!")
        return true
    end
    return false
end

-- MAIN
print("🚀 INITIALIZING...")

if not waitForCharacter() then
    print("❌ Character not found")
    return
end

findCheckpoints()

if #checkpoints > 0 then
    print("🎮 STARTING IN 5 SECONDS...")
    for i = 5, 1, -1 do
        print(i .. "...")
        wait(1)
    end
    
    print("🚀 GO!")
    startSmoothTeleport()
else
    print("❌ No checkpoints found!")
end

-- Commands
_G.stop = function() autoEnabled = false print("🛑 Stopped") end
_G.start = function() if not autoEnabled then autoEnabled = true startSmoothTeleport() end end
_G.status = function() 
    print("Running: " .. (autoEnabled and "YES" or "NO"))
    print("Remaining: " .. getUntouchedCount())
end

print("✅ Script loaded! Ultra-smooth mode active")
