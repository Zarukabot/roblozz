-- Auto Teleport GUI + Mode Fly/Reset
-- By Zarukabot

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.25, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"
autoBtn.Parent = frame

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
modeBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.TextScaled = true
modeBtn.Text = "Mode: Reset"
modeBtn.Parent = frame

-- Variabel
local autoEnabled = false
local mode = "Reset" -- bisa "Reset" atau "Fly"
local checkpoints = {}
local touchedCheckpoints = {}

-- Ambil semua checkpoint otomatis
for _, part in ipairs(workspace:GetDescendants()) do
	if part:IsA("BasePart") and part:GetAttribute("CheckpointId") then
		table.insert(checkpoints, part)
		part.Touched:Connect(function(hit)
			local char = hit.Parent
			if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
				touchedCheckpoints[part] = true
				print("Checkpoint "..part:GetAttribute("CheckpointId").." tersentuh!")
			end
		end)
	end
end

-- Fungsi Fly ke checkpoint
local function flyToCheckpoint(cp)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local goal = cp.Position + Vector3.new(0, 5, 0)

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(goal)})
	tween:Play()
	tween.Completed:Wait()
end

-- Fungsi Reset ke checkpoint
local function resetToCheckpoint(cp)
	local char = LocalPlayer.Character
	if char then
		char:BreakJoints() -- reset
	end
	LocalPlayer.CharacterAdded:Wait()
	task.wait(0.5)
	local newChar = LocalPlayer.Character
	if newChar then
		local hrp = newChar:WaitForChild("HumanoidRootPart")
		hrp.CFrame = cp.CFrame + Vector3.new(0, 3, 0)
	end
end

-- Ambil checkpoint berikutnya yang belum
local function getNextCheckpoint()
	for _, cp in ipairs(checkpoints) do
		if not touchedCheckpoints[cp] then
			return cp
		end
	end
	return nil
end

-- Toggle Auto
autoBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"

	if autoEnabled then
		task.spawn(function()
			while autoEnabled do
				local nextCp = getNextCheckpoint()
				if nextCp then
					if mode == "Fly" then
						flyToCheckpoint(nextCp)
					else
						resetToCheckpoint(nextCp)
					end
					task.wait(1.5) -- delay biar ga lag
				else
					print("Semua checkpoint sudah diambil ✅")
					autoEnabled = false
					autoBtn.Text = "Auto: OFF"
				end
				task.wait(1)
			end
		end)
	end
end)

-- Ganti Mode
modeBtn.MouseButton1Click:Connect(function()
	if mode == "Reset" then
		mode = "Fly"
		modeBtn.Text = "Mode: Fly"
		modeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
	else
		mode = "Reset"
		modeBtn.Text = "Mode: Reset"
		modeBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
	end
end)

print("Auto Teleport GUI Loaded ✅")

modeBtn.MouseButton1Click:Connect(function()
    flyMode = not flyMode
    modeBtn.Text = flyMode and "Mode: Fly" or "Mode: Reset"
end)

print("✅ Auto Checkpoint GUI Loaded (Fly / Reset)")
