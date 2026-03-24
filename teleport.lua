--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// STATE
local autoTeleportEnabled = false
local autoTeleportConnection = nil
local lastTeleportTime = 0
local COOLDOWN = 2
local playerButtons = {}
local currentHighlight = nil
local activeTab = "teleport"

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI_v3"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// HELPERS
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 12)
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(50,80,160)
    s.Thickness = thickness or 1
end

local function makeGradient(parent, c0, c1, rotation)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 135
end

--// NOTIFICATION
local notifyCount = 0
local function notify(msg, color)
    color = color or Color3.fromRGB(50,180,100)
    notifyCount += 1
    local slot = notifyCount

    local nf = Instance.new("Frame", ScreenGui)
    nf.Size = UDim2.new(0,290,0,44)
    nf.Position = UDim2.new(0.5,-145,0,-60)
    nf.BackgroundColor3 = Color3.fromRGB(18,18,26)
    nf.BorderSizePixel = 0
    nf.ZIndex = 30
    makeCorner(nf, 12)
    makeStroke(nf, color, 1.2)

    local accent = Instance.new("Frame", nf)
    accent.Size = UDim2.new(0,4,0.7,0)
    accent.Position = UDim2.new(0,0,0.15,0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    makeCorner(accent, 4)

    local lbl = Instance.new("TextLabel", nf)
    lbl.Size = UDim2.new(1,-18,1,0)
    lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 31

    nf:TweenPosition(UDim2.new(0.5,-145,0,20), "Out","Back",0.4,true)
    task.delay(2.8, function()
        notifyCount = math.max(0, notifyCount-1)
        nf:TweenPosition(UDim2.new(0.5,-145,0,-70),"In","Quad",0.3,true,function()
            nf:Destroy()
        end)
    end)
end

--// MAIN FRAME
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,360,0,420)
Frame.Position = UDim2.new(0.5,-180,0.5,-210)
Frame.BackgroundColor3 = Color3.fromRGB(14,14,20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
makeCorner(Frame, 18)
makeStroke(Frame, Color3.fromRGB(50,90,255), 1.5)

-- Top gradient bar
local topBar = Instance.new("Frame", Frame)
topBar.Size = UDim2.new(1,0,0,3)
topBar.BackgroundColor3 = Color3.fromRGB(60,120,255)
topBar.BorderSizePixel = 0
makeCorner(topBar, 3)
makeGradient(topBar, Color3.fromRGB(100,60,255), Color3.fromRGB(40,180,255))

--// HEADER
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,-50,0,26)
Title.Position = UDim2.new(0,16,0,10)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Teleport Ultra"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Frame)
SubTitle.Size = UDim2.new(1,-50,0,14)
SubTitle.Position = UDim2.new(0,16,0,34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Gift Auto-Teleport Edition"
SubTitle.TextColor3 = Color3.fromRGB(80,130,255)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-36,0,12)
CloseBtn.Text = "−"
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,44,62)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
makeCorner(CloseBtn, 8)

--// TAB BAR
local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(0.9,0,0,34)
TabBar.Position = UDim2.new(0.05,0,0,56)
TabBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
TabBar.BorderSizePixel = 0
makeCorner(TabBar, 10)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,4)
Instance.new("UIPadding", TabBar).PaddingLeft = UDim.new(0,4)

local tabs = {}
local tabPages = {}

local tabDefs = {
    {id="teleport", label="✈️ Teleport"},
    {id="auto",     label="🎁 Auto Hadiah"},
    {id="save",     label="💾 Save Posisi"},
}

local function switchTab(id)
    activeTab = id
    for tid, page in pairs(tabPages) do
        page.Visible = tid == id
    end
    for tid, tbtn in pairs(tabs) do
        if tid == id then
            tbtn.BackgroundColor3 = Color3.fromRGB(50,100,240)
            tbtn.TextColor3 = Color3.new(1,1,1)
        else
            tbtn.BackgroundColor3 = Color3.fromRGB(26,26,38)
            tbtn.TextColor3 = Color3.fromRGB(130,130,160)
        end
    end
end

for _, def in ipairs(tabDefs) do
    local tbtn = Instance.new("TextButton", TabBar)
    tbtn.Size = UDim2.new(0,98,0,26)
    tbtn.BackgroundColor3 = Color3.fromRGB(26,26,38)
    tbtn.TextColor3 = Color3.fromRGB(130,130,160)
    tbtn.Text = def.label
    tbtn.Font = Enum.Font.GothamSemibold
    tbtn.TextSize = 11
    tbtn.BorderSizePixel = 0
    makeCorner(tbtn, 8)
    tbtn.MouseButton1Click:Connect(function() switchTab(def.id) end)
    tabs[def.id] = tbtn

    local page = Instance.new("Frame", Frame)
    page.Size = UDim2.new(0.9,0,0,310)
    page.Position = UDim2.new(0.05,0,0,98)
    page.BackgroundTransparency = 1
    page.Visible = false
    tabPages[def.id] = page
end

-- Aktifkan tab pertama
switchTab("teleport")

--// ========================
--// TAB 1: TELEPORT
--// ========================
local tp = tabPages["teleport"]

local SearchBox = Instance.new("TextBox", tp)
SearchBox.Size = UDim2.new(1,0,0,34)
SearchBox.Position = UDim2.new(0,0,0,0)
SearchBox.PlaceholderText = "🔍 Cari nama player..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(75,75,100)
SearchBox.BackgroundColor3 = Color3.fromRGB(22,22,32)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
makeCorner(SearchBox, 10)
makeStroke(SearchBox, Color3.fromRGB(40,50,90), 1)

local PlayerList = Instance.new("ScrollingFrame", tp)
PlayerList.Size = UDim2.new(1,0,0,260)
PlayerList.Position = UDim2.new(0,0,0,42)
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
PlayerList.BackgroundColor3 = Color3.fromRGB(19,19,28)
PlayerList.BorderSizePixel = 0
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(PlayerList, 10)
makeStroke(PlayerList, Color3.fromRGB(32,42,80), 1)

local PLLayout = Instance.new("UIListLayout", PlayerList)
PLLayout.Padding = UDim.new(0,4)
local PLPad = Instance.new("UIPadding", PlayerList)
PLPad.PaddingTop = UDim.new(0,6)
PLPad.PaddingLeft = UDim.new(0,6)
PLPad.PaddingRight = UDim.new(0,6)

--// ========================
--// TAB 2: AUTO HADIAH
--// ========================
local ap = tabPages["auto"]

local StatusFrame = Instance.new("Frame", ap)
StatusFrame.Size = UDim2.new(1,0,0,50)
StatusFrame.BackgroundColor3 = Color3.fromRGB(19,19,28)
StatusFrame.BorderSizePixel = 0
makeCorner(StatusFrame, 10)
makeStroke(StatusFrame, Color3.fromRGB(32,42,80), 1)

local StatusDot = Instance.new("Frame", StatusFrame)
StatusDot.Size = UDim2.new(0,10,0,10)
StatusDot.Position = UDim2.new(0,12,0.5,-5)
StatusDot.BackgroundColor3 = Color3.fromRGB(130,130,150)
StatusDot.BorderSizePixel = 0
makeCorner(StatusDot, 5)

local StatusLabel = Instance.new("TextLabel", StatusFrame)
StatusLabel.Size = UDim2.new(1,-34,1,0)
StatusLabel.Position = UDim2.new(0,30,0,0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Auto teleport belum aktif"
StatusLabel.TextColor3 = Color3.fromRGB(130,130,155)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true

-- Info box
local InfoBox = Instance.new("Frame", ap)
InfoBox.Size = UDim2.new(1,0,0,60)
InfoBox.Position = UDim2.new(0,0,0,58)
InfoBox.BackgroundColor3 = Color3.fromRGB(22,28,45)
InfoBox.BorderSizePixel = 0
makeCorner(InfoBox, 10)
makeStroke(InfoBox, Color3.fromRGB(40,60,130), 1)

local InfoLabel = Instance.new("TextLabel", InfoBox)
InfoLabel.Size = UDim2.new(1,-16,1,0)
InfoLabel.Position = UDim2.new(0,10,0,0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "💡 Cara kerja:\nPegang kado → script baca teks @NamaPlayer di atas kado → auto teleport!"
InfoLabel.TextColor3 = Color3.fromRGB(100,140,220)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextWrapped = true

-- Cooldown info
local CoolLabel = Instance.new("TextLabel", ap)
CoolLabel.Size = UDim2.new(1,0,0,16)
CoolLabel.Position = UDim2.new(0,0,0,126)
CoolLabel.BackgroundTransparency = 1
CoolLabel.Text = "⏱ Cooldown: 2 detik antar teleport"
CoolLabel.TextColor3 = Color3.fromRGB(70,80,115)
CoolLabel.Font = Enum.Font.Gotham
CoolLabel.TextSize = 10
CoolLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Buttons
local AutoBtn = Instance.new("TextButton", ap)
AutoBtn.Size = UDim2.new(0.48,0,0,38)
AutoBtn.Position = UDim2.new(0,0,0,148)
AutoBtn.Text = "▶  Aktifkan"
AutoBtn.BackgroundColor3 = Color3.fromRGB(35,150,75)
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 13
makeCorner(AutoBtn, 10)

local StopBtn = Instance.new("TextButton", ap)
StopBtn.Size = UDim2.new(0.48,0,0,38)
StopBtn.Position = UDim2.new(0.52,0,0,148)
StopBtn.Text = "■  Stop"
StopBtn.BackgroundColor3 = Color3.fromRGB(155,38,38)
StopBtn.TextColor3 = Color3.fromRGB(255,255,255)
StopBtn.TextTransparency = 0.5
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 13
StopBtn.Active = false
makeCorner(StopBtn, 10)

-- Last teleport log
local LogFrame = Instance.new("Frame", ap)
LogFrame.Size = UDim2.new(1,0,0,80)
LogFrame.Position = UDim2.new(0,0,0,196)
LogFrame.BackgroundColor3 = Color3.fromRGB(19,19,28)
LogFrame.BorderSizePixel = 0
makeCorner(LogFrame, 10)
makeStroke(LogFrame, Color3.fromRGB(32,42,80), 1)

local LogTitle = Instance.new("TextLabel", LogFrame)
LogTitle.Size = UDim2.new(1,0,0,18)
LogTitle.Position = UDim2.new(0,10,0,6)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "LOG TERAKHIR"
LogTitle.TextColor3 = Color3.fromRGB(70,90,160)
LogTitle.Font = Enum.Font.GothamBold
LogTitle.TextSize = 9
LogTitle.TextXAlignment = Enum.TextXAlignment.Left

local LogLabel = Instance.new("TextLabel", LogFrame)
LogLabel.Size = UDim2.new(1,-16,1,-28)
LogLabel.Position = UDim2.new(0,10,0,24)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "Belum ada aktivitas..."
LogLabel.TextColor3 = Color3.fromRGB(110,110,140)
LogLabel.Font = Enum.Font.Gotham
LogLabel.TextSize = 11
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextWrapped = true

--// ========================
--// TAB 3: SAVE POSISI
--// ========================
local sp = tabPages["save"]

local SaveButton = Instance.new("TextButton", sp)
SaveButton.Size = UDim2.new(1,0,0,38)
SaveButton.Text = "💾 Simpan Posisi Sekarang"
SaveButton.BackgroundColor3 = Color3.fromRGB(45,90,210)
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 13
makeCorner(SaveButton, 10)
makeGradient(SaveButton, Color3.fromRGB(60,75,220), Color3.fromRGB(35,135,255))

local SavedCountLabel = Instance.new("TextLabel", sp)
SavedCountLabel.Size = UDim2.new(1,0,0,16)
SavedCountLabel.Position = UDim2.new(0,0,0,44)
SavedCountLabel.BackgroundTransparency = 1
SavedCountLabel.Text = "0 posisi tersimpan"
SavedCountLabel.TextColor3 = Color3.fromRGB(70,80,115)
SavedCountLabel.Font = Enum.Font.Gotham
SavedCountLabel.TextSize = 10
SavedCountLabel.TextXAlignment = Enum.TextXAlignment.Center

local SavedList = Instance.new("ScrollingFrame", sp)
SavedList.Size = UDim2.new(1,0,0,244)
SavedList.Position = UDim2.new(0,0,0,64)
SavedList.ScrollBarThickness = 4
SavedList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
SavedList.BackgroundColor3 = Color3.fromRGB(19,19,28)
SavedList.BorderSizePixel = 0
SavedList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(SavedList, 10)
makeStroke(SavedList, Color3.fromRGB(32,42,80), 1)

local SLLayout = Instance.new("UIListLayout", SavedList)
SLLayout.Padding = UDim.new(0,4)
local SLPad = Instance.new("UIPadding", SavedList)
SLPad.PaddingTop = UDim.new(0,6)
SLPad.PaddingLeft = UDim.new(0,6)
SLPad.PaddingRight = UDim.new(0,6)

--// MINI BUTTON
local MiniButton = Instance.new("TextButton", ScreenGui)
MiniButton.Size = UDim2.new(0,120,0,36)
MiniButton.Position = UDim2.new(0,20,0.5,0)
MiniButton.Text = "⚡ Open"
MiniButton.BackgroundColor3 = Color3.fromRGB(45,90,210)
MiniButton.TextColor3 = Color3.new(1,1,1)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.TextSize = 13
MiniButton.Visible = false
makeCorner(MiniButton, 12)
makeGradient(MiniButton, Color3.fromRGB(60,75,220), Color3.fromRGB(35,135,255))

--// CORE FUNCTIONS

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

local function highlightPlayerBtn(btn)
    if currentHighlight and currentHighlight ~= btn then
        pcall(function()
            currentHighlight.BackgroundColor3 = Color3.fromRGB(22,22,32)
        end)
    end
    if btn then
        btn.BackgroundColor3 = Color3.fromRGB(35,70,175)
        currentHighlight = btn
    end
end

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
                btn.Size = UDim2.new(1,0,0,32)
                btn.Text = "  👤  " .. name
                btn.BackgroundColor3 = Color3.fromRGB(22,22,32)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.TextXAlignment = Enum.TextXAlignment.Left
                makeCorner(btn, 8)
                makeStroke(btn, Color3.fromRGB(32,42,75), 1)

                btn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(player.Character.HumanoidRootPart.Position)
                        highlightPlayerBtn(btn)
                        notify("✈️ Teleport ke " .. name, Color3.fromRGB(50,140,255))
                    else
                        notify("❌ " .. name .. " tidak ada karakter", Color3.fromRGB(220,70,70))
                    end
                end)

                playerButtons[name] = btn
            end
        end
    end

    task.wait()
    PlayerList.CanvasSize = UDim2.new(0,0,0,PLLayout.AbsoluteContentSize.Y + 8)
end

updatePlayers()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayers(SearchBox.Text)
end)
Players.PlayerAdded:Connect(function() task.wait(1); updatePlayers(SearchBox.Text) end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); updatePlayers(SearchBox.Text) end)

--// GET HELD TOOL
local function getHeldTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

--// FIND RECIPIENT — baca @NamaPlayer dari TextLabel di atas kado
local function findRecipient(tool)
    if not tool then return nil end

    -- 1) Scan semua TextLabel/TextButton di dalam tool (BillboardGui dll)
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text
            if text and text ~= "" then
                -- Cek pola @NamaPlayer
                local mentioned = string.match(text, "@([%a%d_]+)")
                if mentioned then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            if string.lower(player.Name) == string.lower(mentioned) or
                               string.find(string.lower(player.Name), string.lower(mentioned), 1, true) then
                                return player
                            end
                        end
                    end
                end
                -- Cek nama player langsung di teks
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        if string.find(string.lower(text), string.lower(player.Name), 1, true) then
                            return player
                        end
                    end
                end
            end
        end
    end

    -- 2) Fallback: StringValue di dalam tool
    local tagNames = {"recipient","giftto","owner","target","for","penerima"}
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("StringValue") then
            for _, tag in ipairs(tagNames) do
                if string.lower(child.Name) == tag then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and
                           string.find(string.lower(child.Value), string.lower(player.Name), 1, true) then
                            return player
                        end
                    end
                end
            end
        end
    end

    -- 3) Fallback: nama Tool itu sendiri
    local toolNameLower = string.lower(tool.Name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if string.find(toolNameLower, string.lower(player.Name), 1, true) then
                return player
            end
        end
    end

    return nil
end

--// STATUS HELPER
local function setStatus(text, color, dotColor)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(130,130,155)
    StatusDot.BackgroundColor3 = dotColor or Color3.fromRGB(130,130,150)
end

local function addLog(text)
    LogLabel.Text = text
end

--// AUTO TELEPORT
local function startAutoTeleport()
    if autoTeleportConnection then autoTeleportConnection:Disconnect() end
    autoTeleportEnabled = true
    AutoBtn.TextTransparency = 0.45
    AutoBtn.Active = false
    StopBtn.TextTransparency = 0
    StopBtn.Active = true

    setStatus("Aktif — mendeteksi kado...", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
    notify("▶ Auto hadiah diaktifkan!", Color3.fromRGB(80,220,120))

    local lastToolName = ""

    autoTeleportConnection = RunService.Heartbeat:Connect(function()
        if not autoTeleportEnabled then return end

        local tool = getHeldTool()
        if tool then
            local recipient = findRecipient(tool)
            if recipient then
                local now = tick()
                if now - lastTeleportTime >= COOLDOWN then
                    lastTeleportTime = now
                    if recipient.Character and recipient.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(recipient.Character.HumanoidRootPart.Position)
                        if playerButtons[recipient.Name] then
                            highlightPlayerBtn(playerButtons[recipient.Name])
                        end
                        setStatus("✅ → "..recipient.Name, Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
                        addLog("🎁 Kado \""..tool.Name.."\" → "..recipient.Name.."\n⏰ "..os.date("%H:%M:%S"))
                        notify("🎁 Auto-teleport ke "..recipient.Name, Color3.fromRGB(80,220,120))
                    end
                end
            else
                if tool.Name ~= lastToolName then
                    lastToolName = tool.Name
                    setStatus("🔍 \""..tool.Name.."\" — tidak ada @match",
                        Color3.fromRGB(200,160,55), Color3.fromRGB(210,150,40))
                end
            end
        else
            if lastToolName ~= "" then
                lastToolName = ""
                setStatus("⏳ Tidak ada kado dipegang...",
                    Color3.fromRGB(120,120,145), Color3.fromRGB(130,130,150))
            end
        end
    end)
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
    setStatus("Dihentikan.", Color3.fromRGB(130,130,155), Color3.fromRGB(130,130,150))
    notify("■ Auto hadiah dihentikan.", Color3.fromRGB(220,70,70))
end

AutoBtn.MouseButton1Click:Connect(startAutoTeleport)
StopBtn.MouseButton1Click:Connect(stopAutoTeleport)

--// SAVE POSISI
local saveCount = 0
SaveButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        saveCount += 1
        local posText = "("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")"

        SavedCountLabel.Text = saveCount .. " posisi tersimpan"

        local row = Instance.new("Frame", SavedList)
        row.Size = UDim2.new(1,0,0,34)
        row.BackgroundColor3 = Color3.fromRGB(22,22,32)
        row.BorderSizePixel = 0
        makeCorner(row, 8)
        makeStroke(row, Color3.fromRGB(38,50,100), 1)

        local rowLabel = Instance.new("TextLabel", row)
        rowLabel.Size = UDim2.new(1,-80,1,0)
        rowLabel.Position = UDim2.new(0,10,0,0)
        rowLabel.BackgroundTransparency = 1
        rowLabel.Text = "📌 #"..saveCount.."  "..posText
        rowLabel.TextColor3 = Color3.new(1,1,1)
        rowLabel.Font = Enum.Font.Gotham
        rowLabel.TextSize = 11
        rowLabel.TextXAlignment = Enum.TextXAlignment.Left

        local goBtn = Instance.new("TextButton", row)
        goBtn.Size = UDim2.new(0,60,0,24)
        goBtn.Position = UDim2.new(1,-66,0.5,-12)
        goBtn.Text = "GO ✈️"
        goBtn.BackgroundColor3 = Color3.fromRGB(45,90,210)
        goBtn.TextColor3 = Color3.new(1,1,1)
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 10
        makeCorner(goBtn, 7)

        local savedPos = pos
        goBtn.MouseButton1Click:Connect(function()
            teleportTo(savedPos)
            notify("📌 Teleport ke posisi #"..saveCount, Color3.fromRGB(160,110,255))
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0,0,0,SLLayout.AbsoluteContentSize.Y + 8)
        notify("💾 Posisi #"..saveCount.." disimpan!", Color3.fromRGB(50,140,255))
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
