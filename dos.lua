--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

--// SETTINGS
local TROLL_INTERVAL = 20 -- tiap 20 detik ada troll
local TROLL_DURATION = 5  -- efek berlangsung 5 detik

-- Fungsi troll random
local function trollPlayer(player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	
	local randomTroll = math.random(1,4)

	-- 🌀 1. Spin Effect
	if randomTroll == 1 then
		print("Spin Troll!")
		local spin = Instance.new("BodyAngularVelocity")
		spin.AngularVelocity = Vector3.new(0,20,0)
		spin.MaxTorque = Vector3.new(0,math.huge,0)
		spin.Parent = root
		
		task.wait(TROLL_DURATION)
		spin:Destroy()

	-- 🚀 2. Super Jump
	elseif randomTroll == 2 then
		print("Super Jump Troll!")
		humanoid.JumpPower = 150
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		
		task.wait(TROLL_DURATION)
		humanoid.JumpPower = 50

	-- 🎈 3. Transparan
	elseif randomTroll == 3 then
		print("Invisible Troll!")
		for _,part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = 0.7
			end
		end
		
		task.wait(TROLL_DURATION)
		
		for _,part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.Transparency = 0
			end
		end

	-- 🌈 4. Confetti Effect
	elseif randomTroll == 4 then
		print("Confetti Troll!")
		local particle = Instance.new("ParticleEmitter")
		particle.Texture = "rbxassetid://243660364"
		particle.Rate = 200
		particle.Lifetime = NumberRange.new(1)
		particle.Speed = NumberRange.new(5)
		particle.Parent = root
		
		task.wait(TROLL_DURATION)
		particle:Destroy()
	end
end

-- Loop troll random player
while true do
	task.wait(TROLL_INTERVAL)
	
	local players = Players:GetPlayers()
	if #players > 0 then
		local randomPlayer = players[math.random(1,#players)]
		trollPlayer(randomPlayer)
	end
end
