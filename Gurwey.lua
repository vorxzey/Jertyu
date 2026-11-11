-- ==========================================
-- KEREN HUB - OFFICE WORKER (OFFICIAL WIND UI)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Load WindUI Library resmi dari GitHub repository Footagesus/WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

-- Buat Window Utama WindUI
local Window = WindUI:CreateWindow({
    Title = "Keren Hub • Office Worker",
    Icon = "briefcase",
    Author = "Auto Farm System",
    Folder = "KerenHubConfig",
    Size = UDim2.fromOffset(450, 300),
    Transparent = true,
    Theme = "Dark", -- Tema Gelap Minimalist
    SideBarWidth = 140,
    HasOutline = true,
})

-- Buat Tab Menu
local MainTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "home",
})

-- Section Status & Informasi
local StatusSection = MainTab:Section({
    Title = "Status Monitor",
    Content = "Menampilkan status pekerjaan kantor secara real-time.",
})

local StatusParagraph = StatusSection:Paragraph({
    Title = "Current Status",
    Desc = "Status: Standby (Mati 🔴)",
})

-- ==========================================
-- LOGIC AUTO-FARM OFFICE WORKER
-- ==========================================
local AutoOfficeEnabled = false
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

-- Dengerin event dari script game asli
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
    CurrentTargetComputer = computerName
    StatusParagraph:SetDesc("Status: Menuju ke " .. tostring(computerName))
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
    CurrentTargetComputer = nil
    StatusParagraph:SetDesc("Status: Tugas Selesai, Menunggu Print Baru...")
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

-- Interaksi ProximityPrompt Natural (Anti-Kick)
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

-- MAIN LOOP AUTO FARM
task.spawn(function()
    while true do
        if AutoOfficeEnabled then
            pcall(function()
                -- 1. Pastikan Masuk Tim Office Worker
                if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Office Worker") then
                    StatusParagraph:SetDesc("Status: Masuk ke Tim Office Worker...")
                    selectOfficeJob()
                end

                -- 2. Eksekusi Komputer / Printer yang Ditunjuk
                if CurrentTargetComputer then
                    local targetModel = ComputersFolder:FindFirstChild(CurrentTargetComputer)
                    if targetModel and targetModel:FindFirstChild("Part") then
                        local targetPart = targetModel.Part
                        local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")

                        StatusParagraph:SetDesc("Status: Berjalan ke " .. CurrentTargetComputer)
                        walkToPart(targetPart)
                        
                        task.wait(math.random(3, 5) / 10)
                        
                        if prompt and prompt.Enabled then
                            StatusParagraph:SetDesc("Status: Memproses Dokumen Printer...")
                            interactPrompt(prompt)
                        end
                    end
                else
                    StatusParagraph:SetDesc("Status: Standby Menunggu Job Printer...")
                end
            end)
        else
            StatusParagraph:SetDesc("Status: Standby (Mati 🔴)")
        end
        task.wait(1)
    end
end)

-- Tombol Toggle Menggunakan Komponen Asli WindUI
MainTab:Toggle({
    Title = "Auto Farm Office",
    Desc = "Otomatis ambil tugas print dan interaksi komputer",
    Value = false,
    Callback = function(state)
        AutoOfficeEnabled = state
        if AutoOfficeEnabled then
            StatusParagraph:SetDesc("Status: Auto Farm Aktif 🟢")
        else
            StatusParagraph:SetDesc("Status: Dimatikan Manual 🔴")
        end
    end
})

-- Notifikasi Berhasil Load
WindUI:Notify({
    Title = "Keren Hub Loaded",
    Content = "Script Office Worker menggunakan WindUI berhasil dimuat!",
    Duration = 3
})
