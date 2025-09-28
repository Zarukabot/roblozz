-- Smart Auto Teleport - Only Untouched Checkpoints
-- Tekan F untuk toggle ON/OFF
-- Tekan G untuk ganti mode Fly/Reset

print("🚀 Loading Smart Auto Teleport...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local autoEnabled = false
local mode = "Fly" -- Fly atau Reset
local checkpoints = {}
local touchedCheckpoints = {} -- Track checkpoint yang sudah disentuh

-- Setup touch detection untuk checkpoint
local function setupTouchDetection(part)
    if part:GetAttribute("TouchSetup") then return end -- Sudah di-setup
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
    return nil -- Semua sudah disentuh
end

-- Cari checkpoints
local function findCheckpoints()
    print("🔍 Mencari checkpoints...")
    checkpoints = {}
    touchedCheckpoints = {} -- Reset tracking
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            -- Cari berdasarkan nama yang umum
            if name:find("checkpoint") or name:find("stage") or name:find("cp") or 
               name:find("teleport") or name:find("spawn") or name:find("part") then
                table.insert(checkpoints, obj)
                print("✅ Found: " .. obj.Name)
                
                -- Setup touch detection
                setupTouchDetection(obj)
            end
            
            -- Atau berdasarkan attribute
            if obj:GetAttribute("CheckpointId") then
                if not table.find(checkpoints, obj) then -- Avoid duplicates
                    table.insert(checkpoints, obj)
                    print("✅ Found (ID): " .. obj.Name .. " - ID:" .. obj:GetAttribute("CheckpointId"))
                    setupTouchDetection(obj)
                end
            end
        end
    end
    
    -- Sort berdasarkan posisi X jika tidak ada ID
    table.sort(checkpoints, function(a, b)
        local idA = a:GetAttribute("CheckpointId")
        local idB = b:GetAttribute("CheckpointId")
        
        if idA and idB then
            return tonumber(idA) < tonumber(idB)
        else
            return a.Position.X < b.Position.X -- Sort berdasarkan posisi X
        end
    end)
    
    print("📊 Total checkpoints: " .. #checkpoints)
    print("🎯 Untouched checkpoints: " .. getUntouchedCount())
    return checkpoints
end

-- Teleport ke checkpoint
local function teleportTo(part)
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
    
    print("🚀 Teleporting to: " .. part.Name .. " | Mode: " .. mode)
    
    if mode == "Fly" then
        -- Mode Fly - smooth movement
        local targetPos = part.Position + Vector3.new(0, 5, 0)
        local distance = (hrp.Position - targetPos).Magnitude
        local speed = 100 -- studs per second
        local duration = math.max(0.1, distance / speed)
        
        print("✈️ Flying " .. math.floor(distance) .. " studs in " .. math.floor(duration*10)/10 .. "s")
        
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(targetPos)}
        )
        
        tween:Play()
        tween.Completed:Wait()
        
    else
        -- Mode Reset
        print("💀 Reset mode - killing character...")
        char.Humanoid.Health = 0
        
        -- Wait for respawn
        local newChar = LocalPlayer.CharacterAdded:Wait()
        wait(1.5) -- Wait for character to fully load
        
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHrp then
            newHrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            print("🏃 Respawned at checkpoint")
        end
    end
    
    return true
end

-- Main auto loop - HANYA KE CHECKPOINT YANG BELUM DISENTUH
local function startAutoLoop()
    print("🔥 Starting smart auto teleport (untouched only)...")
    
    spawn(function()
        while autoEnabled do
            local nextCheckpoint = getNextUntouchedCheckpoint()
            
            if not nextCheckpoint then
                print("🎉 ALL CHECKPOINTS COMPLETED!")
                print("✅ No more untouched checkpoints found")
                autoEnabled = false
                break
            end
            
            -- Cari index untuk display
            local checkpointIndex = table.find(checkpoints, nextCheckpoint) or 0
            print("🎯 Going to untouched checkpoint " .. checkpointIndex .. ": " .. nextCheckpoint.Name)
            
            local success = teleportTo(nextCheckpoint)
            if success then
                -- Wait a bit for touch detection to register
                wait(1)
                
                -- Double check if touched
                if not touchedCheckpoints[nextCheckpoint] then
                    print("⚠️  Checkpoint may not have registered touch, marking as touched")
                    touchedCheckpoints[nextCheckpoint] = true
                end
                
                wait(1.5) -- Wait before next teleport
            else
                print("❌ Teleport failed, trying next checkpoint")
                wait(1)
            end
            
            -- Status update
            local remaining = getUntouchedCount()
            if remaining > 0 then
                print("📊 Remaining untouched checkpoints: " .. remaining)
            end
        end
        
        print("🛑 Smart auto teleport stopped")
    end)
end

-- Toggle auto on/off
local function toggleAuto()
    autoEnabled = not autoEnabled
    
    if autoEnabled then
        print("🟢 SMART AUTO TELEPORT: ON")
        print("⌨️  Tekan F lagi untuk stop")
        print("⌨️  Tekan G untuk ganti mode")
        print("🎯 Hanya akan teleport ke checkpoint yang BELUM disentuh")
        
        -- Find checkpoints first
        findCheckpoints()
        
        if #checkpoints > 0 then
            local untouchedCount = getUntouchedCount()
            if untouchedCount > 0 then
                print("🎯 Found " .. untouchedCount .. " untouched checkpoints")
                startAutoLoop()
            else
                print("✅ All checkpoints already touched!")
                print("💡 Use _G.resetProgress() to reset progress")
                autoEnabled = false
            end
        else
            print("❌ Tidak ada checkpoint ditemukan!")
            autoEnabled = false
        end
    else
        print("🔴 SMART AUTO TELEPORT: OFF")
    end
end

-- Toggle mode
local function toggleMode()
    if mode == "Fly" then
        mode = "Reset"
        print("🔄 Mode changed to: RESET (kill & respawn)")
    else
        mode = "Fly"  
        print("🔄 Mode changed to: FLY (smooth movement)")
    end
end

-- Keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleAuto()
    elseif input.KeyCode == Enum.KeyCode.G then
        toggleMode()
    end
end)

-- Manual teleport to specific checkpoint
local function teleportToIndex(index)
    if index < 1 or index > #checkpoints then
        print("❌ Index " .. index .. " tidak valid! Max: " .. #checkpoints)
        return
    end
    
    local checkpoint = checkpoints[index]
    teleportTo(checkpoint)
end

-- Load checkpoints on start
findCheckpoints()

-- Instructions
print("\n📝 === SMART TELEPORT CONTROLS ===")
print("⌨️  F = Toggle Auto ON/OFF")
print("⌨️  G = Change Mode (Fly/Reset)")
print("💡 Mode FLY = Smooth teleport")
print("💡 Mode RESET = Kill & respawn")
print("🎯 HANYA teleport ke checkpoint yang BELUM disentuh!")
print("🚀 Ready to use!")

-- Global functions untuk manual control
_G.teleportToIndex = teleportToIndex
_G.listCheckpoints = function()
    print("📋 Available checkpoints:")
    for i, cp in ipairs(checkpoints) do
        local status = touchedCheckpoints[cp] and "✅ TOUCHED" or "❌ UNTOUCHED"
        print(i .. ". " .. cp.Name .. " at " .. tostring(cp.Position) .. " - " .. status)
    end
    print("🎯 Total untouched: " .. getUntouchedCount() .. "/" .. #checkpoints)
end
_G.refreshCheckpoints = findCheckpoints
_G.resetProgress = function()
    touchedCheckpoints = {}
    print("🔄 Progress reset! All checkpoints marked as untouched")
    print("🎯 Untouched checkpoints: " .. getUntouchedCount())
end
_G.markAllTouched = function()
    for _, cp in ipairs(checkpoints) do
        touchedCheckpoints[cp] = true
    end
    print("✅ All checkpoints marked as touched")
end

print("✅ Smart Auto Teleport loaded!")
print("💡 Tip: Ketik _G.listCheckpoints() untuk lihat status checkpoint")
print("💡 Tip: Ketik _G.resetProgress() untuk reset progress")
print("💡 Script akan otomatis skip checkpoint yang sudah disentuh!")
