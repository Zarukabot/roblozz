--[[
    ╔══════════════════════════════════════════════╗
    ║         NOVA UI LIBRARY - Modern GUI          ║
    ║         5-Tab Base | Roblox Lua               ║
    ╚══════════════════════════════════════════════╝
    
    CARA PAKAI:
    local GUI = loadstring(game:HttpGet("..."))()
    atau paste langsung ke LocalScript
    
    STRUKTUR:
    - Tab 1: Main
    - Tab 2: Combat
    - Tab 3: Farm
    - Tab 4: Teleport
    - Tab 5: Settings
]]

-- ══════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ══════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════
local CONFIG = {
    Title       = "NOVA UI",
    SubTitle    = "v1.0.0",
    
    -- Warna utama
    BG          = Color3.fromRGB(10, 10, 15),
    BG2         = Color3.fromRGB(16, 16, 24),
    BG3         = Color3.fromRGB(22, 22, 34),
    Accent      = Color3.fromRGB(99, 102, 241),   -- indigo
    AccentHover = Color3.fromRGB(129, 132, 255),
    AccentGlow  = Color3.fromRGB(60, 63, 180),
    Text        = Color3.fromRGB(230, 230, 240),
    TextMuted   = Color3.fromRGB(130, 130, 155),
    Border      = Color3.fromRGB(40, 40, 60),
    
    -- Ukuran window
    Width       = 580,
    Height      = 420,
    
    -- Animasi
    TweenInfo   = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenFast   = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

-- ══════════════════════════════════════
--  UTILITY FUNCTIONS
-- ══════════════════════════════════════
local function Tween(obj, props, info)
    TweenService:Create(obj, info or CONFIG.TweenInfo, props):Play()
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function MakeGradient(parent, color0, color1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color0),
        ColorSequenceKeypoint.new(1, color1),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function MakePadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

-- ══════════════════════════════════════
--  DRAGGABLE HELPER
-- ══════════════════════════════════════
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════════
--  NOVA LIBRARY
-- ══════════════════════════════════════
local Nova = {}
Nova.__index = Nova

-- ══════════════════════════════════════
--  BUILD WINDOW
-- ══════════════════════════════════════
function Nova:Init()
    -- Hapus GUI lama kalau ada
    if LocalPlayer.PlayerGui:FindFirstChild("NovaUI") then
        LocalPlayer.PlayerGui.NovaUI:Destroy()
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NovaUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer.PlayerGui

    -- ── MAIN WINDOW ──────────────────────────
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.new(0, CONFIG.Width, 0, CONFIG.Height)
    Window.Position = UDim2.new(0.5, -CONFIG.Width/2, 0.5, -CONFIG.Height/2)
    Window.BackgroundColor3 = CONFIG.BG
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    MakeCorner(Window, 12)
    MakeStroke(Window, CONFIG.Border, 1)

    -- Background gradient
    MakeGradient(Window,
        Color3.fromRGB(12, 12, 20),
        Color3.fromRGB(8, 8, 14),
        135
    )

    -- Glow dot kiri atas (dekoratif)
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(0, 200, 0, 200)
    Glow.Position = UDim2.new(0, -60, 0, -60)
    Glow.BackgroundColor3 = CONFIG.AccentGlow
    Glow.BackgroundTransparency = 0.85
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 0
    Glow.Parent = Window
    MakeCorner(Glow, 100)

    -- ── TITLEBAR ─────────────────────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Window

    -- Logo dot
    local LogoDot = Instance.new("Frame")
    LogoDot.Size = UDim2.new(0, 26, 0, 26)
    LogoDot.Position = UDim2.new(0, 16, 0.5, -13)
    LogoDot.BackgroundColor3 = CONFIG.Accent
    LogoDot.Parent = TitleBar
    MakeCorner(LogoDot, 6)
    MakeGradient(LogoDot, CONFIG.Accent, Color3.fromRGB(168, 85, 247), 135)

    -- Logo letter
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1,0,1,0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "N"
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 14
    LogoText.TextColor3 = Color3.fromRGB(255,255,255)
    LogoText.Parent = LogoDot

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 120, 1, 0)
    Title.Position = UDim2.new(0, 50, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = CONFIG.Title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = CONFIG.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- SubTitle
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(0, 80, 1, 0)
    SubTitle.Position = UDim2.new(0, 160, 0, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = CONFIG.SubTitle
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 12
    SubTitle.TextColor3 = CONFIG.TextMuted
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = TitleBar

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.BackgroundTransparency = 0.6
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.Parent = TitleBar
    MakeCorner(CloseBtn, 8)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.2}, CONFIG.TweenFast)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundTransparency = 0.6}, CONFIG.TweenFast)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window, {Size = UDim2.new(0, CONFIG.Width, 0, 0), BackgroundTransparency = 1})
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end)

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -80, 0.5, -15)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    MinBtn.BackgroundTransparency = 0.6
    MinBtn.Text = "−"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
    MinBtn.Parent = TitleBar
    MakeCorner(MinBtn, 8)

    local minimized = false
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {BackgroundTransparency = 0.2}, CONFIG.TweenFast)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {BackgroundTransparency = 0.6}, CONFIG.TweenFast)
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Window, {Size = UDim2.new(0, CONFIG.Width, 0, 50)})
        else
            Tween(Window, {Size = UDim2.new(0, CONFIG.Width, 0, CONFIG.Height)})
        end
    end)

    -- Divider bawah titlebar
    local TitleDivider = Instance.new("Frame")
    TitleDivider.Size = UDim2.new(1, -32, 0, 1)
    TitleDivider.Position = UDim2.new(0, 16, 0, 50)
    TitleDivider.BackgroundColor3 = CONFIG.Border
    TitleDivider.BorderSizePixel = 0
    TitleDivider.Parent = Window

    MakeDraggable(Window, TitleBar)

    -- ── SIDEBAR (TAB BUTTONS) ─────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, -60)
    Sidebar.Position = UDim2.new(0, 0, 0, 60)
    Sidebar.BackgroundColor3 = CONFIG.BG2
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    -- Sidebar right border
    local SideDiv = Instance.new("Frame")
    SideDiv.Size = UDim2.new(0, 1, 1, 0)
    SideDiv.Position = UDim2.new(1, 0, 0, 0)
    SideDiv.BackgroundColor3 = CONFIG.Border
    SideDiv.BorderSizePixel = 0
    SideDiv.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = Sidebar
    MakePadding(Sidebar, 12, 8, 12, 8)

    -- ── CONTENT AREA ─────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -138, 1, -68)
    ContentArea.Position = UDim2.new(0, 138, 0, 60)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Window

    -- ══════════════════════════════════════
    --  TAB DATA
    -- ══════════════════════════════════════
    local TABS = {
        { Name = "Main",      Icon = "⚡" },
        { Name = "Combat",    Icon = "⚔️" },
        { Name = "Farm",      Icon = "🌾" },
        { Name = "Teleport",  Icon = "🌀" },
        { Name = "Settings",  Icon = "⚙️" },
    }

    local activeTab     = nil
    local tabButtons    = {}
    local tabContents   = {}

    -- ══════════════════════════════════════
    --  BUILD EACH TAB
    -- ══════════════════════════════════════
    for i, tabData in ipairs(TABS) do

        -- ── TAB BUTTON ────────────────────
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabData.Name .. "Btn"
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = CONFIG.BG2
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.LayoutOrder = i
        TabBtn.Parent = Sidebar
        MakeCorner(TabBtn, 8)

        -- Indicator bar kiri
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Position = UDim2.new(0, -8, 0.2, 0)
        Indicator.BackgroundColor3 = CONFIG.Accent
        Indicator.BorderSizePixel = 0
        Indicator.BackgroundTransparency = 1
        Indicator.Parent = TabBtn
        MakeCorner(Indicator, 4)

        -- Icon
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 24, 1, 0)
        TabIcon.Position = UDim2.new(0, 6, 0, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = tabData.Icon
        TabIcon.Font = Enum.Font.Gotham
        TabIcon.TextSize = 15
        TabIcon.TextColor3 = CONFIG.TextMuted
        TabIcon.Parent = TabBtn

        -- Label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -34, 1, 0)
        TabLabel.Position = UDim2.new(0, 34, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabData.Name
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextSize = 13
        TabLabel.TextColor3 = CONFIG.TextMuted
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        tabButtons[tabData.Name] = {
            Btn = TabBtn,
            Indicator = Indicator,
            Icon = TabIcon,
            Label = TabLabel,
        }

        -- ── TAB CONTENT ───────────────────
        local Content = Instance.new("ScrollingFrame")
        Content.Name = tabData.Name .. "Content"
        Content.Size = UDim2.new(1, -16, 1, -16)
        Content.Position = UDim2.new(0, 8, 0, 8)
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.ScrollBarThickness = 3
        Content.ScrollBarImageColor3 = CONFIG.Accent
        Content.CanvasSize = UDim2.new(0, 0, 0, 0)
        Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Content.Visible = false
        Content.Parent = ContentArea

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = Content

        tabContents[tabData.Name] = Content

        -- ── HOVER EFFECT ──────────────────
        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabData.Name then
                Tween(TabBtn, {BackgroundTransparency = 0.85}, CONFIG.TweenFast)
                Tween(TabLabel, {TextColor3 = CONFIG.Text}, CONFIG.TweenFast)
                TabBtn.BackgroundColor3 = CONFIG.Accent
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabData.Name then
                Tween(TabBtn, {BackgroundTransparency = 1}, CONFIG.TweenFast)
                Tween(TabLabel, {TextColor3 = CONFIG.TextMuted}, CONFIG.TweenFast)
            end
        end)

        -- ── CLICK ─────────────────────────
        TabBtn.MouseButton1Click:Connect(function()
            Nova:SelectTab(tabData.Name, tabButtons, tabContents)
        end)
    end

    -- ══════════════════════════════════════
    --  SELECT TAB FUNCTION
    -- ══════════════════════════════════════
    function Nova:SelectTab(name, btns, contents)
        activeTab = name
        for tName, tData in pairs(btns) do
            if tName == name then
                Tween(tData.Btn,       {BackgroundTransparency = 0.88}, CONFIG.TweenFast)
                tData.Btn.BackgroundColor3 = CONFIG.Accent
                Tween(tData.Indicator, {BackgroundTransparency = 0}, CONFIG.TweenFast)
                Tween(tData.Label,     {TextColor3 = CONFIG.Text}, CONFIG.TweenFast)
                Tween(tData.Icon,      {TextColor3 = CONFIG.AccentHover}, CONFIG.TweenFast)
                contents[tName].Visible = true
            else
                Tween(tData.Btn,       {BackgroundTransparency = 1}, CONFIG.TweenFast)
                Tween(tData.Indicator, {BackgroundTransparency = 1}, CONFIG.TweenFast)
                Tween(tData.Label,     {TextColor3 = CONFIG.TextMuted}, CONFIG.TweenFast)
                Tween(tData.Icon,      {TextColor3 = CONFIG.TextMuted}, CONFIG.TweenFast)
                contents[tName].Visible = false
            end
        end
    end

    -- Simpan referensi untuk builder functions
    self._tabs        = tabContents
    self._tabButtons  = tabButtons
    self._screenGui   = ScreenGui

    -- ══════════════════════════════════════
    --  ISI KONTEN DEFAULT SETIAP TAB
    -- ══════════════════════════════════════
    Nova:_BuildMainTab()
    Nova:_BuildCombatTab()
    Nova:_BuildFarmTab()
    Nova:_BuildTeleportTab()
    Nova:_BuildSettingsTab()

    -- Buka tab pertama
    Nova:SelectTab("Main", tabButtons, tabContents)

    -- Animasi masuk
    Window.Size = UDim2.new(0, CONFIG.Width, 0, 0)
    Window.BackgroundTransparency = 1
    Tween(Window, {
        Size = UDim2.new(0, CONFIG.Width, 0, CONFIG.Height),
        BackgroundTransparency = 0
    })

    return self
end

-- ══════════════════════════════════════
--  COMPONENT BUILDERS (helpers)
-- ══════════════════════════════════════

-- Section Header
function Nova:_Section(parent, text, order)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 28)
    s.BackgroundTransparency = 1
    s.LayoutOrder = order or 1
    s.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = CONFIG.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = s
    MakePadding(s, 0, 0, 0, 4)
    return s
end

-- Toggle Button
function Nova:_Toggle(parent, text, default, callback, order)
    local toggled = default or false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = CONFIG.BG3
    row.LayoutOrder = order or 1
    row.Parent = parent
    MakeCorner(row, 8)
    MakeStroke(row, CONFIG.Border, 1)
    MakePadding(row, 0, 12, 0, 12)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextColor3 = CONFIG.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Track background
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 20)
    track.Position = UDim2.new(1, -48, 0.5, -10)
    track.BackgroundColor3 = toggled and CONFIG.Accent or Color3.fromRGB(50,50,70)
    track.Parent = row
    MakeCorner(track, 10)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = toggled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = track
    MakeCorner(knob, 7)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        Tween(track, {BackgroundColor3 = toggled and CONFIG.Accent or Color3.fromRGB(50,50,70)}, CONFIG.TweenFast)
        Tween(knob,  {Position = toggled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, CONFIG.TweenFast)
        if callback then callback(toggled) end
    end)

    return row
end

-- Button
function Nova:_Button(parent, text, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = CONFIG.Accent
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.AutoButtonColor = false
    btn.LayoutOrder = order or 1
    btn.Parent = parent
    MakeCorner(btn, 8)
    MakeGradient(btn, CONFIG.Accent, Color3.fromRGB(168,85,247), 90)

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = CONFIG.AccentHover}, CONFIG.TweenFast)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = CONFIG.Accent}, CONFIG.TweenFast)
    end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {BackgroundColor3 = CONFIG.AccentGlow}, CONFIG.TweenFast)
        task.delay(0.1, function()
            Tween(btn, {BackgroundColor3 = CONFIG.Accent}, CONFIG.TweenFast)
        end)
        if callback then callback() end
    end)

    return btn
end

-- Slider
function Nova:_Slider(parent, text, min, max, default, callback, order)
    local val = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundColor3 = CONFIG.BG3
    container.LayoutOrder = order or 1
    container.Parent = parent
    MakeCorner(container, 8)
    MakeStroke(container, CONFIG.Border, 1)
    MakePadding(container, 8, 12, 8, 12)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundTransparency = 1
    header.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextColor3 = CONFIG.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = header

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(val)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextColor3 = CONFIG.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = header

    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(40,40,60)
    track.BorderSizePixel = 0
    track.Parent = container
    MakeCorner(track, 3)

    -- Fill
    local pct = (val - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    MakeCorner(fill, 3)
    MakeGradient(fill, CONFIG.Accent, Color3.fromRGB(168,85,247), 90)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(pct, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.ZIndex = 2
    knob.Parent = track
    MakeCorner(knob, 7)

    -- Drag logic
    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local trackPos  = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            local rel = math.clamp((i.Position.X - trackPos) / trackSize, 0, 1)
            local newVal = math.round(min + rel * (max - min))
            val = newVal
            local newPct = (newVal - min) / (max - min)
            fill.Size = UDim2.new(newPct, 0, 1, 0)
            knob.Position = UDim2.new(newPct, -7, 0.5, -7)
            valLabel.Text = tostring(newVal)
            if callback then callback(newVal) end
        end
    end)

    return container
end

-- Label / Info row
function Nova:_Label(parent, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,36)
    f.BackgroundColor3 = CONFIG.BG3
    f.LayoutOrder = order or 1
    f.Parent = parent
    MakeCorner(f, 8)
    MakeStroke(f, CONFIG.Border, 1)
    MakePadding(f, 0, 12, 0, 12)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = CONFIG.TextMuted
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    return f
end

-- ══════════════════════════════════════
--  TAB CONTENT BUILDERS
-- ══════════════════════════════════════

function Nova:_BuildMainTab()
    local c = self._tabs["Main"]
    Nova:_Section(c, "Overview", 1)
    Nova:_Label(c, "👤  Player: " .. LocalPlayer.Name, 2)
    Nova:_Label(c, "🎮  Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 3)
    Nova:_Section(c, "Quick Actions", 4)
    Nova:_Toggle(c, "Anti AFK", false, function(v)
        print("[NovaUI] Anti AFK:", v)
    end, 5)
    Nova:_Toggle(c, "Infinite Jump", false, function(v)
        if v then
            UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end
            end)
        end
        print("[NovaUI] Infinite Jump:", v)
    end, 6)
    Nova:_Button(c, "Rejoin Server", function()
        local tp = game:GetService("TeleportService")
        tp:Teleport(game.PlaceId, LocalPlayer)
    end, 7)
    Nova:_Button(c, "Copy Player ID", function()
        setclipboard(tostring(LocalPlayer.UserId))
        print("[NovaUI] Copied:", LocalPlayer.UserId)
    end, 8)
end

function Nova:_BuildCombatTab()
    local c = self._tabs["Combat"]
    Nova:_Section(c, "Aimbot", 1)
    Nova:_Toggle(c, "Aimbot Aktif", false, function(v)
        print("[NovaUI] Aimbot:", v)
    end, 2)
    Nova:_Toggle(c, "Silent Aim", false, function(v)
        print("[NovaUI] Silent Aim:", v)
    end, 3)
    Nova:_Slider(c, "FOV Size", 10, 500, 100, function(v)
        print("[NovaUI] FOV:", v)
    end, 4)
    Nova:_Section(c, "Visual", 5)
    Nova:_Toggle(c, "ESP Players", false, function(v)
        print("[NovaUI] ESP:", v)
    end, 6)
    Nova:_Toggle(c, "Chams", false, function(v)
        print("[NovaUI] Chams:", v)
    end, 7)
    Nova:_Toggle(c, "Show Health", false, function(v)
        print("[NovaUI] Health ESP:", v)
    end, 8)
    Nova:_Section(c, "Combat Misc", 9)
    Nova:_Toggle(c, "No Recoil", false, function(v)
        print("[NovaUI] No Recoil:", v)
    end, 10)
end

function Nova:_BuildFarmTab()
    local c = self._tabs["Farm"]
    Nova:_Section(c, "Auto Farm", 1)
    Nova:_Toggle(c, "Auto Farm Aktif", false, function(v)
        print("[NovaUI] Auto Farm:", v)
    end, 2)
    Nova:_Toggle(c, "Auto Collect", false, function(v)
        print("[NovaUI] Auto Collect:", v)
    end, 3)
    Nova:_Slider(c, "Farm Delay (ms)", 100, 2000, 500, function(v)
        print("[NovaUI] Farm Delay:", v)
    end, 4)
    Nova:_Section(c, "Auto Quest", 5)
    Nova:_Toggle(c, "Auto Accept Quest", false, function(v)
        print("[NovaUI] Auto Quest:", v)
    end, 6)
    Nova:_Toggle(c, "Auto Complete Quest", false, function(v)
        print("[NovaUI] Auto Complete:", v)
    end, 7)
    Nova:_Section(c, "Actions", 8)
    Nova:_Button(c, "Start Farm Session", function()
        print("[NovaUI] Farm session started")
    end, 9)
    Nova:_Button(c, "Stop All", function()
        print("[NovaUI] Stopped all farm")
    end, 10)
end

function Nova:_BuildTeleportTab()
    local c = self._tabs["Teleport"]
    Nova:_Section(c, "Waypoints", 1)
    Nova:_Button(c, "Teleport ke Spawn", function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                char.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
            end
        end
    end, 2)
    Nova:_Button(c, "Teleport ke Cursor", function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local unit = Mouse.UnitRay
            local result = workspace:Raycast(unit.Origin, unit.Direction * 1000)
            if result then
                char.HumanoidRootPart.CFrame = CFrame.new(result.Position + Vector3.new(0,3,0))
            end
        end
    end, 3)
    Nova:_Section(c, "Player Teleport", 4)
    Nova:_Button(c, "Teleport ke Random Player", function()
        local players = Players:GetPlayers()
        local others = {}
        for _, p in ipairs(players) do
            if p ~= LocalPlayer and p.Character then
                table.insert(others, p)
            end
        end
        if #others > 0 then
            local target = others[math.random(1, #others)]
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            end
        end
    end, 5)
    Nova:_Section(c, "Movement", 6)
    Nova:_Toggle(c, "No Clip", false, function(v)
        print("[NovaUI] NoClip:", v)
    end, 7)
    Nova:_Slider(c, "Walk Speed", 16, 200, 16, function(v)
        if LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = v end
        end
    end, 8)
    Nova:_Slider(c, "Jump Power", 50, 400, 50, function(v)
        if LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = v end
        end
    end, 9)
end

function Nova:_BuildSettingsTab()
    local c = self._tabs["Settings"]
    Nova:_Section(c, "Interface", 1)
    Nova:_Toggle(c, "Show Watermark", true, function(v)
        print("[NovaUI] Watermark:", v)
    end, 2)
    Nova:_Toggle(c, "Notifikasi", true, function(v)
        print("[NovaUI] Notif:", v)
    end, 3)
    Nova:_Section(c, "Keybind", 4)
    Nova:_Label(c, "🔑  Toggle GUI: [RightShift]", 5)
    Nova:_Section(c, "Info", 6)
    Nova:_Label(c, "📦  Nova UI v1.0.0", 7)
    Nova:_Label(c, "👨‍💻  Discord: discord.gg/nova", 8)
    Nova:_Section(c, "Danger Zone", 9)
    Nova:_Button(c, "Unload Script", function()
        Nova._screenGui:Destroy()
        print("[NovaUI] Unloaded.")
    end, 10)
end

-- ══════════════════════════════════════
--  KEYBIND: RightShift = Toggle GUI
-- ══════════════════════════════════════
function Nova:_SetupKeybind()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            local gui = LocalPlayer.PlayerGui:FindFirstChild("NovaUI")
            if gui then
                local win = gui:FindFirstChild("Window")
                if win then
                    win.Enabled = not win.Enabled
                end
            end
        end
    end)
end

-- ══════════════════════════════════════
--  LAUNCH
-- ══════════════════════════════════════
Nova:Init()
Nova:_SetupKeybind()

print("[NovaUI] Loaded! Press RightShift to toggle.")

return Nova
