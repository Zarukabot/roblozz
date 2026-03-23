local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local isOpen = true
local savedPositions = {}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN FRAME
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.9,0,0.75,0)
Frame.Position = UDim2.new(0.5,0,0.5,0)
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

Frame.Active = true
Frame.Draggable = true

-- MINI BAR (fix toggle bug)
local MiniBar = Instance.new("TextButton")
MiniBar.Size = UDim2.new(0.4,0,0.07,0)
MiniBar.Position = UDim2.new(0.5,0,0.92,0)
MiniBar.AnchorPoint = Vector2.new(0.5,0.5)
MiniBar.Text = "⬆ Open Teleport Panel"
MiniBar.Visible = false
MiniBar.Font = Enum.Font.GothamBold
MiniBar.TextSize = 14
MiniBar.TextColor3 = Color3.new(1,1,1)
MiniBar.BackgroundColor3 = Color3.fromRGB(60,100,255)
MiniBar.Parent = ScreenGui
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(1,0)

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,50)
Title.Position = UDim2.new(0,20,0,10)
Title.Text = "Teleport Panel"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- CLOSE BUTTON
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-45,0,15)
Close.Text = "–"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(200,50,50)
Close.Parent = Frame
Instance.new("UICorner", Close).CornerRadius = UDim.new(1,0)

-- SAVE POSITION BUTTON
local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.4,0,0,35)
SaveButton.Position = UDim2.new(0.05,0,0,70)
SaveButton.Text = "💾 Save Position"
SaveButton.Font = Enum.Font.Gotham
SaveButton.TextSize = 14
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.BackgroundColor3 = Color3.fromRGB(70,170,100)
SaveButton.Parent = Frame
Instance.new("UICorner", SaveButton).CornerRadius = UDim.new(0,12)

-- SCROLL FOR SAVED POSITIONS
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.9,0,0.55,0)
Scroll.Position = UDim2.new(0.05,0,0,120)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.Parent = Scroll

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
end)

-- SAVE POSITION FUNCTION
local function saveCurrentPosition()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		table.insert(savedPositions, LocalPlayer.Character.HumanoidRootPart.CFrame)
	end
end

-- REFRESH SAVED LIST
local function refreshSavedList()
	for _, child in pairs(Scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	for index, pos in ipairs(savedPositions) do
		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1,0,0,40)
		Button.Text = "📍 Position "..index
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Button.TextColor3 = Color3.new(1,1,1)
		Button.BackgroundColor3 = Color3.fromRGB(80,80,100)
		Button.Parent = Scroll
		Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)
		
		Button.MouseButton1Click:Connect(function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = pos
			end
		end)
	end
end

SaveButton.MouseButton1Click:Connect(function()
	saveCurrentPosition()
	refreshSavedList()
end)

-- TOGGLE FUNCTIONS
local function closeGUI()
	if not isOpen then return end
	isOpen = false
	
	TweenService:Create(Frame,TweenInfo.new(0.3),{
		Size = UDim2.new(0.8,0,0.1,0),
		Position = UDim2.new(0.5,0,0.9,0)
	}):Play()
	
	MiniBar.Visible = true
end

local function openGUI()
	if isOpen then return end
	isOpen = true
	
	TweenService:Create(Frame,TweenInfo.new(0.3),{
		Size = UDim2.new(0.9,0,0.75,0),
		Position = UDim2.new(0.5,0,0.5,0)
	}):Play()
	
	MiniBar.Visible = false
end

Close.MouseButton1Click:Connect(closeGUI)
MiniBar.MouseButton1Click:Connect(openGUI)

UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	
	if input.KeyCode == Enum.KeyCode.Minus then
		closeGUI()
	end
	
	if input.KeyCode == Enum.KeyCode.Equals then
		openGUI()
	end
end)
