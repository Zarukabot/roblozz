--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

--// STATE
local AUTO = false
local DELAY = 0.25
local collectedCount = 0
local touchedItems = {}

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "AUTO COLLECT"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.35,0)
Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
Toggle.Text = "OFF"
Toggle.TextScaled = true
Toggle.TextColor3 = Color3.new(1,1,1)

local CounterLabel = Instance.new("TextLabel", Frame)
CounterLabel.Size = UDim2.new(1,0,0,30)
CounterLabel.Position = UDim2.new(0,0,0.75,0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.TextColor3 = Color3.new(1,1,1)
CounterLabel.TextScaled = true
CounterLabel.Text = "Collected: 0"

--// DETECT ITEM
local function isCollectable(obj)
    if obj:IsA("BasePart") then
        if obj:FindFirstChild("TouchInterest")
        or string.find(string.lower(obj.Name), "coin")
        or string.find(string.lower(obj.Name), "gem")
        or string.find(string.lower(obj.Name), "collect")
        then
            return true
        end
    end
    return false
end

--// AUTO COLLECT LOOP
task.spawn(function()
    while true do
        if AUTO then
            for _, obj in pairs(workspace:GetDescendants()) do
                if isCollectable(obj) and obj.Parent then
                    if not touchedItems[obj] then
                        firetouchinterest(root, obj, 0)
                        firetouchinterest(root, obj, 1)

                        touchedItems[obj] = true
                        collectedCount += 1
                        CounterLabel.Text = "Collected: " .. collectedCount
                    end
                end
            end
        end
        task.wait(DELAY)
    end
end)

--// TOGGLE BUTTON
Toggle.MouseButton1Click:Connect(function()
    AUTO = not AUTO
    if AUTO then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

        -- reset counter saat dinyalakan
        collectedCount = 0
        touchedItems = {}
        CounterLabel.Text = "Collected: 0"
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
