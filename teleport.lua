--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

--// STATE
local autoTeleportEnabled = false
local autoTeleportConnection = nil
local lastTeleportTime = 0
local COOLDOWN = 2
local playerButtons = {}
local currentHighlight = nil
local activeTab = "teleport"

-- Record/Playback state
local isRecording = false
local isPlaying = false
local recordedSteps = {} -- {type, target, text, delay}
local recordStartTime = 0
local lastStepTime = 0
local playbackConnection = nil
local savedQuests = {} -- list of {name, steps, savedPos}

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
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
end

--// NOTIFICATION
local notifyCount = 0
local function notify(msg, color)
    color = color or Color3.fromRGB(50,180,100)
    notifyCount += 1
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
        notifyCount = math.max(0, notifyCount-1)
        nf:TweenPosition(UDim2.new(0.5,-150,0,-70),"In","Quad",0.3,true,function()
            nf:Destroy()
        end)
    end)
end

--// MAIN FRAME
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,370,0,460)
Frame.Position = UDim2.new(0.5,-185,0.5,-230)
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
SubTitle.Text = "Gift • Quest Record • Teleport"
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
makePad(TabBar, 3, 3, 3, 3)

local tabs = {}
local tabPages = {}

local tabDefs = {
    {id="teleport", label="✈️ Teleport"},
    {id="auto",     label="🎁 Auto Hadiah"},
    {id="quest",    label="📋 Quest"},
    {id="save",     label="💾 Posisi"},
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
            tbtn.BackgroundColor3 = Color3.fromRGB(24,24,36)
            tbtn.TextColor3 = Color3.fromRGB(120,120,150)
        end
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
    page.Size = UDim2.new(0.92,0,0,358)
    page.Position = UDim2.new(0.04,0,0,96)
    page.BackgroundTransparency = 1
    page.Visible = false
    tabPages[def.id] = page
end

switchTab("teleport")

--// ══════════════════════════
--// TAB 1 — TELEPORT
--// ══════════════════════════
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
PlayerList.Size = UDim2.new(1,0,0,310)
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
makePad(PlayerList, 6, 6, 6, 6)

--// ══════════════════════════
--// TAB 2 — AUTO HADIAH
--// ══════════════════════════
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
InfoBox.Size = UDim2.new(1,0,0,52)
InfoBox.Position = UDim2.new(0,0,0,56)
InfoBox.BackgroundColor3 = Color3.fromRGB(20,26,44)
InfoBox.BorderSizePixel = 0
makeCorner(InfoBox, 10)
makeStroke(InfoBox, Color3.fromRGB(40,60,130), 1)

local InfoLabel = Instance.new("TextLabel", InfoBox)
InfoLabel.Size = UDim2.new(1,-16,1,0)
InfoLabel.Position = UDim2.new(0,10,0,0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "💡 Pegang kado → baca @NamaPlayer di atas kado\n→ auto teleport ke player tersebut!"
InfoLabel.TextColor3 = Color3.fromRGB(100,140,220)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextWrapped = true

local CoolLabel = Instance.new("TextLabel", ap)
CoolLabel.Size = UDim2.new(1,0,0,14)
CoolLabel.Position = UDim2.new(0,0,0,116)
CoolLabel.BackgroundTransparency = 1
CoolLabel.Text = "⏱ Cooldown: 2 detik antar teleport"
CoolLabel.TextColor3 = Color3.fromRGB(70,80,115)
CoolLabel.Font = Enum.Font.Gotham
CoolLabel.TextSize = 10
CoolLabel.TextXAlignment = Enum.TextXAlignment.Center

local AutoBtn = Instance.new("TextButton", ap)
AutoBtn.Size = UDim2.new(0.48,0,0,36)
AutoBtn.Position = UDim2.new(0,0,0,136)
AutoBtn.Text = "▶  Aktifkan"
AutoBtn.BackgroundColor3 = Color3.fromRGB(35,150,75)
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 13
makeCorner(AutoBtn, 10)

local StopBtn = Instance.new("TextButton", ap)
StopBtn.Size = UDim2.new(0.48,0,0,36)
StopBtn.Position = UDim2.new(0.52,0,0,136)
StopBtn.Text = "■  Stop"
StopBtn.BackgroundColor3 = Color3.fromRGB(155,38,38)
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.TextTransparency = 0.5
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 13
StopBtn.Active = false
makeCorner(StopBtn, 10)

local LogFrame = Instance.new("Frame", ap)
LogFrame.Size = UDim2.new(1,0,0,130)
LogFrame.Position = UDim2.new(0,0,0,182)
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

--// ══════════════════════════
--// TAB 3 — QUEST RECORD
--// ══════════════════════════
local qp = tabPages["quest"]

-- Record status bar
local QStatusFrame = Instance.new("Frame", qp)
QStatusFrame.Size = UDim2.new(1,0,0,40)
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
QStatusLabel.TextSize = 12
QStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Step counter
local StepCounter = Instance.new("TextLabel", qp)
StepCounter.Size = UDim2.new(1,0,0,14)
StepCounter.Position = UDim2.new(0,0,0,46)
StepCounter.BackgroundTransparency = 1
StepCounter.Text = "0 langkah terekam"
StepCounter.TextColor3 = Color3.fromRGB(70,80,115)
StepCounter.Font = Enum.Font.Gotham
StepCounter.TextSize = 10
StepCounter.TextXAlignment = Enum.TextXAlignment.Center

-- Quest name input
local QNameBox = Instance.new("TextBox", qp)
QNameBox.Size = UDim2.new(1,0,0,32)
QNameBox.Position = UDim2.new(0,0,0,64)
QNameBox.PlaceholderText = "📝 Nama quest (opsional)..."
QNameBox.PlaceholderColor3 = Color3.fromRGB(75,75,100)
QNameBox.BackgroundColor3 = Color3.fromRGB(22,22,32)
QNameBox.TextColor3 = Color3.new(1,1,1)
QNameBox.Font = Enum.Font.Gotham
QNameBox.TextSize = 12
QNameBox.ClearTextOnFocus = false
makeCorner(QNameBox, 9)
makeStroke(QNameBox, Color3.fromRGB(40,50,90), 1)

-- Record / Stop-Record / Play buttons
local RecordBtn = Instance.new("TextButton", qp)
RecordBtn.Size = UDim2.new(0.48,0,0,36)
RecordBtn.Position = UDim2.new(0,0,0,104)
RecordBtn.Text = "⏺  Rekam"
RecordBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
RecordBtn.TextColor3 = Color3.new(1,1,1)
RecordBtn.Font = Enum.Font.GothamBold
RecordBtn.TextSize = 13
makeCorner(RecordBtn, 10)

local StopRecordBtn = Instance.new("TextButton", qp)
StopRecordBtn.Size = UDim2.new(0.48,0,0,36)
StopRecordBtn.Position = UDim2.new(0.52,0,0,104)
StopRecordBtn.Text = "⏹  Stop Rekam"
StopRecordBtn.BackgroundColor3 = Color3.fromRGB(40,44,62)
StopRecordBtn.TextColor3 = Color3.fromRGB(120,120,150)
StopRecordBtn.Font = Enum.Font.GothamBold
StopRecordBtn.TextSize = 12
StopRecordBtn.Active = false
makeCorner(StopRecordBtn, 10)

local PlayBtn = Instance.new("TextButton", qp)
PlayBtn.Size = UDim2.new(0.48,0,0,36)
PlayBtn.Position = UDim2.new(0,0,0,148)
PlayBtn.Text = "▶  Play Quest"
PlayBtn.BackgroundColor3 = Color3.fromRGB(35,130,210)
PlayBtn.TextColor3 = Color3.new(1,1,1)
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.TextSize = 13
makeCorner(PlayBtn, 10)

local SaveQuestBtn = Instance.new("TextButton", qp)
SaveQuestBtn.Size = UDim2.new(0.48,0,0,36)
SaveQuestBtn.Position = UDim2.new(0.52,0,0,148)
SaveQuestBtn.Text = "💾 Simpan Quest"
SaveQuestBtn.BackgroundColor3 = Color3.fromRGB(45,90,200)
SaveQuestBtn.TextColor3 = Color3.new(1,1,1)
SaveQuestBtn.Font = Enum.Font.GothamBold
SaveQuestBtn.TextSize = 12
makeCorner(SaveQuestBtn, 10)

-- Recorded steps preview
local StepsFrame = Instance.new("Frame", qp)
StepsFrame.Size = UDim2.new(1,0,0,20)
StepsFrame.Position = UDim2.new(0,0,0,192)
StepsFrame.BackgroundTransparency = 1

local StepsTitle = Instance.new("TextLabel", StepsFrame)
StepsTitle.Size = UDim2.new(1,0,1,0)
StepsTitle.BackgroundTransparency = 1
StepsTitle.Text = "LANGKAH TEREKAM"
StepsTitle.TextColor3 = Color3.fromRGB(70,90,160)
StepsTitle.Font = Enum.Font.GothamBold
StepsTitle.TextSize = 9
StepsTitle.TextXAlignment = Enum.TextXAlignment.Left

local StepsList = Instance.new("ScrollingFrame", qp)
StepsList.Size = UDim2.new(1,0,0,80)
StepsList.Position = UDim2.new(0,0,0,214)
StepsList.ScrollBarThickness = 3
StepsList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
StepsList.BackgroundColor3 = Color3.fromRGB(19,19,28)
StepsList.BorderSizePixel = 0
StepsList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(StepsList, 10)
makeStroke(StepsList, Color3.fromRGB(32,42,80), 1)

local StepsLayout = Instance.new("UIListLayout", StepsList)
StepsLayout.Padding = UDim.new(0,3)
makePad(StepsList, 4, 6, 6, 4)

-- Saved quests list
local SavedQTitle = Instance.new("TextLabel", qp)
SavedQTitle.Size = UDim2.new(1,0,0,16)
SavedQTitle.Position = UDim2.new(0,0,0,300)
SavedQTitle.BackgroundTransparency = 1
SavedQTitle.Text = "QUEST TERSIMPAN"
SavedQTitle.TextColor3 = Color3.fromRGB(70,90,160)
SavedQTitle.Font = Enum.Font.GothamBold
SavedQTitle.TextSize = 9
SavedQTitle.TextXAlignment = Enum.TextXAlignment.Left

local SavedQuestList = Instance.new("ScrollingFrame", qp)
SavedQuestList.Size = UDim2.new(1,0,0,50)
SavedQuestList.Position = UDim2.new(0,0,0,318)
SavedQuestList.ScrollBarThickness = 3
SavedQuestList.ScrollBarImageColor3 = Color3.fromRGB(60,100,220)
SavedQuestList.BackgroundColor3 = Color3.fromRGB(19,19,28)
SavedQuestList.BorderSizePixel = 0
SavedQuestList.CanvasSize = UDim2.new(0,0,0,0)
makeCorner(SavedQuestList, 10)
makeStroke(SavedQuestList, Color3.fromRGB(32,42,80), 1)

local SQLayout = Instance.new("UIListLayout", SavedQuestList)
SQLayout.Padding = UDim.new(0,3)
makePad(SavedQuestList, 4, 6, 6, 4)

--// ══════════════════════════
--// TAB 4 — SAVE POSISI
--// ══════════════════════════
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
SavedList.Size = UDim2.new(1,0,0,298)
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
makePad(SavedList, 6, 6, 6, 6)

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

--// ══════════════════════════
--// CORE LOGIC
--// ══════════════════════════

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

local function highlightPlayerBtn(btn)
    if currentHighlight and currentHighlight ~= btn then
        pcall(function() currentHighlight.BackgroundColor3 = Color3.fromRGB(22,22,32) end)
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
local function getHeldTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

local function findRecipient(tool)
    if not tool then return nil end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text
            if text and text ~= "" then
                local mentioned = string.match(text, "@([%a%d_]+)")
                if mentioned then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and
                           string.find(string.lower(player.Name), string.lower(mentioned), 1, true) then
                            return player
                        end
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and
                       string.find(string.lower(text), string.lower(player.Name), 1, true) then
                        return player
                    end
                end
            end
        end
    end
    local toolLower = string.lower(tool.Name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and
           string.find(toolLower, string.lower(player.Name), 1, true) then
            return player
        end
    end
    return nil
end

local function setStatus(text, color, dotColor)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(130,130,155)
    StatusDot.BackgroundColor3 = dotColor or Color3.fromRGB(130,130,150)
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
                        if playerButtons[recipient.Name] then highlightPlayerBtn(playerButtons[recipient.Name]) end
                        setStatus("✅ → "..recipient.Name, Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
                        LogLabel.Text = "🎁 \""..tool.Name.."\" → "..recipient.Name.."\n⏰ "..os.date("%H:%M:%S")
                        notify("🎁 Auto-teleport ke "..recipient.Name, Color3.fromRGB(80,220,120))
                    end
                end
            else
                if tool.Name ~= lastToolName then
                    lastToolName = tool.Name
                    setStatus("🔍 \""..tool.Name.."\" — tidak ada match",
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

--// ══════════════════════════
--// QUEST RECORD & PLAYBACK
--// ══════════════════════════

local function setQStatus(text, color, dotColor)
    QStatusLabel.Text = text
    QStatusLabel.TextColor3 = color or Color3.fromRGB(130,130,155)
    QDot.BackgroundColor3 = dotColor or Color3.fromRGB(130,130,150)
end

local function updateStepsList()
    for _, v in pairs(StepsList:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    StepCounter.Text = #recordedSteps .. " langkah terekam"
    for i, step in ipairs(recordedSteps) do
        local lbl = Instance.new("TextLabel", StepsList)
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.BackgroundTransparency = 1
        lbl.Text = i..". ["..string.format("%.1f",step.delay).."s] 🖱 \""..
                   (step.text ~= "" and step.text or step.name).."\""
        lbl.TextColor3 = Color3.fromRGB(150,160,200)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end
    task.wait()
    StepsList.CanvasSize = UDim2.new(0,0,0,StepsLayout.AbsoluteContentSize.Y+6)
end

-- Rekam setiap klik TextButton di PlayerGui saat recording aktif
local recordConnections = {}

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

    setQStatus("⏺ Merekam... klik dialog quest!", Color3.fromRGB(220,60,60), Color3.fromRGB(220,60,60))
    notify("⏺ Rekaman dimulai! Mainkan quest sekarang.", Color3.fromRGB(220,60,60))

    -- Simpan posisi saat mulai rekam (posisi ambil quest)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        table.insert(recordedSteps, {
            type = "position",
            pos = pos,
            delay = 0,
            name = "Start Position",
            text = ""
        })
        updateStepsList()
    end

    -- Monitor semua TextButton yang muncul di PlayerGui
    local function hookGui(gui)
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("TextButton") and desc ~= CloseBtn and
               not string.find(desc.Parent.Name, "TeleportUltra", 1, true) then
                local conn = desc.MouseButton1Click:Connect(function()
                    if not isRecording then return end
                    local now = tick()
                    local delay = now - lastStepTime
                    lastStepTime = now
                    table.insert(recordedSteps, {
                        type = "click",
                        target = desc,
                        name = desc.Name,
                        text = desc.Text,
                        delay = delay,
                        path = desc:GetFullName()
                    })
                    updateStepsList()
                    notify("🔘 Rekam klik: \""..desc.Text.."\"", Color3.fromRGB(100,180,255))
                end)
                table.insert(recordConnections, conn)
            end
        end
    end

    -- Hook existing GUIs
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name ~= "TeleportUltraGUI_v4" then
            hookGui(gui)
        end
    end

    -- Hook GUIs yang muncul setelah recording dimulai
    local addedConn = PlayerGui.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if child.Name ~= "TeleportUltraGUI_v4" then
            hookGui(child)
        end
    end)
    table.insert(recordConnections, addedConn)

    -- Juga hook descendant baru di GUI yang sudah ada
    local descConn = PlayerGui.DescendantAdded:Connect(function(desc)
        if not isRecording then return end
        if desc:IsA("TextButton") and desc ~= CloseBtn and
           not string.find(desc.Parent.Name, "TeleportUltra", 1, true) then
            task.wait(0.05)
            local conn = desc.MouseButton1Click:Connect(function()
                if not isRecording then return end
                local now = tick()
                local delay = now - lastStepTime
                lastStepTime = now
                table.insert(recordedSteps, {
                    type = "click",
                    target = desc,
                    name = desc.Name,
                    text = desc.Text,
                    delay = delay,
                    path = desc:GetFullName()
                })
                updateStepsList()
                notify("🔘 Rekam klik: \""..desc.Text.."\"", Color3.fromRGB(100,180,255))
            end)
            table.insert(recordConnections, conn)
        end
    end)
    table.insert(recordConnections, descConn)
end

local function stopRecording()
    if not isRecording then return end
    isRecording = false

    for _, conn in ipairs(recordConnections) do
        conn:Disconnect()
    end
    recordConnections = {}

    RecordBtn.TextTransparency = 0; RecordBtn.Active = true
    StopRecordBtn.BackgroundColor3 = Color3.fromRGB(40,44,62)
    StopRecordBtn.TextColor3 = Color3.fromRGB(120,120,150); StopRecordBtn.Active = false

    local clickCount = 0
    for _, s in ipairs(recordedSteps) do
        if s.type == "click" then clickCount += 1 end
    end

    setQStatus("✅ Selesai! "..clickCount.." klik terekam.", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
    notify("⏹ Rekaman selesai! "..clickCount.." klik.", Color3.fromRGB(80,220,120))
    updateStepsList()
end

-- Playback
local function playQuest(steps)
    if isPlaying then return end
    if #steps == 0 then notify("❌ Tidak ada langkah!", Color3.fromRGB(220,70,70)); return end
    isPlaying = true

    setQStatus("▶ Memainkan quest...", Color3.fromRGB(50,180,255), Color3.fromRGB(50,180,255))
    notify("▶ Memulai playback quest!", Color3.fromRGB(50,180,255))

    task.spawn(function()
        for i, step in ipairs(steps) do
            if not isPlaying then break end

            if step.type == "position" then
                -- Teleport ke posisi awal quest
                teleportTo(step.pos)
                setQStatus("📍 Teleport ke posisi quest...", Color3.fromRGB(160,110,255), Color3.fromRGB(160,110,255))
                task.wait(1.5)

            elseif step.type == "click" then
                -- Tunggu sesuai delay yang direkam (max 5 detik)
                local waitTime = math.min(step.delay, 5)
                task.wait(waitTime)

                -- Cari tombol berdasarkan teks atau nama
                local found = false
                local function findAndClick(parent)
                    if found then return end
                    for _, desc in ipairs(parent:GetDescendants()) do
                        if desc:IsA("TextButton") and desc.Visible then
                            if (step.text ~= "" and desc.Text == step.text) or
                               (desc.Name == step.name) then
                                -- Simulasi klik
                                local ok = pcall(function()
                                    local vgui = game:GetService("VirtualUser")
                                    vgui:Button1Down(
                                        Vector2.new(
                                            desc.AbsolutePosition.X + desc.AbsoluteSize.X/2,
                                            desc.AbsolutePosition.Y + desc.AbsoluteSize.Y/2
                                        ),
                                        workspace.CurrentCamera.CFrame
                                    )
                                    task.wait(0.05)
                                    vgui:Button1Up(
                                        Vector2.new(
                                            desc.AbsolutePosition.X + desc.AbsoluteSize.X/2,
                                            desc.AbsolutePosition.Y + desc.AbsoluteSize.Y/2
                                        ),
                                        workspace.CurrentCamera.CFrame
                                    )
                                end)
                                if not ok then
                                    -- Fallback: fire MouseButton1Click langsung
                                    pcall(function()
                                        desc.MouseButton1Click:Fire()
                                    end)
                                end
                                found = true
                                setQStatus("🖱 Klik: \""..step.text.."\" ("..i.."/"..#steps..")",
                                    Color3.fromRGB(50,180,255), Color3.fromRGB(50,180,255))
                                break
                            end
                        end
                    end
                end

                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui.Name ~= "TeleportUltraGUI_v4" then
                        findAndClick(gui)
                    end
                end

                if not found then
                    setQStatus("⚠️ Langkah "..i.." tidak ditemukan, skip...",
                        Color3.fromRGB(200,160,55), Color3.fromRGB(200,150,40))
                end
            end
        end

        isPlaying = false
        setQStatus("✅ Quest selesai diputar!", Color3.fromRGB(80,220,120), Color3.fromRGB(80,220,100))
        notify("✅ Playback quest selesai!", Color3.fromRGB(80,220,120))
    end)
end

RecordBtn.MouseButton1Click:Connect(startRecording)
StopRecordBtn.MouseButton1Click:Connect(stopRecording)
PlayBtn.MouseButton1Click:Connect(function() playQuest(recordedSteps) end)

-- Save Quest
local questCount = 0
SaveQuestBtn.MouseButton1Click:Connect(function()
    if #recordedSteps == 0 then
        notify("❌ Tidak ada langkah untuk disimpan!", Color3.fromRGB(220,70,70))
        return
    end
    questCount += 1
    local qname = QNameBox.Text ~= "" and QNameBox.Text or ("Quest #"..questCount)
    local snapshot = {}
    for _, s in ipairs(recordedSteps) do
        table.insert(snapshot, s)
    end
    table.insert(savedQuests, {name=qname, steps=snapshot})

    -- Buat row di saved quest list
    local row = Instance.new("Frame", SavedQuestList)
    row.Size = UDim2.new(1,0,0,28)
    row.BackgroundColor3 = Color3.fromRGB(22,22,32)
    row.BorderSizePixel = 0
    makeCorner(row, 7)
    makeStroke(row, Color3.fromRGB(38,50,100), 1)

    local qlbl = Instance.new("TextLabel", row)
    qlbl.Size = UDim2.new(1,-70,1,0)
    qlbl.Position = UDim2.new(0,8,0,0)
    qlbl.BackgroundTransparency = 1
    qlbl.Text = "📋 "..qname
    qlbl.TextColor3 = Color3.new(1,1,1)
    qlbl.Font = Enum.Font.Gotham
    qlbl.TextSize = 11
    qlbl.TextXAlignment = Enum.TextXAlignment.Left

    local runBtn = Instance.new("TextButton", row)
    runBtn.Size = UDim2.new(0,58,0,20)
    runBtn.Position = UDim2.new(1,-62,0.5,-10)
    runBtn.Text = "▶ Run"
    runBtn.BackgroundColor3 = Color3.fromRGB(35,130,210)
    runBtn.TextColor3 = Color3.new(1,1,1)
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextSize = 10
    makeCorner(runBtn, 6)

    local savedSteps = snapshot
    runBtn.MouseButton1Click:Connect(function()
        playQuest(savedSteps)
        notify("▶ Menjalankan: "..qname, Color3.fromRGB(50,180,255))
    end)

    task.wait()
    SavedQuestList.CanvasSize = UDim2.new(0,0,0,SQLayout.AbsoluteContentSize.Y+6)
    notify("💾 Quest \""..qname.."\" disimpan!", Color3.fromRGB(50,140,255))
    QNameBox.Text = ""
end)

--// SAVE POSISI
local saveCount = 0
local function savePosition(label)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        saveCount += 1
        local posText = "("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")"
        local displayLabel = label or ("Posisi #"..saveCount)
        SavedCountLabel.Text = saveCount .. " posisi tersimpan"

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
        rowLabel.Text = "📌 "..displayLabel.."\n"..posText
        rowLabel.TextColor3 = Color3.new(1,1,1)
        rowLabel.Font = Enum.Font.Gotham
        rowLabel.TextSize = 10
        rowLabel.TextXAlignment = Enum.TextXAlignment.Left
        rowLabel.TextWrapped = true

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
            notify("📌 Teleport ke "..displayLabel, Color3.fromRGB(160,110,255))
        end)

        task.wait()
        SavedList.CanvasSize = UDim2.new(0,0,0,SLLayout.AbsoluteContentSize.Y+8)
        return true
    end
    return false
end

SaveButton.MouseButton1Click:Connect(function()
    if savePosition() then
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
