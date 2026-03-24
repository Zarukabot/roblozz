--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// REMOTES
-- buat RemoteEvent untuk main sound global
local remote = Instance.new("RemoteEvent")
remote.Name = "PlayGlobalSound"
remote.Parent = ReplicatedStorage

-- ServerScriptService: mainkan sound
-- letakkan ini di ServerScriptService
--[[
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("PlayGlobalSound")

remote.OnServerEvent:Connect(function(player, soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 1
	sound.Parent = workspace
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end)
]]

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoundboardGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,320,0,450)
Frame.Position = UDim2.new(0,20,0,50)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.Text = "🎵 Soundboard Global"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,0,1,-40)
Scroll.Position = UDim2.new(0,0,0,40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.Parent = Scroll

-- Daftar suara Roblox
local sounds = {
	["Bell"] = "rbxassetid://911882694",
	["Gunshot"] = "rbxassetid://130776583",
	["Explosion"] = "rbxassetid://138186576",
	["Jump"] = "rbxassetid://10209845",
	["Pop"] = "rbxassetid://132114019",
	["Laugh"] = "rbxassetid://2801263",
	["Siren"] = "rbxassetid://138208144"
}

-- Tombol
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
		-- Kirim request ke server untuk mainkan sound di workspace
		remote:FireServer(id)
	end)
end
