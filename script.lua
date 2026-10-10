-- ====================================================================
--                  STEAL AN EGG - ULTIMATE HUB v3.0
--              Created with Fluent UI & Advanced Logic
-- ====================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
local SavedBaseCFrame = nil
local AutoTpBaseOnEgg = false
local AutoStealEggs = false
local AutoBringEggs = false
local ESPEnabled = false
local ESPConnections = {}
local HighlightInstances = {}

local CustomSpeed = 16
local CustomJump = 50
local SpeedEnabled = false
local JumpEnabled = false
local InfiniteJumpEnabled = false
local NoclipEnabled = false

-- Window Creation
local Window = Fluent:CreateWindow({
    Title = "Steal an Egg 🥚 | Ultimate Hub",
    SubTitle = "by Assistant",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs Configuration
local Tabs = {
    Main = Window:AddTab({ Title = "Main Stealing 🥚", Icon = "egg" }),
    Teleport = Window:AddTab({ Title = "Base & Waypoints 📍", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player Mod ⚡", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals (ESP) 👁️", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings ⚙️", Icon = "settings" })
}

local Options = Fluent.Options

-- ====================================================================
-- [1] TAB: MAIN STEALING
-- ====================================================================

Tabs.Main:AddParagraph({
    Title = "💡 طريقة العمل",
    Content = "1. اذهب لبيسك واضغط زر 'حفظ مكان البيس' في تبويب النقاط.\n2. فعل خيار النقل التلقائي لتنتقل فوراً إلى بيسك عند التقاط أو مسك أي بيضة."
})

-- Auto Teleport to Base Toggle
local TpToggle = Tabs.Main:AddToggle("AutoTpEggToggle", {
    Title = "⚡ Auto Teleport to Base (عند مسك البيضة)",
    Default = false
})

TpToggle:OnChanged(function()
    AutoTpBaseOnEgg = Options.AutoTpEggToggle.Value
    if AutoTpBaseOnEgg and not SavedBaseCFrame then
        Fluent:Notify({
            Title = "تحذير!",
            Content = "لم تقم بتحديد مكان البيس بعد! يرجى تحديده من تبويب Base & Waypoints.",
            Duration = 5
        })
    end
end)

-- Fast Auto Steal Prompts
local StealToggle = Tabs.Main:AddToggle("AutoStealToggle", {
    Title = "🥚 Auto Steal Prompts (سرقة تلقائية مجاورة)",
    Default = false
})

StealToggle:OnChanged(function()
    AutoStealEggs = Options.AutoStealToggle.Value
end)

-- Auto Bring Eggs Nearby
local BringToggle = Tabs.Main:AddToggle("AutoBringToggle", {
    Title = "🧲 Auto Bring Nearby Eggs (سحب البيض القريب)",
    Default = false
})

BringToggle:OnChanged(function()
    AutoBringEggs = Options.AutoBringToggle.Value
end)

-- ====================================================================
-- [2] TAB: BASE & TELEPORT WAYPOINTS
-- ====================================================================

Tabs.Teleport:AddSection("Base Position")

Tabs.Teleport:AddButton({
    Title = "📍 1. حفظ موقع البيس الحالي (Set Current Base)",
    Description = "قف في منتصف بيسك واضغط هذا الزر للتحفيظ",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            SavedBaseCFrame = char.HumanoidRootPart.CFrame
            Fluent:Notify({
                Title = "تم الحفظ بنجاح! 🎯",
                Content = "تم تسجيل الموقع كـ البيس الخاص بك.",
                Duration = 4
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "🚀 2. الانتقال اليدوي إلى البيس (Teleport to Base)",
    Description = "ينقلك مباشرة لموقع بيسك المحفوظ",
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

-- ====================================================================
-- [3] TAB: PLAYER MODIFICATIONS
-- ====================================================================

Tabs.Player:AddSection("Movement Customization")

local SpeedSlider = Tabs.Player:AddSlider("SpeedSlider", {
    Title = "سرعة المشي (WalkSpeed)",
    Description = "التعديل على سرعة الحركة",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0
})

SpeedSlider:OnChanged(function(Value)
    CustomSpeed = Value
    SpeedEnabled = true
end)

local JumpSlider = Tabs.Player:AddSlider("JumpSlider", {
    Title = "قوة القفز (JumpPower)",
    Description = "التعديل على ارتفاع القفزة",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0
})

JumpSlider:OnChanged(function(Value)
    CustomJump = Value
    JumpEnabled = true
end)

local InfJumpToggle = Tabs.Player:AddToggle("InfJumpToggle", { Title = "🦘 قفز لانهائي (Infinite Jump)", Default = false })
InfJumpToggle:OnChanged(function() InfiniteJumpEnabled = Options.InfJumpToggle.Value end)

local NoclipToggle = Tabs.Player:AddToggle("NoclipToggle", { Title = "👻 اختراق الجدران (Noclip)", Default = false })
NoclipToggle:OnChanged(function() NoclipEnabled = Options.NoclipToggle.Value end)

-- ====================================================================
-- [4] TAB: VISUALS & ESP
-- ====================================================================

Tabs.Visuals:AddSection("Highlights & ESP")

local EspToggle = Tabs.Visuals:AddToggle("EspToggle", { Title = "👁️ تفعيل ESP للبيض والأدوات", Default = false })
EspToggle:OnChanged(function()
    ESPEnabled = Options.EspToggle.Value
    if not ESPEnabled then
        for _, hl in pairs(HighlightInstances) do
            if hl then hl:Destroy() end
        end
        HighlightInstances = {}
    end
end)

-- ====================================================================
-- [5] CORE LOGIC & LOOPS (LAG-FREE)
-- ====================================================================

-- Check Egg holding logic
local function IsHoldingEgg()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Check Tool in Character
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
            return true
        end
    end
    
    -- Check Tool in Backpack
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

-- Teleport / Auto Egg Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if AutoTpBaseOnEgg and SavedBaseCFrame and IsHoldingEgg() then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local currentPos = char.HumanoidRootPart.Position
                    if (currentPos - SavedBaseCFrame.Position).Magnitude > 15 then
                        char.HumanoidRootPart.CFrame = SavedBaseCFrame
                        task.wait(0.4)
                    end
                end
            end
        end)
    end
end)

-- Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.25)
        if AutoStealEggs then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local text = string.lower((prompt.ObjectText or "") .. " " .. (prompt.ActionText or ""))
                        if string.find(text, "steal") or string.find(text, "egg") or string.find(text, "take") then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Bring Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoBringEggs then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(workspace:GetChildren()) do
                        if part:IsA("BasePart") and string.find(string.lower(part.Name), "egg") then
                            part.CFrame = char.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- Player Properties Render Loop
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

-- Infinite Jump Event
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ESP Functionality Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if ESPEnabled then
            pcall(function()
                for _, item in pairs(workspace:GetChildren()) do
                    if string.find(string.lower(item.Name), "egg") and not HighlightInstances[item] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = item
                        HighlightInstances[item] = hl
                    end
                end
            end)
        end
    end
end)

-- Auto Load & Setup Interface Settings
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Steal an Egg Hub Loaded!",
    Content = "استمتع بأداء سريع وبدون لاق.",
    Duration = 5
})
