-- 🚀 Full Admin Mount Visual + Admin Features GUI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Tunggu karakter
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- =========================
-- 1. Admin Mount
-- =========================
local function createAdminMount()
    if char:FindFirstChild("AdminMount") then return end
    local mount = Instance.new("Part")
    mount.Name = "AdminMount"
    mount.Size = Vector3.new(4,1,6)
    mount.Position = char.HumanoidRootPart.Position - Vector3.new(0,2,0)
    mount.Anchored = false
    mount.CanCollide = false
    mount.Material = Enum.Material.Neon
    mount.BrickColor = BrickColor.new("Bright purple")
    mount.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = char.HumanoidRootPart
    weld.Part1 = mount
    weld.Parent = mount
end

-- =========================
-- 2. Aura Particle
-- =========================
local function createAdminAura()
    if char.HumanoidRootPart:FindFirstChild("AdminAura") then return end
    local attachment = Instance.new("Attachment")
    attachment.Name = "AdminAura"
    attachment.Parent = char.HumanoidRootPart

    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(Color3.fromRGB(128,0,255), Color3.fromRGB(255,0,255))
    particle.LightEmission = 0.7
    particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.5), NumberSequenceKeypoint.new(1,1)})
    particle.Rate = 25
    particle.Lifetime = NumberRange.new(0.5,1)
    particle.Speed = NumberRange.new(1,3)
    particle.Parent = attachment
end

-- =========================
-- 3. Title di Atas Kepala
-- =========================
local function createAdminTitle()
    local head = char:WaitForChild("Head")
    if head:FindFirstChild("AdminTitle") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdminTitle"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "👑 Admin Mount"
    textLabel.TextColor3 = Color3.fromRGB(255,0,255)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.Parent = billboard
end

-- =========================
-- 4. Admin Features GUI
-- =========================
local function createAdminGUI()
    if char:FindFirstChild("PlayerGui") == nil then return end
    local PlayerGui = char:WaitForChild("PlayerGui")
    if PlayerGui:FindFirstChild("AdminGUI") then PlayerGui.AdminGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdminGUI"
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,220,0,180)
    MainFrame.Position = UDim2.new(0.5,-110,0.5,-90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,15)
    corner.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,35)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(40,40,55)
    title.Text = "👑 Admin Features"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = MainFrame
    local tcorner = Instance.new("UICorner")
    tcorner.CornerRadius = UDim.new(0,15)
    tcorner.Parent = title

    -- Example Feature Buttons
    local function createButton(text,posY,callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,200,0,30)
        btn.Position = UDim2.new(0,10,0,posY)
        btn.BackgroundColor3 = Color3.fromRGB(100,50,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Text = text
        btn.Parent = MainFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(callback)
    end

    -- Contoh tombol: Fly / Speed
    createButton("Fly",50,function()
        print("🛸 Fly feature activated (visual/local only)")
    end)
    createButton("Speed Boost",90,function()
        print("⚡ Speed Boost activated (visual/local only)")
    end)
    createButton("Teleport to Spawn",130,function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(Vector3.new(0,5,0))
        end
        print("📍 Teleported to Spawn (local)")
    end)
end

-- =========================
-- 5. Aktifkan Semua
-- =========================
local function enableAdminMountFull()
    createAdminMount()
    createAdminAura()
    createAdminTitle()
    createAdminGUI()
    print("✅ Admin Mount Visual + Features activated!")
end

-- Jalankan
enableAdminMountFull()

-- Pastikan title muncul saat respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    wait(1)
    enableAdminMountFull()
end)
