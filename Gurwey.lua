-- ==========================================
-- KEREN HUB - BARISTA CUSTOM UI + SEATED TELEPORT BYPASS
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama kalau script-nya di-execute ulang
if PlayerGui:FindFirstChild("KerenHubBarista") then
    PlayerGui.KerenHubBarista:Destroy()
end

-- ==========================================
-- MEMBUAT CUSTOM UI (FLOATING WINDOW)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KerenHubBarista"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser-geser pakai mouse/jari!

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 65)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "☕ Keren Hub Barista"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Parent = MainFrame
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 0, 0, 35)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Status: Mati 🔴"
StatusText.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusText.TextSize = 11

-- Toggle Button (On/Off)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah (Off)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 62)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 32)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- ==========================================
-- LOGIC AUTO-FARM & STATE
-- ==========================================
local AutoBaristaEnabled = false
local CurrentState = "IDLE" 

local BaristaEvent = ReplicatedStorage:WaitForChild("BaristaAssets"):WaitForChild("Events"):WaitForChild("BaristaEvent")
local CurrentToken = nil

BaristaEvent.OnClientEvent:Connect(function(action, data)
    if action == "JobStarted" or action == "SpawnNPC" then
        if type(data) == "table" and data.Token then
            CurrentToken = data.Token
        end
    end
end)

-- Tangkap Notif Teks In-Game
PlayerGui.DescendantAdded:Connect(function(v)
    pcall(function()
        if AutoBaristaEnabled and (v:IsA("TextLabel") or v:IsA("TextButton")) then
            local text = v.Text
            if text:find("Shift di mulai") then CurrentState = "JOB_STARTED"
            elseif text:find("Npc") then CurrentState = "NPC_ARRIVED"
            elseif text:find("Sedang menyeduh") then CurrentState = "BREWING"
            elseif text:find("Pesanan sudah siap") then CurrentState = "READY"
            elseif text:find("Kerja bagus") then CurrentState = "DONE"
            end
        end
    end)
end)

local COORDS = {
    ShiftSpot     = CFrame.new(-4992.262, 4.287, -716.253),
    CoffeeMachine = CFrame.new(-4997.648, 4.287, -794.613),
    Customer      = CFrame.new(-4996.451, 4.287, -760.959)
}

-- 1. METODE "BAR GEDE" & AUTO CLICK (Jalan terus selama Toggle ON)
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if AutoBaristaEnabled then
                local baristaGui = PlayerGui:FindFirstChild("BaristaGUI")
                if baristaGui then
                    local targetZone = baristaGui:FindFirstChild("TargetZone", true)
                    if targetZone then
                        targetZone.Size = UDim2.new(targetZone.Size.X.Scale, targetZone.Size.X.Offset, 1, 0)
                    end
                    
                    for _, v in pairs(baristaGui:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("ImageButton")) and firesignal then
                            firesignal(v.MouseButton1Click)
                        end
                    end
                end
            end
        end)
    end
end)

-- 2. ANTI-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

local function selectBaristaJob()
    pcall(function()
        local Event = ReplicatedStorage:FindFirstChild("JobEvents") and ReplicatedStorage.JobEvents:FindFirstChild("TeamChangeRequest")
        if Event then Event:FireServer("Barista", 11378976, 1, 0, "Detector") end
    end)
end

-- 3. TRIK GACOR: SEATED TELEPORT (Bypass Anti-Cheat Instant Move)
local function seatedTeleport(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- Paksa status duduk agar server mendeteksinya sebagai status kendaraan/aman
        humanoid.Sit = true
        task.wait(0.05)

        -- Teleport instan CFrame ke lokasi tujuan
        hrp.CFrame = targetCFrame
        task.wait(0.1)

        -- Berdiri kembali
        humanoid.Sit = false
    end)
end

local function fireNearestPrompt()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Parent then
                local partPos = v.Parent:IsA("Model") and v.Parent.PrimaryPart and v.Parent.PrimaryPart.Position or (v.Parent:IsA("BasePart") and v.Parent.Position)
                if partPos and (partPos - hrp.Position).Magnitude <= 15 then
                    if fireproximityprompt then fireproximityprompt(v) end
                end
            end
        end
    end)
end

-- 4. MAIN AUTO-FARM THREAD
task.spawn(function()
    while true do
        if AutoBaristaEnabled then
            pcall(function()
                selectBaristaJob()
                task.wait(0.5)

                -- Step 1: Shift (Pakai Teleport Duduk)
                StatusText.Text = "Status: Ambil Shift..."
                seatedTeleport(COORDS.ShiftSpot)
                fireNearestPrompt()
                task.wait(0.3)

                -- Step 2: Brew Kopi
                if AutoBaristaEnabled then
                    StatusText.Text = "Status: Sedang Menyeduh..."
                    seatedTeleport(COORDS.CoffeeMachine)
                    BaristaEvent:FireServer("TryBrew")
                    task.wait(0.3)
                    if CurrentToken then
                        BaristaEvent:FireServer("CompleteMinigame", { ["Token"] = CurrentToken })
                    end
                    task.wait(0.5)
                end

                -- Step 3: Antar ke Pelanggan
                if AutoBaristaEnabled then
                    StatusText.Text = "Status: Mengantar Pesanan..."
                    seatedTeleport(COORDS.Customer)
                    BaristaEvent:FireServer("ServeOrder")
                    task.wait(0.5)
                end

                CurrentState = "IDLE"
                StatusText.Text = "Status: Siklus Selesai, Mengulang..."
            end)
        else
            StatusText.Text = "Status: Standby (Mati)"
            task.wait(0.5)
        end
        task.wait(0.5)
    end
end)

-- Tombol On / Off Callback
ToggleBtn.MouseButton1Click:Connect(function()
    AutoBaristaEnabled = not AutoBaristaEnabled
    if AutoBaristaEnabled then
        ToggleBtn.Text = "AUTO FARM: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Hijau
    else
        ToggleBtn.Text = "AUTO FARM: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Merah
        StatusText.Text = "Status: Dimatikan Manual"
    end
end)

print("[Keren Hub] Custom Floating UI + Seated Teleport Berhasil Dimuat!")
