
-- Auto Teleport Checkpoint Belum Dikunjungi
-- By Zarukabot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "AutoTeleportGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.7, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.3, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
autoBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextScaled = true
autoBtn.Text = "Auto: OFF"

-- Variabel
local autoEnabled = false
local checkpoints = {}
local visited = {}

-- Ambil checkpoint (namanya ada "checkpoint" atau SpawnLocation)
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:IsA("SpawnLocation")) then
		table.insert(checkpoints, obj)
	end
end

print("Total checkpoint ditemukan:", #checkpoints)

-- Fungsi teleport
local function teleportTo(cp)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
end

-- Cari checkpoint berikutnya yang belum
local function getNextCheckpoint()
	for _, cp in ipairs(checkpoints) do
		if not visited[cp] then
			return cp
		end
	end
	return nil
end

-- Deteksi saat player menyentuh checkpoint → tandai visited
for _, cp in ipairs(checkpoints) do
	cp.Touched:Connect(function(hit)
		local char = hit.Parent
		if char and Players:GetPlayerFromCharacter(char) == LocalPlayer then
			visited[cp] = true
			print("Checkpoint tersentuh:", cp.Name)
		end
	end)
end

-- Toggle button
autoBtn.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	autoBtn.Text = autoEnabled and "Auto: ON" or "Auto: OFF"

	if autoEnabled then
		task.spawn(function()
			while autoEnabled do
				local target = getNextCheckpoint()
				if target then
					teleportTo(target)
					print("Teleport ke checkpoint:", target.Name)
				else
					print("✅ Semua checkpoint sudah dikunjungi")
					autoEnabled = false
					autoBtn.Text = "Auto: OFF"
					break
				end
				task.wait(5) -- delay biar tidak spam
			end
		end)
	end
end)

print("Auto Teleport GUI Loaded ✅")
