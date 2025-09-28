-- Hybrid Auto Checkpoint + Spawn GUI
-- Bisa deteksi checkpoint custom (CheckpointId) + fallback spawn point default
-- By Zarukabot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoHybridGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.3, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Checkpoint"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"
autoBtn.Parent = frame

-- Variabel
local autoEnabled = false
local lastCheckpoint = nil
local lastSpawnCFrame = nil

-- Fungsi teleport
local function teleportBack()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	if lastCheckpoint then
		-- Teleport ke checkpoint terakhir
		hrp.CFrame = CFrame.new(lastCheckpoint.Position + Vector3.new(0, 3, 0))
	elseif lastSpawnCFrame then
		-- Teleport ke spawn terakhir
		hrp.CFrame = lastSpawnCFrame
	end
end

-- Deteksi checkpoint custom
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part:GetAttribute("CheckpointId") then
		part.Touched:Connect(function(hit)
			local char = hit.Parent
			if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
				lastCheckpoint = part
				print("Checkpoint "..part:GetAttribute("CheckpointId").." tersentuh!")
			end
		end)
	end
end

-- Update spawn default
local function onCharacterAdded(char)
	task.wait(0.5)
	local hrp = char:WaitForChild("HumanoidRootPart")
	lastSpawnCFrame = hrp.CFrame + Vector3.new(0, 3, 0)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

-- Toggle button
autoBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"

	if autoEnabled then
		task.spawn(function()
			while autoEnabled do
				local char = LocalPlayer.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health <= 0 then
						LocalPlayer.CharacterAdded:Wait()
						task.wait(0.5)
						teleportBack()
					end
				end
				task.wait(1)
			end
		end)
	end
end)

print("Hybrid Auto Checkpoint/Spawn GUI Loaded ✅")
