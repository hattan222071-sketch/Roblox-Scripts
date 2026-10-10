-- Steal an Egg - Optimized Script by Assistant
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal an Egg | Pro Hub 🥚",
   LoadingTitle = "Loading Fast Script...",
   LoadingSubtitle = "Optimized & Lag-Free",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main Features 🚀", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local basePosition = nil
local autoTeleportWithEgg = false
local autoSteal = false

-- 1. زر لتحديد مكان البيس الخاص بك
MainTab:CreateButton({
   Name = "📍 1. Set Current Position as Base (قف في بيسك واضغطه)",
   Callback = function()
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         basePosition = char.HumanoidRootPart.CFrame
         Rayfield:Notify({
            Title = "تم حفظ البيس بنجاح!",
            Content = "سيتم نقلك إلى هذا المكان فور الإمساك بالبيضة.",
            Duration = 3,
         })
      end
   end,
})

-- 2. ميزة النقل التلقائي للبيس أول ما تمسك البيضة بدون لاق
MainTab:CreateToggle({
   Name = "⚡ 2. Auto Teleport to Base When Holding Egg",
   CurrentValue = false,
   Flag = "AutoTpEgg",
   Callback = function(Value)
      autoTeleportWithEgg = Value
      task.spawn(function()
         while autoTeleportWithEgg do
            task.wait(0.15) -- خفيف جداً ولا يسبب أي لاق في السيرفر
            pcall(function()
               if not basePosition then return end
               local char = LocalPlayer.Character
               if not char or not char:FindFirstChild("HumanoidRootPart") then return end
               
               local hasEgg = false
               -- التحقق مما إذا كان اللاعب يمسك بيضة في يده أو حقيبته
               for _, item in pairs(char:GetChildren()) do
                  if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                     hasEgg = true
                     break
                  end
               end
               
               local bp = LocalPlayer:FindFirstChild("Backpack")
               if bp and not hasEgg then
                  for _, item in pairs(bp:GetChildren()) do
                     if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                        hasEgg = true
                        break
                     end
                  end
               end
               
               -- إذا مسك البيضة، يتم نقله فوراً لبيسه
               if hasEgg then
                  local rootPart = char.HumanoidRootPart
                  if (rootPart.Position - basePosition.Position).Magnitude > 15 then
                     rootPart.CFrame = basePosition
                     task.wait(0.5) -- مهلة بسيطة لمنع التكرار المزعج
                  end
               end
            end)
         end
      end)
   end,
})

-- 3. تجميع البيض التلقائي (Auto Steal) بدون مشاكل
MainTab:CreateToggle({
   Name = "🥚 3. Fast Auto Steal Prompts",
   CurrentValue = false,
   Flag = "AutoSteal",
   Callback = function(Value)
      autoSteal = Value
      task.spawn(function()
         while autoSteal do
            task.wait(0.2)
            pcall(function()
               for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ProximityPrompt") then
                     local txt = string.lower(v.ObjectText .. " " .. v.ActionText)
                     if string.find(txt, "steal") or string.find(txt, "take") or string.find(txt, "egg") then
                        fireproximityprompt(v)
                     end
                  end
               end
            end)
         end
      end)
   end,
})

-- تبويب السرعة واللاعبين
local PlayerTab = Window:CreateTab("Player ⚡", 4483362458)

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

Rayfield:Notify({
   Title = "Script Loaded Successfully",
   Content = "Enjoy lag-free stealing!",
   Duration = 4,
})
