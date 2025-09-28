
-- Auto Teleport Checkpoint (Fly / Reset Mode)
-- By Zarukabot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "AutoTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.25, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"

local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
modeBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.TextScaled = true
modeBtn.Text = "Mode: Fly"

-- Variabel
local autoEnabled = false
local mode = "Fly" -- "Fly" / "Reset"
local checkpoints = {}
local visited = {}

-- Ambil checkpoint (namanya ada "checkpoint" atau SpawnLocation)
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:IsA("SpawnLocation")) then
		table.insert(checkpoints, obj)
	end
end

print("Total checkpoint ditemukan:", #checkpoints)

-- Fungsi teleport Fly Mode
local function flyTeleport(cp)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	-- simulasi fly dengan set velocity nol
	hrp.Velocity = Vector3.zero
	hrp.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
end

-- Fungsi teleport Reset Mode
local function resetTeleport(cp)
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0 -- kill dulu
			char = LocalPlayer.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			task.wait(0.5)
			hrp.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
		end
	end
end

-- Pilih checkpoint berikutnya yang belum
local function getNextCheckpoint()
	for _, cp in ipairs(checkpoints) do
		if not visited[cp] then
			return cp
		end
	end
	return nil
end

-- Deteksi saat player menyentuh checkpoint
for _, cp in ipairs(checkpoints) do
	cp.Touched:Connect(function(hit)
		local char = hit.Parent
		if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
			visited[cp] = true
			print("Checkpoint tersentuh:", cp.Name)
		end
	end)
end

-- Toggle mode button
modeBtn.MouseButton1Click:Connect(function()
	if mode == "Fly" then
		mode = "Reset"
		modeBtn.Text = "Mode: Reset"
	else
		mode = "Fly"
		modeBtn.Text = "Mode: Fly"
	end
	print("Mode teleport diganti ke:", mode)
end)

-- Toggle auto button
autoBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"

	if autoEnabled then
		task.spawn(function()
			while autoEnabled do
				local target = getNextCheckpoint()
				if target then
					if mode == "Fly" then
						flyTeleport(target)
					else
						resetTeleport(target)
					end
					print("Teleport ke checkpoint:", target.Name, "dengan mode", mode)
				else
					print("✅ Semua checkpoint sudah dikunjungi (idle)")
				end
				task.wait(5) -- delay antar teleport
			end
		end)
	end
end)

print("Auto Teleport GUI (Fly & Reset) Loaded ✅")
