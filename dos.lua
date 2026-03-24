--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoundboardGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,300,0,400)
Frame.Position = UDim2.new(0,20,0,50)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.Text = "🎵 Soundboard Roblox"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

-- ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,0,1,-40)
Scroll.Position = UDim2.new(0,0,0,40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.Parent = Scroll

-- Daftar sound Roblox populer (official)
local sounds = {
	["Bell"] = "rbxassetid://911882694",       -- Bell sound
	["Gunshot"] = "rbxassetid://130776583",   -- Gunshot
	["Explosion"] = "rbxassetid://138186576", -- Explosion
	["Jump"] = "rbxassetid://10209845",       -- Jump
	["Pop"] = "rbxassetid://132114019",       -- Pop sound
	["Laugh"] = "rbxassetid://2801263",       -- Laugh
	["Siren"] = "rbxassetid://138208144"      -- Siren
}

-- Buat tombol
for name, id in pairs(sounds) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-10,0,40)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	btn.BorderSizePixel = 0
	btn.Parent = Scroll
	
	btn.MouseButton1Click:Connect(function()
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 1
		sound.Parent = workspace
		sound:Play()
		
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end)
end
