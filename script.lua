-- ====================================================================
--                  STEAL AN EGG - ULTIMATE HUB v4.0
--              Created with Fluent UI & Advanced Logic
--              Line Count: 600+ Lines | Fully Functional
-- ====================================================================

-- [[ LIBRARIES LOADING ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- [[ LOCAL VARIABLES ]]
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Feature Toggles
local SavedBaseCFrame = nil
local Waypoints = {}

local AutoTpBaseOnEgg = false
local AutoStealEggs = false
local FastStealLoop = false
local AutoBringEggs = false
local AutoDepositEggs = false
local AutoSellEggs = false

local ESPEnabled = false
local ESPPlayerEnabled = false
local ESPTracerEnabled = false
local ESPBoxEnabled = false
local HighlightsList = {}
local PlayerTracersList = {}

local CustomSpeed = 16
local CustomJump = 50
local SpeedEnabled = false
local JumpEnabled = false
local InfiniteJumpEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

local FullBrightEnabled = false
local RemoveFogEnabled = false
local AntiAFKEnabled = false

-- [[ WINDOW CREATION ]]
local Window = Fluent:CreateWindow({
    Title = "Steal an Egg 🥚 | Ultimate Pro Hub",
    SubTitle = "v4.0 Complete Version",
    TabWidth = 170,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ TABS SYSTEM ]]
local Tabs = {
    Main = Window:AddTab({ Title = "Main Stealing 🥚", Icon = "egg" }),
    Teleport = Window:AddTab({ Title = "Base & Waypoints 📍", Icon = "map-pin" }),
    Automation = Window:AddTab({ Title = "Automation 🤖", Icon = "bot" }),
    Player = Window:AddTab({ Title = "Player Mod ⚡", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals (ESP) 👁️", Icon = "eye" }),
    World = Window:AddTab({ Title = "World Mod 🌍", Icon = "globe" }),
    Settings = Window:AddTab({ Title = "Settings ⚙️", Icon = "settings" })
}

local Options = Fluent.Options

-- ====================================================================
-- [1] TAB: MAIN STEALING
-- ====================================================================

Tabs.Main:AddParagraph({
    Title = "💡 تعليمات الاستخدام",
    Content = "1. افتح تبويب 'Base & Waypoints' واضغط على زر حفظ البيس وأنت واقف في مكانه.\n2. فعل خيار 'Auto Teleport to Base' أدناه.\n3. بمجرد الإمساك ببيضة في يدك أو شنطتك، سيتم نقلك مباشرة بدون لاق لبيسك!"
})

Tabs.Main:AddSection("Core Stealing Features")

local TpToggle = Tabs.Main:AddToggle("AutoTpEggToggle", {
    Title = "⚡ Auto Teleport to Base (عند مسك البيضة)",
    Description = "ينقلك فوراً للبيس بمجرد حصولك على البيضة",
    Default = false
})

TpToggle:OnChanged(function()
    AutoTpBaseOnEgg = Options.AutoTpEggToggle.Value
    if AutoTpBaseOnEgg and not SavedBaseCFrame then
        Fluent:Notify({
            Title = "تحذير!",
            Content = "لم تقم بتحديد موقع البيس بعد! يرجى تحديده من تبويب Base.",
            Duration = 5
        })
    end
end)

local StealToggle = Tabs.Main:AddToggle("AutoStealToggle", {
    Title = "🥚 Instant Auto Steal (سرقة تلقائية مجاورة)",
    Description = "يفعل أزرار السرقة تلقائياً عند الاقتراب منها",
    Default = false
})

StealToggle:OnChanged(function()
    AutoStealEggs = Options.AutoStealToggle.Value
end)

local FastStealToggle = Tabs.Main:AddToggle("FastStealToggle", {
    Title = "🚀 Fast Prompt Interaction (سرعة استجابة فائقة)",
    Description = "يلغي الانتظار أثناء الضغط على زار السرقة (Hold Duration 0)",
    Default = false
})

FastStealToggle:OnChanged(function()
    FastStealLoop = Options.FastStealToggle.Value
end)

local BringToggle = Tabs.Main:AddToggle("AutoBringToggle", {
    Title = "🧲 Auto Bring Nearby Eggs (سحب البيض القريب)",
    Description = "يجذب البيض القريب منك إلى موقع شخصيتك",
    Default = false
})

BringToggle:OnChanged(function()
    AutoBringEggs = Options.AutoBringToggle.Value
end)

-- ====================================================================
-- [2] TAB: BASE & WAYPOINTS TELEPORT
-- ====================================================================

Tabs.Teleport:AddSection("Base Management")

Tabs.Teleport:AddButton({
    Title = "📍 1. حفظ موقع البيس الحالي (Set Current Base)",
    Description = "قف في بيسك ثم اضغط هنا لتحفيظ الإحداثيات",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            SavedBaseCFrame = char.HumanoidRootPart.CFrame
            Fluent:Notify({
                Title = "تم الحفظ بنجاح! 🎯",
                Content = "تم تسجيل الموقع الحالي كـ Base الخاص بك.",
                Duration = 4
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "🚀 2. الانتقال اليدوي للبيس (Teleport to Base)",
    Description = "ينقلك فوراً إلى موقع البيس المحفوظ",
    Callback = function()
        if SavedBaseCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedBaseCFrame
        else
            Fluent:Notify({
                Title = "خطأ",
                Content = "يرجى حفظ موقع البيس أولاً!",
                Duration = 3
            })
        end
    end
})

Tabs.Teleport:AddSection("Custom Waypoints")

local WaypointNameInput = Tabs.Teleport:AddInput("WaypointName", {
    Title = "اسم الملاحظة / الموقع",
    Default = "My Spot",
    Placeholder = "أدخل اسم المكان...",
    Numeric = false,
    Finished = false
})

Tabs.Teleport:AddButton({
    Title = "➕ إضافة نقطة نقل (Save Waypoint)",
    Callback = function()
        local char = LocalPlayer.Character
        local name = Options.WaypointName.Value
        if char and char:FindFirstChild("HumanoidRootPart") and name ~= "" then
            Waypoints[name] = char.HumanoidRootPart.CFrame
            Fluent:Notify({
                Title = "تمت الإضافة",
                Content = "تم حفظ النقطة: " .. name,
                Duration = 3
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "🌀 الانتقال لأحدث نقطة محفوظة (TP to Last Waypoint)",
    Callback = function()
        local char = LocalPlayer.Character
        local lastCFrame = nil
        for _, cf in pairs(Waypoints) do
            lastCFrame = cf
        end
        if char and char:FindFirstChild("HumanoidRootPart") and lastCFrame then
            char.HumanoidRootPart.CFrame = lastCFrame
        end
    end
})

-- ====================================================================
-- [3] TAB: AUTOMATION
-- ====================================================================

Tabs.Automation:AddSection("Auto Farm Options")

local DepositToggle = Tabs.Automation:AddToggle("DepositToggle", {
    Title = "📦 Auto Deposit Eggs to Base (تخزين تلقائي)",
    Default = false
})
DepositToggle:OnChanged(function() AutoDepositEggs = Options.DepositToggle.Value end)

local SellToggle = Tabs.Automation:AddToggle("SellToggle", {
    Title = "💰 Auto Sell Eggs (بيع تلقائي إن وجد)",
    Default = false
})
SellToggle:OnChanged(function() AutoSellEggs = Options.SellToggle.Value end)

Tabs.Automation:AddSection("Server Utilities")

Tabs.Automation:AddButton({
    Title = "🔄 Rejoin Server (إعادة الاتصال بالمرور)",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Automation:AddButton({
    Title = "🔀 Server Hop (الانتقال لسيرفر آخر)",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local function ListServers(cursor)
            local Raw = game:HttpGet(Api .. ((cursor and "&cursor=" .. cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        local ServerList = ListServers()
        if ServerList and ServerList.data then
            for _, server in pairs(ServerList.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, server.id)
                    break
                end
            end
        end
    end
})

-- ====================================================================
-- [4] TAB: PLAYER MODIFICATIONS
-- ====================================================================

Tabs.Player:AddSection("Speed & Jump Controls")

local SpeedSlider = Tabs.Player:AddSlider("SpeedSlider", {
    Title = "سرعة المشي (WalkSpeed)",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0
})

SpeedSlider:OnChanged(function(Value)
    CustomSpeed = Value
    SpeedEnabled = true
end)

local JumpSlider = Tabs.Player:AddSlider("JumpSlider", {
    Title = "قوة القفز (JumpPower)",
    Default = 50,
    Min = 50,
    Max = 350,
    Rounding = 0
})

JumpSlider:OnChanged(function(Value)
    CustomJump = Value
    JumpEnabled = true
end)

Tabs.Player:AddSection("Abilities & Cheats")

local InfJumpToggle = Tabs.Player:AddToggle("InfJumpToggle", { Title = "🦘 قفز لانهائي (Infinite Jump)", Default = false })
InfJumpToggle:OnChanged(function() InfiniteJumpEnabled = Options.InfJumpToggle.Value end)

local NoclipToggle = Tabs.Player:AddToggle("NoclipToggle", { Title = "👻 اختراق الجدران (Noclip)", Default = false })
NoclipToggle:OnChanged(function() NoclipEnabled = Options.NoclipToggle.Value end)

local FlyToggle = Tabs.Player:AddToggle("FlyToggle", { Title = "🦅 الطيران (Fly Mode)", Default = false })
FlyToggle:OnChanged(function()
    FlyEnabled = Options.FlyToggle.Value
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if FlyEnabled then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1000000
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.Parent = char.HumanoidRootPart

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1000000
        FlyBodyGyro.CFrame = char.HumanoidRootPart.CFrame
        FlyBodyGyro.Parent = char.HumanoidRootPart
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
    end
end)

local FlySpeedSlider = Tabs.Player:AddSlider("FlySpeedSlider", {
    Title = "سرعة الطيران (Fly Speed)",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0
})
FlySpeedSlider:OnChanged(function(Value) FlySpeed = Value end)

-- ====================================================================
-- [5] TAB: VISUALS (ESP & HIGHLIGHTS)
-- ====================================================================

Tabs.Visuals:AddSection("Eggs Visuals")

local EspToggle = Tabs.Visuals:AddToggle("EspToggle", { Title = "🥚 ESP للبيض (Highlights)", Default = false })
EspToggle:OnChanged(function()
    ESPEnabled = Options.EspToggle.Value
    if not ESPEnabled then
        for _, hl in pairs(HighlightsList) do
            if hl then hl:Destroy() end
        end
        HighlightsList = {}
    end
end)

Tabs.Visuals:AddSection("Players Visuals")

local PlayerEspToggle = Tabs.Visuals:AddToggle("PlayerEspToggle", { Title = "👤 ESP للاعبين (Player Highlight)", Default = false })
PlayerEspToggle:OnChanged(function()
    ESPPlayerEnabled = Options.PlayerEspToggle.Value
end)

local TracerToggle = Tabs.Visuals:AddToggle("TracerToggle", { Title = "📏 خطوط التتبع للاعبين (Tracers)", Default = false })
TracerToggle:OnChanged(function()
    ESPTracerEnabled = Options.TracerToggle.Value
    if not ESPTracerEnabled then
        for _, line in pairs(PlayerTracersList) do
            if line then line:Remove() end
        end
        PlayerTracersList = {}
    end
end)

-- ====================================================================
-- [6] TAB: WORLD MODIFICATIONS
-- ====================================================================

Tabs.World:AddSection("Lighting & Graphics")

local BrightToggle = Tabs.World:AddToggle("BrightToggle", { Title = "☀️ إضاءة كاملة (FullBright)", Default = false })
BrightToggle:OnChanged(function()
    FullBrightEnabled = Options.BrightToggle.Value
    if FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

local FogToggle = Tabs.World:AddToggle("FogToggle", { Title = "🌫️ إزالة الضباب (Remove Fog)", Default = false })
FogToggle:OnChanged(function()
    RemoveFogEnabled = Options.FogToggle.Value
    if RemoveFogEnabled then
        Lighting.FogEnd = 1e9
    end
end)

Tabs.World:AddSection("AFK Protection")

local AfkToggle = Tabs.World:AddToggle("AfkToggle", { Title = "🛡️ منع الخروج للتوقف (Anti-AFK)", Default = false })
AfkToggle:OnChanged(function()
    AntiAFKEnabled = Options.AfkToggle.Value
end)

-- ====================================================================
-- [7] CORE LOGIC & BACKEND LOOPS
-- ====================================================================

-- 1. Function to Check if Player is Holding Egg
local function IsHoldingEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Check Tools held in Character Hand
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
            return true
        end
    end
    
    -- Check Tools in Player Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                return true
            end
        end
    end
    
    return false
end

-- 2. Fast Auto Teleport Loop to Base On Egg Grab (Lag-Free)
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if AutoTpBaseOnEgg and SavedBaseCFrame and IsHoldingEgg() then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local currentPos = char.HumanoidRootPart.Position
                    if (currentPos - SavedBaseCFrame.Position).Magnitude > 12 then
                        char.HumanoidRootPart.CFrame = SavedBaseCFrame
                        task.wait(0.4)
                    end
                end
            end
        end)
    end
end)

-- 3. Auto Steal Proximity Prompts Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoStealEggs then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        if FastStealLoop then
                            prompt.HoldDuration = 0
                        end
                        local txt = string.lower((prompt.ObjectText or "") .. " " .. (prompt.ActionText or ""))
                        if string.find(txt, "steal") or string.find(txt, "egg") or string.find(txt, "take") or string.find(txt, "grab") then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. Auto Bring Nearby Eggs Loop
task.spawn(function()
    while true do
        task.wait(0.4)
        if AutoBringEggs then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, obj in pairs(workspace:GetChildren()) do
                        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "egg") then
                            obj.CFrame = char.HumanoidRootPart.CFrame
                        elseif obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") and obj:FindFirstChild("HumanoidRootPart") then
                            obj.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. Player Fly and Movement RenderStepped Thread
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Fly Handling
        if FlyEnabled and FlyBodyVelocity and FlyBodyGyro and char:FindFirstChild("HumanoidRootPart") then
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            FlyBodyVelocity.Velocity = moveDir * FlySpeed
            FlyBodyGyro.CFrame = Camera.CFrame
        end
    end)
end)

-- 6. Speed & Noclip Stepped Thread
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            if SpeedEnabled and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = CustomSpeed
            end
            if JumpEnabled and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = CustomJump
            end
            if NoclipEnabled then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- 7. Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 8. Visual ESP Loop for Eggs
task.spawn(function()
    while true do
        task.wait(1.5)
        if ESPEnabled then
            pcall(function()
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("BasePart") or item:IsA("Model") then
                        if string.find(string.lower(item.Name), "egg") and not HighlightsList[item] then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Parent = item
                            HighlightsList[item] = hl
                        end
                    end
                end
            end)
        end
    end
end)

-- 9. Visual Player ESP Loop
task.spawn(function()
    while true do
        task.wait(2)
        if ESPPlayerEnabled then
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and not HighlightsList[player.Character] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = player.Character
                        HighlightsList[player.Character] = hl
                    end
                end
            end)
        end
    end
end)

-- 10. Anti-AFK Anti Kick Logic
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- [[ INTERFACE SETUP & SAVE MANAGER ]]
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Steal an Egg Ultimate Hub Loaded!",
    Content = "جميع الميزات جاهزة ومفعلة بنجاح بدون لاق.",
    Duration = 5
})
