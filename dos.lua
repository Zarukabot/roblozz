--// SERVICES
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local VIPDataStore = DataStoreService:GetDataStore("VIPStatus")

--// CONFIG
local VIP_DEFAULT = false -- default player tidak VIP
local VIP_BENEFIT = {
    WalkSpeed = 50,   -- contoh benefit
    JumpPower = 100,
    ExtraCoins = 500
}

--// FUNCTIONS
local function giveVIP(player)
    player:SetAttribute("VIP", true)
    -- bisa langsung beri benefit
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = VIP_BENEFIT.WalkSpeed
            humanoid.JumpPower = VIP_BENEFIT.JumpPower
        end
    end
    -- simpan ke DataStore
    pcall(function()
        VIPDataStore:SetAsync(player.UserId, true)
    end)
end

local function removeVIP(player)
    player:SetAttribute("VIP", false)
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 -- default
            humanoid.JumpPower = 50 -- default
        end
    end
    -- hapus dari DataStore
    pcall(function()
        VIPDataStore:SetAsync(player.UserId, false)
    end)
end

local function checkVIP(player)
    -- cek DataStore
    local success, value = pcall(function()
        return VIPDataStore:GetAsync(player.UserId)
    end)
    if success and value then
        giveVIP(player)
    else
        player:SetAttribute("VIP", VIP_DEFAULT)
    end
end

--// PLAYER HANDLER
Players.PlayerAdded:Connect(function(player)
    -- cek VIP saat join
    checkVIP(player)

    -- kalau karakter spawn lagi
    player.CharacterAdded:Connect(function(char)
        if player:GetAttribute("VIP") then
            local humanoid = char:WaitForChild("Humanoid")
            humanoid.WalkSpeed = VIP_BENEFIT.WalkSpeed
            humanoid.JumpPower = VIP_BENEFIT.JumpPower
        end
    end)
end)

--// COMMAND EXAMPLE (Developer only)
local function onCommand(player, cmd)
    if player.UserId == game.CreatorId then
        local split = string.split(cmd, " ")
        if split[1] == "vip" then
            local targetName = split[2]
            local action = split[3] -- add/remove
            local target = Players:FindFirstChild(targetName)
            if target then
                if action == "add" then
                    giveVIP(target)
                elseif action == "remove" then
                    removeVIP(target)
                end
            end
        end
    end
end

-- Contoh pemakaian: Developer ketik chat "/vip PlayerName add" atau "/vip PlayerName remove"
game.Players.PlayerChatted:Connect(onCommand)
