--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")

local FishDataStore = DataStoreService:GetDataStore("FishInventory")

--// CONFIG
local FISH_FOLDER_NAME = "FishSpawn" -- semua fish yang ada di server (workspace)
local ROD_NAME = "FishingRod"
local AUTO_CATCH_DELAY = 0.1 -- delay kecil supaya server tidak lag
local ULTRA_SPEED_MODE = false

--// FUNCTIONS
local function collectAllFishFromServer(player)
    local fishFolder = workspace:FindFirstChild(FISH_FOLDER_NAME)
    if not fishFolder then return {} end

    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        inventory = Instance.new("Folder")
        inventory.Name = "Inventory"
        inventory.Parent = player
    end

    local collected = {}

    for _, fish in pairs(fishFolder:GetChildren()) do
        if fish:IsA("BasePart") or fish:IsA("Model") then
            local name = fish.Name
            if inventory:FindFirstChild(name) then
                inventory[name].Value += 1
            else
                local value = Instance.new("IntValue")
                value.Name = name
                value.Value = 1
                value.Parent = inventory
            end
            table.insert(collected, name)
            fish:Destroy()
        end
    end

    return collected
end

local function setupPlayer(player)
    -- Inventory
    local inventory = {}
    player:SetAttribute("FishCount",0)

    -- Load DataStore
    local success, data = pcall(function()
        return FishDataStore:GetAsync(player.UserId)
    end)
    if success and data then
        inventory = data
        local total = 0
        for _,v in pairs(inventory) do total += v end
        player:SetAttribute("FishCount",total)
    end

    -- GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "FishingGUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,200)
    frame.Position = UDim2.new(0.05,0,0.05,0)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.Parent = gui
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "🎣 FISHING INVENTORY"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextScaled = true
    title.Parent = frame

    local counterLabel = Instance.new("TextLabel")
    counterLabel.Size = UDim2.new(1,0,0,40)
    counterLabel.Position = UDim2.new(0,0,0.7,0)
    counterLabel.BackgroundTransparency = 1
    counterLabel.TextColor3 = Color3.fromRGB(255,255,255)
    counterLabel.TextScaled = true
    counterLabel.Text = "Fish Collected: "..player:GetAttribute("FishCount")
    counterLabel.Parent = frame

    -- Detect equip rod
    player.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart")
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == ROD_NAME then
                task.spawn(function()
                    while child.Parent == char do
                        task.wait(AUTO_CATCH_DELAY / (ULTRA_SPEED_MODE and 3 or 1))

                        -- Ambil semua fish yang ada di server
                        local collected = collectAllFishFromServer(player)

                        -- Update counter
                        local total = 0
                        for _,v in pairs(player.Inventory:GetChildren()) do
                            total += v.Value
                        end
                        player:SetAttribute("FishCount",total)
                        counterLabel.Text = "Fish Collected: "..total

                        -- Optional: sound effect
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://12222225"
                        sound.Volume = 1
                        sound.Parent = hrp
                        sound:Play()
                        game.Debris:AddItem(sound,2)
                    end
                end)
            end
        end)
    end)

    -- Auto save tiap 30 detik
    task.spawn(function()
        while player.Parent do
            task.wait(30)
            pcall(function()
                FishDataStore:SetAsync(player.UserId, player.Inventory:GetChildren())
            end)
        end
    end)
end

-- Setup semua player
for _,p in pairs(Players:GetPlayers()) do
    setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)
