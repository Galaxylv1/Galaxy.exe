local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔫 Rivals 🔫",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "👑 KJxHub 👑",
   LoadingSubtitle = "by KJ",
   Theme = "Serenity", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "KJx Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Rivals | Key",
      Subtitle = "Key System",
      Note = "Key:https://pastebin.com/raw/ZwcdizdA", -- Use this to tell the user how to get a key
      FileName = "HubKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/ZwcdizdA"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🔫🔫 | Aimbot", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Excuted Successfully",
   Content = "Very cool gui",
   Duration = 5,
   Image = nil,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},
})

local Toggle = Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- Place this script in a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local isRightMouseButtonDown = false -- Tracks right mouse button state
local fov = 90 -- Field of view radius

-- Function to find the closest player's head within the FOV circle
local function findClosestPlayerHeadInFOV()
    local closestHead = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headScreenPosition, onScreen = camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local distanceToCenter = (Vector2.new(headScreenPosition.X, headScreenPosition.Y) - centerScreen).Magnitude

                if distanceToCenter < fov and distanceToCenter < closestDistance then
                    closestHead = head
                    closestDistance = distanceToCenter
                end
            end
        end
    end

    return closestHead
end

-- Function to lock the camera onto a player's head
local function lockOnToHead()
    if isRightMouseButtonDown then
        local targetHead = findClosestPlayerHeadInFOV()
        if targetHead then
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
        end
    end
end

-- Listen for right mouse button press and release
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseButtonDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseButtonDown = false
    end
end)

-- Continuously lock-on while the right mouse button is held
RunService.RenderStepped:Connect(function()
    lockOnToHead()
end)

   end,
})
