-- 🚀 Admin Mount Visual + Title
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tunggu karakter
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- === FUNCTION: Buat Mount ===
local function createAdminMount()
    if char:FindFirstChild("AdminMount") then return end -- prevent duplicate

    local mount = Instance.new("Part")
    mount.Name = "AdminMount"
    mount.Size = Vector3.new(4,1,6)
    mount.Position = char.HumanoidRootPart.Position - Vector3.new(0,2,0)
    mount.Anchored = false
    mount.CanCollide = false
    mount.Material = Enum.Material.Neon
    mount.BrickColor = BrickColor.new("Bright purple")
    mount.Parent = workspace

    -- Weld ke HumanoidRootPart
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = char.HumanoidRootPart
    weld.Part1 = mount
    weld.Parent = mount
end

-- === FUNCTION: Buat Aura Particle ===
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

-- === FUNCTION: Buat Title di atas kepala ===
local function createAdminTitle()
    if char:FindFirstChild("AdminTitle") then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdminTitle"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.StudsOffset = Vector3.new(0,2.5,0)
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

-- === FUNCTION: Aktifkan Semua ===
local function enableAdminMountVisual()
    createAdminMount()
    createAdminAura()
    createAdminTitle()
    print("✅ Admin Mount Visual + Title activated!")
end

-- Jalankan
enableAdminMountVisual()
