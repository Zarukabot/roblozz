--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// ==============================
--// 🔐 FULL ADVANCED KEY SYSTEM + GET KEY BUTTON
--// ==============================
local CONFIG = {
    ManualKey = "RYUZO-ULTRA-2026", -- ganti sesuai keinginan
    ExpireDate = os.time({year=2026, month=12, day=31}),
    MaxAttempts = 3,
    WhitelistUserIds = { 1234567890 },
    KeyLink = "https://example.com/getkey"
}

local function generateDailyKey()
    local day = os.date("*t").yday
    local year = os.date("*t").year
    return "RYUZO-"..year.."-"..day
end

local DAILY_KEY = generateDailyKey()

for _,id in ipairs(CONFIG.WhitelistUserIds) do
    if LocalPlayer.UserId == id then
        _G.KeyUnlocked = true
        break
    end
end

if os.time() > CONFIG.ExpireDate then
    LocalPlayer:Kick("Script Expired.")
end

-- KEY GUI
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "UltraKeySystem"
KeyGui.Parent = game.CoreGui
KeyGui.ResetOnSpawn = false

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0,320,0,200)
KeyFrame.Position = UDim2.new(0.5,-160,0.5,-100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel", KeyFrame)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "🔐 ULTRA KEY SYSTEM"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.85,0,0,35)
KeyBox.Position = UDim2.new(0.075,0,0.35,0)
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0,10)

local Submit = Instance.new("TextButton", KeyFrame)
Submit.Size = UDim2.new(0.6,0,0,35)
Submit.Position = UDim2.new(0.2,0,0.6,0)
Submit.Text = "Unlock"
Submit.BackgroundColor3 = Color3.fromRGB(50,120,255)
Submit.TextColor3 = Color3.new(1,1,1)
Submit.Font = Enum.Font.GothamBold
Submit.TextSize = 14
Instance.new("UICorner", Submit).CornerRadius = UDim.new(0,10)

local GetKey = Instance.new("TextButton", KeyFrame)
GetKey.Size = UDim2.new(0.6,0,0,30)
GetKey.Position = UDim2.new(0.2,0,0.85,0)
GetKey.Text = "🔗 Get Key"
GetKey.BackgroundColor3 = Color3.fromRGB(80,80,90)
GetKey.TextColor3 = Color3.new(1,1,1)
GetKey.Font = Enum.Font.Gotham
GetKey.TextSize = 13
Instance.new("UICorner", GetKey).CornerRadius = UDim.new(0,8)

-- LOCK MAIN GUI UNTUK TELEPORT
local function lockMainGUI()
    if game.CoreGui:FindFirstChild("TeleportUltraGUI") then
        game.CoreGui.TeleportUltraGUI.Enabled = false
    end
end

local function unlockMainGUI()
    if game.CoreGui:FindFirstChild("TeleportUltraGUI") then
        game.CoreGui.TeleportUltraGUI.Enabled = true
    end
    KeyGui:Destroy()
end

lockMainGUI()

-- VALIDATION
local Attempts = 0
local function isValidKey(input)
    if input == CONFIG.ManualKey or input == DAILY_KEY then
        return true
    end
    return false
end

Submit.MouseButton1Click:Connect(function()
    if isValidKey(KeyBox.Text) then
        _G.KeyUnlocked = true
        unlockMainGUI()
    else
        Attempts += 1
        Submit.Text = "❌ Wrong ("..Attempts..")"
        task.wait(1)
        Submit.Text = "Unlock"
        if Attempts >= CONFIG.MaxAttempts then
            LocalPlayer:Kick("Too many wrong key attempts.")
        end
    end
end)

GetKey.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CONFIG.KeyLink)
        GetKey.Text = "📋 Link Copied!"
        task.wait(1)
        GetKey.Text = "🔗 Get Key"
    else
        GetKey.Text = "❌ Clipboard Not Supported"
        task.wait(1)
        GetKey.Text = "🔗 Get Key"
    end
end)

repeat task.wait() until _G.KeyUnlocked == true

--// ==============================
--// ⚡ TELEPORT GUI
--// ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUltraGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,360,0,400)
Frame.Position = UDim2.new(0.5,-180,0.5,-200)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,-40,0,40)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Teleport Player"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle, Search, Player List, Save Pos, Mini Button dst (tetap seperti script lama)...
-- [Kamu bisa menempel seluruh kode teleport GUI yang sudah kamu punya di sini]
