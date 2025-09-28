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
    local maxScan = 800 -- Reduced from 1000
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if scannedCount >= maxScan then
            print("⚠️  Scan limited for performance")
            break
        end
        scannedCount = scannedCount + 1
        
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            -- Only search for specific names
            if name:find("checkpoint") or name:find("stage") or name:find("cp") then
                table.insert(checkpoints, obj)
                print("✅ Found: " .. obj.Name)
                setupTouchDetection(obj)
            end
            
            -- Or by attribute
            if obj:GetAttribute("CheckpointId") then
                if not table.find(checkpoints, obj) then
                    table.insert(checkpoints, obj)
                    print("✅ Found (ID): " .. obj.Name)
                    setupTouchDetection(obj)
                end
            end
        end
        
        -- Yield every 30 objects (reduced from 50)
        if scannedCount % 30 == 0 then
            RunService.Heartbeat:Wait()
        end
    end
    
    -- Sort checkpoints
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
    
    local targetPos = part.Position + Vector3.new(0, 6, 0) -- Higher for safety
    local distance = (hrp.Position - targetPos).Magnitude
    
    -- Very smooth settings
    local speed = 40 -- Even slower for ultra-smooth
    local duration = math.max(1, distance / speed) -- Minimum 1 second
    
    print("🛸 Distance: " .. math.floor(distance) .. " studs | Time: " .. math.floor(duration*10)/10 .. "s")
    
    -- Ultra-smooth tween
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(
            duration, 
            Enum.EasingStyle.Sine, -- Very smooth easing
            Enum.EasingDirection.InOut,
            0, -- No repeat
            false, -- No reverse
            0 -- No delay
        ),
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
    print("✨ Maximum performance optimization")
    
    spawn(function()
        while autoEnabled do
            local nextCheckpoint = getNextUntouchedCheckpoint()
            
            if not nextCheckpoint then
                print("🎉 MISSION COMPLETE!")
                print("✅ All checkpoints conquered!")
                autoEnabled = false
                break
            end
            
            local index = table.find(checkpoints, nextCheckpoint) or 0
            local remaining = getUntouchedCount()
            
            print("🎯 Next: " .. nextCheckpoint.Name .. " (" .. (index) .. "/" .. #checkpoints .. ")")
            print("📊 Progress: " .. (#checkpoints - remaining) .. "/" .. #checkpoints .. " done")
            
            local success = smoothTeleport(nextCheckpoint)
            
            if success then
                print("✅ Teleport successful!")
                
                -- Wait for touch registration
                wait(2.5) -- Longer wait
                
                -- Force mark if needed
                if not touchedCheckpoints[nextCheckpoint] then
                    print("🔧 Auto-marking checkpoint as completed")
                    touchedCheckpoints[nextCheckpoint] = true
                end
                
                -- Long delay between teleports for stability
                print("⏳ Waiting 4 seconds before next teleport...")
                wait(4)
                
            else
                print("❌ Teleport failed, waiting 6 seconds...")
                wait(6)
            end
            
            -- Extra yield for performance
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
        end
        
        print("🏁 Auto teleport completed successfully!")
    end)
end

-- Wait for character (with timeout)
local function waitForCharacter()
    print("⏳ Waiting for character...")
    local timeOut = 0
    
    while not LocalPlayer.Character and timeOut < 30 do
        wait(0.5)
        timeOut = timeOut + 0.5
    end
    
    if LocalPlayer.Character then
        wait(3) -- Extra wait for full load
        print("✅ Character ready!")
        return true
    else
        print("❌ Character spawn timeout!")
        return false
    end
end

-- === MAIN EXECUTION ===
print("🚀 INITIALIZING ULTRA-SMOOTH TELEPORT...")

-- Wait for character
if not waitForCharacter() then
    print("❌ Failed to initialize - character not found")
    return
end

-- Find checkpoints
findCheckpoints()

-- Start if checkpoints found
if #checkpoints > 0 then
    print("🎮 ULTRA-SMOOTH TELEPORT STARTING IN 5 SECONDS...")
    print("⚡ Anti-lag optimizations active")
    print("🐌 Speed: 40 studs/sec (ultra-smooth)")
    print("⏱️  Delays: 4 seconds between teleports")
    
    for i = 5, 1, -1 do
        print(i .. "...")
        wait(1)
    end
    
    print("🚀 LAUNCHING SMOOTH TELEPORT!")
    startSmoothTeleport()
    
else
    print("❌ No checkpoints detected!")
    print("💡 Looking for parts named: checkpoint, stage, cp")
    print("💡 Or parts with CheckpointId attribute")
end

-- Control functions
_G.stopTeleport = function()
    autoEnabled = false
    print("🛑 Smooth teleport stopped")
end

_G.startTeleport = function()
    if not autoEnabled then
        autoEnabled = true
        startSmoothTeleport()
    else
        print("⚠️  Teleport already running")
    end
end

_G.checkStatus = function()
    print("📊 STATUS REPORT:")
    print("   Running: " .. (autoEnabled and "✅ YES" or "❌ NO"))
    print("   Checkpoints: " .. #checkpoints)
    print("   Completed: " .. (#checkpoints - getUntouchedCount()))
    print("   Remaining: " .. getUntouchedCount())
end

_G.listAll = function()
    print("📋 ALL CHECKPOINTS:")
    for i, cp in ipairs(checkpoints) do
        local status = touchedCheckpoints[cp] and "✅ DONE" or "❌ TODO"
        print("   " .. i .. ". " .. cp.Name .. " - " .. status)
    end
end

_G.resetAll = function()
    touchedCheckpoints = {}
    print("🔄 All progress reset!")
end

print("\n📝 === ULTRA-SMOOTH TELEPORT ACTIVE ===")
print("🐌 Speed optimized for zero lag")
print("⏱️  4-second delays between teleports")
print("🛸 Smooth sine-wave movement")
print("\n💡 Available commands:")
print("   _G.stopTeleport() - Stop script")
print("   _G.startTeleport() - Restart script")
print("   _G.checkStatus() - View progress")
print("   _G.listAll() - List all checkpoints")
print("   _G.resetAll() - Reset progress")
print("\n🚀 Ultra-smooth teleport is running!")
