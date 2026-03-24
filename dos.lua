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

-- Pastikan ada RemoteEvent di ReplicatedStorage
local FishEvent = ReplicatedStorage:FindFirstChild("FishEvent")
if not FishEvent then
    FishEvent = Instance.new("RemoteEvent")
    FishEvent.Name = "FishEvent"
    FishEvent.Parent = ReplicatedStorage
end

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
Title.Text = "🎣 AUTO FISH MODE"
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
local function catchFish()
    if AUTO_FISH_MODE then
        -- animasi fishing cepat
        humanoid:Move(Vector3.new(0,0,0)) -- bisa ditambahkan animasi tool nanti
        task.wait(0.5) -- delay cepat untuk catch
        fishCount += 1
        CounterLabel.Text = "Fish Caught: "..fishCount
        FishEvent:FireServer() -- kirim ke server
    end
end

--// RUN LOOP
RunService.RenderStepped:Connect(function()
    if AUTO_FISH_MODE then
        catchFish()
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
