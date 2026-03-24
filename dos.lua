--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteToolkitFULL"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,12)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Remote Toolkit FULL"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Search bar
local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Size = UDim2.new(1,-20,0,35)
SearchBox.Position = UDim2.new(0,10,0,55)
SearchBox.PlaceholderText = "Search Remote..."
SearchBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.ClearTextOnFocus = false
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextScaled = true
local SearchUICorner = Instance.new("UICorner", SearchBox)
SearchUICorner.CornerRadius = UDim.new(0,6)

-- Scroll frame for remotes
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Position = UDim2.new(0,10,0,95)
ScrollFrame.Size = UDim2.new(1,-20,0,300)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundTransparency = 1
local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0,5)

-- Parameter input
local ParamBox = Instance.new("TextBox", MainFrame)
ParamBox.Size = UDim2.new(1,-20,0,35)
ParamBox.Position = UDim2.new(0,10,0,405)
ParamBox.PlaceholderText = 'Parameters (comma separated, e.g. "Hello,100,true")'
ParamBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
ParamBox.TextColor3 = Color3.new(1,1,1)
ParamBox.ClearTextOnFocus = false
ParamBox.Font = Enum.Font.Gotham
ParamBox.TextScaled = true
local ParamCorner = Instance.new("UICorner", ParamBox)
ParamCorner.CornerRadius = UDim.new(0,6)

-- Log frame
local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Position = UDim2.new(0,10,0,450)
LogFrame.Size = UDim2.new(1,-20,0,120)
LogFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
LogFrame.CanvasSize = UDim2.new(0,0,0,0)
LogFrame.ScrollBarThickness = 6
local LogList = Instance.new("UIListLayout", LogFrame)
LogList.Padding = UDim.new(0,2)

-- Refresh & Collapse Buttons
local RefreshButton = Instance.new("TextButton", MainFrame)
RefreshButton.Size = UDim2.new(0.48,-15,0,35)
RefreshButton.Position = UDim2.new(0,10,1,-45)
RefreshButton.Text = "🔄 Refresh"
RefreshButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
RefreshButton.TextColor3 = Color3.new(1,1,1)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextScaled = true
local RefreshCorner = Instance.new("UICorner", RefreshButton)
RefreshCorner.CornerRadius = UDim.new(0,6)

local CollapseButton = Instance.new("TextButton", MainFrame)
CollapseButton.Size = UDim2.new(0.48,-15,0,35)
CollapseButton.Position = UDim2.new(0.52,5,1,-45)
CollapseButton.Text = "🗕 Collapse"
CollapseButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
CollapseButton.TextColor3 = Color3.new(1,1,1)
CollapseButton.Font = Enum.Font.Gotham
CollapseButton.TextScaled = true
local CollapseCorner = Instance.new("UICorner", CollapseButton)
CollapseCorner.CornerRadius = UDim.new(0,6)

local collapsed = false
CollapseButton.MouseButton1Click:Connect(function()
	collapsed = not collapsed
	if collapsed then
		MainFrame.Size = UDim2.new(0,500,0,100)
		CollapseButton.Text = "🗖 Expand"
	else
		MainFrame.Size = UDim2.new(0,500,0,600)
		CollapseButton.Text = "🗕 Collapse"
	end
end)

--// UTILS
local function logMessage(msg,typeStr)
	local textLabel = Instance.new("TextLabel", LogFrame)
	textLabel.Size = UDim2.new(1,0,0,25)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Gotham
	if typeStr=="INFO" then
		textLabel.TextColor3 = Color3.fromRGB(200,200,200)
	elseif typeStr=="RETURN" then
		textLabel.TextColor3 = Color3.fromRGB(100,255,100)
	elseif typeStr=="EVENT" then
		textLabel.TextColor3 = Color3.fromRGB(100,200,255)
	else
		textLabel.TextColor3 = Color3.fromRGB(255,255,255)
	end
	textLabel.Text = "["..typeStr.."] "..msg
	LogFrame.CanvasSize = UDim2.new(0,0,0,LogList.AbsoluteContentSize.Y)
end

local function parseParams(paramStr)
	local params = {}
	for param in paramStr:gmatch("[^,]+") do
		param = param:gsub("^%s*(.-)%s*$","%1") -- trim
		if param == "true" then
			table.insert(params,true)
		elseif param == "false" then
			table.insert(params,false)
		elseif tonumber(param) then
			table.insert(params,tonumber(param))
		else
			table.insert(params,param)
		end
	end
	return unpack(params)
end

--// LOAD REMOTES
local remoteButtons = {}
local function loadRemotes()
	-- Clear old buttons
	for _,v in pairs(ScrollFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	remoteButtons = {}
	local ySize = 0
	local searchText = SearchBox.Text:lower()
	for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
		if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) and (remote.Name:lower():find(searchText) or searchText=="") then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,0,0,40)
			btn.Text = remote.Name.." ["..remote.ClassName.."]"
			btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Font = Enum.Font.Gotham
			btn.TextScaled = true
			btn.Parent = ScrollFrame
			local corner = Instance.new("UICorner",btn)
			corner.CornerRadius = UDim.new(0,6)
			
			btn.MouseButton1Click:Connect(function()
				local ok,err = pcall(function()
					local params = parseParams(ParamBox.Text)
					if remote:IsA("RemoteEvent") then
						remote:FireServer(params)
						logMessage("Fired RemoteEvent: "..remote.Name,"INFO")
					else
						local result = remote:InvokeServer(params)
						logMessage("RemoteFunction "..remote.Name.." returned: "..tostring(result),"RETURN")
					end
				end)
				if not ok then
					logMessage("Error firing remote: "..err,"INFO")
				end
			end)
			
			remoteButtons[remote] = btn
			ySize = ySize + 45
		end
	end
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,ySize)
end

-- Refresh
RefreshButton.MouseButton1Click:Connect(loadRemotes)
SearchBox:GetPropertyChangedSignal("Text"):Connect(loadRemotes)

-- Auto listen RemoteEvent in ReplicatedStorage
for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
	if remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(function(...)
			logMessage(remote.Name.." sent: "..table.concat({...},","),"EVENT")
		end)
	end
end

-- Initial load
loadRemotes()
