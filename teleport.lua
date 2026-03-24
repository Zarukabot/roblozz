--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

--// MAIN FRAME (LEBIH RINGKAS)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,360,0,480)
Frame.Position = UDim2.new(0.5,-180,0.5,-240)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,-40,0,40)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Teleport & Lyric Finder"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-35,0,5)
CloseBtn.Text = "-"
CloseBtn.BackgroundColor3 = Color3.fromRGB(50,120,255)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,8)

-- MINI OPEN BUTTON
local MiniButton = Instance.new("TextButton", ScreenGui)
MiniButton.Size = UDim2.new(0,110,0,35)
MiniButton.Position = UDim2.new(0,20,0.5,0)
MiniButton.Text = "⚡ Open"
MiniButton.BackgroundColor3 = Color3.fromRGB(50,120,255)
MiniButton.TextColor3 = Color3.new(1,1,1)
MiniButton.Visible = false
Instance.new("UICorner", MiniButton).CornerRadius = UDim.new(0,12)

-- SEARCH PLAYER
local SearchBox = Instance.new("TextBox", Frame)
SearchBox.Size = UDim2.new(0.9,0,0,30)
SearchBox.Position = UDim2.new(0.05,0,0,45)
SearchBox.PlaceholderText = "🔍 Search Player..."
SearchBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,8)

-- PLAYER LIST
local PlayerList = Instance.new("ScrollingFrame", Frame)
PlayerList.Size = UDim2.new(0.9,0,0,110)
PlayerList.Position = UDim2.new(0.05,0,0,80)
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.ScrollBarThickness = 5
PlayerList.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", PlayerList)
Layout.Padding = UDim.new(0,5)

-- SAVE POSITION BUTTON
local SaveButton = Instance.new("TextButton", Frame)
SaveButton.Size = UDim2.new(0.9,0,0,30)
SaveButton.Position = UDim2.new(0.05,0,0,200)
SaveButton.Text = "💾 Save Position"
SaveButton.BackgroundColor3 = Color3.fromRGB(50,120,255)
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 12
Instance.new("UICorner", SaveButton).CornerRadius = UDim.new(0,8)

-- SAVED LIST
local SavedList = Instance.new("ScrollingFrame", Frame)
SavedList.Size = UDim2.new(0.9,0,0,80)
SavedList.Position = UDim2.new(0.05,0,0,235)
SavedList.CanvasSize = UDim2.new(0,0,0,0)
SavedList.ScrollBarThickness = 5
SavedList.BackgroundTransparency = 1

local SavedLayout = Instance.new("UIListLayout", SavedList)
SavedLayout.Padding = UDim.new(0,5)

-- LYRIC SCAN BUTTON
local LyricButton = Instance.new("TextButton", Frame)
LyricButton.Size = UDim2.new(0.9,0,0,30)
LyricButton.Position = UDim2.new(0.05,0,0,320)
LyricButton.Text = "🔎 Scan Lirik"
LyricButton.BackgroundColor3 = Color3.fromRGB(120,80,255)
LyricButton.TextColor3 = Color3.new(1,1,1)
LyricButton.Font = Enum.Font.GothamBold
LyricButton.TextSize = 12
Instance.new("UICorner", LyricButton).CornerRadius = UDim.new(0,8)

-- LYRIC LIST
local LyricList = Instance.new("ScrollingFrame", Frame)
LyricList.Size = UDim2.new(0.9,0,0,80)
LyricList.Position = UDim2.new(0.05,0,0,355)
LyricList.CanvasSize = UDim2.new(0,0,0,0)
LyricList.ScrollBarThickness = 5
LyricList.BackgroundTransparency = 1

local LyricLayout = Instance.new("UIListLayout", LyricList)
LyricLayout.Padding = UDim.new(0,5)

-- TELEPORT FUNCTION
local function teleportTo(pos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- UPDATE PLAYER LIST
local function updatePlayers(filter)
    for _,v in pairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not filter or string.find(player.Name:lower(), filter:lower(),1,true) then
                local btn = Instance.new("TextButton", PlayerList)
                btn.Size = UDim2.new(1,-5,0,28)
                btn.Text = "👤 "..player.Name
                btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

                btn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(player.Character.HumanoidRootPart.Position)
                    end
                end)
            end
        end
    end

    task.wait()
    PlayerList.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+5)
end

updatePlayers()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayers(SearchBox.Text)
end)

-- SAVE POSITION
SaveButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        local btn = Instance.new("TextButton", SavedList)
        btn.Size = UDim2.new(1,-5,0,28)
        btn.Text = "📌 "..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

        btn.MouseButton1Click:Connect(function()
            teleportTo(pos)
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0,0,0,SavedLayout.AbsoluteContentSize.Y+5)
    end
end)

-- SCAN LIRIK (MANUAL)
LyricButton.MouseButton1Click:Connect(function()

    for _,v in pairs(LyricList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("lirik") or name:find("lyric") or name:find("jingle") or name:find("dip") or name:find("crunch") then

                local btn = Instance.new("TextButton", LyricList)
                btn.Size = UDim2.new(1,-5,0,28)
                btn.Text = "🎵 "..obj.Name
                btn.BackgroundColor3 = Color3.fromRGB(70,70,90)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

                btn.MouseButton1Click:Connect(function()
                    teleportTo(obj.Position)
                end)
            end
        end
    end

    task.wait()
    LyricList.CanvasSize = UDim2.new(0,0,0,LyricLayout.AbsoluteContentSize.Y+5)
end)

-- TOGGLE SYSTEM
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    MiniButton.Visible = false
end)
