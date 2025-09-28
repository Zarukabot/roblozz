
-- Auto Teleport Checkpoints (Sequential Mode)
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
local currentIndex = 1

-- Ambil semua checkpoint (urut sesuai order di workspace)
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:IsA("SpawnLocation")) then
		table.insert(checkpoints, obj)
	end
end

-- Sortir biar konsisten
table.sort(checkpoints, function(a, b)
	return a.Position.X < b.Position.X -- bisa diganti ke Y/Z sesuai urutan map
end)

-- Fungsi teleport + tandai visited
local function teleportTo(part, index)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)

	-- tandai langsung sebagai visited
	visited[index] = true
	print("✅ Checkpoint "..index.." sudah dikunjungi")
end

-- Loop auto (berurutan)
local function autoLoop()
	while autoEnabled and currentIndex <= #checkpoints do
		local delayTime = tonumber(delayBox.Text) or 5

		if not visited[currentIndex] then
			local target = checkpoints[currentIndex]
			print("Teleport ke checkpoint "..currentIndex)
			teleportTo(target, currentIndex)
		end

		currentIndex += 1
		task.wait(delayTime)
	end

	if currentIndex > #checkpoints then
		print("✅ Semua checkpoint sudah dikunjungi secara berurutan")
		autoEnabled = false
		autoBtn.Text = "Auto: OFF"
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

print("✅ Auto Teleport Checkpoints Loaded (Sequential Mode)")
