--// SERVICES
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playtimeStore = DataStoreService:GetDataStore("PlaytimeData")

--// SETTINGS
local TIME_MULTIPLIER = 1 -- 1 = normal | 2 = 2x lebih cepat | 5 = 5x

--==================================================
-- PLAYER JOIN
--==================================================

Players.PlayerAdded:Connect(function(player)

	-- Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local TimePlayed = Instance.new("IntValue")
	TimePlayed.Name = "TimePlayed"
	TimePlayed.Parent = leaderstats
	TimePlayed.Value = 0

	-- Load Data
	local success, data = pcall(function()
		return playtimeStore:GetAsync(player.UserId)
	end)

	if success and data then
		TimePlayed.Value = data
	end

	-- Timer Loop
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			TimePlayed.Value += 1 * TIME_MULTIPLIER
		end
	end)

end)

--==================================================
-- SAVE WHEN LEAVE
--==================================================

Players.PlayerRemoving:Connect(function(player)

	local timeStat = player:FindFirstChild("leaderstats") and 
	                 player.leaderstats:FindFirstChild("TimePlayed")

	if timeStat then
		pcall(function()
			playtimeStore:SetAsync(player.UserId, timeStat.Value)
		end)
	end

end)
