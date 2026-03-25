--// SERVICES
local RunService = game:GetService("RunService")

--// SETTINGS
local TIME_MULTIPLIER = 10 
-- 1 = normal
-- 5 = 5x lebih cepat
-- 10 = 10x lebih cepat
-- 50 = super cepat

local startTime = tick()

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FakePlaytimeDashboard"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 160)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,15)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "📊 PLAYTIME BOOSTER"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local TimeLabel = Instance.new("TextLabel", Frame)
TimeLabel.Position = UDim2.new(0,0,0,50)
TimeLabel.Size = UDim2.new(1,0,0,50)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(0,255,170)
TimeLabel.TextScaled = true
TimeLabel.Text = "00:00:00"

local MultiplierLabel = Instance.new("TextLabel", Frame)
MultiplierLabel.Position = UDim2.new(0,0,0,100)
MultiplierLabel.Size = UDim2.new(1,0,0,25)
MultiplierLabel.BackgroundTransparency = 1
MultiplierLabel.TextColor3 = Color3.new(1,1,1)
MultiplierLabel.TextScaled = true
MultiplierLabel.Text = "Speed: "..TIME_MULTIPLIER.."x"

--==================================================
-- FORMAT TIME
--==================================================

local function formatTime(seconds)
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

--==================================================
-- UPDATE LOOP (FAKE TIME)
--==================================================

RunService.RenderStepped:Connect(function()
	local realElapsed = tick() - startTime
	local fakeElapsed = realElapsed * TIME_MULTIPLIER
	TimeLabel.Text = formatTime(fakeElapsed)
end)

print("🚀 Fake Playtime Loaded")
