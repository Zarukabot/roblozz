--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// REMOTE (harus ada server script juga)
local SubmitWord = ReplicatedStorage:WaitForChild("SubmitWord")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ModernSambungKata"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 450, 0, 300)
frame.Position = UDim2.new(0.5, -225, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Name = "Main"

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,20)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "SAMBUNG KATA"
title.TextColor3 = Color3.fromRGB(0,255,200)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- LETTER DISPLAY
local letterLabel = Instance.new("TextLabel", frame)
letterLabel.Size = UDim2.new(1,0,0,80)
letterLabel.Position = UDim2.new(0,0,0,60)
letterLabel.BackgroundTransparency = 1
letterLabel.Text = "A"
letterLabel.TextColor3 = Color3.fromRGB(255,255,255)
letterLabel.Font = Enum.Font.GothamBlack
letterLabel.TextScaled = true

-- TEXTBOX
local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(0.8,0,0,45)
textBox.Position = UDim2.new(0.1,0,0,160)
textBox.BackgroundColor3 = Color3.fromRGB(35,35,40)
textBox.PlaceholderText = "Ketik kata..."
textBox.TextColor3 = Color3.new(1,1,1)
textBox.Font = Enum.Font.Gotham
textBox.TextScaled = true
textBox.ClearTextOnFocus = false

local boxCorner = Instance.new("UICorner", textBox)
boxCorner.CornerRadius = UDim.new(0,12)

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,40)
status.Position = UDim2.new(0,0,1,-45)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255,80,80)
status.Font = Enum.Font.Gotham
status.TextScaled = true

-- TIMER BAR
local timerBarBG = Instance.new("Frame", frame)
timerBarBG.Size = UDim2.new(0.8,0,0,8)
timerBarBG.Position = UDim2.new(0.1,0,1,-60)
timerBarBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
timerBarBG.BorderSizePixel = 0

local timerBar = Instance.new("Frame", timerBarBG)
timerBar.Size = UDim2.new(1,0,1,0)
timerBar.BackgroundColor3 = Color3.fromRGB(0,255,200)
timerBar.BorderSizePixel = 0

local timerCorner = Instance.new("UICorner", timerBar)
timerCorner.CornerRadius = UDim.new(1,0)

-- TIMER FUNCTION
local function startTimer()
	timerBar.Size = UDim2.new(1,0,1,0)
	local tween = TweenService:Create(timerBar,
		TweenInfo.new(10, Enum.EasingStyle.Linear),
		{Size = UDim2.new(0,0,1,0)}
	)
	tween:Play()
end

startTimer()

-- SUBMIT
local function submit()
	if textBox.Text ~= "" then
		SubmitWord:FireServer(textBox.Text)
	end
end

textBox.FocusLost:Connect(function(enter)
	if enter then
		submit()
	end
end)

-- RESPONSE FROM SERVER
SubmitWord.OnClientEvent:Connect(function(success, data, score)
	if success then
		letterLabel.Text = data
		status.TextColor3 = Color3.fromRGB(0,255,120)
		status.Text = "BENAR! +Poin"
		textBox.Text = ""
		startTimer()
	else
		status.TextColor3 = Color3.fromRGB(255,80,80)
		status.Text = data
	end
	
	task.wait(2)
	status.Text = ""
end)
