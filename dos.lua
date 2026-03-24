--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteFiringGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "🔌 Remote Firing Tool"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

--// SCROLLING FRAME
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Position = UDim2.new(0,10,0,60)
ScrollFrame.Size = UDim2.new(1,-20,1,-120)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0,5)

--// REFRESH BUTTON
local RefreshButton = Instance.new("TextButton", MainFrame)
RefreshButton.Size = UDim2.new(1,-20,0,40)
RefreshButton.Position = UDim2.new(0,10,1,-50)
RefreshButton.Text = "🔄 Refresh Remote List"
RefreshButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
RefreshButton.TextColor3 = Color3.new(1,1,1)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextScaled = true

local UICorner2 = Instance.new("UICorner", RefreshButton)
UICorner2.CornerRadius = UDim.new(0,8)

--// FUNCTION TO LOAD REMOTES
local function LoadRemotes()
	-- Clear old buttons
	for _, v in pairs(ScrollFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	
	local ySize = 0
	
	for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
		if remote:IsA("RemoteEvent") then
			
			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1,-5,0,40)
			Button.Text = "Fire: "..remote.Name
			Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
			Button.TextColor3 = Color3.new(1,1,1)
			Button.Font = Enum.Font.Gotham
			Button.TextScaled = true
			Button.Parent = ScrollFrame
			
			local UICorner3 = Instance.new("UICorner", Button)
			UICorner3.CornerRadius = UDim.new(0,8)
			
			Button.MouseButton1Click:Connect(function()
				print("Firing Remote:", remote.Name)
				
				-- contoh kirim parameter sederhana
				remote:FireServer("TestMessage")
			end)
			
			ySize = ySize + 45
		end
	end
	
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,ySize)
end

-- Refresh Click
RefreshButton.MouseButton1Click:Connect(function()
	LoadRemotes()
end)

-- Auto Load Saat Awal
LoadRemotes()
