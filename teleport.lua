--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// STATE
local savedPositions = {}
local autoTeleportEnabled = false
local autoTeleportConnection = nil
local lastTeleportTime = 0
local COOLDOWN = 2 -- seconds

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI_v2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// UTILITY: Create rounded frame
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 12)
    return c
end

local function makeGradient(parent, c0, c1)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = 135
end

--// NOTIFICATION SYSTEM
local function notify(msg, color)
    color = color or Color3.fromRGB(50,180,100)
    local nFrame = Instance.new("Frame", ScreenGui)
    nFrame.Size = UDim2.new(0, 280, 0, 45)
    nFrame.Position = UDim2.new(0.5, -140, 0, -50)
    nFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    nFrame.BorderSizePixel = 0
    nFrame.ZIndex = 10
    makeCorner(nFrame, 12)

    local accent = Instance.new("Frame", nFrame)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    makeCorner(accent, 4)

    local label = Instance.new("TextLabel", nFrame)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = msg
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 11
    label.TextTruncate = Enum.TextTruncate.AtEnd

    -- Animate in
    nFrame:TweenPosition(UDim2.new(0.5,-140,0,20), "Out", "Back", 0.4, true)
    task.delay(2.5, function()
        nFrame:TweenPosition(UDim2.new(0.5,-140,0,-60), "In", "Quad", 0.3, true, function()
            nFrame:Destroy()
        end)
    end)
end

--// MAIN FRAME
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 370, 0, 500)
Frame.Position = UDim2.new(0.5, -185, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
makeCorner(Frame, 18)

-- Subtle top gradient accent bar
local topBar = Instance.new("Frame", Frame)
topBar.Size = UDim2.new(1, 0, 0, 4)
topBar.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
topBar.BorderSizePixel = 0
makeCorner(topBar, 4)
makeGradient(topBar, Color3.fromRGB(80,60,255), Color3.fromRGB(50,180,255))

-- Outer glow stroke
local stroke = Instance.new("UIStroke", Frame)
stroke.Color = Color3.fromRGB(50, 100, 255)
stroke.Thickness = 1.2
stroke.Transparency = 0.6

--// HEADER
local Header = Instance.new("Frame", Frame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Teleport Ultra"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size = UDim2.new(1, -90, 0, 14)
SubTitle.Position = UDim2.new(0, 16, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Gift Auto-Teleport Edition"
SubTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 11)
CloseBtn.Text = "−"
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
makeCorner(CloseBtn, 8)

--// DIVIDER
local function makeDivider(parent, yPos, label)
    local div = Instance.new("Frame", parent)
    div.Size = UDim2.new(0.9, 0, 0, 1)
    div.Position = UDim2.new(0.05, 0, 0, yPos)
    div.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    div.BorderSizePixel = 0

    if label then
        local lbl = Instance.new("TextLabel", div)
        lbl.Size = UDim2.new(0, 110, 0, 18)
        lbl.Position = UDim2.new(0, 8, -8, 0)
        lbl.BackgroundColor3 = Color3.fromRGB(15,15,20)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(100,120,200)
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 10
        lbl.BorderSizePixel = 0
    end
    return div
end

--// SECTION HELPER (label above content)
local function makeSectionLabel(parent, yPos, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0.9, 0, 0, 18)
    lbl.Position = UDim2.new(0.05, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(100, 130, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

--// SEARCH BAR
makeSectionLabel(Frame, 58, "  PLAYERS")

local SearchBox = Instance.new("TextBox", Frame)
SearchBox.Size = UDim2.new(0.9, 0, 0, 34)
SearchBox.Position = UDim2.new(0.05, 0, 0, 78)
SearchBox.PlaceholderText = "🔍 Search player..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90,90,110)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
makeCorner(SearchBox, 10)
Instance.new("UIStroke", SearchBox).Color = Color3.fromRGB(50,60,90)

--// PLAYER LIST
local PlayerList = Instance.new("ScrollingFrame", Frame)
PlayerList.Size = UDim2.new(0.9, 0, 0, 110)
PlayerList.Position = UDim2.new(0.05, 0, 0, 120)
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
PlayerList.BackgroundColor3 = Color3.fromRGB(20,20,28)
PlayerList.BorderSizePixel = 0
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(PlayerList, 10)

local Layout = Instance.new("UIListLayout", PlayerList)
Layout.Padding = UDim.new(0, 4)
Instance.new("UIPadding", PlayerList).PaddingTop = UDim.new(0,5)

-- DIVIDER
makeDivider(Frame, 240, "  AUTO GIFT TELEPORT")

--// AUTO TELEPORT SECTION
makeSectionLabel(Frame, 253, "  BENDA DIPEGANG → AUTO TELEPORT KE PLAYER")

local AutoStatusLabel = Instance.new("TextLabel", Frame)
AutoStatusLabel.Size = UDim2.new(0.9, 0, 0, 28)
AutoStatusLabel.Position = UDim2.new(0.05, 0, 0, 272)
AutoStatusLabel.BackgroundColor3 = Color3.fromRGB(22,22,32)
AutoStatusLabel.TextColor3 = Color3.fromRGB(140,140,160)
AutoStatusLabel.Font = Enum.Font.Gotham
AutoStatusLabel.TextSize = 12
AutoStatusLabel.Text = "Status: Menunggu benda..."
AutoStatusLabel.BorderSizePixel = 0
makeCorner(AutoStatusLabel, 8)

local AutoBtn = Instance.new("TextButton", Frame)
AutoBtn.Size = UDim2.new(0.44, 0, 0, 34)
AutoBtn.Position = UDim2.new(0.05, 0, 0, 308)
AutoBtn.Text = "▶  Aktifkan Auto"
AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 12
makeCorner(AutoBtn, 10)

local StopBtn = Instance.new("TextButton", Frame)
StopBtn.Size = UDim2.new(0.44, 0, 0, 34)
StopBtn.Position = UDim2.new(0.51, 0, 0, 308)
StopBtn.Text = "■  Stop Auto"
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
StopBtn.Active = false
StopBtn.TextTransparency = 0.5
makeCorner(StopBtn, 10)

-- DIVIDER
makeDivider(Frame, 355, "  SAVED POSITIONS")

--// SAVE POSITION
local SaveButton = Instance.new("TextButton", Frame)
SaveButton.Size = UDim2.new(0.9, 0, 0, 34)
SaveButton.Position = UDim2.new(0.05, 0, 0, 368)
SaveButton.Text = "💾 Simpan Posisi Sekarang"
SaveButton.BackgroundColor3 = Color3.fromRGB(50, 100, 230)
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 12
makeCorner(SaveButton, 10)
makeGradient(SaveButton, Color3.fromRGB(60,80,220), Color3.fromRGB(40,140,255))

local SavedList = Instance.new("ScrollingFrame", Frame)
SavedList.Size = UDim2.new(0.9, 0, 0, 75)
SavedList.Position = UDim2.new(0.05, 0, 0, 410)
SavedList.ScrollBarThickness = 4
SavedList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
SavedList.BackgroundColor3 = Color3.fromRGB(20,20,28)
SavedList.BorderSizePixel = 0
SavedList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(SavedList, 10)

local SavedLayout = Instance.new("UIListLayout", SavedList)
SavedLayout.Padding = UDim.new(0, 4)
Instance.new("UIPadding", SavedList).PaddingTop = UDim.new(0,5)

--// MINI BUTTON
local MiniButton = Instance.new("TextButton", ScreenGui)
MiniButton.Size = UDim2.new(0, 120, 0, 36)
MiniButton.Position = UDim2.new(0, 20, 0.5, 0)
MiniButton.Text = "⚡ Open"
MiniButton.BackgroundColor3 = Color3.fromRGB(50, 100, 230)
MiniButton.TextColor3 = Color3.new(1,1,1)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.TextSize = 13
MiniButton.Visible = false
makeCorner(MiniButton, 12)
makeGradient(MiniButton, Color3.fromRGB(60,80,220), Color3.fromRGB(40,140,255))

--// TELEPORT FUNCTION
local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

--// PLAYER BUTTON HIGHLIGHT
local currentHighlight = nil
local function highlightPlayerBtn(btn)
    if currentHighlight and currentHighlight ~= btn then
        currentHighlight.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    end
    if btn then
        btn.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
        currentHighlight = btn
    end
end

--// UPDATE PLAYER LIST
local playerButtons = {}

local function updatePlayers(filter)
    playerButtons = {}
    currentHighlight = nil
    for _, v in pairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local name = player.Name
            if not filter or filter == "" or
               string.find(string.lower(name), string.lower(filter), 1, true) then

                local btn = Instance.new("TextButton", PlayerList)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Text = "  👤 " .. name
                btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.TextXAlignment = Enum.TextXAlignment.Left
                makeCorner(btn, 8)
                Instance.new("UIStroke", btn).Color = Color3.fromRGB(40,50,80)

                btn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(player.Character.HumanoidRootPart.Position)
                        highlightPlayerBtn(btn)
                        notify("✈️ Teleport ke " .. name, Color3.fromRGB(50,150,255))
                    end
                end)

                playerButtons[name] = btn
            end
        end
    end

    task.wait()
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 8)
end

updatePlayers()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayers(SearchBox.Text)
end)
Players.PlayerAdded:Connect(function() updatePlayers(SearchBox.Text) end)
Players.PlayerRemoving:Connect(function() updatePlayers(SearchBox.Text) end)

--// GET HELD TOOL NAME
local function getHeldToolName()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            return obj.Name
        end
    end
    return nil
end

--// DETECT PLAYER NAME IN TOOL NAME (partial match)
local function findPlayerInToolName(toolName)
    if not toolName then return nil end
    local lowerTool = string.lower(toolName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if string.find(lowerTool, string.lower(player.Name), 1, true) then
                return player
            end
        end
    end
    return nil
end

--// AUTO TELEPORT LOOP
local function startAutoTeleport()
    if autoTeleportConnection then
        autoTeleportConnection:Disconnect()
    end
    autoTeleportEnabled = true
    AutoBtn.TextTransparency = 0.5
    AutoBtn.Active = false
    StopBtn.TextTransparency = 0
    StopBtn.Active = true

    autoTeleportConnection = RunService.Heartbeat:Connect(function()
        if not autoTeleportEnabled then return end

        local toolName = getHeldToolName()
        if toolName then
            local target = findPlayerInToolName(toolName)
            if target then
                local now = tick()
                if now - lastTeleportTime >= COOLDOWN then
                    lastTeleportTime = now
                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(target.Character.HumanoidRootPart.Position)
                        -- Highlight in list
                        if playerButtons[target.Name] then
                            highlightPlayerBtn(playerButtons[target.Name])
                        end
                        AutoStatusLabel.Text = "✅ Teleport → " .. target.Name
                        AutoStatusLabel.TextColor3 = Color3.fromRGB(80,220,120)
                        notify("🎁 Auto-teleport ke " .. target.Name, Color3.fromRGB(80,220,120))
                    end
                end
            else
                AutoStatusLabel.Text = "🔍 Pegang: " .. toolName .. " (no match)"
                AutoStatusLabel.TextColor3 = Color3.fromRGB(200,160,60)
            end
        else
            AutoStatusLabel.Text = "⏳ Tidak ada benda dipegang..."
            AutoStatusLabel.TextColor3 = Color3.fromRGB(130,130,150)
        end
    end)

    notify("▶ Auto teleport diaktifkan!", Color3.fromRGB(80,220,120))
end

local function stopAutoTeleport()
    autoTeleportEnabled = false
    if autoTeleportConnection then
        autoTeleportConnection:Disconnect()
        autoTeleportConnection = nil
    end
    AutoBtn.TextTransparency = 0
    AutoBtn.Active = true
    StopBtn.TextTransparency = 0.5
    StopBtn.Active = false
    AutoStatusLabel.Text = "Status: Auto teleport berhenti."
    AutoStatusLabel.TextColor3 = Color3.fromRGB(140,140,160)
    notify("■ Auto teleport dihentikan.", Color3.fromRGB(220,80,80))
end

AutoBtn.MouseButton1Click:Connect(startAutoTeleport)
StopBtn.MouseButton1Click:Connect(stopAutoTeleport)

--// SAVE POSITION
SaveButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local label = "📌 " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z)

        local btn = Instance.new("TextButton", SavedList)
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.Text = label
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        makeCorner(btn, 8)
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(50,80,160)

        local savedPos = pos
        btn.MouseButton1Click:Connect(function()
            teleportTo(savedPos)
            notify("📌 Teleport ke posisi tersimpan", Color3.fromRGB(180,120,255))
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0, 0, 0, SavedLayout.AbsoluteContentSize.Y + 8)
        notify("💾 Posisi disimpan!", Color3.fromRGB(50,150,255))
    end
end)

--// TOGGLE GUI
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    MiniButton.Visible = true
end)
MiniButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    MiniButton.Visible = false
end)
