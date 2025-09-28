-- Auto Teleport Checkpoints (Fix)
-- Hanya teleport ke Checkpoint / SpawnLocation yang belum disentuh
-- By Zarukabot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCheckpointGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Checkpoint"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"
autoBtn.Parent = frame

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0.8, 0, 0.25, 0)
delayBox.Position = UDim2.new(0.1, 0, 0.55, 0)
delayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.TextScaled = true
delayBox.Text = "5" -- default 5 detik
delayBox.Parent = frame

-- Variabel
local autoEnabled = false
local checkpoints = {}
local visited = {}
local spawnCFrame = nil

-- Ambil semua checkpoint
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:IsA("SpawnLocation")) then
		table.insert(checkpoints, obj)
	end
end

-- Fungsi teleport
local function teleportTo(part)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
end

-- Simpan spawn awal
local function onCharacterAdded(char)
	task.wait(0.5)
	local hrp = char:WaitForChild("HumanoidRootPart")
	spawnCFrame = hrp.CFrame
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

-- Tandai visited saat disentuh
for i, part in ipairs(checkpoints) do
	part.Touched:Connect(function(hit)
		local char = hit.Parent
		if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
			visited[i] = true
			print("Checkpoint "..i.." tersentuh!")
		end
	end)
end

-- Cari checkpoint terdekat yang belum
local function getNextCheckpoint()
	local char = LocalPlayer.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local closest, dist = nil, math.huge
	for i, part in ipairs(checkpoints) do
		if not visited[i] then
			local d = (part.Position - hrp.Position).Magnitude
			if d < dist then
				closest, dist = part, d
			end
		end
	end
	return closest
end

-- Loop auto
local function autoLoop()
	while autoEnabled do
		local delayTime = tonumber(delayBox.Text) or 5
		local target = getNextCheckpoint()

		if target then
			print("Teleport ke checkpoint belum dikunjungi")
			teleportTo(target)
		else
			print("✅ Semua checkpoint sudah dikunjungi")
			break
		end

		task.wait(delayTime)
	end
end

-- Toggle button
autoBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"

	if autoEnabled then
		task.spawn(autoLoop)
	end
end)

print("✅ Auto Teleport Checkpoints Loaded")
