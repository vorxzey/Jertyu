-- ==========================================
-- WIND UI POLOSAN (TEMPLATE DASAR)
-- ==========================================

-- Load WindUI Library resmi dari GitHub
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

-- Buat Window Utama
local Window = WindUI:CreateWindow({
    Title = "WindUI Template",
    Icon = "layout",
    Author = "Keren Hub",
    Folder = "WindUIConfig",
    Size = UDim2.fromOffset(450, 300),
    Transparent = true,
    Theme = "Dark", -- Tema Gelap Minimalist ala iOS
    SideBarWidth = 140,
    HasOutline = true,
})

-- Buat Tab Pertama
local Tab = Window:Tab({
    Title = "Home",
    Icon = "home",
})

-- Contoh Section
local Section = Tab:Section({
    Title = "General Section",
    Content = "Ini adalah bagian konten utama.",
})

-- Contoh Toggle Polosan
Section:Toggle({
    Title = "Contoh Toggle",
    Desc = "Status aktif atau mati",
    Value = false,
    Callback = function(state)
        print("Toggle state:", state)
    end
})

-- Contoh Button Polosan
Section:Button({
    Title = "Contoh Button",
    Desc = "Klik untuk tes fungsi",
    Callback = function()
        WindUI:Notify({
            Title = "Notifikasi",
            Content = "Tombol berhasil diklik!",
            Duration = 2
        })
    end
})

-- Notifikasi Berhasil Load
WindUI:Notify({
    Title = "Berhasil",
    Content = "WindUI Polosan berhasil dimuat!",
    Duration = 3
})
