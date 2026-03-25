--[[
╔═══════════════════════════════════════════════════════╗
║   ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗                 ║
║   ████╗  ██║██╔═══██╗██║   ██║██╔══██╗                ║
║   ██╔██╗ ██║██║   ██║██║   ██║███████║                ║
║   ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║                ║
║   ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║                ║
║   ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝               ║
║                                                       ║
║   Modern GUI v2.0  |  Mobile-Responsive               ║
║   5 Tabs: Main · Combat · Farm · Teleport · Settings  ║
╚═══════════════════════════════════════════════════════╝

  CARA PAKAI:
  · Paste ke LocalScript di StarterPlayerScripts
  · Atau jalankan lewat executor
  · Toggle GUI: RightShift  |  Di HP: tap tombol toggle
]]

-- ┌─────────────────────────────────────┐
-- │           SERVICES                  │
-- └─────────────────────────────────────┘
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ┌─────────────────────────────────────┐
-- │        DEVICE DETECTION             │
-- └─────────────────────────────────────┘
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Ukuran responsif
local W  = isMobile and 340 or 560
local H  = isMobile and 480 or 410
local FS = isMobile and 11  or 13   -- base font size

-- ┌─────────────────────────────────────┐
-- │           THEME                     │
-- └─────────────────────────────────────┘
local T = {
    -- Backgrounds
    BG0    = Color3.fromRGB(7,   8,  14),   -- window bg
    BG1    = Color3.fromRGB(12,  13,  22),  -- sidebar
    BG2    = Color3.fromRGB(18,  19,  32),  -- card bg
    BG3    = Color3.fromRGB(24,  26,  42),  -- input bg
    BG4    = Color3.fromRGB(30,  32,  52),  -- hover

    -- Accents
    A1     = Color3.fromRGB(94,  114, 255), -- primary blue-violet
    A2     = Color3.fromRGB(162,  89, 255), -- purple
    A3     = Color3.fromRGB(56,  189, 248), -- cyan highlight
    A4     = Color3.fromRGB(34,  211, 238), -- teal glow

    -- Text
    TXT    = Color3.fromRGB(235, 237, 255),
    TXT2   = Color3.fromRGB(160, 163, 210),
    TXT3   = Color3.fromRGB(90,  95,  140),

    -- Status colors
    Green  = Color3.fromRGB(52,  211, 153),
    Red    = Color3.fromRGB(251,  87, 100),
    Yellow = Color3.fromRGB(250, 204,  21),

    -- Borders
    Bord   = Color3.fromRGB(36,  38,  65),
    BordHi = Color3.fromRGB(60,  64, 100),
}

local TI      = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_SLOW = TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ┌─────────────────────────────────────┐
-- │            HELPERS                  │
-- └─────────────────────────────────────┘
local function tw(obj, props, ti) TweenService:Create(obj, ti or TI, props):Play() end
local function corner(p, r)  local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p, c, t) local s=Instance.new("UIStroke"); s.Color=c or T.Bord; s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function pad(p, a,b,c_,d) local x=Instance.new("UIPadding"); x.PaddingTop=UDim.new(0,a or 0); x.PaddingRight=UDim.new(0,b or 0); x.PaddingBottom=UDim.new(0,c_ or 0); x.PaddingLeft=UDim.new(0,d or 0); x.Parent=p; return x end
local function listLayout(p, gap, dir) local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,gap or 6); l.SortOrder=Enum.SortOrder.LayoutOrder; if dir then l.FillDirection=dir end; l.Parent=p; return l end
local function grad(p, c0, c1, rot) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(c0,c1); g.Rotation=rot or 90; g.Parent=p; return g end

local function newFrame(p, size, pos, bg, trans)
    local f=Instance.new("Frame")
    f.Size=size or UDim2.new(1,0,1,0)
    if pos then f.Position=pos end
    f.BackgroundColor3=bg or T.BG2
    f.BackgroundTransparency=trans or 0
    f.BorderSizePixel=0
    f.Parent=p
    return f
end

local function newLabel(p, txt, size, font, color, xAlign)
    local l=Instance.new("TextLabel")
    l.Size=size or UDim2.new(1,0,1,0)
    l.BackgroundTransparency=1
    l.Text=txt or ""
    l.Font=font or Enum.Font.GothamSemibold
    l.TextSize=FS
    l.TextColor3=color or T.TXT
    l.TextXAlignment=xAlign or Enum.TextXAlignment.Left
    l.TextScaled=false
    l.RichText=true
    l.Parent=p
    return l
end

-- ┌─────────────────────────────────────┐
-- │        DRAGGABLE                    │
-- └─────────────────────────────────────┘
local function makeDraggable(win, handle)
    local drag, dInp, mPos, fPos = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag=true; mPos=i.Position; fPos=win.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then drag=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then dInp=i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i==dInp and drag then
            local d=i.Position-mPos
            win.Position=UDim2.new(fPos.X.Scale, fPos.X.Offset+d.X, fPos.Y.Scale, fPos.Y.Offset+d.Y)
        end
    end)
end

-- ┌─────────────────────────────────────┐
-- │      MAIN LIBRARY TABLE             │
-- └─────────────────────────────────────┘
local Nova = {}
Nova.__index = Nova

-- ╔═══════════════════════════════════╗
-- ║           BUILD GUI               ║
-- ╚═══════════════════════════════════╝
function Nova:Build()
    if LP.PlayerGui:FindFirstChild("NovaUI_v2") then
        LP.PlayerGui.NovaUI_v2:Destroy()
    end

    -- ── ScreenGui ──────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "NovaUI_v2"
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    SG.Parent = LP.PlayerGui
    self._sg = SG

    -- ── Window ─────────────────────────────────────────────
    local Win = newFrame(SG,
        UDim2.new(0, W, 0, H),
        UDim2.new(0.5, -W/2, 0.5, -H/2),
        T.BG0
    )
    Win.Name = "Win"
    Win.ClipsDescendants = true
    corner(Win, 14)
    stroke(Win, T.Bord, 1)
    self._win = Win

    -- Subtle noise overlay (visual texture via gradient)
    local noiseBg = newFrame(Win, UDim2.new(1,0,1,0), nil, T.BG0, 0)
    noiseBg.ZIndex = 0
    grad(noiseBg, T.BG0, Color3.fromRGB(10,9,20), 145)

    -- Top glow orb
    local orb1 = newFrame(Win, UDim2.new(0,220,0,220), UDim2.new(0,-50,0,-60), T.A1, 0.88)
    orb1.ZIndex=0; corner(orb1, 110)
    local orb2 = newFrame(Win, UDim2.new(0,160,0,160), UDim2.new(1,-80,1,-80), T.A2, 0.90)
    orb2.ZIndex=0; corner(orb2, 80)

    -- ── Sidebar ────────────────────────────────────────────
    local SIDEBAR_W = isMobile and 52 or 130
    local SB = newFrame(Win,
        UDim2.new(0, SIDEBAR_W, 1, -52),
        UDim2.new(0, 0, 0, 52),
        T.BG1
    )
    SB.Name = "Sidebar"
    corner(SB, 0)
    -- Right border
    local sbLine = newFrame(SB, UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), T.Bord)

    listLayout(SB, 4)
    pad(SB, 10, 6, 10, 6)

    -- ── Content Area ───────────────────────────────────────
    local CA = newFrame(Win,
        UDim2.new(1, -(SIDEBAR_W+2), 1, -60),
        UDim2.new(0, SIDEBAR_W+2, 0, 52),
        T.BG0, 1
    )
    CA.Name = "ContentArea"
    CA.ClipsDescendants = true

    -- ── Titlebar ───────────────────────────────────────────
    local TB = newFrame(Win,
        UDim2.new(1, 0, 0, 52),
        nil,
        T.BG0, 1
    )
    TB.Name = "TitleBar"
    TB.ZIndex = 5

    -- Logo badge
    local logoBadge = newFrame(TB, UDim2.new(0,32,0,32), UDim2.new(0,14,0.5,-16), T.A1)
    corner(logoBadge, 9)
    grad(logoBadge, T.A1, T.A2, 135)
    local logoLetter = newLabel(logoBadge, "N", nil, Enum.Font.GothamBold, Color3.new(1,1,1), Enum.TextXAlignment.Center)
    logoLetter.TextSize = 15

    -- Title text
    local titleLbl = newLabel(TB, "NOVA", UDim2.new(0,80,0,22), Enum.Font.GothamBold, T.TXT, Enum.TextXAlignment.Left)
    titleLbl.Position = UDim2.new(0, 54, 0, 8)
    titleLbl.TextSize = isMobile and 14 or 15

    local subLbl = newLabel(TB, "v2.0  ·  Modern", UDim2.new(0,120,0,14), Enum.Font.Gotham, T.TXT3, Enum.TextXAlignment.Left)
    subLbl.Position = UDim2.new(0, 55, 0, 30)
    subLbl.TextSize = 10

    -- Close btn
    local function makeWinBtn(xOff, bg, symbol, action)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(1, xOff, 0.5, -13)
        btn.BackgroundColor3 = bg
        btn.BackgroundTransparency = 0.55
        btn.Text = symbol
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.new(1,1,1)
        btn.AutoButtonColor = false
        btn.ZIndex = 6
        btn.Parent = TB
        corner(btn, 7)
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundTransparency=0.1},TI_FAST) end)
        btn.MouseLeave:Connect(function() tw(btn,{BackgroundTransparency=0.55},TI_FAST) end)
        btn.MouseButton1Click:Connect(action)
        return btn
    end

    makeWinBtn(-14, T.Red, "✕", function()
        tw(Win, {Size=UDim2.new(0,W,0,0), BackgroundTransparency=1}, TI_SLOW)
        task.delay(0.4, function() SG:Destroy() end)
    end)

    local minimized = false
    makeWinBtn(-46, T.Yellow, "–", function()
        minimized = not minimized
        tw(Win, {Size=UDim2.new(0,W,0, minimized and 52 or H)}, TI)
    end)

    -- Title divider
    local titleDiv = newFrame(Win, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,52), T.Bord)

    makeDraggable(Win, TB)

    -- ══════════════════════════════════════
    --  TAB DEFINITIONS
    -- ══════════════════════════════════════
    local TABS = {
        { id="Main",     icon="⚡",  label="Main"     },
        { id="Combat",   icon="⚔",  label="Combat"   },
        { id="Farm",     icon="🌾", label="Farm"     },
        { id="Teleport", icon="🌀", label="Teleport" },
        { id="Settings", icon="⚙",  label="Settings" },
    }

    local tabBtns     = {}
    local tabPages    = {}
    local activeTabId = nil

    -- ══════════════════════════════════════
    --  BUILD TAB BUTTONS + PAGES
    -- ══════════════════════════════════════
    for i, tab in ipairs(TABS) do

        -- ── Button ───────────────────────────────
        local btnFrame = newFrame(SB, UDim2.new(1,0,0,isMobile and 42 or 38), nil, T.BG1, 1)
        btnFrame.LayoutOrder = i
        corner(btnFrame, 9)

        -- Active indicator strip
        local strip = newFrame(btnFrame, UDim2.new(0,3,0,20), UDim2.new(0,0,0.5,-10), T.A1, 1)
        corner(strip, 2)

        -- Icon
        local iconLbl = newLabel(btnFrame,
            tab.icon,
            isMobile and UDim2.new(1,0,1,0) or UDim2.new(0,28,1,0),
            Enum.Font.Gotham,
            T.TXT3,
            isMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Center
        )
        iconLbl.TextSize = isMobile and 17 or 15
        if not isMobile then
            iconLbl.Position = UDim2.new(0, 4, 0, 0)
        end

        -- Label (hidden on mobile)
        if not isMobile then
            local tabLabelTxt = newLabel(btnFrame,
                tab.label,
                UDim2.new(1,-36,1,0),
                Enum.Font.GothamSemibold,
                T.TXT3,
                Enum.TextXAlignment.Left
            )
            tabLabelTxt.Position = UDim2.new(0, 34, 0, 0)
            tabLabelTxt.TextSize = FS
            tabBtns[tab.id] = { frame=btnFrame, strip=strip, icon=iconLbl, lbl=tabLabelTxt }
        else
            tabBtns[tab.id] = { frame=btnFrame, strip=strip, icon=iconLbl, lbl=nil }
        end

        -- Click button overlay
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size=UDim2.new(1,0,1,0)
        clickBtn.BackgroundTransparency=1
        clickBtn.Text=""
        clickBtn.Parent=btnFrame

        clickBtn.MouseEnter:Connect(function()
            if activeTabId ~= tab.id then
                tw(btnFrame, {BackgroundTransparency=0.75, BackgroundColor3=T.BG4}, TI_FAST)
            end
        end)
        clickBtn.MouseLeave:Connect(function()
            if activeTabId ~= tab.id then
                tw(btnFrame, {BackgroundTransparency=1}, TI_FAST)
            end
        end)
        clickBtn.MouseButton1Click:Connect(function()
            Nova:SwitchTab(tab.id)
        end)

        -- ── Page (ScrollingFrame) ─────────────────
        local page = Instance.new("ScrollingFrame")
        page.Name = tab.id.."Page"
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = T.A1
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = CA

        listLayout(page, 7)
        tabPages[tab.id] = page
    end

    self._tabBtns  = tabBtns
    self._tabPages = tabPages

    -- ══════════════════════════════════════
    --  SWITCH TAB
    -- ══════════════════════════════════════
    function Nova:SwitchTab(id)
        activeTabId = id
        for tid, bd in pairs(tabBtns) do
            local active = (tid == id)
            tw(bd.frame, {
                BackgroundTransparency = active and 0.82 or 1,
                BackgroundColor3       = active and T.A1 or T.BG1,
            }, TI_FAST)
            tw(bd.strip, {BackgroundTransparency = active and 0 or 1}, TI_FAST)
            tw(bd.icon,  {TextColor3 = active and T.A3 or T.TXT3}, TI_FAST)
            if bd.lbl then
                tw(bd.lbl, {TextColor3 = active and T.TXT or T.TXT3}, TI_FAST)
                bd.lbl.Font = active and Enum.Font.GothamBold or Enum.Font.GothamSemibold
            end
            tabPages[tid].Visible = active
        end
    end

    -- ══════════════════════════════════════
    --  COMPONENT BUILDERS
    -- ══════════════════════════════════════

    -- Section header
    function Nova:Section(page, text, order)
        local f = newFrame(page, UDim2.new(1,0,0,24), nil, T.BG0, 1)
        f.LayoutOrder = order or 99
        local line = newFrame(f, UDim2.new(1,-8,0,1), UDim2.new(0,4,1,-1), T.Bord)
        local lbl  = newLabel(f, text:upper(), UDim2.new(0,0,1,0), Enum.Font.GothamBold, T.TXT3, Enum.TextXAlignment.Left)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.TextSize = 9
        lbl.BackgroundColor3 = T.BG0
        lbl.BackgroundTransparency = 0
        pad(lbl, 0, 6, 0, 0)
        line.ZIndex = 1; lbl.ZIndex = 2
        return f
    end

    -- Card wrapper
    function Nova:Card(page, h, order)
        local f = newFrame(page, UDim2.new(1,0,0,h), nil, T.BG2)
        f.LayoutOrder = order or 99
        corner(f, 10)
        stroke(f, T.Bord, 1)
        return f
    end

    -- Toggle
    function Nova:Toggle(page, text, desc, default, cb, order)
        local on = default or false
        local card = Nova:Card(page, desc and 54 or 44, order)
        pad(card, 0, 14, 0, 14)

        local textBlock = newFrame(card, UDim2.new(1,-56,1,0), nil, T.BG2, 1)
        local mainLbl = newLabel(textBlock, text, UDim2.new(1,0,0,22), Enum.Font.GothamSemibold, T.TXT)
        mainLbl.TextSize = FS; mainLbl.Position = UDim2.new(0,0,0,desc and 6 or 11)
        if desc then
            local descLbl = newLabel(textBlock, desc, UDim2.new(1,0,0,14), Enum.Font.Gotham, T.TXT3)
            descLbl.TextSize = 10; descLbl.Position = UDim2.new(0,0,0,26)
        end

        -- Track
        local track = newFrame(card, UDim2.new(0,38,0,22), UDim2.new(1,-52,0.5,-11), on and T.A1 or T.BG3)
        corner(track, 11)
        stroke(track, on and T.A1 or T.BordHi, 1)
        -- Fill gradient when on
        local trackGrad = Instance.new("UIGradient")
        trackGrad.Color = ColorSequence.new(T.A1, T.A2)
        trackGrad.Rotation = 90
        trackGrad.Parent = track
        track.BackgroundTransparency = on and 0 or 0

        local knob = newFrame(track, UDim2.new(0,16,0,16), on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), Color3.new(1,1,1))
        corner(knob, 8)
        -- Knob shadow
        local knobShadow = Instance.new("UIStroke")
        knobShadow.Color = Color3.fromRGB(0,0,0)
        knobShadow.Thickness = 1
        knobShadow.Transparency = 0.7
        knobShadow.Parent = knob

        local function refresh()
            tw(track, {BackgroundColor3 = on and T.A1 or T.BG3}, TI_FAST)
            tw(knob,  {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, TI_FAST)
        end

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size=UDim2.new(1,0,1,0); clickBtn.BackgroundTransparency=1; clickBtn.Text=""
        clickBtn.Parent=card
        clickBtn.MouseButton1Click:Connect(function()
            on = not on; refresh()
            if cb then cb(on) end
        end)

        card.MouseEnter:Connect(function() tw(card,{BackgroundColor3=T.BG3},TI_FAST) end)
        card.MouseLeave:Connect(function() tw(card,{BackgroundColor3=T.BG2},TI_FAST) end)
        return card
    end

    -- Button
    function Nova:Button(page, text, style, cb, order)
        -- style: "primary" | "secondary" | "danger"
        local bgCol = style=="danger" and T.Red or (style=="secondary" and T.BG3 or T.A1)
        local card = newFrame(page, UDim2.new(1,0,0,42), nil, bgCol)
        card.LayoutOrder = order or 99
        corner(card, 10)
        if style ~= "secondary" then
            grad(card, bgCol, style=="danger" and Color3.fromRGB(200,50,80) or T.A2, 90)
        end
        stroke(card, style=="secondary" and T.Bord or bgCol, 1)

        local lbl = newLabel(card, text, nil, Enum.Font.GothamBold, Color3.new(1,1,1), Enum.TextXAlignment.Center)
        lbl.TextSize = FS

        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=card
        btn.MouseEnter:Connect(function()
            tw(card,{BackgroundTransparency=0.2},TI_FAST)
        end)
        btn.MouseLeave:Connect(function()
            tw(card,{BackgroundTransparency=0},TI_FAST)
        end)
        btn.MouseButton1Click:Connect(function()
            tw(card,{BackgroundTransparency=0.5},TI_FAST)
            task.delay(0.08, function() tw(card,{BackgroundTransparency=0},TI_FAST) end)
            if cb then cb() end
        end)
        return card
    end

    -- Slider
    function Nova:Slider(page, text, min, max, def, suffix, cb, order)
        local val = def or min
        local card = Nova:Card(page, 64, order)
        pad(card, 10, 14, 10, 14)

        local topRow = newFrame(card, UDim2.new(1,0,0,18), nil, T.BG2, 1)
        local nameLbl = newLabel(topRow, text, UDim2.new(0.7,0,1,0), Enum.Font.GothamSemibold, T.TXT)
        nameLbl.TextSize = FS
        local valLbl = newLabel(topRow, tostring(val)..(suffix or ""), UDim2.new(0.3,0,1,0), Enum.Font.GothamBold, T.A3, Enum.TextXAlignment.Right)
        valLbl.TextSize = FS

        local track = newFrame(card, UDim2.new(1,0,0,6), UDim2.new(0,0,0,30), T.BG3)
        corner(track, 3)

        local pct = (val-min)/(max-min)
        local fill = newFrame(track, UDim2.new(pct,0,1,0), nil, T.A1)
        corner(fill, 3)
        grad(fill, T.A1, T.A3, 90)

        local knob = newFrame(track, UDim2.new(0,16,0,16), UDim2.new(pct,-8,0.5,-8), Color3.new(1,1,1))
        corner(knob, 8)
        knob.ZIndex = 5
        stroke(knob, T.A1, 1.5)

        -- Drag
        local dragging = false
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)
        -- Also allow clicking track
        local trackBtn = Instance.new("TextButton")
        trackBtn.Size=UDim2.new(1,0,0,22); trackBtn.Position=UDim2.new(0,0,0.5,-11)
        trackBtn.BackgroundTransparency=1; trackBtn.Text=""; trackBtn.Parent=track; trackBtn.ZIndex=4
        trackBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
                local rel = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                local newVal = math.round(min + rel*(max-min))
                val = newVal
                local np = (newVal-min)/(max-min)
                fill.Size=UDim2.new(np,0,1,0)
                knob.Position=UDim2.new(np,-8,0.5,-8)
                valLbl.Text=tostring(newVal)..(suffix or "")
                if cb then cb(newVal) end
            end
        end)
        return card
    end

    -- Info row
    function Nova:InfoRow(page, icon, label, value, order)
        local card = Nova:Card(page, 38, order)
        pad(card, 0, 14, 0, 14)
        local iconLbl = newLabel(card, icon, UDim2.new(0,22,1,0), Enum.Font.Gotham, T.A3, Enum.TextXAlignment.Center)
        iconLbl.TextSize = 14
        local nameLbl = newLabel(card, label, UDim2.new(0.55,0,1,0), Enum.Font.GothamSemibold, T.TXT2)
        nameLbl.Position=UDim2.new(0,26,0,0); nameLbl.TextSize = FS
        local valLbl = newLabel(card, value, UDim2.new(0,0,1,0), Enum.Font.GothamBold, T.TXT, Enum.TextXAlignment.Right)
        valLbl.AutomaticSize=Enum.AutomaticSize.X
        valLbl.Position=UDim2.new(1,-0,0,0)
        valLbl.TextSize = FS
        return card, valLbl
    end

    -- ══════════════════════════════════════
    --  BUILD TAB CONTENTS
    -- ══════════════════════════════════════
    Nova:_Main()
    Nova:_Combat()
    Nova:_Farm()
    Nova:_Teleport()
    Nova:_Settings()

    -- Open first tab with entrance animation
    Win.Size = UDim2.new(0,W,0,0)
    Win.BackgroundTransparency = 1
    tw(Win, {Size=UDim2.new(0,W,0,H), BackgroundTransparency=0}, TI_SLOW)
    task.delay(0.15, function() Nova:SwitchTab("Main") end)

    -- ══════════════════════════════════════
    --  MOBILE TOGGLE BUTTON
    -- ══════════════════════════════════════
    if isMobile then
        local mBtn = Instance.new("TextButton")
        mBtn.Size = UDim2.new(0,46,0,46)
        mBtn.Position = UDim2.new(0,16,1,-70)
        mBtn.BackgroundColor3 = T.A1
        mBtn.Text = "N"
        mBtn.Font = Enum.Font.GothamBold
        mBtn.TextSize = 16
        mBtn.TextColor3 = Color3.new(1,1,1)
        mBtn.ZIndex = 10
        mBtn.Parent = SG
        corner(mBtn, 14)
        grad(mBtn, T.A1, T.A2, 135)
        local vis = true
        mBtn.MouseButton1Click:Connect(function()
            vis = not vis
            Win.Visible = vis
        end)
    end

    return self
end

-- ╔═══════════════════════════════════╗
-- ║          MAIN TAB                 ║
-- ╚═══════════════════════════════════╝
function Nova:_Main()
    local pg = self._tabPages["Main"]

    -- ── Profile Card ─────────────────────────────────────
    local profileCard = newFrame(pg, UDim2.new(1,0,0, isMobile and 90 or 80), nil, T.BG2)
    profileCard.LayoutOrder = 1
    corner(profileCard, 12)
    stroke(profileCard, T.Bord, 1)
    -- Gradient banner top
    local banner = newFrame(profileCard, UDim2.new(1,0,0,32), nil, T.A1)
    banner.ZIndex = 0
    corner(banner, 12)
    grad(banner, T.A1, T.A2, 90)
    -- Cut off bottom corners of banner
    local bannerCover = newFrame(profileCard, UDim2.new(1,0,0,16), UDim2.new(0,0,0,20), T.BG2)
    bannerCover.ZIndex = 0

    -- Avatar circle
    local avatarBorder = newFrame(profileCard, UDim2.new(0,44,0,44), UDim2.new(0,10,0,10), T.A1)
    corner(avatarBorder, 22)
    avatarBorder.ZIndex = 2
    grad(avatarBorder, T.A1, T.A2, 135)

    local avatarFrame = newFrame(avatarBorder, UDim2.new(1,-4,1,-4), UDim2.new(0,2,0,2), T.BG2)
    corner(avatarFrame, 20)
    avatarFrame.ZIndex = 3

    -- Avatar image
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1,0,1,0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=150&height=150&format=png"
    avatarImg.ZIndex = 4
    avatarImg.Parent = avatarFrame
    corner(avatarImg, 20)

    -- Player name
    local pName = newLabel(profileCard, LP.DisplayName, UDim2.new(1,-70,0,20), Enum.Font.GothamBold, T.TXT, Enum.TextXAlignment.Left)
    pName.Position = UDim2.new(0, 62, 0, 30)
    pName.TextSize = isMobile and 13 or 14
    pName.ZIndex = 5

    -- Username
    local pUser = newLabel(profileCard, "@"..LP.Name, UDim2.new(1,-70,0,14), Enum.Font.Gotham, T.TXT3, Enum.TextXAlignment.Left)
    pUser.Position = UDim2.new(0, 62, 0, 50)
    pUser.TextSize = 10
    pUser.ZIndex = 5

    -- User ID badge
    local idBadge = newFrame(profileCard, UDim2.new(0,0,0,18), UDim2.new(1,-10,0,34), T.BG3)
    idBadge.AutomaticSize = Enum.AutomaticSize.X
    idBadge.ZIndex = 5
    corner(idBadge, 5)
    pad(idBadge, 0, 6, 0, 6)
    local idLabel = newLabel(idBadge, "ID: "..LP.UserId, UDim2.new(0,0,1,0), Enum.Font.GothamBold, T.A3, Enum.TextXAlignment.Center)
    idLabel.AutomaticSize = Enum.AutomaticSize.X
    idLabel.TextSize = 9; idLabel.ZIndex = 6

    -- ── Account Stats row ────────────────────────────────
    local statsCard = Nova:Card(pg, 50, 2)
    pad(statsCard, 0, 10, 0, 10)
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Horizontal
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Padding = UDim.new(0, 1)
    statsLayout.Parent = statsCard

    local function statCell(icon, labelTxt, col, order_)
        local cell = newFrame(statsCard, UDim2.new(0.33,0,1,0), nil, T.BG2, 1)
        cell.LayoutOrder = order_
        corner(cell, 0)
        local icn = newLabel(cell, icon, UDim2.new(1,0,0,26), Enum.Font.Gotham, col or T.A3, Enum.TextXAlignment.Center)
        icn.TextSize = 12; icn.Position = UDim2.new(0,0,0,4)
        local lbl2 = newLabel(cell, labelTxt, UDim2.new(1,0,0,14), Enum.Font.Gotham, T.TXT3, Enum.TextXAlignment.Center)
        lbl2.TextSize = 9; lbl2.Position = UDim2.new(0,0,0,30)
        return cell
    end

    -- Get team color indicator
    local teamName = "–"
    if LP.Team then teamName = LP.Team.Name end

    statCell("👤", LP.Name:sub(1,10), T.A3, 1)
    statCell("🏅", "Level "..tostring(math.random(1,100)), T.A2, 2)
    statCell("🎮", tostring(#Players:GetPlayers()).." online", T.Green, 3)

    -- ── Quick Actions ─────────────────────────────────────
    Nova:Section(pg, "Quick Actions", 3)

    Nova:Toggle(pg, "Anti AFK", "Cegah kick otomatis", false, function(v)
        if v then
            self._antiAfk = RunService.Heartbeat:Connect(function()
                local vjs = LP:FindFirstChild("PlayerScripts")
                if vjs then
                    local vjm = vjs:FindFirstChild("PlayerModule")
                end
            end)
        else
            if self._antiAfk then self._antiAfk:Disconnect() end
        end
    end, 4)

    Nova:Toggle(pg, "Infinite Jump", "Lompat tanpa batas", false, function(v)
        self._ijEnabled = v
        if v and not self._ijConn then
            self._ijConn = UserInputService.JumpRequest:Connect(function()
                if LP.Character then
                    local h = LP.Character:FindFirstChildOfClass("Humanoid")
                    if h and self._ijEnabled then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end, 5)

    Nova:Toggle(pg, "Full Bright", "Terangi semua area", false, function(v)
        local lighting = game:GetService("Lighting")
        lighting.Brightness     = v and 5    or 1
        lighting.ClockTime      = v and 14   or lighting.ClockTime
        lighting.FogEnd         = v and 1e6  or 1000
        lighting.GlobalShadows  = not v
    end, 6)

    local btnRow = newFrame(pg, UDim2.new(1,0,0,42), nil, T.BG0, 1)
    btnRow.LayoutOrder = 7
    local bLayout = Instance.new("UIListLayout")
    bLayout.FillDirection = Enum.FillDirection.Horizontal
    bLayout.Padding = UDim.new(0, 7)
    bLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bLayout.Parent = btnRow

    local function halfBtn(txt, style_, cb_, ord_)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5,-4,1,0)
        b.BackgroundColor3 = style_=="danger" and T.Red or T.A1
        b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = FS-1
        b.TextColor3 = Color3.new(1,1,1); b.AutoButtonColor=false
        b.LayoutOrder = ord_; b.Parent = btnRow
        corner(b, 9)
        if style_ ~= "danger" then grad(b, T.A1, T.A2, 90) end
        b.MouseButton1Click:Connect(function() if cb_ then cb_() end end)
        return b
    end

    halfBtn("⟳  Rejoin", "primary", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end, 1)
    halfBtn("📋  Copy ID", "secondary", function()
        if setclipboard then setclipboard(tostring(LP.UserId)) end
    end, 2)
end

-- ╔═══════════════════════════════════╗
-- ║          COMBAT TAB               ║
-- ╚═══════════════════════════════════╝
function Nova:_Combat()
    local pg = self._tabPages["Combat"]
    Nova:Section(pg, "Aimbot", 1)
    Nova:Toggle(pg, "Aimbot", "Auto aim ke player terdekat", false, function(v)
        self._aimbotOn = v
        print("[Nova] Aimbot:", v)
    end, 2)
    Nova:Toggle(pg, "Silent Aim", "Peluru diarahkan tanpa terlihat", false, function(v)
        print("[Nova] Silent Aim:", v)
    end, 3)
    Nova:Slider(pg, "FOV Radius", 50, 600, 120, "px", function(v)
        print("[Nova] FOV:", v)
    end, 4)
    Nova:Slider(pg, "Smoothness", 1, 20, 5, "x", function(v)
        print("[Nova] Smooth:", v)
    end, 5)
    Nova:Section(pg, "Visuals / ESP", 6)
    Nova:Toggle(pg, "Player ESP", "Kotak di sekitar player", false, function(v)
        print("[Nova] ESP:", v)
    end, 7)
    Nova:Toggle(pg, "Name Tag", "Tampilkan nama di atas kepala", false, function(v)
        print("[Nova] NameTag:", v)
    end, 8)
    Nova:Toggle(pg, "Health Bar", "Tampilkan HP player lain", false, function(v)
        print("[Nova] HealthBar:", v)
    end, 9)
    Nova:Toggle(pg, "Chams", "Sorot karakter menembus dinding", false, function(v)
        print("[Nova] Chams:", v)
    end, 10)
    Nova:Section(pg, "Weapon Mods", 11)
    Nova:Toggle(pg, "No Recoil", "Hilangkan recoil senjata", false, function(v)
        print("[Nova] NoRecoil:", v)
    end, 12)
    Nova:Toggle(pg, "Rapid Fire", "Tembak lebih cepat", false, function(v)
        print("[Nova] RapidFire:", v)
    end, 13)
end

-- ╔═══════════════════════════════════╗
-- ║          FARM TAB                 ║
-- ╚═══════════════════════════════════╝
function Nova:_Farm()
    local pg = self._tabPages["Farm"]
    Nova:Section(pg, "Auto Farm", 1)
    Nova:Toggle(pg, "Auto Farm", "Farm otomatis tanpa henti", false, function(v)
        self._farmOn = v
        print("[Nova] AutoFarm:", v)
    end, 2)
    Nova:Toggle(pg, "Auto Collect", "Ambil item/drop otomatis", false, function(v)
        print("[Nova] AutoCollect:", v)
    end, 3)
    Nova:Toggle(pg, "Auto Sell", "Jual hasil farm otomatis", false, function(v)
        print("[Nova] AutoSell:", v)
    end, 4)
    Nova:Slider(pg, "Farm Delay", 100, 3000, 500, "ms", function(v)
        print("[Nova] FarmDelay:", v)
    end, 5)
    Nova:Section(pg, "Quest & Mission", 6)
    Nova:Toggle(pg, "Auto Accept Quest", nil, false, function(v)
        print("[Nova] AutoQuest:", v)
    end, 7)
    Nova:Toggle(pg, "Auto Complete", nil, false, function(v)
        print("[Nova] AutoComplete:", v)
    end, 8)
    Nova:Toggle(pg, "Skip Cutscene", nil, false, function(v)
        print("[Nova] SkipCutscene:", v)
    end, 9)
    Nova:Section(pg, "Actions", 10)
    Nova:Button(pg, "▶  Start Session", "primary", function()
        print("[Nova] Farm session started")
    end, 11)
    Nova:Button(pg, "⏹  Stop All", "secondary", function()
        self._farmOn = false
        print("[Nova] All stopped")
    end, 12)
end

-- ╔═══════════════════════════════════╗
-- ║          TELEPORT TAB             ║
-- ╚═══════════════════════════════════╝
function Nova:_Teleport()
    local pg = self._tabPages["Teleport"]
    Nova:Section(pg, "Waypoints", 1)
    Nova:Button(pg, "🏠  Teleport ke Spawn", "primary", function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if sp then c.HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0,5,0) end
        end
    end, 2)
    Nova:Button(pg, "🖱  Teleport ke Cursor", "secondary", function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local ray = workspace:Raycast(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction*1000)
            if ray then c.HumanoidRootPart.CFrame = CFrame.new(ray.Position+Vector3.new(0,4,0)) end
        end
    end, 3)
    Nova:Section(pg, "Player TP", 4)
    Nova:Button(pg, "🎯  TP ke Random Player", "secondary", function()
        local others = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then table.insert(others,p) end
        end
        if #others>0 then
            local t = others[math.random(#others)]
            local mc = LP.Character
            if mc and mc:FindFirstChild("HumanoidRootPart") and t.Character:FindFirstChild("HumanoidRootPart") then
                mc.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            end
        end
    end, 5)
    Nova:Section(pg, "Movement Stats", 6)
    Nova:Toggle(pg, "No Clip", "Tembus semua objek", false, function(v)
        self._noclip = v
        if v and not self._noclipConn then
            self._noclipConn = RunService.Stepped:Connect(function()
                if self._noclip and LP.Character then
                    for _,p in ipairs(LP.Character:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end)
        end
    end, 7)
    Nova:Slider(pg, "Walk Speed", 16, 250, 16, " stud/s", function(v)
        if LP.Character then
            local h = LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = v end
        end
    end, 8)
    Nova:Slider(pg, "Jump Power", 50, 500, 50, " pow", function(v)
        if LP.Character then
            local h = LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = v end
        end
    end, 9)
    Nova:Slider(pg, "Gravity", 10, 196, 196, "%", function(v)
        workspace.Gravity = v
    end, 10)
end

-- ╔═══════════════════════════════════╗
-- ║          SETTINGS TAB             ║
-- ╚═══════════════════════════════════╝
function Nova:_Settings()
    local pg = self._tabPages["Settings"]
    Nova:Section(pg, "Interface", 1)
    Nova:Toggle(pg, "Tampilkan Watermark", "Label kecil di pojok layar", true, function(v)
        print("[Nova] Watermark:", v)
    end, 2)
    Nova:Toggle(pg, "Notifikasi", "Popup saat toggle diaktifkan", true, function(v)
        print("[Nova] Notif:", v)
    end, 3)
    Nova:Toggle(pg, "Transparent Window", "Sedikit transparan", false, function(v)
        if self._win then
            tw(self._win, {BackgroundTransparency = v and 0.15 or 0}, TI)
        end
    end, 4)
    Nova:Section(pg, "Keybind", 5)
    Nova:InfoRow(pg, "⌨", "Toggle GUI (PC)", "RightShift", 6)
    Nova:InfoRow(pg, "📱", "Toggle GUI (HP)", "Tombol biru", 7)
    Nova:Section(pg, "About", 8)
    Nova:InfoRow(pg, "📦", "Versi", "Nova UI v2.0", 9)
    Nova:InfoRow(pg, "👨‍💻", "Developer", "NovaTeam", 10)
    Nova:InfoRow(pg, "🔗", "Discord", "discord.gg/nova", 11)
    Nova:Section(pg, "Danger", 12)
    Nova:Button(pg, "🗑  Unload Script", "danger", function()
        tw(self._win, {Size=UDim2.new(0,W,0,0), BackgroundTransparency=1}, TI_SLOW)
        task.delay(0.4, function() self._sg:Destroy() end)
    end, 13)
end

-- ┌─────────────────────────────────────┐
-- │         KEYBIND (PC)                │
-- └─────────────────────────────────────┘
function Nova:Keybind()
    UserInputService.InputBegan:Connect(function(i, gpe)
        if not gpe and i.KeyCode == Enum.KeyCode.RightShift then
            if self._win then
                self._win.Visible = not self._win.Visible
            end
        end
    end)
end

-- ┌─────────────────────────────────────┐
-- │              LAUNCH                 │
-- └─────────────────────────────────────┘
Nova:Build()
Nova:Keybind()

print(("[Nova UI v2.0] Loaded! Platform: %s | Toggle: %s"):format(
    isMobile and "Mobile 📱" or "PC 💻",
    isMobile and "Blue button" or "RightShift"
))

return Nova
