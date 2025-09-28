-- Server Script
-- Tempatkan script ini di ServerScriptService

local Players = game:GetService("Players")

-- Fungsi untuk menambahkan title di atas kepala pemain
local function setAdminTitle(player)
    -- Cek apakah pemain sudah punya BillboardGui, hapus dulu kalau ada
    if player.Character and player.Character:FindFirstChild("Head") then
        if player.Character:FindFirstChild("AdminTitle") then
            player.Character.AdminTitle:Destroy()
        end

        -- Buat BillboardGui
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "AdminTitle"
        billboard.Adornee = player.Character.Head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0) -- posisi di atas kepala
        billboard.AlwaysOnTop = true

        -- Buat TextLabel
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "🌄 Admin Gunung 🌄"
        textLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- warna emas
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold

        billboard.Parent = player.Character
    end
end

-- Tambahkan title ketika pemain bergabung
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        setAdminTitle(player)
    end)
end)

-- Jika ada pemain yang sudah di server saat script dijalankan
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        setAdminTitle(player)
    end
end
    MainFrame.Size = UDim2.new(0,250,0,280)
    MainFrame.Position = UDim2.new(0.5,-125,0.5,-140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,15)
    corner.Parent = MainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,35)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(40,40,55)
    title.BackgroundTransparency = 0.1
    title.Text = "👑 Admin Features"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = MainFrame
    local tcorner = Instance.new("UICorner")
    tcorner.CornerRadius = UDim.new(0,15)
    tcorner.Parent = title

    -- Function to create modern button
    local function createButton(text,posY,callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,220,0,30)
        btn.Position = UDim2.new(0,0,0,posY)
        btn.BackgroundColor3 = Color3.fromRGB(120,50,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.Text = text
        btn.Parent = MainFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = btn
        btn.MouseButton1Click:Connect(callback)

        -- Hover effect
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(180,80,255)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(120,50,255)
        end)
    end

    -- Fly
    local flying = false
    createButton("Fly",50,function()
        flying = not flying
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

    -- Speed Boost
    createButton("Speed Boost",90,function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = hum.WalkSpeed + 16 end
    end)

    -- Teleport Spawn
    createButton("Teleport to Spawn",130,function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(Vector3.new(0,5,0)) end
    end)

    -- Teleport Next Checkpoint
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

    -- Manual Checkpoint
    createButton("Add Checkpoint Manually",210,function()
        print("🖱️ Click a part to add checkpoint...")
        local mouse = LocalPlayer:GetMouse()
        local conn
        conn = mouse.Button1Down:Connect(function()
            local target = mouse.Target
            if target and target:IsA("BasePart") then
                if not table.find(checkpoints,target) then
                    table.insert(checkpoints,target)
                    touchedCheckpoints[target] = false
                    print("✅ Added manual checkpoint: "..target.Name)
                end
                conn:Disconnect()
            end
        end)
    end)

    -- Start Auto Teleport
    createButton("Start Auto Teleport",250,function()
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
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(nextCp.Position + Vector3.new(0,5,0))
                    touchedCheckpoints[nextCp] = true
                end
                wait(2)
            end
            autoEnabled = false
        end)
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
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("checkpoint") or obj:GetAttribute("CheckpointId")) then
            table.insert(checkpoints,obj)
            setupTouch(obj)
        end
    end
end

-- =========================
-- 5. RemoteEvent untuk title
-- =========================
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
    wait(1)
    enableAdminMountFull()
end)

print("✅ Modern Admin Mount + GUI + Auto Teleport script loaded!")
