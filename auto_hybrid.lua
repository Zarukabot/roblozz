-- Simple Lua Auto Teleport
-- Tekan F untuk toggle ON/OFF
-- Tekan G untuk ganti mode Fly/Reset

print("🚀 Loading Simple Lua Teleport...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local autoEnabled = false
local mode = "Fly" -- Fly atau Reset
local checkpoints = {}
local currentIndex = 1

-- Cari checkpoints
local function findCheckpoints()
    print("🔍 Mencari checkpoints...")
    checkpoints = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            
            -- Cari berdasarkan nama yang umum
            if name:find("checkpoint") or name:find("stage") or name:find("cp") or 
               name:find("teleport") or name:find("spawn") or name:find("part") then
                table.insert(checkpoints, obj)
                print("✅ Found: " .. obj.Name)
            end
            
            -- Atau berdasarkan attribute
            if obj:GetAttribute("CheckpointId") then
                table.insert(checkpoints, obj)
                print("✅ Found (ID): " .. obj.Name .. " - ID:" .. obj:GetAttribute("CheckpointId"))
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

-- Main auto loop
local function startAutoLoop()
    print("🔥 Starting auto teleport loop...")
    
    spawn(function()
        while autoEnabled do
            if #checkpoints == 0 then
                print("❌ No checkpoints found!")
                break
            end
            
            -- Reset index if exceeded
            if currentIndex > #checkpoints then
                currentIndex = 1
                print("🔄 Looping back to first checkpoint")
            end
            
            local targetCheckpoint = checkpoints[currentIndex]
            if targetCheckpoint and targetCheckpoint.Parent then
                print("📍 Going to checkpoint " .. currentIndex .. "/" .. #checkpoints .. ": " .. targetCheckpoint.Name)
                
                local success = teleportTo(targetCheckpoint)
                if success then
                    currentIndex = currentIndex + 1
                    wait(2) -- Wait 2 seconds between teleports
                else
                    print("❌ Teleport failed, trying next checkpoint")
                    currentIndex = currentIndex + 1
                    wait(1)
                end
            else
                print("❌ Checkpoint " .. currentIndex .. " tidak valid, skip...")
                currentIndex = currentIndex + 1
                wait(0.5)
            end
        end
        
        print("🛑 Auto teleport stopped")
    end)
end

-- Toggle auto on/off
local function toggleAuto()
    autoEnabled = not autoEnabled
    
    if autoEnabled then
        print("🟢 AUTO TELEPORT: ON")
        print("⌨️  Tekan F lagi untuk stop")
        print("⌨️  Tekan G untuk ganti mode")
        
        -- Find checkpoints first
        findCheckpoints()
        currentIndex = 1
        
        if #checkpoints > 0 then
            startAutoLoop()
        else
            print("❌ Tidak ada checkpoint ditemukan!")
            autoEnabled = false
        end
    else
        print("🔴 AUTO TELEPORT: OFF")
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
print("\n📝 === CONTROLS ===")
print("⌨️  F = Toggle Auto ON/OFF")
print("⌨️  G = Change Mode (Fly/Reset)")
print("💡 Mode FLY = Smooth teleport")
print("💡 Mode RESET = Kill & respawn")
print("🚀 Ready to use!")

-- Global functions untuk manual control (opsional)
_G.teleportToIndex = teleportToIndex
_G.listCheckpoints = function()
    print("📋 Available checkpoints:")
    for i, cp in ipairs(checkpoints) do
        print(i .. ". " .. cp.Name .. " at " .. tostring(cp.Position))
    end
end
_G.refreshCheckpoints = findCheckpoints

print("✅ Simple Lua Teleport loaded!")
print("💡 Tip: Ketik _G.listCheckpoints() untuk lihat semua checkpoint")
print("💡 Tip: Ketik _G.teleportToIndex(1) untuk teleport manual")
