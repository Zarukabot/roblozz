--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ExtremeStressTester"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 540)
main.Position = UDim2.new(0.5, -180, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "🔥 EXTREME Stress Tester"
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

-- INPUTS
local function createBox(y, placeholder)
	local box = Instance.new("TextBox", main)
	box.Position = UDim2.new(0,10,0,y)
	box.Size = UDim2.new(1,-20,0,35)
	box.PlaceholderText = placeholder
	box.BackgroundColor3 = Color3.fromRGB(30,30,30)
	box.TextColor3 = Color3.new(1,1,1)
	box.Font = Enum.Font.Gotham
	box.TextScaled = true
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
	return box
end

local amountBox = createBox(105,"Jumlah object (contoh: 2000)")
local delayBox = createBox(150,"Delay spawn (contoh: 0.001)")
local sizeBox = createBox(195,"Ukuran (GUI/Part) contoh: 100")

-- MODE BUTTON
local modeButton = Instance.new("TextButton", main)
modeButton.Position = UDim2.new(0,10,0,240)
modeButton.Size = UDim2.new(1,-20,0,35)
modeButton.Text = "Mode: 2D GUI"
modeButton.BackgroundColor3 = Color3.fromRGB(0,60,120)
modeButton.TextColor3 = Color3.new(1,1,1)
modeButton.Font = Enum.Font.GothamBold
modeButton.TextScaled = true
Instance.new("UICorner", modeButton).CornerRadius = UDim.new(0,6)

local currentMode = "2D"

modeButton.MouseButton1Click:Connect(function()
	if currentMode == "2D" then
		currentMode = "3D"
		modeButton.Text = "Mode: 3D Parts"
	else
		currentMode = "2D"
		modeButton.Text = "Mode: 2D GUI"
	end
end)

-- BUTTONS
local function createButton(y,text,color)
	local btn = Instance.new("TextButton", main)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Size = UDim2.new(1,-20,0,40)
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	return btn
end

local startBtn = createButton(285,"▶ Start",Color3.fromRGB(0,120,0))
local stopBtn = createButton(335,"⏹ Stop",Color3.fromRGB(120,0,0))
local clearBtn = createButton(385,"🧹 Clear",Color3.fromRGB(0,80,120))

-- STORAGE
local folder = Instance.new("Folder", workspace)
folder.Name = "ClientStressParts"

local guiFolder = Instance.new("Folder", main)
guiFolder.Name = "ClientStressGUI"

local running = false
local renderObjects = {}

-- START
startBtn.MouseButton1Click:Connect(function()
	if running then return end
	running = true
	
	local amount = tonumber(amountBox.Text) or 500
	local delayTime = tonumber(delayBox.Text) or 0.01
	local size = tonumber(sizeBox.Text) or 100
	
	task.spawn(function()
		for i = 1, amount do
			if not running then break end
			
			if currentMode == "2D" then
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(0,size,0,20)
				lbl.Position = UDim2.new(math.random(),0,math.random(),0)
				lbl.Text = "Load "..i
				lbl.TextColor3 = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
				lbl.BackgroundTransparency = 1
				lbl.Parent = guiFolder
				table.insert(renderObjects,lbl)
			else
				local part = Instance.new("Part")
				part.Size = Vector3.new(size/10,size/10,size/10)
				part.Position = player.Character.HumanoidRootPart.Position + Vector3.new(
					math.random(-50,50),
					math.random(0,50),
					math.random(-50,50)
				)
				part.Anchored = true
				part.Color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
				part.Parent = folder
				table.insert(renderObjects,part)
			end
			
			task.wait(delayTime)
		end
	end)
end)

-- HEAVY RENDER LOOP
RunService.RenderStepped:Connect(function(dt)
	if not running then return end
	
	for _,obj in pairs(renderObjects) do
		if obj:IsA("Part") then
			obj.CFrame = obj.CFrame * CFrame.Angles(0, math.rad(10), 0)
		elseif obj:IsA("TextLabel") then
			obj.Rotation += 5
		end
	end
end)

-- STOP
stopBtn.MouseButton1Click:Connect(function()
	running = false
end)

-- CLEAR
clearBtn.MouseButton1Click:Connect(function()
	running = false
	for _,v in pairs(folder:GetChildren()) do
		v:Destroy()
	end
	for _,v in pairs(guiFolder:GetChildren()) do
		v:Destroy()
	end
	table.clear(renderObjects)
end)

-- FPS + MEMORY
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
