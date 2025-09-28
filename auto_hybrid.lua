-- Auto Start Teleport - Langsung jalan tanpa tombol
-- Script otomatis mulai teleport ke checkpoint yang belum disentuh

print("🚀 Loading Auto Start Teleport...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local autoEnabled = true -- Langsung ON
local mode = "Fly" -- Default mode Fly
local checkpoints = {}
local touchedCheckpoints = {}

-- Setup touch detection untuk checkpoint
local function setupTouchDetection(part)
    if part:GetAttribute("TouchSetup") then return end
    part:SetAttribute("TouchSetup", true)
    
    part.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and Players:GetPlayerFromCharacter(character) == LocalPlayer then
            if not touchedCheckpoints[part] then
                touchedCheckpoints[part] = true
                print("✅ Checkpoint touched: " .. part.Name)
                print("🎯 Remaining untouched: " .. getUntouchedCount())
            end
        end
    end)
end

-- Hitung checkpoint yang belum disentuh
local function getUntouchedCount()
    local count = 0
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] then
            count = count + 1
        end
    end
    return count
end

-- Cari checkpoint berikutnya yang belum disentuh
local function getNextUntouchedCheckpoint()
    for _, cp in ipairs(checkpoints) do
        if not touchedCheckpoints[cp] and cp.Parent then
            return cp
        end
    end
    return nil
end

-- Cari checkpoints
local function findCheckpoints()
    print("🔍 Scanning for checkpoints...")
    checkpoints = {}
    touchedCheckpoints = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            -- Cari berdasarkan nama
            if name:find("checkpoint") or name:find("stage") or name:find("cp") or 
               name:find("teleport") or name:find("spawn") or name:find("part") then
                table.insert(checkpoints, obj)
                print("✅ Found: " .. obj.Name)
                setupTouchDetection(obj)
            end
            
            -- Atau berdasarkan attribute
            if obj:GetAttribute("CheckpointId") then
                if not table.find(checkpoints, obj) then
                    table.insert(checkpoints, obj)
                    print("✅ Found (ID): " .. obj.Name .. " - ID:" .. obj:GetAttribute("CheckpointId"))
                    setupTouchDetection(obj)
                end
            end
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
    
    print("📊 Total checkpoints found: " .. #checkpoints)
    print("🎯 All checkpoints are untouched: " .. #checkpoints)
    return checkpoints
end

-- Teleport ke checkpoint dengan mode Fly
local function flyToCheckpoint(part)
    local char = LocalPlayer.Character
    if not char then 
        print("❌ Character not found")
        return false 
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        print("❌ HumanoidRootPart not found")
        return false 
    end
    
    print("✈️ Flying to: " .. part.Name)
    
    local targetPos = part.Position + Vector3.new(0, 5, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    local speed = 100 -- studs per second
    local duration = math.max(0.1, distance / speed)
    
    print("🚀 Flying " .. math.floor(distance) .. " studs in " .. math.floor(duration*10)/10 .. "s")
    
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos)}
    )
    
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Main auto loop - Jalan terus otomatis
local function startAutoTeleport()
    print("🔥 AUTO TELEPORT STARTED!")
    print("🎯 Mode: FLY (100 studs/second)")
    print("✨ Script will automatically teleport to untouched checkpoints")
    
    spawn(function()
        while autoEnabled do
            local nextCheckpoint = getNextUntouchedCheckpoint()
            
            if not nextCheckpoint then
                print("🎉 ALL CHECKPOINTS COMPLETED!")
                print("✅ Mission accomplished! No more untouched checkpoints")
                autoEnabled = false
                break
            end
            
            local checkpointIndex = table.find(checkpoints, nextCheckpoint) or 0
            print("🎯 Target: Checkpoint " .. checkpointIndex .. "/" .. #checkpoints .. " - " .. nextCheckpoint.Name)
            
            local success = flyToCheckpoint(nextCheckpoint)
            if success then
                wait(1) -- Wait for touch detection
                
                -- Force mark as touched if not detected
                if not touchedCheckpoints[nextCheckpoint] then
                    print("⚠️  Force marking as touched")
                    touchedCheckpoints[nextCheckpoint] = true
                end
                
                wait(1.5) -- Delay before next teleport
            else
                print("❌ Teleport failed, retrying...")
                wait(2)
            end
            
            -- Progress update
            local remaining = getUntouchedCount()
            if remaining > 0 then
                print("📊 Progress: " .. (#checkpoints - remaining) .. "/" .. #checkpoints .. " completed")
            end
        end
        
        print("🛑 Auto teleport finished")
    end)
end

-- Tunggu character spawn
local function waitForCharacter()
    print("⏳ Waiting for character to spawn...")
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(2) -- Extra wait for full character load
    print("✅ Character ready!")
end

-- Main execution
print("🚀 INITIALIZING AUTO TELEPORT...")

-- Wait for character
waitForCharacter()

-- Find checkpoints
findCheckpoints()

-- Start auto teleport if checkpoints found
if #checkpoints > 0 then
    print("🎮 AUTO TELEPORT WILL START IN 3 SECONDS...")
    wait(1)
    print("3...")
    wait(1)
    print("2...")
    wait(1)
    print("1...")
    print("🚀 GO!")
    
    startAutoTeleport()
else
    print("❌ No checkpoints found!")
    print("💡 Make sure there are parts named with:")
    print("   - checkpoint, stage, cp, teleport, spawn, part")
    print("   - Or parts with CheckpointId attribute")
end

-- Global functions untuk control manual
_G.stopAuto = function()
    autoEnabled = false
    print("🛑 Auto teleport stopped manually")
end

_G.startAuto = function()
    if not autoEnabled then
        autoEnabled = true
        startAutoTeleport()
    else
        print("⚠️  Auto teleport already running")
    end
end

_G.listCheckpoints = function()
    print("📋 Checkpoint Status:")
    for i, cp in ipairs(checkpoints) do
        local status = touchedCheckpoints[cp] and "✅ TOUCHED" or "❌ UNTOUCHED"
        print(i .. ". " .. cp.Name .. " - " .. status)
    end
    print("🎯 Untouched: " .. getUntouchedCount() .. "/" .. #checkpoints)
end

_G.resetProgress = function()
    touchedCheckpoints = {}
    print("🔄 Progress reset! All checkpoints now untouched")
end

print("\n📝 === AUTO TELEPORT ACTIVE ===")
print("✨ Script runs automatically - no keys needed!")
print("🎯 Only teleports to untouched checkpoints")
print("💡 Commands available:")
print("   _G.stopAuto() - Stop teleport")
print("   _G.startAuto() - Restart teleport")  
print("   _G.listCheckpoints() - Show status")
print("   _G.resetProgress() - Reset progress")
print("🚀 Auto teleport is now running!")
