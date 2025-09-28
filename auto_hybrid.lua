-- LocalScript: AdminMountFull
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local autoEnabled = false
local checkpoints = {}
local touchedCheckpoints = {}

-- =========================
-- 1. Admin Mount Visual
-- =========================
local function createAdminMount(char)
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

local function createAdminAura(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    if hrp:FindFirstChild("AdminAura") then return end

    local attachment = Instance.new("Attachment")
    attachment.Name = "AdminAura"
    attachment.Parent = hrp

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
-- 2. Admin Title
-- =========================
local function createAdminTitle(char)
    local head = char:WaitForChild("Head")
    if head:FindFirstChild("AdminTitle") then head.AdminTitle:Destroy() end

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
-- 3. Admin GUI
-- =========================
local function createAdminGUI()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local PlayerGui = char:WaitForChild("PlayerGui")

    if PlayerGui:FindFirstChild("AdminGUI") then PlayerGui.AdminGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdminGUI"
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,220,0,230)
    MainFrame.Position = UDim2.new(0.5,-110,0.5,-115)
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

    -- Tombol Fly
    local flying = false
    createButton("Fly",50,function()
        flying = not flying
        print("🛸 Fly: "..tostring(flying))
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if flying and hum and hrp then
            hum.PlatformStand = true
            spawn(function()
                while flying and hrp.Parent do
                    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector*1
                    wait(0.03)
                end
                if hum then hum.PlatformStand = false end
            end)
        end
    end)

    -- Tombol Speed
    createButton("Speed Boost",90,function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = hum.WalkSpeed + 16 end
    end)

    -- Tombol Teleport Spawn
    createButton("Teleport to Spawn",130,function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(Vector3.new(0,5,0)) end
    end)

    -- Tombol Teleport ke Checkpoint
    createButton("Teleport to Next Checkpoint",170,function()
        if #checkpoints == 0 then return end
        for _, cp in ipairs(checkpoints) do
            if not touchedCheckpoints[cp] then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(cp.Position + Vector3.new(0,5,0)) end
                touchedCheckpoints[cp] = true
                break
            end
        end
    end)
end

-- =========================
-- 4. Checkpoint Auto Teleport
-- =========================
local function setupTouch(part)
    if part:GetAttribute("TouchSetup") then return end
    part:SetAttribute("TouchSetup", true)
    part.Touched:Connect(function(hit)
        if hit.Parent and Players:GetPlayerFromCharacter(hit.Parent) == LocalPlayer then
            touchedCheckpoints[part] = true
        end
    end)
end

local function findCheckpoints()
    checkpoints = {}
    touchedCheckpoints = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:GetAttribute("CheckpointId")) then
            table.insert(checkpoints,obj)
            setupTouch(obj)
        end
    end
end

local function teleportTo(part)
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and part then
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,5,0))
        touchedCheckpoints[part] = true
    end
end

local function startAutoTeleport()
    if #checkpoints == 0 then return end
    autoEnabled = true
    spawn(function()
        while autoEnabled do
            local nextCp
            for _, cp in ipairs(checkpoints) do
                if not touchedCheckpoints[cp] then
                    nextCp = cp
                    break
                end
            end
            if not nextCp then break end
            teleportTo(nextCp)
            wait(2)
        end
        autoEnabled = false
    end)
end

-- =========================
-- 5. RemoteEvent untuk title
-- =========================
local AdminTitleEvent = ReplicatedStorage:WaitForChild("AdminTitleEvent")
AdminTitleEvent.OnClientEvent:Connect(function(targetPlayer)
    if targetPlayer.Character then
        createAdminTitle(targetPlayer.Character)
    end
end)

-- =========================
-- 6. Aktifkan semua untuk LocalPlayer
-- =========================
local function enableAdminMountFull()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    createAdminMount(char)
    createAdminAura(char)
    createAdminGUI()
    findCheckpoints()
end

enableAdminMountFull()
LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    wait(1)
    enableAdminMountFull()
end)
