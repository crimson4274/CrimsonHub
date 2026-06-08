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
  Color = Color3.fromRGB(255, 200, 0)
})

local section = Window:Section({
    Title = "Roles",
    Icon = "user-cog",
    Opened = true
})

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

local function applyNametags(char, color)
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if head then
        local nametag = head:FindFirstChild("namegui")

        if nametag then
            nametag.Tag.Text = char.Name
            nametag.Tag.TextColor3 = color
            return
        end

        local gui = Instance.new("BillboardGui")
        gui.Name = "namegui"
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 200, 0, 25)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
        gui.Parent = head
        
        local label = Instance.new("TextLabel")
        label.Name = "Tag"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = char.Name
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextColor3 = Color3.new(0, 1, 0)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Parent = gui
    end
end

local chamsToggle = false
local nametagToggle = false

local sheriff, murderer = nil, nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local conns = {}
local playerData = ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()

table.insert(conns, RunService.RenderStepped:Connect(function()
    if next(playerData) == nil then
        sheriff = nil
        murderer = nil
    end
    for _, player in Players:GetPlayers() do
        if not playerData[player.Name] and player ~= Players.LocalPlayer then
            local char = player.Character or player.CharacterAdded:Wait()
            if chamsToggle then
                applyChams(char, Color3.new(0, 1, 0))
            end

            if nametagToggle then
                applyNametags(char, Color3.new(0, 1, 0))
            end
        end
    end
    for plr, data in playerData do
        task.spawn(function()
            local player = Players:GetPlayerByUserId(data.UserId)
            if not player or player == Players.LocalPlayer then return end
            local char = player.Character or player.CharacterAdded:Wait()
            if data.Dead or data.Role == "Innocent" then
                if data.Role == "Murderer" then
                    murderer = nil
                elseif data.Role == "Sheriff" or data.Role == "Hero" then
                    sheriff = nil
                end
                            
                if chamsToggle then
                    applyChams(char, Color3.new(0, 1, 0))
                end

                if nametagToggle then
                    applyNametags(char, Color3.new(0, 1, 0))
                end
            elseif data.Role == "Sheriff" or data.Role == "Hero" then
                sheriff = player
                            
                if chamsToggle then
                    applyChams(char, Color3.new(0, 0.4, 1))
                end

                if nametagToggle then
                    applyNametags(char, Color3.new(0, 0.4, 1))
                end
            elseif data.Role == "Murderer" then
                murderer = player
                            
                if chamsToggle then
                    applyChams(char, Color3.new(1, 0, 0))
                end

                if nametagToggle then
                    applyNametags(char, Color3.new(1, 0, 0))
                end
            end
        end)
    end
end))

table.insert(conns, workspace.DescendantRemoving:Connect(function(a)
    task.defer(function()
        if a.Name == "GunDrop" then
            playerData = ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
        end
    end)
end))

table.insert(conns, ReplicatedStorage:WaitForChild("Remotes").Gameplay.PlayerDataChanged.OnClientEvent:Connect(function()
    playerData = ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
end))

local general = section:Tab({ Title = "General", Icon = "user" })
local mrd = section:Tab({ Title = "Murderer", Icon = "skull" })
local srf = section:Tab({ Title = "Sheriff", Icon = "crosshair" })

general:Select()

local gunGrabToggle = false

local function grabGun(gunDrop)
    if Players.LocalPlayer.Backpack:FindFirstChild("Knife") or Players.LocalPlayer.Character:FindFirstChild("Knife") then return end
    if not gunDrop then return end
    
    local head = Players.LocalPlayer.Character.UpperTorso
    firetouchinterest(head, gunDrop, true)
    task.delay(0, firetouchinterest, head, gunDrop, false)
end

local invisible = false

local function setCharacterTransparency(transparency)
    local char = Players.LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = transparency
            end
        end
    end
end

local invisToggle;
local seatPos;

local function toggleInvisibility(state)
    invisible = state
    if invisible then
        setCharacterTransparency(0.75)
        local char = Players.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local savedPos = hrp.CFrame
                task.wait(0.05)
                
                pcall(char.MoveTo, char, Vector3.new(-40, 400, 4000))
                task.wait(0.05)
                
                if not char:FindFirstChild("HumanoidRootPart") or char.HumanoidRootPart.Position.Y < -50 then
                    pcall(char.MoveTo, char, savedPos)
                    invisToggle:Set(false)
                    return
                end
                
                local seat = Instance.new("Seat")
                seat.Name = "InvisibilitySeat"
                seat.Transparency = 1
                seat.Position = Vector3.new(-40, 400, 4000)
                seat.Anchored = false
                seat.CanCollide = false
                seat.Parent = workspace

                local weld = Instance.new("Weld")
                weld.Part0 = seat

                local torso = char:FindFirstChild("UpperTorso")
                if torso then
                    weld.Part1 = torso
                    weld.Parent = seat
                    task.wait()
                    
                    pcall(function()
                        seat.CFrame = savedPos
                    end)

                    seatPos = seat.Position
                else
                    seat:Destroy()
                    seatPos = nil
                end
            else
                seatPos = nil
            end
        end
    else
        setCharacterTransparency(0)
        task.spawn(function()
            if workspace:FindFirstChild("InvisibilitySeat") then
                pcall(workspace.InvisibilitySeat.Destroy, workspace.InvisibilitySeat)
            end
        end)
        seatPos = nil
    end
end

table.insert(conns, Players.LocalPlayer.CharacterAdded:Connect(function()
    print(invisible)
    if invisible then
        toggleInvisibility(false)
        toggleInvisibility(invisible)
    end
end))

invisToggle = general:Toggle({
    Title = "Invisibility",
    Value = false,
    Callback = function(state)
        toggleInvisibility(state)
    end,
})

general:Toggle({
    Title = "Auto Gun Grab",
    Value = false,
    Flag = "auto_gun_grab",
    Callback = function(state)
        gunGrabToggle = state
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop and state then
            grabGun(gunDrop)
        end
    end
})

general:Button({
    Title = "Grab Gun",
    Callback = function()
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop then
            grabGun(gunDrop)
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
        if sheriff == Players.LocalPlayer or sheriff == nil then warn("Error") return end
        local char = sheriff.Character
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
        local knife = Players.LocalPlayer.Character:FindFirstChild("Knife")
        if not knife then return end
        if autoAimThrow then
            local nearestPlayer, _ = getNearestPlayer()
            knife.Events.KnifeThrown:FireServer(knife.Handle.CFrame, nearestPlayer.Character.UpperTorso.CFrame)
        else
            knife.Events.KnifeThrown:FireServer(knife.Handle.CFrame, WeaponService:GetMouseTargetCFrame())
        end
    end
})

srf:Keybind({ 
    Title = "Instant Shoot Keybind",
    Flag = "shoot_key",
    Value = "X", -- default key
    Callback = function(key)
        local gun = Players.LocalPlayer.Character:FindFirstChild("Gun")
        if not gun or not murderer then return end
        gun.Shoot:FireServer(gun.Handle.CFrame, murderer.Character.UpperTorso.CFrame)
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

local noclip;
local clip = true

table.insert(conns, Players.LocalPlayer.CharacterAdded:Connect(function()
    if clip == false then
        noclip:Set(false)
    end
end))

local function toggleNoclip(state)
    if state then
        clip = false
        task.wait(0.1)
        local function loop()
            if clip == false and Players.LocalPlayer.Character ~= nil then
                for _, child in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") then child.CanCollide = false end
                end
            end
        end
        conns.Noclipping = RunService.Stepped:Connect(loop)
    else
        if conns.Noclipping then
            conns.Noclipping:Disconnect()
        end
        clip = true
    end
end

noclip = locp:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = toggleNoclip
})

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
                    conns.FlyInputBegan = nil
                    conns.FlyInputEnded = nil
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
            conns.FlyInputBegan = nil
            conns.FlyInputEnded = nil
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

local targetSection = section:Tab({ Title = "Target", Icon = "goal" })

local function GetPlayerNames()
    local playerList = Players:GetPlayers()
    for index, value in playerList do
        playerList[index] = value.Name
    end
    return playerList
end

local currentTarget = nil

local Dropdown = targetSection:Dropdown({
    Title = "Select Player",
    Values = GetPlayerNames(),
    Callback = function(selected)
        local target = Players:FindFirstChild(tostring(selected))
        if target then
            currentTarget = target
        else
            currentTarget = nil
        end
    end
})

Players.PlayerAdded:Connect(function(new)
    Dropdown:Refresh(GetPlayerNames())
end)

Players.PlayerRemoving:Connect(function(old)
    Dropdown:Refresh(GetPlayerNames())
end)

targetSection:Divider()

targetSection:Button({
    Title = "Teleport to Target",
    Callback = function()
        if currentTarget then
            local hrp = Players.LocalPlayer.Character.HumanoidRootPart
            local chara = currentTarget.Character
            if chara then
                hrp.CFrame = chara.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
            end
        end
    end
})

local function targetFling(target)
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = hum and hum.RootPart

    local tChar = target.Character
    local tHum
    local trp
    local tHead

    if tChar:FindFirstChildOfClass("Humanoid") then
        tHum = tChar:FindFirstChildOfClass("Humanoid")
    end
    if tHum and tHum.RootPart then
        trp = tHum.RootPart
    end
    if tChar:FindFirstChild("Head") then
        tHead = tChar.Head
    end

    if char and hum and hrp then
        if hrp.Velocity.Magnitude < 50 then
            getgenv()._rootPos = hrp.CFrame
        end
        if tHum and tHum.Sit then return end
        if tHead then
            workspace.CurrentCamera.CameraSubject = tHead
        elseif tHum and trp then
            workspace.CurrentCamera.CameraSubject = tHum
        end
        if not tChar:FindFirstChildWhichIsA("BasePart") then return end
        
        local function flAng(root, pos, ang)
            hrp.CFrame = CFrame.new(root.Position) * pos * ang
            char.PrimaryPart.CFrame = CFrame.new(root.Position) * pos * ang
            hrp.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local function fling(root)
            local ftime = 2
            local ttime = tick()
            local ang = 0

            repeat
                if hrp and tHum then
                    if root.Velocity.Magnitude < 50 then
                        ang += 100

                        flAng(root, CFrame.new(0, 1.5, 0) + tHum.MoveDirection * root.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * root.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(2.25, 1.5, -2.25) + tHum.MoveDirection * root.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(-2.25, -1.5, 2.25) + tHum.MoveDirection * root.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, 1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(ang), 0, 0))
                        task.wait()
                    else
                        flAng(root, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        flAng(root, CFrame.new(0, 1.5, trp.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, -trp.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, 1.5, trp.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()

                        flAng(root, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until root.Velocity.Magnitude > 500 or root.Parent ~= target.Character or target.Parent ~= Players or target.Character ~= tChar or tHum.Sit or hum.Health <= 0 or tick() > ttime + ftime
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local velo = Instance.new("BodyVelocity")
        velo.Name = "flingVel"
        velo.Parent = hrp
        velo.Velocity = Vector3.new(9e8, 9e8, 9e8)
        velo.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if trp and tHead then
            if (trp.CFrame.Position - tHead.CFrame.Position).Magnitude > 5 then
                fling(tHead)
            else
                fling(trp)
            end
        elseif trp and not tHead then
            fling(trp)
        elseif not trp and tHead then
            fling(tHead)
        else
            return
        end
        
        velo:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = hum
        
        repeat
            hrp.CFrame = getgenv()._rootPos * CFrame.new(0, .5, 0)
            char.PrimaryPart.CFrame = getgenv()._rootPos * CFrame.new(0, .5, 0)
            hum:ChangeState("GettingUp")
            for _, x in ipairs(char:GetChildren()) do
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (hrp.Position - getgenv()._rootPos.Position).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

targetSection:Button({
    Title = "Fling Target",
    Callback = function()
        if currentTarget then
            targetFling(currentTarget)
        end
    end
})

local esp = section:Tab({ Title = "ESP", Icon = "square-dashed-top-solid" })

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
            grabGun(gunDrop)
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

local function removeNametags()
    for _, player in Players:GetPlayers() do
        if player.Character then
            local gui = player.Character.Head:FindFirstChild("namegui")
            if gui then gui:Destroy() end
        end
    end
end

esp:Toggle({
    Title = "Nametag ESP",
    Type = "Checkbox",
    Flag = "nametag_esp",
    Value = false,
    Callback = function(state)
        nametagToggle = state
        if state == false then
            removeNametags()
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

local tprts = section:Tab({ Title = "Teleports", Icon = "map-pinned" })

tprts:Button({
    Title = "Murderer TP",
    Icon = "map-pin-x",
    IconAlign = "Left",
    Callback = function()
        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
        if not murderer then return end
        local chara = murderer.Character
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
        if not sheriff then return end
        local chara = sheriff.Character
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
                        toggleNoclip(true)
                        local nearest, distance = findNearestPart(x)
                        local value = Instance.new("CFrameValue")
                        value.Changed:Connect(function()
                            Players.LocalPlayer.Character:PivotTo(value.Value)
                        end)
                        tween = TweenService:Create(
                            value,
                            TweenInfo.new(
                                distance / 24,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.Out
                            ),
                            { Value = nearest.CFrame + Vector3.new(0,2,0) }
                        )
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.25)
                        nearest:Destroy()
                    end
                    Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                    toggleNoclip(false)
                end
            end
        end
    until not coinFarmState
    if tween then
        tween:Cancel()
    end
    Players.LocalPlayer.Character.Humanoid.PlatformStand = false
    toggleNoclip(false)
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

local cfg = Window.ConfigManager:Config("CHConfig")

Window:OnDestroy(function()
    for key, conn in conns do
        conn:Disconnect()
        conns[key] = nil
    end
    removeChams()
    removeGunEsp()
    removeCoinEsp()
    hidePlayerNames()
    toggleInvisibility(false)
    coinFarmState = false
    flying = false
    toggleFly()
end)
