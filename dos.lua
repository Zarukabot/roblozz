--// SERVICES
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local playtimeStore = DataStoreService:GetDataStore("PlaytimeSpeed_v1")

--// SPEED SETTINGS
local TIME_SPEED = 5 
-- 1 = normal
-- 2 = 2x lebih cepat
-- 5 = 5x lebih cepat
-- 10 = super cepat

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

	-- Load Data
	local savedTime = 0
	local success, data = pcall(function()
		return playtimeStore:GetAsync(player.UserId)
	end)

	if success and data then
		savedTime = data
	end
	
	TimePlayed.Value = savedTime

	-- Simpan waktu join
	local joinTime = os.time()

	-- Update realtime
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not player.Parent then
			connection:Disconnect()
			return
		end

		local realElapsed = os.time() - joinTime
		local boostedTime = realElapsed * TIME_SPEED

		TimePlayed.Value = savedTime + boostedTime
	end)

end)

--==================================================
-- SAVE
--==================================================

local function save(player)
	local stat = player:FindFirstChild("leaderstats") and 
	             player.leaderstats:FindFirstChild("TimePlayed")

	if stat then
		pcall(function()
			playtimeStore:SetAsync(player.UserId, stat.Value)
		end)
	end
end

Players.PlayerRemoving:Connect(save)

game:BindToClose(function()
	for _, player in pairs(Players:GetPlayers()) do
		save(player)
	end
end)
