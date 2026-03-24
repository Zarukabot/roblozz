--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ManualStressTester"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 500)
main.Position = UDim2.new(0.5, -170, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "🔥 Manual Stress Tester"
title.TextColor3 = Color3.fromRGB(0,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- FPS
local fpsLabel = Instance.new("TextLabel", main)
fpsLabel.Position = UDim2.new(0,10,0,45)
fpsLabel.Size = UDim2.new(1,-20,0,25)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0,255,150)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextScaled = true

-- MEMORY
local memLabel = fpsLabel:Clone()
memLabel.Parent = main
memLabel.Position = UDim2.new(0,10,0,70)
memLabel.TextColor3 = Color3.fromRGB(255,200,0)

-- INPUT: Amount
local amountBox = Instance.new("TextBox", main)
amountBox.Position = UDim2.new(0,10,0,105)
amountBox.Size = UDim2.new(1,-20,0,35)
amountBox.PlaceholderText = "Jumlah object (contoh: 1000)"
amountBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
amountBox.TextColor3 = Color3.new(1,1,1)
amountBox.Font = Enum.Font.Gotham
amountBox.TextScaled = true
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0,6)

-- INPUT: Delay
local delayBox = amountBox:Clone()
delayBox.Parent = main
delayBox.Position = UDim2.new(0,10,0,150)
delayBox.PlaceholderText = "Delay spawn (contoh: 0.01)"

-- INPUT: Size
local sizeBox = amountBox:Clone()
sizeBox.Parent = main
sizeBox.Position = UDim2.new(0,10,0,195)
sizeBox.PlaceholderText = "Ukuran label (contoh: 100)"

-- START BUTTON
local startBtn = Instance.new("TextButton", main)
startBtn.Position = UDim2.new(0,10,0,240)
startBtn.Size = UDim2.new(1,-20,0,40)
startBtn.Text = "▶ Start"
startBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextScaled = true
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

-- STOP BUTTON
local stopBtn = startBtn:Clone()
stopBtn.Parent = main
stopBtn.Position = UDim2.new(0,10,0,290)
stopBtn.Text = "⏹ Stop"
stopBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)

-- CLEAR BUTTON
local clearBtn = startBtn:Clone()
clearBtn.Parent = main
clearBtn.Position = UDim2.new(0,10,0,340)
clearBtn.Text = "🧹 Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(0,80,120)

-- STORAGE
local stressFolder = Instance.new("Folder", main)
stressFolder.Name = "StressObjects"

local running = false

-- START
startBtn.MouseButton1Click:Connect(function()
	if running then return end
	running = true
	
	local amount = tonumber(amountBox.Text) or 100
	local delayTime = tonumber(delayBox.Text) or 0.01
	local size = tonumber(sizeBox.Text) or 100
	
	task.spawn(function()
		for i = 1, amount do
			if not running then break end
			
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0,size,0,20)
			lbl.Position = UDim2.new(math.random(),0,math.random(),0)
			lbl.Text = "Load "..i
			lbl.TextColor3 = Color3.fromRGB(
				math.random(0,255),
				math.random(0,255),
				math.random(0,255)
			)
			lbl.BackgroundTransparency = 1
			lbl.Parent = stressFolder
			
			task.wait(delayTime)
		end
	end)
end)

-- STOP
stopBtn.MouseButton1Click:Connect(function()
	running = false
end)

-- CLEAR
clearBtn.MouseButton1Click:Connect(function()
	for _,v in pairs(stressFolder:GetChildren()) do
		v:Destroy()
	end
end)

-- FPS + MEMORY MONITOR
local last = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
	frames += 1
	if tick() - last >= 1 then
		fpsLabel.Text = "FPS: "..frames
		memLabel.Text = "Memory (MB): "..math.floor(collectgarbage("count")/1024)
		frames = 0
		last = tick()
	end
end)
