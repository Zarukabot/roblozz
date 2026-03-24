--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

--// STATE
local AUTO_FISH_MODE = false
local animationSpeed = 3
local originalWalkSpeed = humanoid.WalkSpeed
local originalJumpPower = humanoid.JumpPower

local fishCount = 0

-- Buat RemoteEvent jika belum ada
local FishEvent = ReplicatedStorage:FindFirstChild("FishEvent")
if not FishEvent then
    FishEvent = Instance.new("RemoteEvent")
    FishEvent.Name = "FishEvent"
    FishEvent.Parent = ReplicatedStorage
end

-- List semua jenis fish
local allFish = {"Common Fish","Rare Fish","Legendary Fish"}

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 200)
Frame.Position = UDim2.new(0.05,0,0.25,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "🎣 ULTRA AUTO FISH"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.2,0)
Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
Toggle.Text = "OFF"
Toggle.TextScaled = true
Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

local CounterLabel = Instance.new("TextLabel", Frame)
CounterLabel.Size = UDim2.new(1,0,0,30)
CounterLabel.Position = UDim2.new(0,0,0.6,0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.TextColor3 = Color3.new(1,1,1)
CounterLabel.TextScaled = true
CounterLabel.Text = "Fish Caught: 0"

--// FAST ANIMATION
humanoid.AnimationPlayed:Connect(function(track)
    track:AdjustSpeed(animationSpeed)
end)

--// AUTO FISH FUNCTION
local function catchAllFish()
    if AUTO_FISH_MODE then
        -- Tangkap semua fish sekaligus
        for _, fishName in pairs(allFish) do
            fishCount += 1
            CounterLabel.Text = "Fish Caught: "..fishCount
            -- Kirim ke server
            FishEvent:FireServer(fishName)
        end
        task.wait(1) -- delay antar loop supaya tidak spam
    end
end

--// RUN LOOP
RunService.RenderStepped:Connect(function()
    if AUTO_FISH_MODE then
        catchAllFish()
    end
end)

--// TOGGLE
Toggle.MouseButton1Click:Connect(function()
    AUTO_FISH_MODE = not AUTO_FISH_MODE
    if AUTO_FISH_MODE then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
