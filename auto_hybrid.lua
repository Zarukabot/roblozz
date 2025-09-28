
-- Simple Auto Teleport Sequential Checkpoints
-- By Zarukabot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Kumpulkan checkpoint
local checkpoints = {}
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:IsA("SpawnLocation")) then
		table.insert(checkpoints, obj)
	end
end

-- Sortir biar urut
table.sort(checkpoints, function(a, b)
	return a.Position.X < b.Position.X
end)

print("Total checkpoint ditemukan:", #checkpoints)

-- Auto teleport berurutan
task.spawn(function()
	for i, cp in ipairs(checkpoints) do
		task.wait(3) -- delay biar tidak lag
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		hrp.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
		print("Teleport ke checkpoint:", i, cp.Name)
	end
	print("✅ Semua checkpoint sudah dikunjungi")
end)
	if autoEnabled then
		task.spawn(autoLoop)
	end
end)

print("✅ Auto Teleport Checkpoints Loaded (Sequential Mode)")
