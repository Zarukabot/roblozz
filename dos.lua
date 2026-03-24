--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")

local FishDataStore = DataStoreService:GetDataStore("FishInventory")

--// CONFIG
local FISH_LIST = {
    {Name = "Common Fish", Rarity = 60},
    {Name = "Rare Fish", Rarity = 30},
    {Name = "Legendary Fish", Rarity = 10}
}
local AUTO_CATCH_DELAY = 0.5 -- detik
local ULTRA_SPEED_MODE = false

--// FUNCTIONS
local function getRandomFish()
    local total = 0
    for _, fish in pairs(FISH_LIST) do total += fish.Rarity end
    local roll = math.random(1, total)
    local cumulative = 0
    for _, fish in pairs(FISH_LIST) do
        cumulative += fish.Rarity
        if roll <= cumulative then return fish.Name end
    end
    return FISH_LIST[1].Name
end

local function setupPlayer(player)
    -- Inventory
    local inventory = {}
    player:SetAttribute("FishCount",0)

    -- Load from DataStore
    local success, data = pcall(function()
        return FishDataStore:GetAsync(player.UserId)
    end)
    if success and data then
        inventory = data
        local total = 0
        for _,v in pairs(inventory) do total += v end
        player:SetAttribute("FishCount",total)
    end

    -- Inventory GUI
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

    -- Equip Rod Detection
    player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")

        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == "FishingRod" then
                task.spawn(function()
                    while child.Parent == char do
                        task.wait(AUTO_CATCH_DELAY / (ULTRA_SPEED_MODE and 3 or 1))
                        local fishName = getRandomFish()

                        -- Update inventory
                        if inventory[fishName] then
                            inventory[fishName] += 1
                        else
                            inventory[fishName] = 1
                        end

                        -- Update counter
                        local total = 0
                        for _,v in pairs(inventory) do total += v end
                        player:SetAttribute("FishCount",total)
                        counterLabel.Text = "Fish Collected: "..total

                        -- Sound effect
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://12222225" -- ganti ID sound
                        sound.Volume = 1
                        sound.Parent = hrp
                        sound:Play()
                        game.Debris:AddItem(sound,2)
                    end
                end)
            end
        end)
    end)

    -- Auto save inventory tiap 30 detik
    task.spawn(function()
        while player.Parent do
            task.wait(30)
            pcall(function()
                FishDataStore:SetAsync(player.UserId, inventory)
            end)
        end
    end)
end

-- Setup existing and new players
for _,p in pairs(Players:GetPlayers()) do
    setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)
