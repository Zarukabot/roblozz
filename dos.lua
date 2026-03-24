--// SERVICES
local Players = game:GetService("Players")

--// SETTINGS
local CHECK_INTERVAL = 5       -- cek tiap 5 detik
local BASE_ADD = 20            -- uang tetap kalau kecil
local BONUS_PERCENT = 0.10     -- 10% dari uang kalau besar
local MAX_MONEY = 100000       -- optional batas maksimum

-- Player join
Players.PlayerAdded:Connect(function(player)
	
	-- Leaderstats (mata uang)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 100 -- uang awal
	money.Parent = leaderstats

	-- Auto detect & tambah uang
	task.spawn(function()
		while player.Parent do
			task.wait(CHECK_INTERVAL)

			local currentMoney = money.Value
			local addAmount = 0

			-- Logic auto-add
			if currentMoney < 500 then
				addAmount = BASE_ADD
			else
				addAmount = math.floor(currentMoney * BONUS_PERCENT)
			end

			-- Jangan melebihi MAX_MONEY
			if currentMoney + addAmount > MAX_MONEY then
				addAmount = MAX_MONEY - currentMoney
			end

			money.Value += addAmount
		end
	end)
end)
