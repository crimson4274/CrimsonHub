local _version = "1.6.64-fix"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

local Window = WindUI:CreateWindow({
    Title = "Crimson Hub", -- window title
    Icon = "ethernet-port", -- lucide icon or "rbxassetid://" or URL. optional
    Author = "by zBlizzardzy", -- window subtitle. optional
    Theme = "Crimson",
    Folder = "CrimsonHubMM2"
})

Window:Tag({
  Title = "New",
  Icon = "sparkles",
  Color = Color3.new(255, 170, 0)
})

local cfg = Window.ConfigManager:Config("CHConfig")

local section = Window:Section({
    Title = "Roles",
    Icon = "user-cog",
    Opened = true
})

local function getKnife(player)
    local char = player.Character
    local knife = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
    return knife
end

local function getGun(player)
    local char = player.Character
    local gun = char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
    return gun
end

local Players = game:GetService("Players")

local function getRoles()
    local sheriff, murderer
    for _, player in Players:GetPlayers() do
        if player.Character then
            if getKnife(player) then murderer = player end
            if getGun(player) then sheriff = player end
        end
    end
    return sheriff, murderer
end

local general = section:Tab({ Title = "General", Icon = "user" })
local mrd = section:Tab({ Title = "Murderer", Icon = "skull" })
local srf = section:Tab({ Title = "Sheriff", Icon = "crosshair" })

general:Select()

local gunGrabToggle = false

local function grabGunTP(gunDrop)
    if getKnife(Players.LocalPlayer) then return end
    if not gunDrop then return end
    
    local hrp = Players.LocalPlayer.Character.HumanoidRootPart
    local oldCF = hrp.CFrame
    
    hrp.CFrame = gunDrop.CFrame
    
    gunDrop.Destroying:Wait()
    
    hrp.CFrame = oldCF
end

local conns = {}
local ndd = {}

local function hidePlayerNames()
    for player, dd in ndd do
        if conns["ShowNames_" .. player.Name] then
            conns["ShowNames_" .. player.Name]:Disconnect()
        end

        if conns["NameCharAdd_" .. player.Name] then
            conns["NameCharAdd_" .. player.Name]:Disconnect()
        end

        ndd[player] = nil
        dd[1].NameDisplayDistance = dd[2]
    end
end

local function showPlayerNames(player)
    hidePlayerNames()
    if player.Character then
        local char = player.Character
        local hum = char.Humanoid
        ndd[player] = {hum, hum.NameDisplayDistance}

        hum.NameDisplayDistance = game.StarterPlayer.NameDisplayDistance
        conns["ShowNames_" .. player.Name] = hum:GetPropertyChangedSignal("NameDisplayDistance"):Connect(function()
            ndd[player] = {hum, hum.NameDisplayDistance}
            hum.NameDisplayDistance = game.StarterPlayer.NameDisplayDistance
        end)

        conns["NameCharAdd_" .. player.Name] = player.CharacterAdded:Connect(function(new)
            char = new
            hum = char:WaitForChild("Humanoid")
            ndd[player] = {hum, hum.NameDisplayDistance}

            if conns["ShowNames_" .. player.Name] then
                conns["ShowNames_" .. player.Name]:Disconnect()
            end

            hum.NameDisplayDistance = game.StarterPlayer.NameDisplayDistance
            conns["ShowNames_" .. player.Name] = hum:GetPropertyChangedSignal("NameDisplayDistance"):Connect(function()
                ndd[player] = {hum, hum.NameDisplayDistance}
                hum.NameDisplayDistance = game.StarterPlayer.NameDisplayDistance
            end)
        end)
    end
end

general:Toggle({
    Title = "Show Player Names",
    Value = false,
    Flag = "show_names",
    Callback = function(state)
        if state then
            for _, player in Players:GetPlayers() do
                showPlayerNames(player)
            end
        else
            hidePlayerNames()
        end
    end
})

general:Toggle({
    Title = "Auto Gun Grab",
    Value = false,
    Flag = "auto_gun_grab",
    Callback = function(state)
        gunGrabToggle = state
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop and state then
            grabGunTP(gunDrop)
        end
    end
})

general:Button({
    Title = "Grab Gun",
    Callback = function()
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop then
            grabGunTP(gunDrop)
        end
    end
})

general:Divider()

general:Button({
    Title = "Trap Sheriff",
    Icon = "columns-4",
    IconAlign = "Left",
    Desc = "Teleports and freezes the sheriff",
    Callback = function()
        local myCF = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        local targetCF = myCF + myCF.LookVector * 3
        local sher, _ = getRoles()
        if sher == Players.LocalPlayer then warn("Error") return end
        local char = sher.Character
        char.HumanoidRootPart.Anchored = true
        char.HumanoidRootPart.CFrame = CFrame.new(targetCF.Position, Vector3.new(myCF.Position.X, targetCF.Position.Y, myCF.Position.Z))
    end
})

general:Button({
    Title = "Release Player",
    Icon = "square-arrow-out-up-right",
    IconAlign = "Left",
    Desc = "Releases the sheriff",
    Callback = function()
        for _, m in Players:GetPlayers() do
            local char = m.Character
            char.HumanoidRootPart.Anchored = false
        end
    end
})

mrd:Button({
    Title = "Kill Aura",
    Icon = "slice",
    IconAlign = "Left",
    Desc = "Teleport innocents to you",
    Callback = function()
        local myCF = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        local targetCF = myCF + myCF.LookVector * 3
        for _, player in Players:GetPlayers() do
            if player ~= Players.LocalPlayer then
                local char = player.Character
                char.HumanoidRootPart.Anchored = true
                char.HumanoidRootPart.CFrame = CFrame.new(targetCF.Position, Vector3.new(myCF.Position.X, targetCF.Position.Y, myCF.Position.Z))
            end
        end
    end
})

local function getNearestPlayer()
    local myCF = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    local nearestPlayer, nearestDistance
    for _, player in Players:GetPlayers() do
        local char = player.Character
        if char then
            local distance = player:DistanceFromCharacter(myCF.Position)
            nearestDistance = distance
            nearestPlayer = player
        end
    end
    return nearestPlayer, nearestDistance
end

local autoAimThrow = false

mrd:Toggle({
    Title = "Auto Aim Throw",
    Value = false,
    Flag = "auto_aim_throw",
    Callback = function(state)
        autoAimThrow = state
    end
})

local WeaponService = require(game:GetService("ReplicatedStorage"):WaitForChild("ClientServices"):WaitForChild("WeaponService"))

mrd:Keybind({
    Title = "Instant Throw Keybind",
    Flag = "throw_key",
    Value = "Z", -- default key
    Callback = function(key)
        local knife = getKnife(Players.LocalPlayer)
        if not knife then return end
        if autoAimThrow then
            local nearestPlayer, _ = getNearestPlayer()
            knife:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(knife.Handle.CFrame, nearestPlayer.Character.Torso.CFrame)
        else
            knife:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(knife.Handle.CFrame, WeaponService:GetMouseTargetCFrame())
        end
    end
})

srf:Keybind({ 
    Title = "Instant Shoot Keybind",
    Flag = "shoot_key",
    Value = "X", -- default key
    Callback = function(key)
        local gun = getGun(Players.LocalPlayer)
        if not gun then return end
        local _, murd = getRoles()
        gun:WaitForChild("Shoot"):FireServer(gun.Handle.CFrame, murd.Character.Torso.CFrame)
    end
})

local section = Window:Section({
    Title = "More",
    Icon = "bolt",
    Opened = true
})

local locp = section:Tab({ Title = "Player", Icon = "user-cog" })

locp:Slider({
    Title = "Speed",
    Value = { Min = 4, Max = 50, Default = 16 },
    Step = 1, -- integer steps
    Callback = function(value)
        Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

locp:Slider({
    Title = "Jump Power",
    Value = { Min = 12, Max = 100, Default = 50 },
    Step = 1, -- integer steps
    Callback = function(value)
        Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

local invincible = false
local RunService = game:GetService("RunService")

locp:Toggle({
    Title = "Noclip (BROKEN)",
    Value = false,
    Callback = function(state)
        noclip = state
    end
}):Lock()

local flySpeed = 50
local flying = false

local UIS = game:GetService("UserInputService")

local function toggleFly()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    if flying == true then
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        local flyCfg = {F = 0, B = 0, L = 0, R = 0}
        local altCfg = table.clone(flyCfg)
        local speed = flySpeed
        
        local function fly()
            local gyro = Instance.new("BodyGyro")
            local velo = Instance.new("BodyVelocity")
            
            gyro.P = 9e4
            gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            gyro.CFrame = hrp.CFrame
            
            velo.Velocity = Vector3.new(0, 0, 0)
            velo.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            gyro.Parent = hrp
            velo.Parent = hrp
            
            task.spawn(function()
                repeat task.wait()
                    hum.PlatformStand = true
                    
                    local camCF = workspace.CurrentCamera.CFrame
                    if flyCfg.L + flyCfg.R ~= 0 or flyCfg.F + flyCfg.B ~= 0 then
                        speed = flySpeed
                        velo.Velocity = ((camCF.LookVector * (flyCfg.F + flyCfg.B)) + ((camCF * CFrame.new(flyCfg.L + flyCfg.R, (flyCfg.F + flyCfg.B) * 0.2, 0).Position) - camCF.Position)) * speed
                        altCfg = table.clone(flyCfg)
                    elseif flyCfg.L + flyCfg.R + flyCfg.F + flyCfg.B == 0 and speed ~= 0 then
                        speed = 0
                        velo.Velocity = ((camCF.LookVector * (altCfg.F + altCfg.B)) + ((camCF * CFrame.new(altCfg.L + altCfg.R, (altCfg.F + altCfg.B) * 0.2, 0).Position) - camCF.Position)) * speed
                    else
                        velo.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    gyro.CFrame = camCF
                until not flying
                
                flyCfg = {F = 0, B = 0, L = 0, R = 0}
                altCfg = table.clone(flyCfg)
                speed = 0
                
                gyro:Destroy()
                velo:Destroy()
                
                hum.PlatformStand = false
                
                if conns.FlyInputBegan and conns.FlyInputEnded then
                    conns.FlyInputBegan:Disconnect()
                    conns.FlyInputEnded:Disconnect()
                end
            end)
        end
        
        conns.FlyInputBegan = UIS.InputBegan:Connect(function(input, ignore)
            if ignore then return end
            
            if input.KeyCode == Enum.KeyCode.W then
                flyCfg.F = 1
            elseif input.KeyCode == Enum.KeyCode.S then
                flyCfg.B = -1
            elseif input.KeyCode == Enum.KeyCode.A then
                flyCfg.L = -1
            elseif input.KeyCode == Enum.KeyCode.D then
                flyCfg.R = 1
            end
        end)
        
        conns.FlyInputEnded = UIS.InputEnded:Connect(function(input, ignore)
            if ignore then return end
            
            if input.KeyCode == Enum.KeyCode.W then
                flyCfg.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                flyCfg.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                flyCfg.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                flyCfg.R = 0
            end
        end)
        fly()
    else
        hum.PlatformStand = false
        if conns.FlyInputBegan and conns.FlyInputEnded then
            conns.FlyInputBegan:Disconnect()
            conns.FlyInputEnded:Disconnect()
        end
    end
end

locp:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state)
        flying = state
        toggleFly()
    end
})

locp:Slider({
    Title = "Fly Speed",
    Value = { Min = 24, Max = 100, Default = 50 },
    Step = 1, -- integer steps
    Callback = function(value)
        flySpeed = value
    end
})

locp:Toggle({
    Title = "Invincibility",
    Value = false,
    Callback = function(state)
        invincible = state
    end
})

local esp = section:Tab({ Title = "ESP", Icon = "square-dashed-top-solid" })

local function applyChams(char, color)
    if not char then return end
    
    local hl = char:FindFirstChild("espHl")
    if hl then
        hl.FillColor = color
        hl.OutlineColor = color
        return
    end
    
    local h = Instance.new("Highlight")
    h.Name = "espHl"
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0.25
    h.FillColor = color
    h.OutlineColor = color
    h.Parent = char
end

local chamsToggle = false

local function removeChams()
    for _, player in Players:GetPlayers() do
        if player.Character then
            local hl = player.Character:FindFirstChild("espHl")
            if hl then hl:Destroy() end
        end
    end
end

esp:Toggle({
    Title = "Player ESP",
    Type = "Checkbox",
    Flag = "chams_esp",
    Value = false,
    Callback = function(state)
        chamsToggle = state
        if state == false then
            removeChams()
        end
    end
})

local function gunDropEsp(gunDrop)
    if not gunDrop then return end
    
    local hl = gunDrop:FindFirstChild("dropEspHl")
    if hl then
        hl.FillColor = Color3.fromRGB(255,255,0)
        hl.OutlineColor = Color3.fromRGB(255,255,0)
        return
    end
    
    local h = Instance.new("Highlight")
    h.Name = "dropEspHl"
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0.25
    h.FillColor = Color3.fromRGB(255,255,0)
    h.OutlineColor = Color3.fromRGB(255,255,0)
    h.Parent = gunDrop
end

local function coinDropEsp(coin)
    if not coin then return end
    
    local hl = coin:FindFirstChild("coinEspHl")
    if hl then
        hl.FillColor = Color3.fromRGB(255,255,0)
        hl.OutlineColor = Color3.fromRGB(255,255,0)
        return
    end
    
    local h = Instance.new("Highlight")
    h.Name = "coinEspHl"
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0.25
    h.FillColor = Color3.fromRGB(255,255,0)
    h.OutlineColor = Color3.fromRGB(255,255,0)
    h.Parent = coin
end

local function removeGunEsp()
    local gunDrop = workspace:FindFirstChild("dropEspHl", true)
    if gunDrop then
        gunDrop:Destroy()
    end
end

local function removeCoinEsp()
    for _, coinDrop in workspace:GetDescendants() do
        if coinDrop.Name == "coinEspHl" then
            coinDrop:Destroy()
        end
    end
end

local gunEspToggle = false
local coinEspToggle = false

table.insert(conns, workspace.DescendantAdded:Connect(function(gunDrop)
    if gunDrop.Name == "GunDrop" then
        if gunEspToggle then
            gunDropEsp(gunDrop)
        end
        
        if gunGrabToggle then
            grabGunTP(gunDrop)
        end
    end
    
    if gunDrop.Name == "MainCoin" and coinEspToggle then
        coinDropEsp(gunDrop)
    end
end))

esp:Toggle({
    Title = "Gun ESP",
    Type = "Checkbox",
    Flag = "gun_drop_esp",
    Value = false,
    Callback = function(state)
        gunEspToggle = state
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop and state then
            gunDropEsp(gunDrop)
        end
        if state == false then
            removeGunEsp()
        end
    end
})

esp:Toggle({
    Title = "Coin ESP",
    Type = "Checkbox",
    Flag = "chams_esp",
    Value = false,
    Callback = function(state)
        coinEspToggle = state
        if state == true then
            for _, coinVisual in workspace:GetDescendants() do
                if coinVisual.Name == "MainCoin" then
                    coinDropEsp(coin)
                end
            end
        else
            removeCoinEsp()
        end
    end
})

local function getRoleColor(player)
    local s, m = getRoles()
    if s == player then
        return Color3.fromRGB(0,100,255)
    elseif m == player then
        return Color3.new(1,0,0)
    end
    return Color3.new(0,1,0)
end

local tprts = section:Tab({ Title = "Teleports", Icon = "map-pinned" })

tprts:Button({
    Title = "Murderer TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        local _, murd = getRoles()
        local chara = murd.Character
        if chara then
            hrp.CFrame = chara.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
        end
    end
})

tprts:Button({
    Title = "Sheriff TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        local sher, _ = getRoles()
        local chara = sher.Character
        if chara then
            hrp.CFrame = chara.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
        end
    end
})

tprts:Button({
    Title = "Gun TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop then
            hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
        end
    end
})

local safezonem = Instance.new("Model")
safezonem.Name = "MM2-Safezone"
safezonem.Parent = workspace

local baseplate = Instance.new("Part")
baseplate.Name = "Zonebase"
baseplate.Anchored = true
baseplate.CFrame = CFrame.new(10000, 500, 10000)
baseplate.Size = Vector3.new(32, 1, 32)
baseplate.BrickColor = BrickColor.new("Bright red")
baseplate.Material = Enum.Material.Neon
baseplate.Transparency = 0.4
baseplate.Parent = safezonem

tprts:Button({
    Title = "Safezone TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        if baseplate then
            hrp.CFrame = baseplate.CFrame + Vector3.new(0, 2, 0)
        end
    end
})

tprts:Button({
    Title = "Lobby TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        local a = workspace:FindFirstChild("RegularLobby"):FindFirstChild("Spawns"):GetChildren()
        local spawnRandom = a[math.random(1, #a)]
        if spawnRandom then
            hrp.CFrame = spawnRandom.CFrame + Vector3.new(0, 2, 0)
        end
    end
})

local function getMap()
    local mapBase
    for _, model in workspace:GetDescendants() do
        if model:IsA("Model") and model.Name == "Base" then
            mapBase = model
            break
        end
    end
    return mapBase and mapBase.Parent
end

tprts:Button({
    Title = "Map TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        local map = getMap()
        if map then
            local a = map:FindFirstChild("Spawns"):GetChildren()
            local spawnRandom = a[math.random(1, #a)]
            if spawnRandom then
                hrp.CFrame = spawnRandom.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end
})

tprts:Divider()

local function GetPlayerNames()
    local playerList = Players:GetPlayers()
    for index, value in playerList do
        playerList[index] = value.Name
    end
    return playerList
end

local Dropdown = tprts:Dropdown({
    Title = "Player TP",
    Values = GetPlayerNames(),
    Callback = function(selected)
        print("Selected:", selected)
    end
})

Players.PlayerAdded:Connect(function(new)
    Dropdown.Values = GetPlayerNames()
end)

Players.PlayerRemoving:Connect(function(old)
    Dropdown.Values = GetPlayerNames()
end)

local farm = section:Tab({ Title = "Farm", Icon = "coins" })

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local coinFarmState = false

local function findNearestPart(folder)
    local parts = folder:GetChildren()
    local nearest, distance = nil, math.huge
    for _, v in parts do
        local dist = (Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
        if dist < distance then
            nearest = v
            distance = dist
        end
    end
    return nearest, distance
end

local function coinFarm()
    local tween
    repeat
        task.wait(.25)
        local ws = workspace:GetChildren()
        for _, w in ws do
            local v = w:GetChildren()
            for _, x in v do
                if x.Name == "CoinContainer" then
                    if x:FindFirstChild("Coin_Server") ~= nil then
                        Players.LocalPlayer.Character.Humanoid.PlatformStand = true
                        local nearest, distance = findNearestPart(x)
                        tween = TweenService:Create(
                            Players.LocalPlayer.Character.HumanoidRootPart,
                            TweenInfo.new(
                                distance / 24,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.Out
                            ),
                            { CFrame = nearest.CFrame + Vector3.new(0,2,0) }
                        )
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.25)
                        nearest:Destroy()
                    end
                    Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end
        end
    until not coinFarmState
    if tween then
        tween:Cancel()
    end
    Players.LocalPlayer.Character.Humanoid.PlatformStand = false
end

farm:Toggle({
    Title = "Coin Farm",
    Value = false,
    Callback = function(state)
        coinFarmState = state
        coinFarm()
    end
})

local settings = section:Tab({ Title = "Settings", Icon = "settings" })

local uiToggle = settings:Keybind({
    Title = "Toggle UI",
    Value = "V",
    Callback = function(key)
        Window:Toggle()
    end
})

table.insert(conns, RunService.RenderStepped:Connect(function()
    if chamsToggle then
        for _, player in Players:GetPlayers() do
            if player ~= Players.LocalPlayer and player.Character then
                local color = getRoleColor(player)
                applyChams(player.Character, color)
            end
        end
    end
end))

Window:OnDestroy(function()
    for _, conn in conns do
        conn:Disconnect()
    end
    removeChams()
    removeGunEsp()
    removeCoinEsp()
    hidePlayerNames()
    coinFarmState = false
    flying = false
    toggleFly()
end)
