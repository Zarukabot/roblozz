--[[
  ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗     ██╗   ██╗██████╗
  ████╗  ██║██╔═══██╗██║   ██║██╔══██╗    ██║   ██║╚════██╗
  ██╔██╗ ██║██║   ██║██║   ██║███████║    ██║   ██║ █████╔╝
  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║    ╚██╗ ██╔╝ ╚═══██╗
  ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║     ╚████╔╝ ██████╔╝
  ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝      ╚═══╝  ╚═════╝
  Modern Executor GUI  |  5 Tabs  |  Mobile Ready
  Tabs: Profile · Main · Combat · Farm · Settings
  Toggle: RightShift (PC) | Float Button (Mobile)
]]

------------------------------------------------------
-- SERVICES
------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()

------------------------------------------------------
-- DEVICE + SIZE
------------------------------------------------------
local MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local WIN_W  = MOBILE and 345 or 570
local WIN_H  = MOBILE and 500 or 430
local FS     = MOBILE and 11 or 13

------------------------------------------------------
-- COLOURS
------------------------------------------------------
local C = {
    bg0   = Color3.fromRGB(8,   9,  16),
    bg1   = Color3.fromRGB(13,  14,  24),
    bg2   = Color3.fromRGB(20,  21,  36),
    bg3   = Color3.fromRGB(27,  29,  48),
    a1    = Color3.fromRGB(99,  115, 255),
    a2    = Color3.fromRGB(168,  85, 255),
    a3    = Color3.fromRGB(56,  189, 248),
    green = Color3.fromRGB(52,  211, 153),
    red   = Color3.fromRGB(248,  86,  99),
    yellow= Color3.fromRGB(250, 204,  21),
    txt   = Color3.fromRGB(232, 235, 255),
    txt2  = Color3.fromRGB(155, 160, 210),
    txt3  = Color3.fromRGB(82,   88, 138),
    bord  = Color3.fromRGB(34,  37,  64),
}

local TI      = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_FAST = TweenInfo.new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_SLOW = TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

------------------------------------------------------
-- TINY HELPERS
------------------------------------------------------
local function tw(o,p,t)   TweenService:Create(o,t or TI,p):Play() end
local function rnd(o,r)    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o end
local function bord(o,col,th) local s=Instance.new("UIStroke"); s.Color=col or C.bord; s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o end
local function pad(o,t,r,b,l) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,t or 0); p.PaddingRight=UDim.new(0,r or 0); p.PaddingBottom=UDim.new(0,b or 0); p.PaddingLeft=UDim.new(0,l or 0); p.Parent=o end
local function vlist(o,gap)   local l=Instance.new("UIListLayout"); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,gap or 6); l.Parent=o end
local function hlist(o,gap)   local l=Instance.new("UIListLayout"); l.SortOrder=Enum.SortOrder.LayoutOrder; l.FillDirection=Enum.FillDirection.Horizontal; l.Padding=UDim.new(0,gap or 6); l.Parent=o end
local function grad(o,c0,c1,rot) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(c0,c1); g.Rotation=rot or 90; g.Parent=o end

-- Frame factory
local function F(parent, size, pos, bg, trans, zindex)
    local f = Instance.new("Frame")
    f.Size               = size  or UDim2.new(1,0,1,0)
    f.Position           = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3   = bg    or C.bg2
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel    = 0
    if zindex then f.ZIndex = zindex end
    f.Parent = parent
    return f
end

-- Label factory
local function L(parent, text, size, pos, font, fs, color, xa)
    local l = Instance.new("TextLabel")
    l.Size               = size  or UDim2.new(1,0,1,0)
    l.Position           = pos   or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text               = text  or ""
    l.Font               = font  or Enum.Font.GothamSemibold
    l.TextSize           = fs    or FS
    l.TextColor3         = color or C.txt
    l.TextXAlignment     = xa    or Enum.TextXAlignment.Left
    l.TextScaled         = false
    l.RichText           = true
    l.Parent             = parent
    return l
end

-- Invisible click button overlay
local function clickOverlay(parent, cb)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1; b.Text=""; b.ZIndex=20
    b.Parent=parent
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

------------------------------------------------------
-- DRAGGABLE
------------------------------------------------------
local function makeDrag(win, handle)
    local drg,dInp,mPos,fPos=false
    local function startDrag(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drg=true; mPos=i.Position; fPos=win.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then drg=false end
            end)
        end
    end
    local function moveDrag(i)
        if (i.UserInputType==Enum.UserInputType.MouseMovement
        or  i.UserInputType==Enum.UserInputType.Touch) then dInp=i end
    end
    handle.InputBegan:Connect(startDrag)
    handle.InputChanged:Connect(moveDrag)
    UserInputService.InputChanged:Connect(function(i)
        if i==dInp and drg then
            local d=i.Position-mPos
            win.Position=UDim2.new(fPos.X.Scale,fPos.X.Offset+d.X,fPos.Y.Scale,fPos.Y.Offset+d.Y)
        end
    end)
end

------------------------------------------------------
-- DESTROY OLD GUI
------------------------------------------------------
local old = LP.PlayerGui:FindFirstChild("NovaUI_v3")
if old then old:Destroy() end

------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name="NovaUI_v3"; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn=false; SG.IgnoreGuiInset=true
SG.Parent = LP.PlayerGui

------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------
local Win = F(SG, UDim2.new(0,WIN_W,0,WIN_H),
    UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2), C.bg0)
Win.Name="Win"; Win.ClipsDescendants=true
rnd(Win, 14); bord(Win, C.bord, 1)

-- bg gradient
local bgGrad = F(Win,UDim2.new(1,0,1,0),nil,C.bg0)
bgGrad.ZIndex=0
grad(bgGrad, C.bg0, Color3.fromRGB(9,8,18), 135)

-- decorative glows
local glow1 = F(Win,UDim2.new(0,200,0,200),UDim2.new(0,-50,0,-50),C.a1,0.88,0)
rnd(glow1,100)
local glow2 = F(Win,UDim2.new(0,140,0,140),UDim2.new(1,-60,1,-60),C.a2,0.90,0)
rnd(glow2,70)

------------------------------------------------------
-- TITLEBAR
------------------------------------------------------
local SIDEBAR_W = MOBILE and 54 or 136

local TBar = F(Win, UDim2.new(1,0,0,50), nil, C.bg0, 1)
TBar.Name="TBar"; TBar.ZIndex=10

-- Logo badge
local logo = F(TBar,UDim2.new(0,30,0,30),UDim2.new(0,13,0.5,-15),C.a1)
rnd(logo,8); grad(logo,C.a1,C.a2,135)
L(logo,"N",nil,nil,Enum.Font.GothamBold,15,Color3.new(1,1,1),Enum.TextXAlignment.Center)

-- Title
L(TBar,"NOVA",UDim2.new(0,70,0,20),UDim2.new(0,51,0,8),Enum.Font.GothamBold,15,C.txt)
L(TBar,"v3.0 · Modern UI",UDim2.new(0,140,0,14),UDim2.new(0,52,0,29),Enum.Font.Gotham,10,C.txt3)

-- Window buttons
local function winBtn(xOff, bg, sym, action)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,26,0,26); b.Position=UDim2.new(1,xOff,0.5,-13)
    b.BackgroundColor3=bg; b.BackgroundTransparency=0.55
    b.Text=sym; b.Font=Enum.Font.GothamBold; b.TextSize=11
    b.TextColor3=Color3.new(1,1,1); b.AutoButtonColor=false; b.ZIndex=12
    b.Parent=TBar; rnd(b,7)
    b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.1},TI_FAST) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.55},TI_FAST) end)
    b.MouseButton1Click:Connect(action)
    return b
end

winBtn(-12, C.red, "✕", function()
    tw(Win,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},TI_SLOW)
    task.delay(0.4, function() SG:Destroy() end)
end)

local minimized=false
winBtn(-44, C.yellow, "–", function()
    minimized=not minimized
    tw(Win,{Size=UDim2.new(0,WIN_W,0,minimized and 50 or WIN_H)},TI)
end)

-- Divider
F(Win,UDim2.new(1,-20,0,1),UDim2.new(0,10,0,50),C.bord)

makeDrag(Win, TBar)

------------------------------------------------------
-- SIDEBAR
------------------------------------------------------
local SB = F(Win,
    UDim2.new(0,SIDEBAR_W,1,-58),
    UDim2.new(0,0,0,58),
    C.bg1)
SB.Name="Sidebar"
-- right border line
F(SB,UDim2.new(0,1,1,0),UDim2.new(1,-1,0,0),C.bord)
vlist(SB, 3)
pad(SB, 8,5,8,5)

------------------------------------------------------
-- CONTENT AREA
------------------------------------------------------
local CA = F(Win,
    UDim2.new(1,-(SIDEBAR_W+1),1,-58),
    UDim2.new(0,SIDEBAR_W+1,0,58),
    C.bg0,1)
CA.Name="ContentArea"; CA.ClipsDescendants=true

------------------------------------------------------
-- TAB DEFINITIONS
------------------------------------------------------
local TABS = {
    { id="Profile",  icon="👤", label="Profile"  },
    { id="Main",     icon="⚡", label="Main"     },
    { id="Combat",   icon="⚔", label="Combat"   },
    { id="Farm",     icon="🌾", label="Farm"     },
    { id="Settings", icon="⚙", label="Settings" },
}

local tabBtns  = {}   -- [id] = { frame, strip, iconLbl, nameLbl }
local tabPages = {}   -- [id] = ScrollingFrame
local activeTab = nil

------------------------------------------------------
-- BUILD TAB BUTTONS + PAGES
------------------------------------------------------
for i, tab in ipairs(TABS) do
    -- ── Button ─────────────────────────────────
    local btnF = F(SB, UDim2.new(1,0,0,MOBILE and 44 or 40), nil, C.bg1, 1)
    btnF.LayoutOrder=i; rnd(btnF,9)

    -- accent strip on left
    local strip = F(btnF,UDim2.new(0,3,0,18),UDim2.new(0,0,0.5,-9),C.a1,1)
    rnd(strip,2)

    -- icon
    local iconL = L(btnF, tab.icon,
        MOBILE and UDim2.new(1,0,1,0) or UDim2.new(0,28,1,0),
        MOBILE and UDim2.new(0,0,0,0)  or UDim2.new(0,6,0,0),
        Enum.Font.Gotham, MOBILE and 17 or 15, C.txt3,
        Enum.TextXAlignment.Center)

    -- label (hide on mobile)
    local nameL = nil
    if not MOBILE then
        nameL = L(btnF, tab.label,
            UDim2.new(1,-38,1,0), UDim2.new(0,36,0,0),
            Enum.Font.GothamSemibold, FS, C.txt3)
    end

    tabBtns[tab.id] = { frame=btnF, strip=strip, icon=iconL, name=nameL }

    -- hover
    local overlay = clickOverlay(btnF)
    overlay.MouseEnter:Connect(function()
        if activeTab~=tab.id then
            tw(btnF,{BackgroundColor3=C.bg3,BackgroundTransparency=0.5},TI_FAST)
        end
    end)
    overlay.MouseLeave:Connect(function()
        if activeTab~=tab.id then
            tw(btnF,{BackgroundColor3=C.bg1,BackgroundTransparency=1},TI_FAST)
        end
    end)
    overlay.MouseButton1Click:Connect(function()
        -- SwitchTab defined below
        _G._novaSwitchTab(tab.id)
    end)

    -- ── Page ────────────────────────────────────
    local pg = Instance.new("ScrollingFrame")
    pg.Name=tab.id.."Page"
    pg.Size=UDim2.new(1,-14,1,-14); pg.Position=UDim2.new(0,7,0,7)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=2; pg.ScrollBarImageColor3=C.a1
    pg.CanvasSize=UDim2.new(0,0,0,0); pg.AutomaticCanvasSize=Enum.AutomaticSize.Y
    pg.Visible=false; pg.Parent=CA
    vlist(pg, 7)
    tabPages[tab.id] = pg
end

------------------------------------------------------
-- SWITCH TAB FUNCTION (global so overlay can call)
------------------------------------------------------
local function switchTab(id)
    activeTab = id
    for tid, bd in pairs(tabBtns) do
        local on = (tid==id)
        tw(bd.frame, {
            BackgroundColor3     = on and C.a1 or C.bg1,
            BackgroundTransparency = on and 0.82 or 1,
        }, TI_FAST)
        tw(bd.strip,{BackgroundTransparency = on and 0 or 1}, TI_FAST)
        tw(bd.icon, {TextColor3 = on and C.a3 or C.txt3}, TI_FAST)
        if bd.name then
            tw(bd.name,{TextColor3 = on and C.txt or C.txt3}, TI_FAST)
            bd.name.Font = on and Enum.Font.GothamBold or Enum.Font.GothamSemibold
        end
        tabPages[tid].Visible = on
    end
end
_G._novaSwitchTab = switchTab

------------------------------------------------------
-- ──────────────────────────────────────────────────
--  COMPONENT LIBRARY
-- ──────────────────────────────────────────────────
------------------------------------------------------

-- Section label
local function Section(pg, text, order)
    local f = F(pg, UDim2.new(1,0,0,22), nil, C.bg0, 1)
    f.LayoutOrder=order
    local line = F(f, UDim2.new(1,-6,0,1), UDim2.new(0,3,1,-1), C.bord)
    local lbl  = L(f, text:upper(), nil, nil, Enum.Font.GothamBold, 9, C.txt3)
    lbl.AutomaticSize=Enum.AutomaticSize.X
    lbl.BackgroundColor3=C.bg0; lbl.BackgroundTransparency=0
    pad(lbl,0,5,0,0); line.ZIndex=1; lbl.ZIndex=2
end

-- Card
local function Card(pg, h, order)
    local f = F(pg, UDim2.new(1,0,0,h), nil, C.bg2)
    f.LayoutOrder=order; rnd(f,10); bord(f,C.bord,1)
    return f
end

-- Toggle
local function Toggle(pg, title, sub, default, cb, order)
    local on = default or false
    local card = Card(pg, sub and 56 or 44, order)
    pad(card, 0,14,0,14)

    -- Text
    local tblock = F(card, UDim2.new(1,-54,1,0), nil, C.bg2, 1)
    local tl = L(tblock, title, UDim2.new(1,0,0,20),
        UDim2.new(0,0,0, sub and 8 or 12),
        Enum.Font.GothamSemibold, FS, C.txt)
    if sub then
        L(tblock, sub, UDim2.new(1,0,0,14), UDim2.new(0,0,0,28),
          Enum.Font.Gotham, 10, C.txt3)
    end

    -- Track
    local track = F(card, UDim2.new(0,40,0,22), UDim2.new(1,-54,0.5,-11), on and C.a1 or C.bg3)
    rnd(track,11); bord(track, on and C.a1 or C.bord, 1)

    local knob = F(track, UDim2.new(0,16,0,16),
        on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
        Color3.new(1,1,1))
    rnd(knob,8); knob.ZIndex=3

    local function refresh()
        tw(track,{BackgroundColor3=on and C.a1 or C.bg3},TI_FAST)
        tw(knob, {Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)},TI_FAST)
    end

    clickOverlay(card, function()
        on=not on; refresh()
        if cb then cb(on) end
    end)
    card.MouseEnter:Connect(function() tw(card,{BackgroundColor3=C.bg3},TI_FAST) end)
    card.MouseLeave:Connect(function() tw(card,{BackgroundColor3=C.bg2},TI_FAST) end)
    return card
end

-- Button
local function Btn(pg, text, style, cb, order)
    -- style: "primary" | "secondary" | "danger"
    local bgc = style=="danger" and C.red or (style=="secondary" and C.bg3 or C.a1)
    local card = F(pg, UDim2.new(1,0,0,42), nil, bgc)
    card.LayoutOrder=order; rnd(card,10)
    if style=="primary" then grad(card,C.a1,C.a2,90)
    elseif style=="danger" then grad(card,C.red,Color3.fromRGB(200,40,70),90) end
    if style=="secondary" then bord(card,C.bord,1) end

    L(card, text, nil, nil, Enum.Font.GothamBold, FS, Color3.new(1,1,1), Enum.TextXAlignment.Center)

    local ov = clickOverlay(card)
    ov.MouseEnter:Connect(function() tw(card,{BackgroundTransparency=0.25},TI_FAST) end)
    ov.MouseLeave:Connect(function() tw(card,{BackgroundTransparency=0},TI_FAST) end)
    ov.MouseButton1Click:Connect(function()
        tw(card,{BackgroundTransparency=0.55},TI_FAST)
        task.delay(0.1,function() tw(card,{BackgroundTransparency=0},TI_FAST) end)
        if cb then cb() end
    end)
    return card
end

-- Slider
local function Slider(pg, text, min, max, def, suffix, cb, order)
    local val = def or min
    local card = Card(pg, 64, order); pad(card,10,14,10,14)

    local topRow = F(card,UDim2.new(1,0,0,18),nil,C.bg2,1)
    local nameLbl= L(topRow,text,UDim2.new(0.7,0,1,0),nil,Enum.Font.GothamSemibold,FS,C.txt)
    local valLbl = L(topRow,tostring(val)..(suffix or ""),UDim2.new(0.3,0,1,0),nil,
                     Enum.Font.GothamBold,FS,C.a3,Enum.TextXAlignment.Right)

    local track = F(card,UDim2.new(1,0,0,6),UDim2.new(0,0,0,30),C.bg3)
    rnd(track,3)

    local pct = (val-min)/(max-min)
    local fill = F(track,UDim2.new(pct,0,1,0),nil,C.a1)
    rnd(fill,3); grad(fill,C.a1,C.a3,90)

    local knob = F(track,UDim2.new(0,16,0,16),UDim2.new(pct,-8,0.5,-8),Color3.new(1,1,1))
    rnd(knob,8); knob.ZIndex=5; bord(knob,C.a1,1.5)

    local dragging=false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    local trackBtn=Instance.new("TextButton")
    trackBtn.Size=UDim2.new(1,0,0,24); trackBtn.Position=UDim2.new(0,0,0.5,-12)
    trackBtn.BackgroundTransparency=1; trackBtn.Text=""; trackBtn.ZIndex=4; trackBtn.Parent=track
    trackBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            val=math.round(min+rel*(max-min))
            local np=(val-min)/(max-min)
            fill.Size=UDim2.new(np,0,1,0); knob.Position=UDim2.new(np,-8,0.5,-8)
            valLbl.Text=tostring(val)..(suffix or "")
            if cb then cb(val) end
        end
    end)
end

-- Info row
local function InfoRow(pg, icon, label, value, order)
    local card=Card(pg,38,order); pad(card,0,14,0,14)
    L(card,icon,UDim2.new(0,20,1,0),nil,Enum.Font.Gotham,14,C.a3,Enum.TextXAlignment.Center)
    L(card,label,UDim2.new(0.6,0,1,0),UDim2.new(0,26,0,0),Enum.Font.GothamSemibold,FS,C.txt2)
    local vl=L(card,value,UDim2.new(0,0,1,0),UDim2.new(1,0,0,0),Enum.Font.GothamBold,FS,C.txt,Enum.TextXAlignment.Right)
    vl.AutomaticSize=Enum.AutomaticSize.X
    return card, vl
end

-- Two-button row
local function BtnRow(pg, t1, t2, cb1, cb2, order)
    local wrap=F(pg,UDim2.new(1,0,0,42),nil,C.bg0,1)
    wrap.LayoutOrder=order; hlist(wrap,7)
    local function half(txt,style_,cb_,ord_)
        local bgc=style_=="danger" and C.red or (style_=="secondary" and C.bg3 or C.a1)
        local b=F(wrap,UDim2.new(0.5,-4,1,0),nil,bgc)
        b.LayoutOrder=ord_; rnd(b,10)
        if style_=="primary" then grad(b,C.a1,C.a2,90) end
        if style_=="secondary" then bord(b,C.bord,1) end
        L(b,txt,nil,nil,Enum.Font.GothamBold,FS,Color3.new(1,1,1),Enum.TextXAlignment.Center)
        local ov=clickOverlay(b); ov.MouseButton1Click:Connect(function() if cb_ then cb_() end end)
    end
    half(t1,"primary",cb1,1); half(t2,"secondary",cb2,2)
end

------------------------------------------------------
-- ══════════════════════════════════════════════════
--  TAB 1 · PROFILE
-- ══════════════════════════════════════════════════
------------------------------------------------------
do
    local pg = tabPages["Profile"]

    -- ── Profile hero card ────────────────────────
    local hero = F(pg, UDim2.new(1,0,0,100), nil, C.bg2)
    hero.LayoutOrder=1; rnd(hero,12); bord(hero,C.bord,1)

    -- banner gradient strip
    local banner = F(hero,UDim2.new(1,0,0,38),nil,C.a1)
    banner.ZIndex=1; rnd(banner,12); grad(banner,C.a1,C.a2,90)
    -- cover bottom corners of banner
    F(hero,UDim2.new(1,0,0,14),UDim2.new(0,0,0,24),C.bg2,0,1)

    -- avatar ring
    local ring=F(hero,UDim2.new(0,52,0,52),UDim2.new(0,14,0,14),C.a1,0,3)
    rnd(ring,26); grad(ring,C.a1,C.a2,135)
    local avFrame=F(ring,UDim2.new(1,-4,1,-4),UDim2.new(0,2,0,2),C.bg2,0,4)
    rnd(avFrame,24)
    local avImg=Instance.new("ImageLabel")
    avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.ZIndex=5
    avImg.Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"
    avImg.Parent=avFrame; rnd(avImg,22)

    -- name + username
    local dispName=LP.DisplayName
    local userName=LP.Name
    L(hero,dispName,UDim2.new(1,-80,0,22),UDim2.new(0,74,0,36),Enum.Font.GothamBold,MOBILE and 13 or 14,C.txt).ZIndex=5
    L(hero,"@"..userName,UDim2.new(1,-80,0,14),UDim2.new(0,75,0,58),Enum.Font.Gotham,10,C.txt3).ZIndex=5

    -- ID badge
    local idBadge=F(hero,UDim2.new(0,0,0,18),UDim2.new(1,-10,0,38),C.bg3,0,5)
    idBadge.AutomaticSize=Enum.AutomaticSize.X; rnd(idBadge,5); pad(idBadge,0,7,0,7)
    L(idBadge,"ID · "..LP.UserId,UDim2.new(0,0,1,0),nil,Enum.Font.GothamBold,9,C.a3,Enum.TextXAlignment.Center).AutomaticSize=Enum.AutomaticSize.X

    -- ── Stats row ────────────────────────────────
    local statsWrap=F(pg,UDim2.new(1,0,0,60),nil,C.bg2)
    statsWrap.LayoutOrder=2; rnd(statsWrap,10); bord(statsWrap,C.bord,1)
    hlist(statsWrap,1)

    local function statCell(icon, val, lbl2, ord)
        local cell=F(statsWrap,UDim2.new(0.333,0,1,0),nil,C.bg2,1)
        cell.LayoutOrder=ord; rnd(cell,0)
        L(cell,icon,UDim2.new(1,0,0,24),UDim2.new(0,0,0,6),Enum.Font.Gotham,14,C.a3,Enum.TextXAlignment.Center)
        L(cell,val,UDim2.new(1,0,0,14),UDim2.new(0,0,0,28),Enum.Font.GothamBold,FS,C.txt,Enum.TextXAlignment.Center)
        L(cell,lbl2,UDim2.new(1,0,0,12),UDim2.new(0,0,0,42),Enum.Font.Gotham,9,C.txt3,Enum.TextXAlignment.Center)
    end

    local plrCount = tostring(#Players:GetPlayers())
    statCell("👥", plrCount, "Online",  1)
    statCell("🎮", tostring(game.PlaceId):sub(1,7), "Place ID", 2)
    statCell("⏱", "Live", "Server",    3)

    -- ── Account info ─────────────────────────────
    Section(pg,"Account Info",3)
    InfoRow(pg,"👤","Display Name",  LP.DisplayName, 4)
    InfoRow(pg,"🔖","Username",       "@"..LP.Name,   5)
    InfoRow(pg,"🆔","User ID",        tostring(LP.UserId), 6)

    local _, teamVal = InfoRow(pg,"🏷","Team", LP.Team and LP.Team.Name or "None", 7)

    -- ── Actions ──────────────────────────────────
    Section(pg,"Actions",8)
    BtnRow(pg,"📋  Copy UID","🔄  Rejoin",
        function()
            if setclipboard then setclipboard(tostring(LP.UserId)) end
            print("[Nova] UID copied:", LP.UserId)
        end,
        function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end, 9)
    Btn(pg,"🌐  Copy Profile Link","secondary",function()
        if setclipboard then
            setclipboard("https://www.roblox.com/users/"..LP.UserId.."/profile")
        end
    end, 10)
end

------------------------------------------------------
-- ══════════════════════════════════════════════════
--  TAB 2 · MAIN
-- ══════════════════════════════════════════════════
------------------------------------------------------
do
    local pg = tabPages["Main"]

    Section(pg,"Player Mods",1)
    Toggle(pg,"Infinite Jump","Lompat berkali-kali",false,function(v)
        _G._novaIJ = v
        if v and not _G._novaIJConn then
            _G._novaIJConn = UserInputService.JumpRequest:Connect(function()
                if _G._novaIJ and LP.Character then
                    local h=LP.Character:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end,2)

    Toggle(pg,"Anti AFK","Cegah kick otomatis",false,function(v)
        _G._novaAfk=v
        if v then
            _G._afkConn=RunService.Heartbeat:Connect(function()
                if not _G._novaAfk then _G._afkConn:Disconnect() end
            end)
        end
    end,3)

    Toggle(pg,"Full Bright","Cerahkan semua area",false,function(v)
        local L2=game:GetService("Lighting")
        if v then
            _G._oldBright=L2.Brightness; _G._oldClock=L2.ClockTime
            L2.Brightness=5; L2.ClockTime=14; L2.FogEnd=1e6; L2.GlobalShadows=false
        else
            L2.Brightness=_G._oldBright or 1
            L2.ClockTime=_G._oldClock or 14
            L2.FogEnd=1000; L2.GlobalShadows=true
        end
    end,4)

    Toggle(pg,"No Clip","Tembus semua objek",false,function(v)
        _G._novaNC=v
        if v and not _G._ncConn then
            _G._ncConn=RunService.Stepped:Connect(function()
                if _G._novaNC and LP.Character then
                    for _,p in ipairs(LP.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide=false end
                    end
                end
            end)
        end
    end,5)

    Section(pg,"Movement",6)
    Slider(pg,"Walk Speed",16,250,16," ws",function(v)
        if LP.Character then
            local h=LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=v end
        end
    end,7)
    Slider(pg,"Jump Power",50,500,50," jp",function(v)
        if LP.Character then
            local h=LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower=v end
        end
    end,8)
    Slider(pg,"Gravity",10,196,196," g",function(v)
        workspace.Gravity=v
    end,9)

    Section(pg,"Utilities",10)
    Toggle(pg,"Hide GUI","Sembunyikan seluruh GUI game",false,function(v)
        LP.PlayerGui.ScreenGui and nil
        for _,g in ipairs(LP.PlayerGui:GetChildren()) do
            if g.Name~="NovaUI_v3" and g:IsA("ScreenGui") then
                g.Enabled=not v
            end
        end
    end,11)
    Toggle(pg,"Show FPS","Tampilkan FPS di konsol",false,function(v)
        _G._showFps=v
        if v and not _G._fpsConn then
            local t,frames=tick(),0
            _G._fpsConn=RunService.RenderStepped:Connect(function()
                if not _G._showFps then _G._fpsConn:Disconnect(); return end
                frames=frames+1
                if tick()-t>=1 then
                    print("[Nova FPS]",frames); t=tick(); frames=0
                end
            end)
        end
    end,12)
    Btn(pg,"💾  Save Character Pos","secondary",function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            _G._savedCFrame=LP.Character.HumanoidRootPart.CFrame
            print("[Nova] Position saved!")
        end
    end,13)
    Btn(pg,"📍  Teleport to Saved Pos","primary",function()
        if _G._savedCFrame and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame=_G._savedCFrame
        else
            print("[Nova] No saved position!")
        end
    end,14)
end

------------------------------------------------------
-- ══════════════════════════════════════════════════
--  TAB 3 · COMBAT
-- ══════════════════════════════════════════════════
------------------------------------------------------
do
    local pg = tabPages["Combat"]

    Section(pg,"Aimbot",1)
    Toggle(pg,"Aimbot","Auto-aim ke player terdekat",false,function(v)
        _G._aimbot=v
        print("[Nova] Aimbot:",v)
    end,2)
    Toggle(pg,"Silent Aim","Peluru melacak target",false,function(v)
        print("[Nova] SilentAim:",v)
    end,3)
    Slider(pg,"FOV Radius",50,600,150," px",function(v)
        _G._aimbotFov=v
    end,4)
    Slider(pg,"Smooth Speed",1,20,5,"x",function(v)
        _G._aimbotSmooth=v
    end,5)

    Section(pg,"Visual / ESP",6)
    Toggle(pg,"Player ESP","Kotak merah di sekitar player",false,function(v)
        _G._esp=v
        if v then
            _G._espConn=RunService.RenderStepped:Connect(function()
                if not _G._esp then _G._espConn:Disconnect(); return end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP and p.Character then
                        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- basic esp highlight
                            local hl=p.Character:FindFirstChild("_NovaHL")
                            if not hl then
                                hl=Instance.new("SelectionBox"); hl.Name="_NovaHL"
                                hl.Color3=C.red; hl.LineThickness=0.05
                                hl.Adornee=p.Character; hl.Parent=p.Character
                            end
                        end
                    end
                end
            end)
        else
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl=p.Character:FindFirstChild("_NovaHL")
                    if hl then hl:Destroy() end
                end
            end
        end
    end,7)
    Toggle(pg,"Name Tag","Tampilkan nama di atas kepala",false,function(v)
        print("[Nova] NameTag:",v)
    end,8)
    Toggle(pg,"Health Bar","Bar HP di atas karakter",false,function(v)
        print("[Nova] HealthBar:",v)
    end,9)
    Toggle(pg,"Chams","Sorot lewat dinding",false,function(v)
        _G._chams=v
        if v then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character then
                    for _,part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material=Enum.Material.Neon
                            part.Color=C.red
                        end
                    end
                end
            end
        else
            print("[Nova] Chams off — rejoin to revert")
        end
    end,10)

    Section(pg,"Weapon",11)
    Toggle(pg,"No Recoil","Hilangkan recoil senjata",false,function(v) print("[Nova] NoRecoil:",v) end,12)
    Toggle(pg,"Rapid Fire","Tembak lebih cepat",false,function(v) print("[Nova] RapidFire:",v) end,13)
    Toggle(pg,"Infinite Ammo","Ammo tidak habis",false,function(v) print("[Nova] InfAmmo:",v) end,14)
end

------------------------------------------------------
-- ══════════════════════════════════════════════════
--  TAB 4 · FARM
-- ══════════════════════════════════════════════════
------------------------------------------------------
do
    local pg = tabPages["Farm"]

    Section(pg,"Auto Farm",1)
    Toggle(pg,"Auto Farm","Farm otomatis terus menerus",false,function(v)
        _G._farm=v
        if v and not _G._farmConn then
            _G._farmConn=RunService.Heartbeat:Connect(function()
                if not _G._farm then _G._farmConn:Disconnect(); _G._farmConn=nil; return end
                -- game-specific farm logic goes here
            end)
        end
        print("[Nova] AutoFarm:",v)
    end,2)
    Toggle(pg,"Auto Collect","Ambil item/drop otomatis",false,function(v)
        print("[Nova] AutoCollect:",v)
    end,3)
    Toggle(pg,"Auto Sell","Jual hasil farm otomatis",false,function(v)
        print("[Nova] AutoSell:",v)
    end,4)
    Toggle(pg,"Auto Rebirth","Rebirth otomatis saat siap",false,function(v)
        print("[Nova] AutoRebirth:",v)
    end,5)
    Slider(pg,"Farm Delay",50,3000,500," ms",function(v)
        _G._farmDelay=v
    end,6)

    Section(pg,"Quest",7)
    Toggle(pg,"Auto Accept Quest",nil,false,function(v) print("[Nova] AutoQuest:",v) end,8)
    Toggle(pg,"Auto Complete Quest",nil,false,function(v) print("[Nova] AutoComplete:",v) end,9)
    Toggle(pg,"Skip Cutscene",nil,false,function(v) print("[Nova] SkipCutscene:",v) end,10)

    Section(pg,"Teleport Farm",11)
    Btn(pg,"🌀  TP ke Mob Terdekat","primary",function()
        -- find nearest NPC
        local nearest,dist=nil,math.huge
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj~=LP.Character then
                local h=obj:FindFirstChildOfClass("Humanoid")
                local hrp=obj:FindFirstChild("HumanoidRootPart")
                if h and hrp and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local d=(hrp.Position-LP.Character.HumanoidRootPart.Position).Magnitude
                    if d<dist then dist=d; nearest=hrp end
                end
            end
        end
        if nearest and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame=nearest.CFrame+Vector3.new(0,4,0)
        end
    end,12)
    BtnRow(pg,"▶  Start","⏹  Stop All",
        function() _G._farm=true; print("[Nova] Farm started") end,
        function()
            _G._farm=false
            print("[Nova] All stopped")
        end,13)
end

------------------------------------------------------
-- ══════════════════════════════════════════════════
--  TAB 5 · SETTINGS
-- ══════════════════════════════════════════════════
------------------------------------------------------
do
    local pg = tabPages["Settings"]

    Section(pg,"Interface",1)
    Toggle(pg,"Transparent Window","Window sedikit bening",false,function(v)
        tw(Win,{BackgroundTransparency=v and 0.18 or 0},TI)
    end,2)
    Toggle(pg,"Compact Mode","Kurangi ukuran padding",false,function(v)
        print("[Nova] Compact:",v)
    end,3)

    Section(pg,"Notifikasi",4)
    Toggle(pg,"Popup Notifikasi","Tampilkan notif saat toggle",true,function(v)
        _G._novaNotif=v
    end,5)
    Toggle(pg,"Suara Klik","Efek suara tombol",false,function(v)
        print("[Nova] Sound:",v)
    end,6)

    Section(pg,"Keybind",7)
    InfoRow(pg,"⌨","Toggle GUI (PC)","RightShift",8)
    InfoRow(pg,"📱","Toggle GUI (HP)","Tombol biru",9)

    Section(pg,"Server Info",10)
    InfoRow(pg,"🌐","Job ID",  game.JobId~="" and game.JobId:sub(1,14).."…" or "Private",11)
    InfoRow(pg,"👥","Players", tostring(#Players:GetPlayers()).." / "..tostring(game.Players.MaxPlayers),12)
    InfoRow(pg,"🗺","Place ID",tostring(game.PlaceId),13)

    Section(pg,"About",14)
    InfoRow(pg,"📦","Versi",    "Nova UI v3.0",15)
    InfoRow(pg,"👨‍💻","Dev",      "NovaTeam",    16)
    InfoRow(pg,"💬","Discord",  "discord.gg/nova",17)

    Section(pg,"Danger Zone",18)
    Btn(pg,"🗑  Unload Script","danger",function()
        tw(Win,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},TI_SLOW)
        task.delay(0.4,function() SG:Destroy() end)
    end,19)
end

------------------------------------------------------
-- MOBILE FLOAT BUTTON
------------------------------------------------------
if MOBILE then
    local mBtn=Instance.new("TextButton")
    mBtn.Size=UDim2.new(0,50,0,50); mBtn.Position=UDim2.new(0,16,1,-76)
    mBtn.BackgroundColor3=C.a1; mBtn.Text="N"; mBtn.Font=Enum.Font.GothamBold
    mBtn.TextSize=18; mBtn.TextColor3=Color3.new(1,1,1); mBtn.ZIndex=30
    mBtn.Parent=SG; rnd(mBtn,14); grad(mBtn,C.a1,C.a2,135)
    local shown=true
    mBtn.MouseButton1Click:Connect(function()
        shown=not shown; Win.Visible=shown
    end)
end

------------------------------------------------------
-- PC KEYBIND
------------------------------------------------------
UserInputService.InputBegan:Connect(function(i,gpe)
    if not gpe and i.KeyCode==Enum.KeyCode.RightShift then
        Win.Visible=not Win.Visible
    end
end)

------------------------------------------------------
-- OPEN ANIMATION + DEFAULT TAB
------------------------------------------------------
Win.Size=UDim2.new(0,WIN_W,0,0); Win.BackgroundTransparency=1
tw(Win,{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0},TI_SLOW)
task.delay(0.15,function() switchTab("Profile") end)

print(("[Nova UI v3.0] Ready!  Platform: %s"):format(MOBILE and "Mobile 📱" or "PC 💻"))
