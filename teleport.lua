--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

--// MAIN FRAME (SIZE SAMA)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,420,0,450)
Frame.Position = _G.TeleportGUIPos or UDim2.new(0.5,-210,0.5,-225)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,18)

Frame:GetPropertyChangedSignal("Position"):Connect(function()
    _G.TeleportGUIPos = Frame.Position
end)

-- SHADOW
local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Size = UDim2.new(1,30,1,30)
Shadow.Position = UDim2.new(0,-15,0,-15)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.6
Shadow.BackgroundTransparency = 1
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10,10,118,118)
Shadow.ZIndex = 0

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Teleport Player Ultra"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- SEARCH
local SearchBox = Instance.new("TextBox", Frame)
SearchBox.Size = UDim2.new(0.9,0,0,40)
SearchBox.Position = UDim2.new(0.05,0,0,60)
SearchBox.PlaceholderText = "🔍 Search Player..."
SearchBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,12)

-- PLAYER LIST
local PlayerList = Instance.new("ScrollingFrame", Frame)
PlayerList.Size = UDim2.new(0.9,0,0,150)
PlayerList.Position = UDim2.new(0.05,0,0,110)
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.ScrollBarThickness = 6
PlayerList.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", PlayerList)
Layout.Padding = UDim.new(0,6)

-- SAVE POSITION BUTTON
local SaveButton = Instance.new("TextButton", Frame)
SaveButton.Size = UDim2.new(0.9,0,0,40)
SaveButton.Position = UDim2.new(0.05,0,0,270)
SaveButton.Text = "💾 Save Current Position"
SaveButton.BackgroundColor3 = Color3.fromRGB(50,120,255)
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 14
Instance.new("UICorner", SaveButton).CornerRadius = UDim.new(0,12)

-- SAVED LIST
local SavedList = Instance.new("ScrollingFrame", Frame)
SavedList.Size = UDim2.new(0.9,0,0,100)
SavedList.Position = UDim2.new(0.05,0,0,320)
SavedList.CanvasSize = UDim2.new(0,0,0,0)
SavedList.ScrollBarThickness = 6
SavedList.BackgroundTransparency = 1

local SavedLayout = Instance.new("UIListLayout", SavedList)
SavedLayout.Padding = UDim.new(0,6)

-- MINI TOGGLE
local ToggleMini = Instance.new("TextButton", ScreenGui)
ToggleMini.Size = UDim2.new(0,120,0,35)
ToggleMini.Position = UDim2.new(0,20,0.5,0)
ToggleMini.Text = "⚡ Open"
ToggleMini.BackgroundColor3 = Color3.fromRGB(50,120,255)
ToggleMini.TextColor3 = Color3.new(1,1,1)
ToggleMini.Visible = false
Instance.new("UICorner", ToggleMini).CornerRadius = UDim.new(0,12)

--// TELEPORT
local function teleportTo(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

--// UPDATE PLAYER LIST (FIX TOTAL)
local selectedButton = nil

local function updatePlayers(filter)

    for _,child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if not filter or string.find(string.lower(player.Name), string.lower(filter), 1, true) then

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,-5,0,35)
                btn.Text = "👤 "..player.Name
                btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.Parent = PlayerList
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

                btn.MouseButton1Click:Connect(function()

                    if selectedButton then
                        selectedButton.BackgroundColor3 = Color3.fromRGB(40,40,45)
                    end

                    btn.BackgroundColor3 = Color3.fromRGB(50,120,255)
                    selectedButton = btn

                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(player.Character.HumanoidRootPart.Position)
                    end
                end)
            end
        end
    end

    task.wait()
    PlayerList.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
end

updatePlayers()

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayers(SearchBox.Text)
end)

Players.PlayerAdded:Connect(function()
    updatePlayers(SearchBox.Text)
end)

Players.PlayerRemoving:Connect(function()
    updatePlayers(SearchBox.Text)
end)

-- AUTO REFRESH tiap 2 detik
task.spawn(function()
    while true do
        task.wait(2)
        updatePlayers(SearchBox.Text)
    end
end)

--// SAVE POSITION SYSTEM
SaveButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        local pos = LocalPlayer.Character.HumanoidRootPart.Position

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-5,0,35)
        btn.Text = "📌 "..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = SavedList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

        btn.MouseButton1Click:Connect(function()
            teleportTo(pos)
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0,0,0,SavedLayout.AbsoluteContentSize.Y+10)
    end
end)

--// TOGGLE SYSTEM
local function closeGUI()
    Frame.Visible = false
    ToggleMini.Visible = true
end

local function openGUI()
    Frame.Visible = true
    ToggleMini.Visible = false
end

ToggleMini.MouseButton1Click:Connect(openGUI)

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Minus then
        closeGUI()
    elseif input.KeyCode == Enum.KeyCode.Equals then
        openGUI()
    end
end)
