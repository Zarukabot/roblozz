--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

--------------------------------------------------
-- STATE
--------------------------------------------------
local ULTRA_MODE = false
local animationSpeed = 3 -- 3x fast animation
local originalWalkSpeed = humanoid.WalkSpeed
local originalJumpPower = humanoid.JumpPower

--------------------------------------------------
-- GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "🔥 ULTRA EXTREME MODE"
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
-- PERFORMANCE FUNCTIONS
--------------------------------------------------
local function enableUltraMode()
    -- Grafik super minimal
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(128,128,128)

    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.Transparency = 0
        end
    end

    humanoid.WalkSpeed = 50
    humanoid.JumpPower = 100
end

local function disableUltraMode()
    humanoid.WalkSpeed = originalWalkSpeed
    humanoid.JumpPower = originalJumpPower
end

--------------------------------------------------
-- ANIMATION BOOST x3
--------------------------------------------------
humanoid.AnimationPlayed:Connect(function(track)
    track:AdjustSpeed(animationSpeed)
end)

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
-- ULTRA OPTIMIZER LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
    humanoid.MaxSlopeAngle = 89
    -- optimasi ringan part
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Material ~= Enum.Material.Plastic then
            v.Material = Enum.Material.Plastic
        end
    end
end)

--------------------------------------------------
-- GUI TOGGLE
--------------------------------------------------
Toggle.MouseButton1Click:Connect(function()
    ULTRA_MODE = not ULTRA_MODE
    if ULTRA_MODE then
        enableUltraMode()
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        disableUltraMode()
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
