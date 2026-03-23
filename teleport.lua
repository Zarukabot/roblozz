local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local isOpen = true

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernTeleportGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,0,0,0)
Frame.Position = UDim2.new(0.5,0,0.5,0)
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

-- Open animation awal
TweenService:Create(Frame,TweenInfo.new(0.4,Enum.EasingStyle.Back),{
	Size = UDim2.new(0,360,0,500)
}):Play()

-- Floating Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0,50,0,50)
OpenButton.Position = UDim2.new(0,20,0.5,-25)
OpenButton.Text = "+"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.BackgroundColor3 = Color3.fromRGB(70,120,255)
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1,0)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,50)
Title.Position = UDim2.new(0,20,0,10)
Title.Text = "Teleport To Player"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-45,0,15)
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(200,50,50)
Close.Parent = Frame
Instance.new("UICorner", Close).CornerRadius = UDim.new(1,0)

-- Search
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1,-40,0,40)
SearchBox.Position = UDim2.new(0,20,0,70)
SearchBox.PlaceholderText = "🔍 Search player..."
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.BackgroundColor3 = Color3.fromRGB(45,45,50)
SearchBox.BorderSizePixel = 0
SearchBox.Parent = Frame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,12)

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-40,1,-130)
Scroll.Position = UDim2.new(0,20,0,120)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0,8)
UIListLayout.Parent = Scroll

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Scroll.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y+10)
end)

Frame.Active = true
Frame.Draggable = true

-- Teleport
local function teleportToPlayer(targetPlayer)
	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame =
			targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
	end
end

-- Refresh List
local function refreshList()
	for _, child in pairs(Scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local search = string.lower(SearchBox.Text)

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if search == "" or string.find(string.lower(player.Name), search) then
				
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(1,0,0,45)
				Button.Text = player.Name
				Button.Font = Enum.Font.Gotham
				Button.TextSize = 15
				Button.TextColor3 = Color3.new(1,1,1)
				Button.BackgroundColor3 = Color3.fromRGB(50,50,60)
				Button.BorderSizePixel = 0
				Button.Parent = Scroll
				
				Instance.new("UICorner", Button).CornerRadius = UDim.new(0,12)

				Button.MouseEnter:Connect(function()
					TweenService:Create(Button,TweenInfo.new(0.15),{
						BackgroundColor3 = Color3.fromRGB(70,70,90)
					}):Play()
				end)
				Button.MouseLeave:Connect(function()
					TweenService:Create(Button,TweenInfo.new(0.15),{
						BackgroundColor3 = Color3.fromRGB(50,50,60)
					}):Play()
				end)

				Button.MouseButton1Click:Connect(function()
					teleportToPlayer(player)
				end)
			end
		end
	end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

-- OPEN
local function openGUI()
	if isOpen then return end
	isOpen = true
	Frame.Visible = true
	TweenService:Create(Frame,TweenInfo.new(0.3,Enum.EasingStyle.Back),{
		Size = UDim2.new(0,360,0,500)
	}):Play()
	OpenButton.Visible = false
end

-- CLOSE
local function closeGUI()
	if not isOpen then return end
	isOpen = false
	local tween = TweenService:Create(Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
		Size = UDim2.new(0,0,0,0)
	})
	tween:Play()
	tween.Completed:Wait()
	Frame.Visible = false
	OpenButton.Visible = true
end

-- Keyboard Control
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	
	if input.KeyCode == Enum.KeyCode.Minus then
		closeGUI()
	end
	
	if input.KeyCode == Enum.KeyCode.Equals then
		openGUI()
	end
end)

-- Button Control
Close.MouseButton1Click:Connect(closeGUI)
OpenButton.MouseButton1Click:Connect(openGUI)

refreshList() 
