-- CLIENT SIDE (EXECUTOR)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SPEED = 20 -- ubah sesuai keinginan

local leaderstats = player:WaitForChild("leaderstats")
local stat = leaderstats:WaitForChild("TimePlayed")

local startValue = stat.Value
local startTime = tick()

print("Fake Time Boost Active")

RunService.RenderStepped:Connect(function()
	local elapsed = (tick() - startTime) * SPEED
	stat.Value = math.floor(startValue + elapsed)
end)
