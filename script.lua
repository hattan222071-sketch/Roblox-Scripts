-- Roblox - Steal an Egg Complete Script
-- GUI Library Integration

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal an Egg | Hub 🥚",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main Features 🚀", 4483362458)

-- Variables & Toggles
local AutoSteal = false
local AutoCollect = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- Auto Steal Function
MainTab:CreateToggle({
   Name = "Auto Steal Eggs 🥚",
   CurrentValue = false,
   Flag = "AutoStealFlag",
   Callback = function(Value)
      AutoSteal = Value
      task.spawn(function()
         while AutoSteal do
            pcall(function()
               for _, v in pairs(workspace:GetDescendants()) do
                  if v:IsA("ProximityPrompt") and string.find(string.lower(v.ObjectText or v.ActionText), "steal") then
                     fireproximityprompt(v)
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

-- Auto Collect Eggs Function
MainTab:CreateToggle({
   Name = "Auto Collect Nearby Eggs ✨",
   CurrentValue = false,
   Flag = "AutoCollectFlag",
   Callback = function(Value)
      AutoCollect = Value
      task.spawn(function()
         while AutoCollect do
            pcall(function()
               local char = game.Players.LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  for _, obj in pairs(workspace:GetChildren()) do
                     if string.find(string.lower(obj.Name), "egg") and obj:IsA("BasePart") then
                        obj.CFrame = char.HumanoidRootPart.CFrame
                     end
                  end
               end
            end)
            task.wait(0.5)
         end
      end)
   end,
})

local PlayerTab = Window:CreateTab("Player ⚡", 4483362458)

-- Speed Slider
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      WalkSpeedValue = Value
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- Jump Slider
PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      JumpPowerValue = Value
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

-- Re-apply on Respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
   char:WaitForChild("Humanoid")
   char.Humanoid.WalkSpeed = WalkSpeedValue
   char.Humanoid.JumpPower = JumpPowerValue
end)

Rayfield:Notify({
   Title = "Script Loaded",
   Content = "Steal an Egg Script is ready to use!",
   Duration = 5,
   Image = 4483362458,
})
