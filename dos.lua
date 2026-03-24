--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--------------------------------------------------
-- STATE
--------------------------------------------------

local PERFORMANCE_MODE = false
local animationSpeed = 2

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "🔥 EXTREME MODE"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.3,0)
Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
Toggle.Text = "OFF"
Toggle.TextScaled = true
Toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

local FPSLabel = Instance.new("TextLabel", Frame)
FPSLabel.Size = UDim2.new(1,0,0,30)
FPSLabel.Position = UDim2.new(0,0,0.7,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.new(1,1,1)
FPSLabel.TextScaled = true
FPSLabel.Text = "FPS: ..."

--------------------------------------------------
-- FPS BOOST FUNCTION
--------------------------------------------------

local function enablePerformance()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9

    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end

    humanoid.WalkSpeed = 22
    humanoid.JumpPower = 65
end

local function disablePerformance()
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end

--------------------------------------------------
-- FAST ANIMATION
--------------------------------------------------

local function applyAnimationBoost()
    humanoid.AnimationPlayed:Connect(function(track)
        track:AdjustSpeed(animationSpeed)
    end)
end

applyAnimationBoost()

--------------------------------------------------
-- FPS MONITOR
--------------------------------------------------

local last = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        FPSLabel.Text = "FPS: " .. frames
        frames = 0
        last = tick()
    end
end)

--------------------------------------------------
-- TOGGLE BUTTON
--------------------------------------------------

Toggle.MouseButton1Click:Connect(function()
    PERFORMANCE_MODE = not PERFORMANCE_MODE

    if PERFORMANCE_MODE then
        enablePerformance()
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        disablePerformance()
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
