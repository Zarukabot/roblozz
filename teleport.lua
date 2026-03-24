--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

--// STATE
local autoTeleportEnabled = false
local autoTeleportConnection = nil
local lastTeleportTime = 0
local COOLDOWN = 2
local playerButtons = {}
local currentHighlight = nil

local isRecording = false
local isPlaying = false
local loopEnabled = false
local loopRunning = false
local loopCount = 0
local recordedSteps = {}
local recordStartTime = 0
local lastStepTime = 0
local recordConnections = {}
local savedQuests = {}

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI_v4"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// HELPERS
local function makeCorner(parent, radius)
    Instance.new("UICorner", parent).CornerRadius = UDim.new(0, radius or 12)
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
local function makePad(parent, top, left, right, bottom)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
end

--// NOTIFICATION
local function notify(msg, color)
    color = color or Color3.fromRGB(50,180,100)
    local nf = Instance.new("Frame", ScreenGui)
    nf.Size = UDim2.new(0,300,0,44)
    nf.Position = UDim2.new(0.5,-150,0,-60)
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
    nf:TweenPosition(UDim2.new(0.5,-150,0,20),"Out","Back",0.4,true)
    task.delay(2.8, function()
        nf:TweenPosition(UDim2.new(0.5,-150,0,-70),"In","Quad",0.3,true,function()
            nf:Destroy()
        end)
    end)
end

--// MAIN FRAME
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,370,0,470)
Frame.Position = UDim2.new(0.5,-185,0.5,-235)
Frame.BackgroundColor3 = Color3.fromRGB(14,14,20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
makeCorner(Frame, 18)
makeStroke(Frame, Color3.fromRGB(50,90,255), 1.5)

local topBar = Instance.new("Frame", Frame)
topBar.Size = UDim2.new(1,0,0,3)
topBar.BackgroundColor3 = Color3.fromRGB(60,120,255)
topBar.BorderSizePixel = 0
makeCorner(topBar, 3)
makeGradient(topBar, Color3.fromRGB(100,60,255), Color3.fromRGB(40,180,255))

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
SubTitle.Text = "Gift • Quest Record • Auto Loop"
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
TabBar.Size = UDim2.new(0.92,0,0,32)
TabBar.Position = UDim2.new(0.04,0,0,56)
TabBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
TabBar.BorderSizePixel = 0
makeCorner(TabBar, 10)
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,3)
makePad(TabBar,3,3,3,3)

local tabs = {}
local tabPages = {}
local tabDefs = {
    {id="teleport", label="✈️ TP"},
    {id="auto",     label="🎁 Hadiah"},
    {id="quest",    label="📋 Quest"},
    {id="save",     label="💾 Posisi"},
}

local function switchTab(id)
    for tid, page in pairs(tabPages) do page.Visible = tid == id end
    for tid, tbtn in pairs(tabs) do
        tbtn.BackgroundColor3 = tid==id and Color3.fromRGB(50,100,240) or Color3.fromRGB(24,24,36)
        tbtn.TextColor3 = tid==id and Color3.new(1,1,1) or Color3.fromRGB(120,120,150)
    end
end

for _, def in ipairs(tabDefs) do
    local tbtn = Instance.new("TextButton", TabBar)
    tbtn.Size = UDim2.new(0.24,0,1,-6)
    tbtn.BackgroundColor3 = Color3.fromRGB(24,24,36)
    tbtn.TextColor3 = Color3.fromRGB(120,120,150)
    tbtn.Text = def.label
    tbtn.Font = Enum.Font.GothamSemibold
    tbtn.TextSize = 10
    tbtn.BorderSizePixel = 0
    makeCorner(tbtn, 7)
    tbtn.MouseButton1Click:Connect(function() switchTab(def.id) end)
    tabs[def.id] = tbtn
    local page = Instance.new("Frame", Frame)
    page.Size = UDim2.new(0.92,0,0,368)
    page.Position = UDim2.new(0.04,0,0,96)
    page.BackgroundTransparency = 1
    page.Visible = false
    tabPages[def.id] = page
end
switchTab("teleport")

--// ══════════════════════
--// TAB 1 - TELEPORT
--// ══════════════════════
local tp = tabPages["teleport"]

local SearchBox = Instance.new("TextBox", tp)
SearchBox.Size = UDim2.new(1,0,0,34)
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
PlayerList.Size = UDim2.new(1,0,0,326)
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
makePad(PlayerList,6,6,6,6)

--// ══════════════════════
--// TAB 2 - AUTO HADIAH
--// ══════════════════════
local ap = tabPages["auto"]

local StatusFrame = Instance.new("Frame", ap)
StatusFrame.Size = UDim2.new(1,0,0,48)
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

local InfoBox = Instance.new("Frame", ap)
InfoBox.Size = UDim2.new(1,0,0,50)
InfoBox.Position = UDim2.new(0,0,0,56)
InfoBox.BackgroundColor3 = Color3.fromRGB(20,26,44)
InfoBox.BorderSizePixel = 0
makeCorner(InfoBox, 10)
makeStroke(InfoBox, Color3.fromRGB(40,60,130), 1)

local InfoLabel = Instance.new("TextLabel", InfoBox)
InfoLabel.Size = UDim2.new(1,-16,1,0)
InfoLabel.Position = UDim2.new(0,10,0,0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "💡 Pegang kado → baca @NamaPlayer\ndi atas kado → auto teleport!"
InfoLabel.TextColor3 = Color3.fromRGB(100,140,220)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextWrapped = true

local AutoBtn = Instance.new("TextButton", ap)
AutoBtn.Size = UDim2.new(0.48,0,0,36)
AutoBtn.Position = UDim2.new(0,0,0,114)
AutoBtn.Text = "▶  Aktifkan"
AutoBtn.BackgroundColor3 = Color3.fromRGB(35,150,75)
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 13
makeCorner(AutoBtn, 10)

local StopBtn = Instance.new("TextButton", ap)
StopBtn.Size = UDim2.new(0.48,0,0,36)
StopBtn.Position = UDim2.new(0.52,0,0,114)
StopBtn.Text = "■  Stop"
StopBtn.BackgroundColor3 = Color3.fromRGB(155,38,38)
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.TextTransparency = 0.5
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 13
StopBtn.Active = false
makeCorner(StopBtn, 10)

local LogFrame = Instance.new("Frame", ap)
LogFrame.Size = UDim2.new(1,0,0,148)
LogFrame.Position = UDim2.new(0,0,0,160)
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

--// ══════════════════════
--// TAB 3 - QUEST
--// ══════════════════════
local qp = tabPages["quest"]

-- Status
local QStatusFrame = Instance.new("Frame", qp)
QStatusFrame.Size = UDim2.new(1,0,0,38)
QStatusFrame.BackgroundColor3 = Color3.fromRGB(19,19,28)
QStatusFrame.BorderSizePixel = 0
makeCorner(QStatusFrame, 10)
makeStroke(QStatusFrame, Color3.fromRGB(32,42,80), 1)

local QDot = Instance.new("Frame", QStatusFrame)
QDot.Size = UDim2.new(0,10,0,10)
QDot.Position = UDim2.new(0,12,0.5,-5)
QDot.BackgroundColor3 = Color3.fromRGB(130,130,150)
QDot.BorderSizePixel = 0
makeCorner(QDot, 5)

local QStatusLabel = Instance.new("TextLabel", QStatusFrame)
QStatusLabel.Size = UDim2.new(1,-34,1,0)
QStatusLabel.Position = UDim2.new(0,30,0,0)
QStatusLabel.BackgroundTransparency = 1
QStatusLabel.Text = "Siap merekam quest..."
QStatusLabel.TextColor3 = Color3.fromRGB(130,130,155)
QStatusLabel.Font = Enum.Font.Gotham
QStatusLabel.TextSize = 11
QStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Nama quest
local QNameBox = Instance.new("TextBox", qp)
QNameBox.Size = UDim2.new(1,0,0,30)
QNameBox.Position = UDim2.new(0,0,0,44)
QNameBox.PlaceholderText = "📝 Nama quest..."
QNameBox.PlaceholderColor3 = Color3.fromRGB(75,75,100)
QNameBox.BackgroundColor3 = Color3.fromRGB(22,22,32)
QNameBox.TextColor3 = Color3.new(1,1,1)
QNameBox.Font = Enum.Font.Gotham
QNameBox.TextSize = 12
QNameBox.ClearTextOnFocus = false
makeCorner(QNameBox, 9)
makeStroke(QNameBox, Color3.fromRGB(40,50,90), 1)

-- Rekam / Stop rekam
local RecordBtn = Instance.new("TextButton", qp)
RecordBtn.Size = UDim2.new(0.48,0,0,34)
RecordBtn.Position = UDim2.new(0,0,0,80)
RecordBtn.Text = "⏺  Rekam"
RecordBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
RecordBtn.TextColor3 = Color3.new(1,1,1)
RecordBtn.Font = Enum.Font.GothamBold
RecordBtn.TextSize = 12
makeCorner(RecordBtn, 10)

local StopRecordBtn = Instance.new("TextButton", qp)
StopRecordBtn.Size = UDim2.new(0.48,0,0,34)
StopRecordBtn.Position = UDim2.new(0.52,0,0,80)
StopRecordBtn.Text = "⏹  Stop Rekam"
StopRecordBtn.BackgroundColor3 = Color3.fromRGB(40,44,62)
StopRecordBtn.TextColor3 = Color3.fromRGB(120,120,150)
StopRecordBtn.Font = Enum.Font.GothamBold
StopRecordBtn.TextSize = 11
StopRecordBtn.Active = false
makeCorner(StopRecordBtn, 10)

-- Play / Save
local PlayBtn = Instance.new("TextButton", qp)
PlayBtn.Size = UDim2.new(0.48,0,0,34)
PlayBtn.Position = UDim2.new(0,0,0,120)
PlayBtn.Text = "▶  Play 1x"
PlayBtn.BackgroundColor3 = Color3.fromRGB(35,130,210)
PlayBtn.TextColor3 = Color3.new(1,1,1)
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.TextSize = 12
makeCorner(PlayBtn, 10)

local SaveQuestBtn = Instance.new("TextButton", qp)
SaveQuestBtn.Size = UDim2.new(0.48,0,0,34)
SaveQuestBtn.Position = UDim2.new(0.52,0,0,120)
SaveQuestBtn.Text = "💾 Simpan"
SaveQuestBtn.BackgroundColor3 = Color3.fromRGB(45,90,200)
SaveQuestBtn.TextColor3 = Color3.new(1,1,1)
SaveQuestBtn.Font = Enum.Font.GothamBold
SaveQuestBtn.TextSize = 12
makeCorner(SaveQuestBtn, 10)

-- AUTO LOOP TOGGLE
local LoopBtn = Instance.new("TextButton", qp)
LoopBtn.Size = UDim2.new(1,0,0,38)
LoopBtn.Position = UDim2.new(0,0,0,162)
LoopBtn.Text = "🔁  Auto Loop: OFF"
LoopBtn.BackgroundColor3 = Color3.fromRGB(30,30,45)
LoopBtn.TextColor3 = Color3.fromRGB(120,120,150)
LoopBtn.Font = Enum.Font.GothamBold
LoopBtn.TextSize = 13
makeCorner(LoopBtn, 10)
makeStroke(LoopBtn, Color3.fromRGB(50,60,100), 1)

-- Loop info
local LoopInfoFrame = Instance.new("Frame", qp)
LoopInfoFrame.Size = UDim2.new(1,0,0,32)
LoopInfoFrame.Position = UDim2.new(0,0,0,206)
LoopInfoFrame.BackgroundColor3 = Color3.fromRGB(19,19,28)
LoopInfoFrame.BorderSizePixel = 0
makeCorner(LoopInfoFrame, 8)
makeStroke(LoopInfoFrame, Color3.fromRGB(32,42,80), 1)

local LoopStatusLabel = Instance.new("TextLabel", LoopInfoFrame)
LoopStatusLabel.Size = UDim2.new(0.6,0,1,0)
LoopStatusLabel.Position = UDim2.new(0,10,0,0)
LoopStatusLabel.BackgroundTransparency = 1
LoopStatusLabel.Text = "Belum berjalan"
LoopStatusLabel.TextColor3 = Color3.fromRGB(110,110,140)
LoopStatusLabel.Font = Enum.Font.Gotham
LoopStatusLabel.TextSize = 10
LoopStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local LoopCountLabel = Instance.new("TextLabel", LoopInfoFrame)
LoopCountLabel.Size = UDim2.new(0.38,0,1,0)
LoopCountLabel.Position = UDim2.new(0.62,0,0,0)
LoopCountLabel.BackgroundTransparency = 1
LoopCountLabel.Text = "0x loop"
LoopCountLabel.TextColor3 = Color3.fromRGB(80,220,120)
LoopCountLabel.Font = Enum.Font.GothamBold
LoopCountLabel.TextSize = 11
LoopCountLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Step counter + list
local StepCounter = Instance.new("TextLabel", qp)
StepCounter.Size = UDim2.new(1,0,0,14)
StepCounter.Position = UDim2.new(0,0,0,244)
StepCounter.BackgroundTransparency = 1
StepCounter.Text = "0 langkah terekam"
StepCounter.TextColor3 = Color3.fromRGB(70,80,115)
StepCounter.Font = Enum.Font.Gotham
StepCounter.TextSize = 10
StepCounter.TextXAlignment = Enum.TextXAlignment.Center

local StepsList = Instance.new("ScrollingFrame", qp)
StepsList.Size = UDim2.new(1,0,0,60)
StepsList.Position = UDim2.new(0,0,0,260)
StepsList.ScrollBarThickness = 3
StepsList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
StepsList.BackgroundColor3 = Color3.fromRGB(19,19,28)
StepsList.BorderSizePixel = 0
StepsList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(StepsList, 8)
makeStroke(StepsList, Color3.fromRGB(32,42,80), 1)
local StepsLayout = Instance.new("UIListLayout", StepsList)
StepsLayout.Padding = UDim.new(0,2)
makePad(StepsList,4,6,6,4)

-- Saved quest list
local SavedQTitle = Instance.new("TextLabel", qp)
SavedQTitle.Size = UDim2.new(1,0,0,14)
SavedQTitle.Position = UDim2.new(0,0,0,328)
SavedQTitle.BackgroundTransparency = 1
SavedQTitle.Text = "QUEST TERSIMPAN"
SavedQTitle.TextColor3 = Color3.fromRGB(70,90,160)
SavedQTitle.Font = Enum.Font.GothamBold
SavedQTitle.TextSize = 9
SavedQTitle.TextXAlignment = Enum.TextXAlignment.Left

local SavedQuestList = Instance.new("ScrollingFrame", qp)
SavedQuestList.Size = UDim2.new(1,0,0,52)
SavedQuestList.Position = UDim2.new(0,0,0,344)
SavedQuestList.ScrollBarThickness = 3
SavedQuestList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
SavedQuestList.BackgroundColor3 = Color3.fromRGB(19,19,28)
SavedQuestList.BorderSizePixel = 0
SavedQuestList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(SavedQuestList, 8)
makeStroke(SavedQuestList, Color3.fromRGB(32,42,80), 1)
local SQLayout = Instance.new("UIListLayout", SavedQuestList)
SQLayout.Padding = UDim.new(0,3)
makePad(SavedQuestList,4,6,6,4)

--// ══════════════════════
--// TAB 4 - SAVE POSISI
--// ══════════════════════
local sp = tabPages["save"]

local SaveButton = Instance.new("TextButton", sp)
SaveButton.Size = UDim2.new(1,0,0,36)
SaveButton.Text = "💾 Simpan Posisi Sekarang"
SaveButton.BackgroundColor3 = Color3.fromRGB(45,90,210)
SaveButton.TextColor3 = Color3.new(1,1,1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 13
makeCorner(SaveButton, 10)
makeGradient(SaveButton, Color3.fromRGB(60,75,220), Color3.fromRGB(35,135,255))

local SavedCountLabel = Instance.new("TextLabel", sp)
SavedCountLabel.Size = UDim2.new(1,0,0,14)
SavedCountLabel.Position = UDim2.new(0,0,0,42)
SavedCountLabel.BackgroundTransparency = 1
SavedCountLabel.Text = "0 posisi tersimpan"
SavedCountLabel.TextColor3 = Color3.fromRGB(70,80,115)
SavedCountLabel.Font = Enum.Font.Gotham
SavedCountLabel.TextSize = 10
SavedCountLabel.TextXAlignment = Enum.TextXAlignment.Center

local SavedList = Instance.new("ScrollingFrame", sp)
SavedList.Size = UDim2.new(1,0,0,308)
SavedList.Position = UDim2.new(0,0,0,60)
SavedList.ScrollBarThickness = 4
SavedList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
SavedList.BackgroundColor3 = Color3.fromRGB(19,19,28)
SavedList.BorderSizePixel = 0
SavedList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(SavedList, 10)
makeStroke(SavedList, Color3.fromRGB(32,42,80), 1)
local SLLayout = Instance.new("UIListLayout", SavedList)
SLLayout.Padding = UDim.new(0,4)
makePad(SavedList,6,6,6,6)

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

--// ══════════════════════════════
--// CORE LOGIC
--// ══════════════════════════════

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

local function getHeldTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

local function highlightBtn(btn)
    if currentHighlight and currentHighlight ~= btn then
        pcall(function() currentHighlight.BackgroundColor3 = Color3.fromRGB(22,22,32) end)
    end
    if btn then btn.BackgroundColor3 = Color3.fromRGB(35,70,175); currentHighlight = btn end
end

local function updatePlayers(filter)
    playerButtons = {}; currentHighlight = nil
    for _, v in pairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local name = player.Name
            if not filter or filter=="" or
               string.find(string.lower(name), string.lower(filter), 1, true) then
                local btn = Instance.new("TextButton", PlayerList)
                btn.Size = UDim2.new(1,0,0,32)
                btn.Text = "  👤  "..name
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
                        highlightBtn(btn)
                        notify("✈️ Teleport ke "..name, Color3.fromRGB(50,140,255))
                    else
                        notify("❌ "..name.." tidak ada karakter", Color3.fromRGB(220,70,70))
                    end
                end)
                playerButtons[name] = btn
            end
        end
    end
    task.wait()
    PlayerList.CanvasSize = UDim2.new(0,0,0,PLLayout.AbsoluteContentSize.Y+8)
end

updatePlayers()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() updatePlayers(SearchBox.Text) end)
Players.PlayerAdded:Connect(function() task.wait(1); updatePlayers(SearchBox.Text) end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); updatePlayers(SearchBox.Text) end)

--// AUTO HADIAH
local function findRecipient(tool)
    if not tool then return nil end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text
            if text and text ~= "" then
                local mentioned = string.match(text, "@([%a%d_]+)")
                if mentioned then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and
                           string.find(string.lower(p.Name), string.lower(mentioned), 1, true) then
                            return p
                        end
                    end
                end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and
                       string.find(string.lower(text), string.lower(p.Name), 1, true) then
                        return p
                    end
                end
            end
        end
    end
    local tl = string.lower(tool.Name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.find(tl, string.lower(p.Name), 1, true) then
            return p
        end
    end
    return nil
end

local function setStatus(text, color, dotColor)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(130,130,155)
    StatusDot.BackgroundColor3 = dotColor or Color3.fromRGB(130,130,150)
end

local function setQStatus(text, color, dotColor)
    QStatusLabel.Text = text
    QStatusLabel.TextColor3 = color or Color3.fromRGB(130,130,155)
    QDot.BackgroundColor3 = dotColor or Color3.fromRGB(130,130,150)
end

local function startAutoTeleport()
    if autoTeleportConnection then autoTeleportConnection:Disconnect() end
    autoTeleportEnabled = true
    AutoBtn.TextTransparency = 0.45; AutoBtn.Active = false
    StopBtn.TextTransparency = 0; StopBtn.Active = true
    setStatus("Aktif — mendeteksi kado...", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
    notify("▶ Auto hadiah aktif!", Color3.fromRGB(80,220,120))
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
                        if playerButtons[recipient.Name] then highlightBtn(playerButtons[recipient.Name]) end
                        setStatus("✅ → "..recipient.Name, Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
                        LogLabel.Text = "🎁 \""..tool.Name.."\" → "..recipient.Name.."\n⏰ "..os.date("%H:%M:%S")
                        notify("🎁 Auto-teleport ke "..recipient.Name, Color3.fromRGB(80,220,120))
                    end
                end
            else
                if tool.Name ~= lastToolName then
                    lastToolName = tool.Name
                    setStatus("🔍 \""..tool.Name.."\" — no match",
                        Color3.fromRGB(200,160,55), Color3.fromRGB(210,150,40))
                end
            end
        else
            if lastToolName ~= "" then
                lastToolName = ""
                setStatus("⏳ Tidak ada kado...", Color3.fromRGB(120,120,145), Color3.fromRGB(130,130,150))
            end
        end
    end)
end

local function stopAutoTeleport()
    autoTeleportEnabled = false
    if autoTeleportConnection then autoTeleportConnection:Disconnect(); autoTeleportConnection = nil end
    AutoBtn.TextTransparency = 0; AutoBtn.Active = true
    StopBtn.TextTransparency = 0.5; StopBtn.Active = false
    setStatus("Dihentikan.", Color3.fromRGB(130,130,155), Color3.fromRGB(130,130,150))
    notify("■ Auto hadiah dihentikan.", Color3.fromRGB(220,70,70))
end

AutoBtn.MouseButton1Click:Connect(startAutoTeleport)
StopBtn.MouseButton1Click:Connect(stopAutoTeleport)

--// ══════════════════════════════
--// QUEST RECORD
--// ══════════════════════════════

local function updateStepsList()
    for _, v in pairs(StepsList:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    StepCounter.Text = #recordedSteps.." langkah terekam"
    for i, step in ipairs(recordedSteps) do
        local lbl = Instance.new("TextLabel", StepsList)
        lbl.Size = UDim2.new(1,0,0,16)
        lbl.BackgroundTransparency = 1
        local icon = step.type=="clickdetector" and "🖱" or
                     step.type=="position" and "📍" or "🔘"
        lbl.Text = i..". "..icon.." ["..string.format("%.1f",step.delay).."s] "..
                   (step.text~="" and step.text or step.name)
        lbl.TextColor3 = Color3.fromRGB(150,160,200)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end
    task.wait()
    StepsList.CanvasSize = UDim2.new(0,0,0,StepsLayout.AbsoluteContentSize.Y+6)
end

local function startRecording()
    if isRecording then return end
    isRecording = true
    recordedSteps = {}
    recordStartTime = tick()
    lastStepTime = tick()
    updateStepsList()

    RecordBtn.TextTransparency = 0.4; RecordBtn.Active = false
    StopRecordBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    StopRecordBtn.TextColor3 = Color3.new(1,1,1); StopRecordBtn.Active = true
    setQStatus("⏺ Merekam...", Color3.fromRGB(220,60,60), Color3.fromRGB(220,60,60))
    notify("⏺ Rekaman dimulai!", Color3.fromRGB(220,60,60))

    -- Simpan posisi awal
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        table.insert(recordedSteps, {
            type="position",
            pos=char.HumanoidRootPart.Position,
            delay=0, name="Start", text=""
        })
        updateStepsList()
    end

    -- Hook ClickDetector di workspace
    local function hookCD(parent)
        for _, desc in ipairs(parent:GetDescendants()) do
            if desc:IsA("ClickDetector") then
                local conn = desc.MouseClick:Connect(function()
                    if not isRecording then return end
                    local now = tick()
                    local delay = now - lastStepTime
                    lastStepTime = now
                    local npcPart = desc.Parent
                    local npcPos = nil
                    if npcPart:IsA("BasePart") then
                        npcPos = npcPart.Position
                    elseif npcPart:FindFirstChild("HumanoidRootPart") then
                        npcPos = npcPart.HumanoidRootPart.Position
                    elseif npcPart:FindFirstChildWhichIsA("BasePart") then
                        npcPos = npcPart:FindFirstChildWhichIsA("BasePart").Position
                    end
                    table.insert(recordedSteps, {
                        type="clickdetector",
                        path=desc:GetFullName(),
                        npcPos=npcPos,
                        delay=delay,
                        name=desc.Parent.Name,
                        text="NPC: "..desc.Parent.Name
                    })
                    updateStepsList()
                    notify("🖱 Rekam klik NPC: "..desc.Parent.Name, Color3.fromRGB(255,180,50))
                end)
                table.insert(recordConnections, conn)
            end
        end
    end
    hookCD(workspace)

    -- Hook TextButton di PlayerGui
    local function hookBtn(parent)
        for _, desc in ipairs(parent:GetDescendants()) do
            if desc:IsA("TextButton") and
               not string.find(tostring(desc.Parent),"TeleportUltra",1,true) then
                local conn = desc.MouseButton1Click:Connect(function()
                    if not isRecording then return end
                    local now = tick()
                    local delay = now - lastStepTime
                    lastStepTime = now
                    table.insert(recordedSteps, {
                        type="click",
                        name=desc.Name,
                        text=desc.Text,
                        delay=delay,
                        path=desc:GetFullName()
                    })
                    updateStepsList()
                    notify("🔘 Rekam: \""..desc.Text.."\"", Color3.fromRGB(100,180,255))
                end)
                table.insert(recordConnections, conn)
            end
        end
    end
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name ~= "TeleportUltraGUI_v4" then hookBtn(gui) end
    end

    -- Hook descendants baru
    local c1 = PlayerGui.DescendantAdded:Connect(function(desc)
        if not isRecording then return end
        if desc:IsA("TextButton") and
           not string.find(tostring(desc.Parent),"TeleportUltra",1,true) then
            task.wait(0.05)
            local conn = desc.MouseButton1Click:Connect(function()
                if not isRecording then return end
                local now = tick()
                local delay = now - lastStepTime
                lastStepTime = now
                table.insert(recordedSteps, {
                    type="click", name=desc.Name,
                    text=desc.Text, delay=delay, path=desc:GetFullName()
                })
                updateStepsList()
                notify("🔘 Rekam: \""..desc.Text.."\"", Color3.fromRGB(100,180,255))
            end)
            table.insert(recordConnections, conn)
        end
    end)
    table.insert(recordConnections, c1)

    local c2 = workspace.DescendantAdded:Connect(function(desc)
        if not isRecording or not desc:IsA("ClickDetector") then return end
        task.wait(0.05)
        local conn = desc.MouseClick:Connect(function()
            if not isRecording then return end
            local now = tick()
            local delay = now - lastStepTime
            lastStepTime = now
            local npcPart = desc.Parent
            local npcPos = nil
            if npcPart:IsA("BasePart") then npcPos = npcPart.Position
            elseif npcPart:FindFirstChild("HumanoidRootPart") then npcPos = npcPart.HumanoidRootPart.Position
            elseif npcPart:FindFirstChildWhichIsA("BasePart") then npcPos = npcPart:FindFirstChildWhichIsA("BasePart").Position end
            table.insert(recordedSteps, {
                type="clickdetector", path=desc:GetFullName(),
                npcPos=npcPos, delay=delay,
                name=desc.Parent.Name, text="NPC: "..desc.Parent.Name
            })
            updateStepsList()
            notify("🖱 Rekam NPC: "..desc.Parent.Name, Color3.fromRGB(255,180,50))
        end)
        table.insert(recordConnections, conn)
    end)
    table.insert(recordConnections, c2)
end

local function stopRecording()
    if not isRecording then return end
    isRecording = false
    for _, conn in ipairs(recordConnections) do conn:Disconnect() end
    recordConnections = {}
    RecordBtn.TextTransparency = 0; RecordBtn.Active = true
    StopRecordBtn.BackgroundColor3 = Color3.fromRGB(40,44,62)
    StopRecordBtn.TextColor3 = Color3.fromRGB(120,120,150); StopRecordBtn.Active = false
    local clicks = 0
    for _, s in ipairs(recordedSteps) do if s.type~="position" then clicks+=1 end end
    setQStatus("✅ "..clicks.." langkah terekam", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
    notify("⏹ Rekaman selesai! "..clicks.." langkah.", Color3.fromRGB(80,220,120))
    updateStepsList()
end

--// ══════════════════════════════
--// PLAYBACK ENGINE
--// ══════════════════════════════

local function tryClickButton(step)
    local found = false
    local attempts = 0
    while not found and attempts < 4 do
        attempts += 1
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui.Name ~= "TeleportUltraGUI_v4" then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextButton") and desc.Visible then
                        if (step.text~="" and desc.Text==step.text) or
                           desc.Name==step.name then
                            local ok = pcall(function()
                                local vu = game:GetService("VirtualUser")
                                local ax = desc.AbsolutePosition.X + desc.AbsoluteSize.X/2
                                local ay = desc.AbsolutePosition.Y + desc.AbsoluteSize.Y/2
                                vu:Button1Down(Vector2.new(ax,ay), workspace.CurrentCamera.CFrame)
                                task.wait(0.05)
                                vu:Button1Up(Vector2.new(ax,ay), workspace.CurrentCamera.CFrame)
                            end)
                            if not ok then
                                pcall(function() desc.MouseButton1Click:Fire() end)
                            end
                            found = true
                            break
                        end
                    end
                end
            end
            if found then break end
        end
        if not found then task.wait(0.5) end
    end
    return found
end

local function runOnce(steps)
    if #steps == 0 then return false end
    isPlaying = true
    for i, step in ipairs(steps) do
        if not isPlaying then break end
        local waitTime = math.min(step.delay, 4)
        if waitTime > 0.1 then task.wait(waitTime) end

        if step.type == "position" then
            teleportTo(step.pos)
            setQStatus("📍 Teleport posisi awal...",
                Color3.fromRGB(160,110,255), Color3.fromRGB(160,110,255))
            task.wait(1.2)

        elseif step.type == "clickdetector" then
            if step.npcPos then
                teleportTo(step.npcPos + Vector3.new(0,3,4))
                task.wait(0.8)
            end
            local cd = nil
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ClickDetector") and desc.Parent.Name==step.name then
                    cd = desc; break
                end
            end
            if cd then
                pcall(function() fireclickdetector(cd) end)
                setQStatus("🖱 Klik NPC: \""..step.name.."\" ("..i.."/"..#steps..")",
                    Color3.fromRGB(255,180,50), Color3.fromRGB(255,170,40))
                notify("🖱 Klik NPC: "..step.name, Color3.fromRGB(255,180,50))
            else
                setQStatus("⚠️ NPC tidak ditemukan: "..step.name,
                    Color3.fromRGB(200,160,55), Color3.fromRGB(200,150,40))
            end
            task.wait(0.5)

        elseif step.type == "click" then
            local found = tryClickButton(step)
            if found then
                setQStatus("🔘 Klik: \""..step.text.."\" ("..i.."/"..#steps..")",
                    Color3.fromRGB(50,180,255), Color3.fromRGB(50,180,255))
            else
                setQStatus("⚠️ Tombol \""..step.text.."\" skip",
                    Color3.fromRGB(200,160,55), Color3.fromRGB(200,150,40))
            end
        end
    end
    isPlaying = false
    return true
end

--// ══════════════════════════════════════
--// TUNGGU TOOL HILANG (kado diserahkan)
--// ══════════════════════════════════════
local function waitToolGone(timeoutSec)
    -- Tunggu tool dipegang dulu (max 15 detik)
    local t = tick()
    while tick()-t < 15 do
        if not loopEnabled then return false end
        if getHeldTool() then break end
        task.wait(0.2)
    end
    -- Sekarang tunggu sampai tool HILANG
    local t2 = tick()
    while tick()-t2 < (timeoutSec or 60) do
        if not loopEnabled then return false end
        if not getHeldTool() then
            return true -- ✅ tool hilang = kado diserahkan
        end
        task.wait(0.2)
    end
    return false -- timeout
end

--// ══════════════════════════════════════
--// AUTO LOOP
--// ══════════════════════════════════════
local function startLoop(steps)
    if loopRunning then return end
    if #steps == 0 then
        notify("❌ Rekam quest dulu!", Color3.fromRGB(220,70,70)); return
    end
    loopEnabled = true
    loopRunning = true
    loopCount = 0

    LoopBtn.Text = "🔁  Auto Loop: ON"
    LoopBtn.BackgroundColor3 = Color3.fromRGB(35,150,75)
    LoopBtn.TextColor3 = Color3.new(1,1,1)
    notify("🔁 Auto Loop dimulai!", Color3.fromRGB(80,220,120))

    task.spawn(function()
        while loopEnabled do
            loopCount += 1
            LoopCountLabel.Text = loopCount.."x loop"
            LoopStatusLabel.Text = "Loop #"..loopCount.." — quest..."

            -- Jalankan semua langkah
            local ok = runOnce(steps)
            if not ok or not loopEnabled then break end

            -- Tunggu sampai tool/kado hilang dari tangan
            LoopStatusLabel.Text = "⏳ Tunggu kado diserahkan..."
            setQStatus("⏳ Tunggu kado diserahkan...",
                Color3.fromRGB(200,160,55), Color3.fromRGB(200,150,40))

            local delivered = waitToolGone(60)
            if not loopEnabled then break end

            if delivered then
                notify("✅ Kado diserahkan! Loop #"..loopCount.." selesai.", Color3.fromRGB(80,220,120))
                task.wait(1.5) -- jeda sebelum loop berikutnya
            else
                notify("⚠️ Timeout 60s, lanjut loop...", Color3.fromRGB(200,160,55))
                task.wait(1)
            end
        end

        -- Reset saat berhenti
        loopRunning = false
        isPlaying = false
        LoopBtn.Text = "🔁  Auto Loop: OFF"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(30,30,45)
        LoopBtn.TextColor3 = Color3.fromRGB(120,120,150)
        LoopStatusLabel.Text = "Selesai. Total: "..loopCount.."x"
        setQStatus("■ Loop selesai. Total: "..loopCount.."x",
            Color3.fromRGB(130,130,155), Color3.fromRGB(130,130,150))
        notify("■ Loop dihentikan. Total "..loopCount.." loop.", Color3.fromRGB(220,70,70))
    end)
end

local function stopLoop()
    loopEnabled = false
    isPlaying = false
end

LoopBtn.MouseButton1Click:Connect(function()
    if not loopEnabled then
        local stepsToUse = recordedSteps
        if #stepsToUse == 0 and #savedQuests > 0 then
            stepsToUse = savedQuests[#savedQuests].steps
            notify("📋 Pakai: "..savedQuests[#savedQuests].name, Color3.fromRGB(100,180,255))
        end
        startLoop(stepsToUse)
    else
        stopLoop()
        notify("■ Menghentikan loop...", Color3.fromRGB(220,70,70))
    end
end)

RecordBtn.MouseButton1Click:Connect(startRecording)
StopRecordBtn.MouseButton1Click:Connect(stopRecording)

PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then return end
    task.spawn(function()
        runOnce(recordedSteps)
        setQStatus("✅ Play selesai!", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
        notify("✅ Playback selesai!", Color3.fromRGB(80,220,120))
    end)
end)

--// SAVE QUEST
local questCount = 0
SaveQuestBtn.MouseButton1Click:Connect(function()
    if #recordedSteps == 0 then
        notify("❌ Tidak ada langkah!", Color3.fromRGB(220,70,70)); return
    end
    questCount += 1
    local qname = QNameBox.Text~="" and QNameBox.Text or ("Quest #"..questCount)
    local snapshot = {}
    for _, s in ipairs(recordedSteps) do table.insert(snapshot, s) end
    table.insert(savedQuests, {name=qname, steps=snapshot})

    local row = Instance.new("Frame", SavedQuestList)
    row.Size = UDim2.new(1,0,0,26)
    row.BackgroundColor3 = Color3.fromRGB(22,22,32)
    row.BorderSizePixel = 0
    makeCorner(row, 7)
    makeStroke(row, Color3.fromRGB(38,50,100), 1)

    local qlbl = Instance.new("TextLabel", row)
    qlbl.Size = UDim2.new(1,-130,1,0)
    qlbl.Position = UDim2.new(0,8,0,0)
    qlbl.BackgroundTransparency = 1
    qlbl.Text = "📋 "..qname
    qlbl.TextColor3 = Color3.new(1,1,1)
    qlbl.Font = Enum.Font.Gotham
    qlbl.TextSize = 11
    qlbl.TextXAlignment = Enum.TextXAlignment.Left

    local runBtn = Instance.new("TextButton", row)
    runBtn.Size = UDim2.new(0,55,0,20)
    runBtn.Position = UDim2.new(1,-120,0.5,-10)
    runBtn.Text = "▶ Play"
    runBtn.BackgroundColor3 = Color3.fromRGB(35,130,210)
    runBtn.TextColor3 = Color3.new(1,1,1)
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextSize = 10
    makeCorner(runBtn, 6)

    local loopQBtn = Instance.new("TextButton", row)
    loopQBtn.Size = UDim2.new(0,55,0,20)
    loopQBtn.Position = UDim2.new(1,-60,0.5,-10)
    loopQBtn.Text = "🔁 Loop"
    loopQBtn.BackgroundColor3 = Color3.fromRGB(35,150,75)
    loopQBtn.TextColor3 = Color3.new(1,1,1)
    loopQBtn.Font = Enum.Font.GothamBold
    loopQBtn.TextSize = 10
    makeCorner(loopQBtn, 6)

    local savedSteps = snapshot
    runBtn.MouseButton1Click:Connect(function()
        if isPlaying then return end
        task.spawn(function()
            runOnce(savedSteps)
            notify("✅ "..qname.." selesai!", Color3.fromRGB(80,220,120))
        end)
    end)
    loopQBtn.MouseButton1Click:Connect(function()
        if not loopEnabled then
            startLoop(savedSteps)
            notify("🔁 Loop: "..qname, Color3.fromRGB(80,220,120))
        else
            stopLoop()
        end
    end)

    task.wait()
    SavedQuestList.CanvasSize = UDim2.new(0,0,0,SQLayout.AbsoluteContentSize.Y+6)
    notify("💾 Quest \""..qname.."\" disimpan!", Color3.fromRGB(50,140,255))
    QNameBox.Text = ""
end)

--// SAVE POSISI
local saveCount = 0
SaveButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        saveCount += 1
        local posText = "("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")"
        SavedCountLabel.Text = saveCount.." posisi tersimpan"

        local row = Instance.new("Frame", SavedList)
        row.Size = UDim2.new(1,0,0,34)
        row.BackgroundColor3 = Color3.fromRGB(22,22,32)
        row.BorderSizePixel = 0
        makeCorner(row, 8)
        makeStroke(row, Color3.fromRGB(38,50,100), 1)

        local rowLabel = Instance.new("TextLabel", row)
        rowLabel.Size = UDim2.new(1,-74,1,0)
        rowLabel.Position = UDim2.new(0,8,0,0)
        rowLabel.BackgroundTransparency = 1
        rowLabel.Text = "📌 #"..saveCount.."  "..posText
        rowLabel.TextColor3 = Color3.new(1,1,1)
        rowLabel.Font = Enum.Font.Gotham
        rowLabel.TextSize = 10
        rowLabel.TextXAlignment = Enum.TextXAlignment.Left

        local goBtn = Instance.new("TextButton", row)
        goBtn.Size = UDim2.new(0,60,0,24)
        goBtn.Position = UDim2.new(1,-64,0.5,-12)
        goBtn.Text = "GO ✈️"
        goBtn.BackgroundColor3 = Color3.fromRGB(45,90,210)
        goBtn.TextColor3 = Color3.new(1,1,1)
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 10
        makeCorner(goBtn, 7)

        local savedPos = pos
        goBtn.MouseButton1Click:Connect(function()
            teleportTo(savedPos)
            notify("📌 Teleport ke #"..saveCount, Color3.fromRGB(160,110,255))
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0,0,0,SLLayout.AbsoluteContentSize.Y+8)
        notify("💾 Posisi #"..saveCount.." disimpan!", Color3.fromRGB(50,140,255))
    end
end)

--// TOGGLE GUI
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false; MiniButton.Visible = true
end)
MiniButton.MouseButton1Click:Connect(function()
    Frame.Visible = true; MiniButton.Visible = false
end)
