-- ==========================================
-- KEREN HUB - OFFICE WORKER (STANDALONE GUI)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada
if PlayerGui:FindFirstChild("KerenHubOfficeUI") then
    PlayerGui.KerenHubOfficeUI:Destroy()
end

-- ==========================================
-- MEMBUAT TAMPILAN GUI MANUAL (ANTI GAGAL LOAD)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KerenHubOfficeUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Position = UDim2.new(0.5, -140, 0.15, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Header Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 14, 0, 12)
TitleLabel.Size = UDim2.new(1, -28, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "💼 Keren Hub • Office Worker"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status Card
local StatusCard = Instance.new("Frame")
StatusCard.Parent = MainFrame
StatusCard.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
StatusCard.Position = UDim2.new(0.06, 0, 0, 42)
StatusCard.Size = UDim2.new(0.88, 0, 0, 38)

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 10)
CardCorner.Parent = StatusCard

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusCard
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Status: Standby (Mati 🔴)"
StatusText.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusText.TextSize = 11
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(210, 45, 45)
ToggleBtn.Position = UDim2.new(0.06, 0, 0, 92)
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

-- ==========================================
-- LOGIC AUTO-FARM OFFICE WORKER
-- ==========================================
local AutoOfficeEnabled = false
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

-- Dengerin Event Game Asli
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
    CurrentTargetComputer = computerName
    StatusText.Text = "Job: " .. tostring(computerName)
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
    CurrentTargetComputer = nil
    StatusText.Text = "Status: Menunggu Job Baru..."
end)

-- Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- Join Team Office Worker
local function selectOfficeJob()
    pcall(function()
        local TeamChange = JobEvents:FindFirstChild("TeamChangeRequest")
        if TeamChange then
            TeamChange:FireServer("Office Worker", 11378976, 1, 0, "Detector")
            task.wait(2)
        end
    end)
end

-- Jalan Normal ke Printer Target
local function walkToPart(targetPart)
    pcall(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp or not targetPart then return end

        local targetPos = targetPart.Position
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
        humanoid:MoveTo(targetPos)
        
        local startTime = tick()
        while AutoOfficeEnabled and CurrentTargetComputer do
            local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist <= 4 or (tick() - startTime) > 8 then
                break
            end
            task.wait(0.2)
        end
    end)
end

-- Interaksi ProximityPrompt Natural
local function interactPrompt(prompt)
    if not prompt or not prompt.Enabled then return end
    
    local holdTime = prompt.HoldDuration or 0
    if holdTime > 0 then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        local elapsed = 0
        while elapsed < holdTime and AutoOfficeEnabled do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.3)
    else
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end
end

-- LOOP UTAMA
task.spawn(function()
    while true do
        if AutoOfficeEnabled then
            pcall(function()
                if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Office Worker") then
                    StatusText.Text = "Status: Masuk Tim Office..."
                    selectOfficeJob()
                end

                if CurrentTargetComputer then
                    local targetModel = ComputersFolder:FindFirstChild(CurrentTargetComputer)
                    if targetModel and targetModel:FindFirstChild("Part") then
                        local targetPart = targetModel.Part
                        local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")

                        StatusText.Text = "Menuju: " .. CurrentTargetComputer
                        walkToPart(targetPart)
                        
                        task.wait(math.random(3, 5) / 10)
                        
                        if prompt and prompt.Enabled then
                            StatusText.Text = "Memproses Dokumen..."
                            interactPrompt(prompt)
                        end
                    end
                else
                    StatusText.Text = "Status: Menunggu Print..."
                end
            end)
        else
            StatusText.Text = "Status: Standby (Mati 🔴)"
        end
        task.wait(1)
    end)
end)

-- Tombol On/Off Callback
ToggleBtn.MouseButton1Click:Connect(function()
    AutoOfficeEnabled = not AutoOfficeEnabled
    if AutoOfficeEnabled then
        ToggleBtn.Text = "AUTO FARM: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 200, 95)
    else
        ToggleBtn.Text = "AUTO FARM: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(210, 45, 45)
        StatusText.Text = "Status: Dimatikan Manual"
    end
end)

print("[Keren Hub] Office Worker Standalone UI Berhasil Dimuat!")
