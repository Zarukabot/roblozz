-- AutoFish (hybrid auto-detect) for Fish It
-- Untuk executor: Fluxus / Synapse / Delta / Arceus X
-- Paste dan jalankan. Toggle GUI untuk ON/OFF.
-- Author: ChatGPT (adapted for Roblox exploits)

-- ===== helpers for GUI protection (common in exploits) =====
local function get_parent_for_gui()
    -- prefer gethui() if available
    if (type(gethui) == "function") then
        return gethui()
    end
    -- prefer CoreGui (may fail on some environments)
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if success and core then return core end
    -- fallback to PlayerGui
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local H = get_parent_for_gui()

-- syn.protect_gui support
local function protect_gui(gui)
    if (type(syn) == "table" and syn.protect_gui) then
        pcall(function() syn.protect_gui(gui) end)
    end
end

-- ===== VirtualInputManager helpers (mouse / key) =====
local VIM = game:GetService("VirtualInputManager")
local function send_mouse_click_at(x, y)
    -- press
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    end)
    wait(0.01)
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function send_keypress(key)
    pcall(function()
        VIM:SendKeyEvent(true, key, false, game)
    end)
    wait(0.02)
    pcall(function()
        VIM:SendKeyEvent(false, key, false, game)
    end)
end

-- ===== basic UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishHybridUI_v1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = H
protect_gui(ScreenGui)

local main = Instance.new("Frame", ScreenGui)
main.Name = "Main"
main.Size = UDim2.new(0, 360, 0, 140)
main.Position = UDim2.new(0.02, 0, 0.25, 0)
main.AnchorPoint = Vector2.new(0,0)
main.BackgroundColor3 = Color3.fromRGB(22,22,25)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = true
main.Round = Instance.new("UICorner", main)
main.Round.CornerRadius = UDim.new(0, 10)
main.UIStroke = Instance.new("UIStroke", main)
main.UIStroke.Thickness = 1
main.UIStroke.Color = Color3.fromRGB(40,40,45)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -16, 0, 26)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AutoFish — Hybrid Detector"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextXAlignment = Enum.TextXAlignment.Left

local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(0.48, -8, 0, 28)
statusLabel.Position = UDim2.new(0, 8, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(255,120,90)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.48, -8, 0, 28)
toggleBtn.Position = UDim2.new(0.52, 0, 0, 38)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(230,230,230)
toggleBtn.Text = "Turn ON"
toggleBtn.AutoButtonColor = true
toggleBtn.Round = Instance.new("UICorner", toggleBtn)
toggleBtn.Round.CornerRadius = UDim.new(0,8)

local methodLabel = Instance.new("TextLabel", main)
methodLabel.Size = UDim2.new(0.5, -8, 0, 20)
methodLabel.Position = UDim2.new(0, 8, 0, 74)
methodLabel.BackgroundTransparency = 1
methodLabel.Text = "Input method:"
methodLabel.Font = Enum.Font.Gotham
methodLabel.TextSize = 13
methodLabel.TextColor3 = Color3.fromRGB(200,200,200)
methodLabel.TextXAlignment = Enum.TextXAlignment.Left

local methodDropdown = Instance.new("TextButton", main)
methodDropdown.Size = UDim2.new(0.45, -8, 0, 26)
methodDropdown.Position = UDim2.new(0.5, 0, 0, 72)
methodDropdown.BackgroundColor3 = Color3.fromRGB(30,30,35)
methodDropdown.Font = Enum.Font.Gotham
methodDropdown.TextSize = 13
methodDropdown.TextColor3 = Color3.fromRGB(230,230,230)
methodDropdown.Text = "Mouse (default)"
methodDropdown.AutoButtonColor = true
methodDropdown.Round2 = Instance.new("UICorner", methodDropdown)
methodDropdown.Round2.CornerRadius = UDim.new(0,6)

local infoLabel = Instance.new("TextLabel", main)
infoLabel.Size = UDim2.new(1, -16, 0, 26)
infoLabel.Position = UDim2.new(0,8,1,-36)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Mode: Hybrid detect | Heuristic scanning"
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextColor3 = Color3.fromRGB(170,170,170)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- dropdown simple (cycle three choices)
local inputMethods = {"Mouse", "Key: E", "Key: Space"}
local currentMethodIndex = 1
methodDropdown.MouseButton1Click:Connect(function()
    currentMethodIndex = currentMethodIndex % #inputMethods + 1
    methodDropdown.Text = inputMethods[currentMethodIndex] .. (currentMethodIndex==1 and " (default)" or "")
end)

-- ===== detection logic =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local running = false
local autoTickConnection

local function find_moving_indicator_and_box()
    -- returns indicatorGui, boxGui, parentRoot
    -- Heuristics:
    -- 1) scan PlayerGui descendants for ImageLabel / Frame that moves over short time (indicator)
    -- 2) for each moving element, try to find sibling/frame that looks like 'box' (smaller rectangular area)
    local candidates = {}
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("ImageLabel") or gui:IsA("ImageButton") or gui:IsA("Frame")) and gui.Visible then
            -- ignore tiny invisible things
            local ok, absPos = pcall(function() return gui.AbsolutePosition end)
            if ok then
                table.insert(candidates, gui)
            end
        end
    end

    local function is_moving(obj)
        -- sample positions quickly
        local ok1, p1 = pcall(function() return obj.AbsolutePosition end)
        if not ok1 then return false end
        wait(0.06)
        local ok2, p2 = pcall(function() return obj.AbsolutePosition end)
        if not ok2 then return false end
        local dist = (p2 - p1).magnitude
        return dist >= 1 -- moved at least 1px
    end

    -- find first moving candidate that has a nearby sibling box-like element
    for _, obj in pairs(candidates) do
        local ok, size = pcall(function() return obj.AbsoluteSize end)
        if not ok then size = Vector2.new(0,0) end
        -- skip too big full-screen things
        if size.X < 600 and size.Y < 200 then
            local success, moved = pcall(is_moving, obj)
            if success and moved then
                -- try to find a 'box' in same parent or parent's parent: a child with smaller size and centered-ish
                local parent = obj.Parent
                local searchList = {}
                if parent then
                    for _, ch in pairs(parent:GetChildren()) do
                        if (ch:IsA("Frame") or ch:IsA("ImageLabel") or ch:IsA("ImageButton")) and ch ~= obj and ch.Visible then
                            table.insert(searchList, ch)
                        end
                    end
                end
                -- also search parent's parent
                if parent and parent.Parent then
                    for _, ch in pairs(parent.Parent:GetChildren()) do
                        if (ch:IsA("Frame") or ch:IsA("ImageLabel") or ch:IsA("ImageButton")) and ch ~= obj and ch.Visible then
                            table.insert(searchList, ch)
                        end
                    end
                end

                -- heuristics for box: smaller size than parent, rectangular, not moving much
                for _, cand in pairs(searchList) do
                    local okc, s = pcall(function() return cand.AbsoluteSize end)
                    if okc then
                        if s.X > 10 and s.Y > 6 and s.X < 500 then
                            -- ensure candidate is not moving
                            local notmoving = true
                            local okm, moved2 = pcall(is_moving, cand)
                            if not okm then notmoving = false else notmoving = (not moved2)
                            if notmoving then
                                -- found probable pair
                                return obj, cand, parent
                            end
                        end
                    end
                end

                -- fallback: return moving obj alone (maybe box is transparent)
                return obj, nil, parent
            end
        end
    end

    -- fallback: try to find by name patterns (Indicator, Pointer, Hitbox, Box)
    local patterns = {"Indicator","Pointer","Hitbox","Box","Target","Bar","Cursor"}
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
            for _, p in pairs(patterns) do
                if string.find(string.lower(gui.Name), string.lower(p)) then
                    -- try to find sibling box
                    local parent = gui.Parent
                    if parent then
                        for _, ch in pairs(parent:GetChildren()) do
                            if ch ~= gui and (ch:IsA("Frame") or ch:IsA("ImageLabel")) then
                                return gui, ch, parent
                            end
                        end
                    end
                    return gui, nil, parent
                end
            end
        end
    end

    return nil, nil, nil
end

-- given indicator and box, compute whether indicator is inside box
local function is_indicator_inside_box(indicator, box)
    if not indicator or not box then return false end
    local ipos_ok, ipos = pcall(function() return indicator.AbsolutePosition end)
    local isz_ok, isz = pcall(function() return indicator.AbsoluteSize end)
    local bpos_ok, bpos = pcall(function() return box.AbsolutePosition end)
    local bsz_ok, bsz = pcall(function() return box.AbsoluteSize end)
    if not (ipos_ok and isz_ok and bpos_ok and bsz_ok) then return false end
    local icenter = ipos + isz/2
    if icenter.X >= bpos.X and icenter.X <= (bpos.X + bsz.X) and icenter.Y >= bpos.Y and icenter.Y <= (bpos.Y + bsz.Y) then
        return true
    end
    return false
end

-- If box not detected, fallback to threshold in parent frame (like center area)
local function indicator_in_parent_center(indicator, parent)
    if not indicator or not parent then return false end
    local ipos_ok, ipos = pcall(function() return indicator.AbsolutePosition end)
    local isz_ok, isz = pcall(function() return indicator.AbsoluteSize end)
    local ppos_ok, ppos = pcall(function() return parent.AbsolutePosition end)
    local psz_ok, psz = pcall(function() return parent.AbsoluteSize end)
    if not (ipos_ok and isz_ok and ppos_ok and psz_ok) then return false end
    local icenter = ipos + isz/2
    -- define central box as middle 30% area
    local left = ppos.X + psz.X*0.35
    local right = ppos.X + psz.X*0.65
    local top = ppos.Y + psz.Y*0.3
    local bottom = ppos.Y + psz.Y*0.7
    if icenter.X >= left and icenter.X <= right and icenter.Y >= top and icenter.Y <= bottom then
        return true
    end
    return false
end

-- ===== main loop =====
local last_detect_time = 0
local detected = {indicator = nil, box = nil, parent = nil}

local function try_detect_once()
    local now = tick()
    if now - last_detect_time < 1 then return end -- throttle
    last_detect_time = now
    local ind, box, parent = find_moving_indicator_and_box()
    if ind then
        detected.indicator = ind
        detected.box = box
        detected.parent = parent
        return true
    else
        detected.indicator = nil
        detected.box = nil
        detected.parent = nil
        return false
    end
end

local function do_actuation()
    if not detected.indicator then return end
    local ind = detected.indicator
    local box = detected.box
    local parent = detected.parent
    local inside = false
    if box then
        inside = is_indicator_inside_box(ind, box)
    else
        inside = indicator_in_parent_center(ind, parent)
    end

    if inside then
        local method = inputMethods[currentMethodIndex]
        if method == "Mouse" then
            -- click at indicator center
            local okPos, pos = pcall(function() return ind.AbsolutePosition + ind.AbsoluteSize/2 end)
            if okPos then
                send_mouse_click_at(pos.X, pos.Y)
            else
                -- fallback center of screen
                local w = workspace.CurrentCamera.ViewportSize
                send_mouse_click_at(w.X/2, w.Y/2)
            end
        elseif method == "Key: E" then
            send_keypress("E")
        elseif method == "Key: Space" then
            send_keypress(" ")
        end
        -- short cooldown to avoid spamming
        wait(0.08)
    end
end

-- attempt auto-detect every few seconds until found
local function detector_loop()
    while running do
        local ok = pcall(try_detect_once)
        if ok and detected.indicator then
            -- found something
            infoLabel.Text = "Mode: Detector found GUI (auto)"
            statusLabel.Text = "Status: ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(130,255,120)
            break
        else
            infoLabel.Text = "Mode: Scanning PlayerGui..."
        end
        wait(0.7)
    end
end

-- auto tick loop performing detection and actuation
local function tick_loop()
    -- try initial detection
    try_detect_once()
    while running do
        -- if not detected, try to detect
        if not detected.indicator then
            try_detect_once()
            wait(0.12)
        else
            -- check actuation
            pcall(do_actuation)
            wait(0.02)
        end
    end
end

-- GUI interactions
toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggleBtn.Text = "Turn OFF"
        statusLabel.Text = "Status: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(130,255,120)
        -- start detection + tick
        spawn(function() detector_loop() end)
        autoTickConnection = spawn(function() tick_loop() end)
    else
        toggleBtn.Text = "Turn ON"
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255,120,90)
        -- running will stop loops naturally
    end
end)

-- draggable
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- clean up on teleport / character removed
Players.LocalPlayer.OnTeleport:Connect(function()
    running = false
    pcall(function() ScreenGui:Destroy() end)
end)

-- final info
infoLabel.Text = "Mode: Hybrid detect | Click method: " .. inputMethods[currentMethodIndex]
print("AutoFishHybrid_v1 loaded. Toggle ON to start.")
