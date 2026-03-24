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

-- Inventory per player
local inventory = {}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 220)
Frame.Position = UDim2.new(0.05,0,0.2,0)
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
CounterLabel.Size = UDim2.new(1,0,0,40)
CounterLabel.Position = UDim2.new(0,0,0.6,0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.TextColor3 = Color3.new(1,1,1)
CounterLabel.TextScaled = true
CounterLabel.Text = "Fish Collected: 0"

--// FAST ANIMATION
humanoid.AnimationPlayed:Connect(function(track)
    track:AdjustSpeed(animationSpeed)
end)

--// ALL FISH IN SERVER (simulasi)
local function getAllFish()
    local fishNames = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("fish") then
            table.insert(fishNames, obj.Name)
        end
    end
    return fishNames
end

--// FUNCTION: Masukkan semua fish ke inventory langsung
local function collectAllFishToInventory()
    if not AUTO_FISH_MODE then return end

    local allFish = getAllFish()
    for _, fishName in pairs(allFish) do
        if inventory[fishName] then
            inventory[fishName] += 1
        else
            inventory[fishName] = 1
        end
    end

    -- Update GUI counter
    local totalFish = 0
    for _, v in pairs(inventory) do totalFish += v end
    CounterLabel.Text = "Fish Collected: "..totalFish
end

--// LOOP
RunService.RenderStepped:Connect(function()
    if AUTO_FISH_MODE then
        collectAllFishToInventory()
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

-- Optional: Print inventory tiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        if next(inventory) then
            print("🧰 Inventory:")
            for name, amount in pairs(inventory) do
                print(name..": "..amount)
            end
        end
    end
end)
