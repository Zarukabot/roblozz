--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "RemoteToolkitMini"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420) -- ✅ kecil, mobile friendly
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "⚡ Remote Mini"
title.TextColor3 = Color3.fromRGB(0,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- FPS LABEL
local fpsLabel = Instance.new("TextLabel", main)
fpsLabel.Position = UDim2.new(0,10,0,45)
fpsLabel.Size = UDim2.new(1,-20,0,25)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0,255,150)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextScaled = true

-- REMOTE LIST
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0,10,0,75)
scroll.Size = UDim2.new(1,-20,0,260)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)

-- COLLAPSE BUTTON
local collapse = Instance.new("TextButton", main)
collapse.Size = UDim2.new(1,-20,0,30)
collapse.Position = UDim2.new(0,10,1,-40)
collapse.Text = "🗕 Collapse"
collapse.BackgroundColor3 = Color3.fromRGB(0,60,60)
collapse.TextColor3 = Color3.fromRGB(0,255,255)
collapse.Font = Enum.Font.Gotham
collapse.TextScaled = true
Instance.new("UICorner", collapse).CornerRadius = UDim.new(0,6)

local collapsed = false
collapse.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        main.Size = UDim2.new(0,320,0,80)
        collapse.Text = "🗖 Expand"
    else
        main.Size = UDim2.new(0,320,0,420)
        collapse.Text = "🗕 Collapse"
    end
end)

-- LOAD REMOTES (No Spam)
local function loadRemotes()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local sizeY = 0
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,0,0,32)
            btn.Text = remote.Name
            btn.BackgroundColor3 = Color3.fromRGB(0,40,40)
            btn.TextColor3 = Color3.fromRGB(0,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

            sizeY += 36

            btn.MouseButton1Click:Connect(function()
                print("Selected Remote:", remote:GetFullName())
            end)
        end
    end

    scroll.CanvasSize = UDim2.new(0,0,0,sizeY)
end

loadRemotes()

-- FPS MONITOR (Performance Mode)
local last = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        fpsLabel.Text = "FPS: "..frames
        frames = 0
        last = tick()
    end
end)
