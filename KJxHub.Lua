--// Services
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

--// Libraries
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
local EspLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/x114/RobloxScripts/main/OpenSourceEsp"))()
local WebhookURL = "https://discord.com/api/webhooks/1313994383225393273/8mQC9mq-cMcqpi3RxY-WK89tKqatIzK-RbnJnu9KT-VV-vZbk7WFL2zqadaJNevzk9ti"

--// Variables
local Script = {
    version = "v2.0.15",
    ver_name = "FREE"
}
local Window = Library:CreateWindow{
    Title = Script.version.." "..Script.ver_name.." | StechHub",
    SubTitle = "discord.gg/TFMa5taUn5",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 700),
    Resize = true,
    MinSize = Vector2.new(300, 350),
    Acrylic = false,
    Theme = "Viow Arabian Mix",
    MinimizeKey = Enum.KeyCode.RightShift,
    Transparent = false
}


local work = false
local _Path = "StechHub"
local _RivalsPath = _Path.."/Rivals"
local _ConfigPath = _RivalsPath.."/settings" -- stechRivals/settings
makefolder(_ConfigPath)
local MaterialsList = {}
for index, value in Enum.Material:GetEnumItems() do
    table.insert(MaterialsList, tostring(string.gsub(tostring(value), "Enum.Material.", "")))
end
local EnabledDisabled = {
    ["true"] = "Enabled",
    ["false"] = "Disabled"
}
local SilentAim = {
    Enabled = false,
    HitChance = 100,
    AimPart = {"HumanoidRootPart"},
    WallCheck = false,
    Keybind = "T",
    NotWorkIfFlashed = false
}
local AimLock = {
    Enabled = false,
    Prediction = 0.1,
    Holding = false,
    AimPart = "Head"
}
local AutoFire = {
    Enabled = false,
    FireDelay = 0,
    FireCooldown = 0
}
local TriggerBot = {
    Enabled = false,
    FireDelay = 0,
    HealthCheck = false
}
local Visuals = {
    WorldReflectance = false,
    Reflectance = 0.25,
    WorldColor = Lighting.Ambient,
    ESP = false,
    CustomTime = false,
    Time = 0,
    ThirdPerson = false,
    NeonLight = false,
    NeonLightRange = 15,
    NeonLightBrightness = 2,
    OldTime = Lighting.ClockTime,
    AntiFlashbang = false,
    GrenadeChams = false
}
local ViewModels = {
    NoHands = false,
    CustomMaterial = false,
    GunMaterial = Enum.Material.Neon,
    GunMaterialList = MaterialsList,
    CustomColor = false,
    GunColor = Color3.fromRGB(255,255,255)
}
local Misc = {
    DisableAnim = false,
    FastSpeedEnabled = false,
    FastSpeedMultiplier = 0
}
local ConfigTable = {
    ConfigSelected = nil,
    ConfigList = {},
    ConfigName = ".json"
}

--// Sounds
for _, sound in game:GetService("SoundService"):GetChildren() do
    if sound:IsA("Sound") then
        if sound.SoundId == "rbxassetid://15675059323" then
            sound:Destroy()
        end
    end
end

local TurnOn = Instance.new("Sound")
TurnOn.SoundId = "rbxassetid://15675059323"
TurnOn.Parent = game:GetService("SoundService")
TurnOn.Volume = 1.5

local TurnOff = Instance.new("Sound")
TurnOff.SoundId = "rbxassetid://15675059323"
local pitch = Instance.new("PitchShiftSoundEffect", TurnOff)
pitch.Octave = 0.9
pitch.Enabled = true
TurnOff.Parent = game:GetService("SoundService")
TurnOff.Volume = 1.5

--// Drawing FOV
local AimLockFov = Drawing.new("Circle")
AimLockFov.Filled = false
AimLockFov.Transparency = 1
AimLockFov.Thickness = 1
AimLockFov.Color = Color3.fromRGB(0, 0, 255)
AimLockFov.NumSides = 1000
AimLockFov.Radius = 70
AimLockFov.Visible = false
local SilentAimFov = Drawing.new("Circle")
SilentAimFov.Filled = false
SilentAimFov.Transparency = 1
SilentAimFov.Thickness = 1
SilentAimFov.Color = Color3.fromRGB(255, 0, 0)
SilentAimFov.NumSides = 1000
SilentAimFov.Radius = 60
SilentAimFov.Visible = false

--// Funcs
function SendWebhook(content_msg)
    local MessageData = {
        ["content"] = content_msg
    }
    local JsonData = HttpService:JSONEncode(MessageData)
    local Request = http_request
    local ToPost = {Url = WebhookURL, Body = JsonData, Method = "POST", Headers = {["content-type"] = "application/json"}}
    Request(ToPost)
end
function Notify(Title, Content)
    Library:Notify({
        Title = Title,
        Content = Content,
        Duration = 2.5
    })
end
function IsVisible(character, part)
    return #workspace.CurrentCamera:GetPartsObscuringTarget({ character.Head.Position }, { workspace.CurrentCamera, game:GetService("Players").LocalPlayer.Character}) == 2
end
function GetClosestPlayerToMouse(vis, radius)
    local closestPlayer = nil
    local shortestDistance = math["huge"]
    local mousePosition = UIS:GetMouseLocation()

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local hrp = player.Character.HumanoidRootPart
            local hrpPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            
            if player.Character.Humanoid.Health ~= 0 then
                if onScreen then
                    local screenPosition = Vector2.new(hrpPosition.X, hrpPosition.Y)
                    local distance = (screenPosition - mousePosition).Magnitude
    
                    if distance < shortestDistance then
                        if vis then
                            if distance <= radius then
                                closestPlayer = player
                                shortestDistance = distance
                                continue
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance
                            continue
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end
function LookAt(target)
    workspace.CurrentCamera.CFrame = CFrame.lookAt(
        workspace.CurrentCamera.CFrame.Position,
        target.Position
    )
end
function LockAt(target)
    workspace.Camera.CFrame = CFrame.new(
        workspace.Camera.CFrame.Position,
        target.Position + 
        target.Velocity * AimLock.Prediction
    )
end
function GetSilentAimPart(Player)
    local closestPart = nil
    local shortestDistance = math["huge"]
    local mousePos = UIS:GetMouseLocation()

    for _, PartName in SilentAim.AimPart do
        local part = Player.Character[PartName]
        if part ~= nil then
            local partPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenPos = Vector2.new(partPos.X, partPos.Y)
                local distance = (screenPos - mousePos).Magnitude
    
                if distance < shortestDistance then
                    closestPart = part
                    shortestDistance = distance
                end
            end 
        end
    end 
    
    return closestPart
end
function SilentAimUIS(io:InputObject, gameProcessedEvent)
    if not gameProcessedEvent then
        if io.UserInputType == Enum.UserInputType.MouseButton1 and SilentAim.Enabled then
            local percentage = math.random(0, 100)
            if percentage <= SilentAim.HitChance then
                local closestPlayer = GetClosestPlayerToMouse(SilentAimFov.Visible, tonumber(SilentAimFov.Radius))
                if closestPlayer ~= nil then
                    if SilentAim.NotWorkIfFlashed then
                        if Lighting:FindFirstChild("Flashbang") then
                            return
                        end
                    end
                    local target = GetSilentAimPart(closestPlayer)
                    LookAt(target)
                end
            end
        end
    end 
end
function LockAimFunc(value)
    if not work then return end
    AimLock.Enabled = value
    if AimLock.Enabled then
        while task.wait() do
            if AimLock.Enabled then
                local Player = GetClosestPlayerToMouse(AimLockFov.Visible, tonumber(AimLockFov.Radius))
                if Player then
                    local Part = Player.Character[AimLock.AimPart]
                    LockAt(Part)
                end
            end
        end
    end
end
function IsHovering(Target)
    if Target.Name == "HitboxBody" or Target.Name == "HitboxHead" then
        return Target.Parent
    else
        return false
    end
end
function TriggerBotEnable()
    if TriggerBot.Enabled then
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        while task.wait() do
            if TriggerBot.Enabled then
                local Character = IsHovering(mouse.Target)
                if Character ~= false then
                    if TriggerBot.HealthCheck then
                        if Character.Humanoid.Health ~= 0 then
                            task.wait(TriggerBot.FireDelay)
                            mouse1click()
                        end
                    else
                        task.wait(TriggerBot.FireDelay)
                        mouse1click()
                    end
                end
            end
        end
    end
end
function MakeWorldReflectance(value)
    if not work then return end
    Visuals.WorldReflectance = value
    for _, obj : Part in game:GetDescendants() do
        if value then
            pcall(function()
                if obj.Reflectance == 0 then
                    obj.Reflectance = Visuals.Reflectance
                end
            end)
        else
            pcall(function()
                obj.Reflectance = 0
            end)
        end
    end
end
function ChangeWorldColor(value)
    if not work then return end
    Lighting.Ambient = value
    Visuals.WorldColor = value
end
function GetPlayerViewModels()
    if workspace:FindFirstChild("ViewModels") then
        local ViewModelsObject = workspace.ViewModels
        if ViewModelsObject.FirstPerson:GetChildren()[1] ~= nil then
            local PlayerViewModels = ViewModelsObject.FirstPerson:GetChildren()[1]
            return PlayerViewModels
        else
            return nil
        end
    else
        return nil
    end
end
function HandsToggle(value)
    if not work then return end
    ViewModels.HandsEnabled = value
    while task.wait() do
        local PlayerViewModels = GetPlayerViewModels()
        if PlayerViewModels ~= nil then
            if ViewModels.HandsEnabled then
                PlayerViewModels.LeftArm.Mesh.Offset = Vector3.new(0,0,9999)
                PlayerViewModels.RightArm.Mesh.Offset = Vector3.new(0,0,9999)
            else
                PlayerViewModels.LeftArm.Mesh.Offset = Vector3.new(0,0,0)
                PlayerViewModels.RightArm.Mesh.Offset = Vector3.new(0,0,0)
            end
        end
    end
end
function CustomGunMaterial(value)
    if not work then return end
    ViewModels.CustomMaterial = value
    while task.wait(.1) do
        local PlayerViewModels = GetPlayerViewModels()
        if PlayerViewModels ~= nil then
            if ViewModels.CustomMaterial then
                for _, obj in PlayerViewModels:GetDescendants() do
                    if obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("UnionOperation") then
                        obj.Material = ViewModels.GunMaterial
                    end
                end
            end
        end
    end
end
function CustomGunColor(value)
    if not work then return end
    ViewModels.CustomColor = value
    while task.wait(.1) do
        local PlayerViewModels = GetPlayerViewModels()
        if PlayerViewModels ~= nil then
            if ViewModels.CustomColor then
                for _, obj in PlayerViewModels:GetDescendants() do
                    if obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("UnionOperation") then
                        obj.Color = ViewModels.GunColor
                    end
                end
            end
        end
    end
end
function ThirdpersonEnable(value)
    Visuals.ThirdPerson = value
    if Visuals.ThirdPerson then
        while task.wait() do
            if Visuals.ThirdPerson then
                local camera = workspace.CurrentCamera
                camera.Position = camera.Position + Vector3.new(0,0,20)
            end
        end
    end
end
function NeonLight(value)
    if not work then return end
    Visuals.NeonLight = value
    if Visuals.NeonLight then
        for _, NeonPart in game:GetDescendants() do
            if NeonPart:IsA("Part") or NeonPart:IsA("MeshPart") or NeonPart:IsA("UnionOperation") then
                if not NeonPart:FindFirstChild("NeonLight_Stech") and NeonPart.Material == Enum.Material.Neon then
                    local Light = Instance.new("PointLight", NeonPart)
                    Light.Name = "NeonLight_Stech"
                    Light.Shadows = true
                    Light.Color = NeonPart.Color
                    Light.Range = Visuals.NeonLightRange
                    Light.Brightness = Visuals.NeonLightBrightness
                end
            end
        end
    else
        for _, NeonPart in game:GetDescendants() do
            if NeonPart:IsA("Part") or NeonPart:IsA("MeshPart") or NeonPart:IsA("UnionOperation") then
                if NeonPart:FindFirstChild("NeonLight_Stech") and NeonPart.Material == Enum.Material.Neon then
                    NeonPart:FindFirstChild("NeonLight_Stech"):Destroy()
                end
            end
        end
    end
end
function AntiFlashbangFunc(child)
    if Visuals.AntiFlashbang then
        if child.Name == "Flashbang" then
            child.Enabled = false
            game:GetService("Players").LocalPlayer.PlayerGui["FlashbangGui"]:Destroy()
        end 
    end
end
function GrenadeChamsFunc(child)
    if Visuals.GrenadeChams then
        local GrenadeNames = {"Grenade", "Flashbang", "Molotov", "Smoke Grenade"}
        if table.find(GrenadeNames, child.Name) then
            local esp = Instance.new("Highlight", child)
            esp.OutlineTransparency = 1
        end 
    end
end
function DisableAnimationScriptFunc(value)
    if not work then return end
    Misc.DisableAnim = value
    if Misc.DisableAnim then
        while task.wait(.1) do
            if Misc.DisableAnim then
                pcall(function()
                    game:GetService("Players").LocalPlayer.Character.Animate.Enabled = false
                end)
            end
        end
    else
        game:GetService("Players").LocalPlayer.Character.Animate.Enabled = true
    end
end
function SetHumanoidCFrame(multiplier)
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame += game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * multiplier
end
function FastSpeedFunc(value)
    if not work then return end
    Misc.FastSpeedEnabled = value
    if Misc.FastSpeedEnabled then
        while task.wait() do
            if Misc.FastSpeedEnabled then
                if game:GetService("Players").LocalPlayer.Character ~= nil and game:GetService("Players").LocalPlayer.Character.Humanoid ~= nil then
                    if game:GetService("Players").LocalPlayer.Character.Humanoid.Health ~= 0 then
                        SetHumanoidCFrame(Misc.FastSpeedMultiplier)
                    end
                end
            end
        end
    end
end
function AutoFireFunc(value)
    AutoFire.Enabled = value
    if AutoFire.Enabled then
        while task.wait() do
            if AutoFire.Enabled then
                local NearestPlayer = GetClosestPlayerToMouse(false, 1000)
                if NearestPlayer ~= nil then
                    task.wait(AutoFire.FireDelay)
                    mouse1click()
                    task.wait(AutoFire.FireCooldown)
                end
            end
        end
    end
end

--// Connections
UIS.InputBegan:Connect(SilentAimUIS)
Lighting.ChildAdded:Connect(AntiFlashbangFunc)

--// Tabs
local AimTab = Window:CreateTab{
    Title = "Aim Bot",
    Icon = "target"
}
local VisualsTab = Window:CreateTab{
    Title = "Visuals",
    Icon = "eye"
}
local ModelsChangerTab = Window:CreateTab{
    Title = "Models Changer",
    Icon = "sword"
}
local MiscTab = Window:CreateTab{
    Title = "Misc",
    Icon = "banana"
}
local ConfigTab = Window:CreateTab{
    Title = "Config",
    Icon = "folder"
}
local CreditsTab = Window:CreateTab{
    Title = "Credits",
    Icon = "book"
}

--// LockAim
-- local LockAimSection = AimTab:CreateSection("Aim Lock")
-- local LockAimToggle = AimTab:CreateToggle(
--     "LockAimToggle",
--     {
--         Title = "Enabled",
--         Default = false,
--         Callback = LockAimFunc
--     }
-- )
-- local LockAimKeybind = AimTab:CreateKeybind(
--     "LockAimKeybind",
--     {
--         Title = "Keybind",
--         Mode = "Toggle",
--         Default = "Y",
--         Callback = function()
--             LockAimToggle:SetValue(not AimLock.Enabled)
--             if AimLock.Enabled then
--                 TurnOn.Playing = true
--             else
--                 TurnOff.Playing = true
--             end
--             Notify("Lock Aim", EnabledDisabled[tostring(AimLock.Enabled)])
--         end
--     }
-- )
-- local AimLockFovVisible = AimTab:CreateToggle(
--     "AimLockFovVisible",
--     {
--         Title = "FOV Enabled",
--         Default = false,
--         Callback = function(value)
--             if not work then return end
--             AimLockFov.Visible = value
--             while task.wait() do
--                 AimLockFov.Position = game:GetService("UserInputService"):GetMouseLocation()
--             end
--         end
--     }
-- )
-- local AimLockFovRadius = AimTab:CreateSlider(
--     "AimLockFovRadius", {
--     Title = "FOV Radius",
--     Default = AimLockFov.Radius,
--     Min = 0,
--     Max = 1000,
--     Rounding = 0,
--     Callback = function(value)
--         AimLockFov.Radius = value
--     end
-- })
-- local AimLockFovVisibleFovColor = AimTab:CreateColorpicker(
--     "SilentAimFovColor", {
--     Title = "FOV Color",
--     Default = Color3.fromRGB(0, 0, 255),
--     Callback = function(value)
--         AimLockFov.Color = value
--     end
-- })
-- local AimLockHitPrediction = AimTab:CreateSlider(
--     "AimLockHitPrediction", {
--     Title = "Prediction",
--     Default = 0,
--     Min = 0,
--     Max = 1.4,
--     Rounding = 3,
--     Callback = function(value)
--         AimLock.Prediction = value
--     end
-- })
-- local AimLockPart = AimTab:CreateDropdown(
--     "AimLockPart", {
--     Title = "Aim Part",
--     Values = {"HumanoidRootPart", "Head"},
--     Multi = false,
--     Default = 1,
--     }
-- )
-- AimLockPart:OnChanged(function(value)
--     AimLock.AimPart = value
-- end)

--// SilentAim
local SilentAimSection = AimTab:CreateSection("Silent Aim")
local SilentAimToggle = AimTab:CreateToggle(
    "SilentAimToggle",
    {
        Title = "Enabled (YOU NEED TO SPAM TO MAKE IT WORK!)",
        Default = false,
        Callback = function(value)
            SilentAim.Enabled = value
        end
    }
)
local SilentAimKeybind = AimTab:CreateKeybind(
    "SilentAimKeybind",
    {
        Title = "Keybind",
        Mode = "Toggle",
        Default = "T",
        Callback = function()
            SilentAimToggle:SetValue(not SilentAim.Enabled)
            if SilentAim.Enabled then
                TurnOn.Playing = true
            else
                TurnOff.Playing = true
            end
            Notify("Silent Aim", EnabledDisabled[tostring(SilentAim.Enabled)])
        end
    }
)
local SilentAimFovVisible = AimTab:CreateToggle(
    "SilentAimFovVisible",
    {
        Title = "FOV Enabled",
        Default = false,
        Callback = function(value)
            if not work then return end
            SilentAimFov.Visible = value
            while task.wait() do
                SilentAimFov.Position = game:GetService("UserInputService"):GetMouseLocation()
            end
        end
    }
)
local SilentAimFovRadius = AimTab:CreateSlider(
    "SilentAimFovRadius", {
    Title = "FOV Radius",
    Default = SilentAimFov.Radius,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        SilentAimFov.Radius = value
    end
})
local SilentAimFovColor = AimTab:CreateColorpicker(
    "SilentAimFovColor", {
    Title = "FOV Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        SilentAimFov.Color = value
    end
})
local SilentAimHitChance = AimTab:CreateSlider(
    "SilentAimHitChance", {
    Title = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        SilentAim.HitChance = value
    end
})
local SilentAimPart = AimTab:CreateDropdown(
    "SilentAimPart", {
    Title = "Aim Parts",
    Values = {"HumanoidRootPart", "Head", "RightUpperArm", "LeftUpperArm", "RightLowerLeg", "LeftLowerLeg"},
    Multi = true,
    Default = {"HumanoidRootPart"},
    }
)
SilentAimPart:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        table.insert(Values, Value)
    end
    
    SilentAim.AimPart = Values
end)
local NotWorkIfFlashedToggle = AimTab:CreateToggle(
    "NotWorkIfFlashedToggle",
    {
        Title = "Not Work if Flashed",
        Default = false,
        Callback = function(value)
            SilentAim.NotWorkIfFlashed = value
        end
    }
)

--// Auto Fire
-- AimTab:CreateSection("Auto Fire")
-- local AutoFireEnabled = AimTab:CreateToggle(
--     "AutoFireEnabled",
--     {
--         Title = "Enabled",
--         Default = false,
--         Callback = AutoFireFunc
--     }
-- )
-- local AutoFireKeybind = AimTab:CreateKeybind(
--     "AutoFireKeybind",
--     {
--         Title = "Keybind",
--         Mode = "Toggle",
--         Default = "Q",
--         Callback = function()
--             AutoFireEnabled:SetValue(not AutoFire.Enabled)
--             if AutoFire.Enabled then
--                 TurnOn.Playing = true
--             else
--                 TurnOff.Playing = true
--             end
--             Notify("Auto Fire", EnabledDisabled[tostring(AutoFire.Enabled)])
--         end
--     }
-- )
-- local AutoFireDelay = AimTab:CreateSlider(
--     "TriggerBotDelay", {
--     Title = "Fire Delay",
--     Default = 0,
--     Min = 0,
--     Max = 2,
--     Rounding = 3,
--     Callback = function(value)
--         AutoFire.FireDelay = value
--     end
-- })
-- local AutoFireCooldown = AimTab:CreateSlider(
--     "AutoFireCooldown", {
--     Title = "Fire Cooldown",
--     Default = 0,
--     Min = 0,
--     Max = 2,
--     Rounding = 3,
--     Callback = function(value)
--         AutoFire.FireCooldown = value
--     end
-- })

--// TriggerBot
local TriggerBotSection = AimTab:CreateSection("Trigger Bot")
local TriggerBotToggle = AimTab:CreateToggle(
    "TriggerBotToggle",
    {
        Title = "Enabled",
        Default = false,
        Callback = function(value)
            if not work then return end
            TriggerBot.Enabled = value
            if TriggerBot.Enabled then
                TriggerBotEnable()
            end
        end
    }
)
local TriggerBotKeybind = AimTab:CreateKeybind(
    "TriggerBotKeybind",
    {
        Title = "Keybind",
        Mode = "Toggle",
        Default = "Z",
        Callback = function()
            TriggerBotToggle:SetValue(not TriggerBot.Enabled)
            if TriggerBot.Enabled then
                TurnOn.Playing = true
            else
                TurnOff.Playing = true
            end
            Notify("Trigger Bot", EnabledDisabled[tostring(TriggerBot.Enabled)])
        end
    }
)
local TriggerBotDelay = AimTab:CreateSlider(
    "TriggerBotDelay", {
    Title = "Fire Delay",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        TriggerBot.FireDelay = value
    end
})
local TriggerBotHealthCheck = AimTab:CreateToggle(
    "TriggerBotHealthCheck",
    {
        Title = "Health Check",
        Default = false,
        Callback = function(value)
            TriggerBot.HealthCheck = value
        end
    }
)

--// ESP Setup
EspLib.Box = false
EspLib.BoxColor = Color3.fromRGB(255,255,255)
EspLib.BoxOutline = false
EspLib.BoxOutlineColor = Color3.fromRGB(0,0,0)
EspLib.HealthBar = false
EspLib.HealthBarSide = "Left"
EspLib.Names = false
EspLib.NamesColor = Color3.fromRGB(255,255,255)
EspLib.NamesOutline = true
EspLib.NamesFont = 2
EspLib.NamesSize = 17

--// ESP
local EspSection = VisualsTab:CreateSection("ESP")
local EspToggle = VisualsTab:CreateToggle(
    "EspToggle",
    {
        Title = "Enabled",
        Default = false,
        Callback = function(value)
            EspLib.Box = value
        end
    }
)
local EspBoxColorPicker = VisualsTab:CreateColorpicker(
    "EspBoxColorPicker", {
    Title = "Color",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(value)
        EspLib.BoxColor = value
        EspLib.NameColor = value
    end
})
local EspHealthBarToggle = VisualsTab:CreateToggle(
    "EspHealthBarToggle",
    {
        Title = "Health Bar",
        Default = false,
        Callback = function(value)
            EspLib.HealthBar = value
        end
    }
)
local HealthBarPosDropdown = VisualsTab:CreateDropdown(
    "HealthBarPosDropdown", {
    Title = "Health Bar Position",
    Values = {"Left", "Bottom", "Right"},
    Multi = false,
    Default = 1,
    }
)
HealthBarPosDropdown:OnChanged(function(value)
    EspLib.HealthBarSide = value
end)
local EspNamesToggle = VisualsTab:CreateToggle(
    "EspNamesToggle",
    {
        Title = "Names",
        Default = false,
        Callback = function(value)
            EspLib.Names = value
        end
    }
)
-- local GrenadesChamsToggle = VisualsTab:CreateToggle(
--     "GrenadesChamsToggle",
--     {
--         Title = "Grenades Chams",
--         Default = false,
--         Callback = function(value)
--             Visuals.GrenadeChams = value
--         end
--     }
-- )

local VisualsSection = VisualsTab:CreateSection("World")
local AntiFlashbangToggle = VisualsTab:CreateToggle(
    "AntiFlashbangToggle",
    {
        Title = "Anti Flashbang",
        Default = false,
        Callback = function(value)
            Visuals.AntiFlashbang = value
        end
    }
)
local WorldReflectanceToggle = VisualsTab:CreateToggle(
    "WorldReflectanceToggle",
    {
        Title = "World Reflectance",
        Default = false,
        Callback = MakeWorldReflectance
    }
)
local ReflectanceSlider = VisualsTab:CreateSlider(
    "ReflectanceSlider", {
    Title = "Reflectance",
    Default = 0.25,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Visuals.Reflectance = value
    end
})
local WorldColorPicker = VisualsTab:CreateColorpicker(
    "WorldColorPicker", {
    Title = "World Color",
    Default = Lighting.Ambient,
    Callback = ChangeWorldColor
})
local CustomTimeToggle = VisualsTab:CreateToggle(
    "CustomTimeToggle",
    {
        Title = "Custom Time",
        Default = false,
        Callback = function(value)
            if not work then return end
            Visuals.CustomTime = value
            
            if Visuals.CustomTime then
                Visuals.OldTime = Lighting.ClockTime
                Lighting.ClockTime = Visuals.Time
            else
                Lighting.ClockTime = Visuals.OldTime
            end
        end
    }
)
local CustomTimeSlider = VisualsTab:CreateSlider(
    "CustomTimeSlider", {
    Title = "ClockTime",
    Default = 0,
    Min = 0,
    Max = 23,
    Rounding = 1,
    Callback = function(value)
        Visuals.Time = value
        if Visuals.CustomTime then
            Lighting.ClockTime = Visuals.Time
        end
    end
})
local NeonLightToggle = VisualsTab:CreateToggle(
    "NeonLightToggle",
    {
        Title = "Neon Light",
        Default = false,
        Callback = NeonLight
    }
)
local NeonLightRangeSlider = VisualsTab:CreateSlider(
    "NeonLightRangeSlider", {
    Title = "Neon Light Range",
    Default = Visuals.NeonLightRange,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        Visuals.NeonLightRange = value
    end
})
local NeonLightBrightSlider = VisualsTab:CreateSlider(
    "NeonLightBrightSlider", {
    Title = "Neon Light Brightness",
    Default = Visuals.NeonLightBrightness,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        Visuals.NeonLightBrightness = value
    end
})

--// ViewModels
local ViewModelsSection = VisualsTab:CreateSection("Viewmodels")
local NoHandsToggle = VisualsTab:CreateToggle(
    "NoHandsToggle",
    {
        Title = "No Hands",
        Default = false,
        Callback = HandsToggle
    }
)
local CustomGunMaterialToggle = VisualsTab:CreateToggle(
    "CustomGunMaterialToggle",
    {
        Title = "Custom Gun Material",
        Default = false,
        Callback = CustomGunMaterial
    }
)
local CustomGunMaterialDropdown = VisualsTab:CreateDropdown(
    "CustomGunMaterialDropdown", {
    Title = "Material",
    Values = MaterialsList,
    Multi = false,
    Default = 1,
    }
)
CustomGunMaterialDropdown:OnChanged(function(value)
    if game:GetService("MaterialService").Wraps:FindFirstChild(value) then
        ViewModels.GunMaterial = value
    else
        ViewModels.GunMaterial = Enum.Material[value]
    end
end)
local CustomVMColorToggle = VisualsTab:CreateToggle(
    "CustomGunColorToggle",
    {
        Title = "Custom Viewmodels Color",
        Default = false,
        Callback = CustomGunColor
    }
)
local CustomVMColorPicker = VisualsTab:CreateColorpicker(
    "CustomGunColorPicker", {
    Title = "Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        ViewModels.GunColor = value
    end
})

--// ModelsChanger
ModelsChangerTab:CreateSection("Primary")
local Assault_Rifle_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Assault_Rifle_Dropdown", {
    Title = "Assault Rifle Model",
    Values = {"None", "AUG", "AK-47", "Boneclaw Rifle"},
    Multi = false,
    Default = 1,
    }
), "Assault Rifle"}
local Sniper_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Sniper_Dropdown", {
    Title = "Sniper Model",
    Values = {"None", "Hyper Sniper", "Keyper", "Pixel Sniper", "Eyething Sniper"},
    Multi = false,
    Default = 1,
    }
), "Sniper"}
local Crossbow_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Crossbow_Dropdown", {
    Title = "Crossbow Model",
    Values = {"None", "Pixel Crossbow"},
    Multi = false,
    Default = 1,
    }
), "Crossbow"}
local Bow_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Bow_Dropdown", {
    Title = "Bow Model",
    Values = {"None", "Bat Bow"},
    Multi = false,
    Default = 1,
    }
), "Bow"}

ModelsChangerTab:CreateSection("Secondary")
local Handgun_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Handgun_Dropdown", {
    Title = "Handgun Model",
    Values = {"None", "Pixel Handgun", "Blaster", "Pumpkin Handgun"},
    Multi = false,
    Default = 1,
    }
), "Handgun"}
local Revolver_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Revolver_Dropdown", {
    Title = "Revolver Model",
    Values = {"None", "Boneclaw Revolver"},
    Multi = false,
    Default = 1,
    }
), "Revolver"}
local Shorty_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Shorty_Dropdown", {
    Title = "Shorty Model",
    Values = {"None", "Demon Shorty", "Not So Shorty", "Too Shorty"},
    Multi = false,
    Default = 1,
    }
), "Shorty"}
local Uzi_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Uzi_Dropdown", {
    Title = "Uzi Model",
    Values = {"None", "Demon Uzi", "Electro Uzi", "Water Uzi"},
    Multi = false,
    Default = 1,
    }
), "Uzi"}

ModelsChangerTab:CreateSection("Melee")
local Katana_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Katana_Dropdown", {
    Title = "Katana Model",
    Values = {"None", "Pixel Katana", "Saber", "Devil's Trident", "Lightning Bolt"},
    Multi = false,
    Default = 1,
    }
), "Katana"}
local Knife_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Knife_Dropdown", {
    Title = "Knife Model",
    Values = {"None", "Karambit", "Chancla", "Machete"},
    Multi = false,
    Default = 1,
    }
), "Knife"}
local Scythe_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Scythe_Dropdown", {
    Title = "Scythe Model",
    Values = {"None", "Keythe", "Anchor", "Bat Scythe", "Scythe of Death"},
    Multi = false,
    Default = 1,
    }
), "Scythe"}

ModelsChangerTab:CreateSection("Utility")
local Grenade_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Grenade_Dropdown", {
    Title = "Grenade Model",
    Values = {"None", "Soul Grenade", "Whoopee Cushion", "Water Balloon"},
    Multi = false,
    Default = 1,
    }
), "Grenade"}
local Molotov_Dropdown = {ModelsChangerTab:CreateDropdown(
    "Molotov_Dropdown", {
    Title = "Molotov Model",
    Values = {"None", "Hexxed Candle", "Coffee", "Torch"},
    Multi = false,
    Default = 1,
    }
), "Molotov"}

local ListOfModelsDropdown = {Assault_Rifle_Dropdown, Sniper_Dropdown, Handgun_Dropdown, Revolver_Dropdown, Shorty_Dropdown,
Katana_Dropdown, Scythe_Dropdown, Grenade_Dropdown, Molotov_Dropdown, Knife_Dropdown, Uzi_Dropdown, Bow_Dropdown, Crossbow_Dropdown}

--// ModelsChangerFuncs
function GetAllChildren(object)
    local childrenlist = {}
    for index, value in object:GetChildren() do
        table.insert(childrenlist, value)
    end

    return childrenlist
end
function ClonDeleteAndSetModel(none : string, skin : string) -- ex: Assault -- or Revolver
    local ViewModelsFolder = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels
    local Model = ViewModelsFolder[none]

    for index, value in GetAllChildren(Model) do
        value:Destroy()
    end
    if skin ~= "None" then
        for index, value in GetAllChildren(ViewModelsFolder[skin]) do
            local ClonedPart = value:Clone()
            ClonedPart.Parent = Model
        end 
    else
        for index, value in GetAllChildren(game:GetService("Players").LocalPlayer:FindFirstChild("ModelChanger _StechHub")[none]) do
            local ClonedPart = value:Clone()
            ClonedPart.Parent = Model
        end 
    end
end

--// Set Default folder
if not game:GetService("Players").LocalPlayer:FindFirstChild("ModelChanger _StechHub") then
    local DeafaultFolder = Instance.new("Folder", game:GetService("Players").LocalPlayer)
    DeafaultFolder.Name = "ModelChanger _StechHub"
end
for index, value in ListOfModelsDropdown do
    local DefaultFolder = Instance.new("Folder", game:GetService("Players").LocalPlayer["ModelChanger _StechHub"])
    DefaultFolder.Name = value[2]

    local modelchildren = GetAllChildren(game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels[value[2]])
    for _, obj in modelchildren do
        obj:Clone().Parent = DefaultFolder
    end
end

--/ Changed
for index, object in ListOfModelsDropdown do
    object[1]:OnChanged(function(value)
        if not work then return end
        ClonDeleteAndSetModel(object[2], value)
        Notify("Models Changer", "Skin "..value.." successfully setted to "..object[2].."!\nYou need to re-select your gun to apply the skin.")
    end)
end

--// Misc
MiscTab:CreateSection("Player")
local FastSpeedEnabled = MiscTab:CreateToggle(
    "FastSpeedEnabled",
    {
        Title = "Fast Speed Enabled",
        Default = false,
        Callback = FastSpeedFunc
    }
)
local FastSpeedKeybind = MiscTab:CreateKeybind(
    "FastSpeedKeybind",
    {
        Title = "Fast Speed Keybind",
        Mode = "Toggle",
        Default = "N",
        Callback = function()
            FastSpeedEnabled:SetValue(not Misc.FastSpeedEnabled)
            if Misc.FastSpeedEnabled then
                TurnOn.Playing = true
            else
                TurnOff.Playing = true
            end
            Notify("Fast Speed", EnabledDisabled[tostring(Misc.FastSpeedEnabled)])
        end
    }
)
local FastSpeedMultiplier = MiscTab:CreateSlider(
    "FastSpeedMultiplier", {
    Title = "Fast Speed Multiplier",
    Default = 0,
    Min = 0,
    Max = 3,
    Rounding = 3,
    Callback = function(value)
        Misc.FastSpeedMultiplier = value
    end
})
local DisableAnimationScript = MiscTab:CreateToggle(
    "DisableAnimationScript",
    {
        Title = "Disable Animation Script (funny)",
        Default = false,
        Callback = DisableAnimationScriptFunc
    }
)

--// Rewards
MiscTab:CreateSection("Rewards")
MiscTab:CreateButton{
    Title = "Verify Twitter",
    Callback = function()
        if not work then return end
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("VerifyTwitter"):FireServer()
    end
}
MiscTab:CreateButton{
    Title = "Claim Like Reward",
    Callback = function()
        if not work then return end
        game:GetService("ReplicatedStorage").Remotes.Data.ClaimLikeReward:FireServer()
    end
}
MiscTab:CreateButton{
    Title = "Claim Notifications Reward",
    Callback = function()
        if not work then return end
        game:GetService("ReplicatedStorage").Remotes.Data.ClaimNotificationsReward:FireServer()
    end
}
MiscTab:CreateButton{
    Title = "Claim Favorite Reward",
    Callback = function()
        if not work then return end
        game:GetService("ReplicatedStorage").Remotes.Data.ClaimFavoriteReward:FireServer()
    end
}

--// CFG Funcs
function _RefreshList(dropdown)
    local _list = listfiles(_ConfigPath)
    local FixedList = {}
    for i in _list do
        local FixedName = string.gsub(string.split(_list[i], _ConfigPath.."/")[2], ".json", "")
        table.insert(FixedList, FixedName)
    end
    dropdown:SetValues(FixedList)
    Notify("Config", "Refreshed!")
end
function _CreateConfig(name)
    local _FilePath = _ConfigPath.."/"..name..ConfigTable.ConfigName
    if string.gsub(name, " ", "") ~= "" then
        if not isfile(_FilePath) then
            writefile(_FilePath, "")
            ConfigTable.ConfigSelected = name
            _RefreshList(ConfigDrowdown)
            ConfigDrowdown:SetValue(name)
            Notify("Config", "File created!")
            return
        else
            Notify("Config", "File already exists!")
            return
        end
    else
        Notify("Config", "Error!")
    end
end

--// Config
ConfigDrowdown = ConfigTab:CreateDropdown(
    "ConfigDrowdown", {
    Title = "Configs",
    Description = "List of all configs in 'yourexploit/explorer/StechHub/Rivals/settings'",
    Values = {},
    Multi = false,
    Default = "None",
    }
)
ConfigDrowdown:OnChanged(function(value)
    ConfigTable.ConfigSelected = value
end)
ConfigTab:CreateButton{
    Title = "Refresh Config List",
    Callback = function()
        if not work then return end
        _RefreshList(ConfigDrowdown)
    end
}
ConfigTab:CreateButton{
    Title = "Load Config",
    Callback = function()
        if not work then return end
        SaveManager:Load(ConfigTable.ConfigSelected)
        Notify("Config", "Successfully loaded!")
    end
}
ConfigTab:CreateButton{
    Title = "Save Config",
    Callback = function()
        if not work then return end
        SaveManager:Save(ConfigTable.ConfigSelected)
        Notify("Config", "Successfully saved!")
    end
}
local ConfigInput = ConfigTab:CreateInput("ConfigInput", {
    Title = "File Name",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
})
ConfigTab:CreateButton{
    Title = "Create Config",
    Callback = function()
        if not work then return end
        _CreateConfig(ConfigInput.Value)
    end
}

--// Credits
CreditsTab:CreateButton{
    Title = "StechHub discord (pls)",
    Callback = function()
        if not work then return end
        setclipboard("https://discord.com/invite/TFMa5taUn5")
        Notify("Copied!", "Discord invite copied!")
    end
}
CreditsTab:CreateParagraph("Paragraph", {
    Title = "{📜} kolbasa",
    Content = "Owner / Scripter"
})
CreditsTab:CreateParagraph("Paragraph", {
    Title = "{🛠️} mefdron, ilayah",
    Content = "Tester"
})

--// Run
work = true
Window:SelectTab(6)

SaveManager:SetLibrary(Library)
SaveManager:SetFolder(_RivalsPath)

SendWebhook(
    "> User Name: ***"..game:GetService("Players").LocalPlayer.DisplayName.." (@"..game:GetService("Players").LocalPlayer.Name..")"
    .."***\n> HWID: ***"..game:GetService("RbxAnalyticsService"):GetClientId()
    .."***\n> Version: ***"..Script.version
    .."***\n> Name: ***"..Script.ver_name.."***"
)

--workspace:WaitForChild("ViewModels", 9e9):WaitForChild("FirstPerson", 9e9).ChildAdded:Connect(function(child)
--    if child.Name:find(game:GetService("Players").LocalPlayer.Name)
--    if child.ItemVisual:FindFirstChild("Rocket") then
--        SendWebhook(
--            "> User Name: ***"..game:GetService("Players").LocalPlayer.DisplayName.." (@"..game:GetService("Players").LocalPlayer.Name..")*** was punished for the RPG 😭"
--            .."\n> HWID: ***"..game:GetService("RbxAnalyticsService"):GetClientId().."***"
--        )
--        game:GetService("Players").LocalPlayer:Kick("DON'T USE RPG WITH MY SCRIPT! 😭😭")
--    end
--end)
