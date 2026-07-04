-- =============================================
-- MM2 ULTIMATE HUB v3 (PART 1/3)
-- Ядро, GUI, визуальные функции
-- =============================================

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Config = {AimbotSmoothness = 0.25, AimbotFOV = 250, SpeedValue = 16, JumpPowerValue = 50, FlySpeed = 60, FarmRadius = 30}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
Title.Text = "🔥 MM2 ULTIMATE v3"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -16, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 8, 0, 42)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 750)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local function CreateSection(title, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(0, 220, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollingFrame
    return label
end

local function CreateToggle(text, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollingFrame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.72, 0, 0.15, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 50, 50)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.Parent = frame
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 50, 50)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

local function CreateButton(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = ScrollingFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== ВИЗУАЛЬНЫЕ ФУНКЦИИ (ESP, Chams, FullBright) =====
local espObjects = {}
local espEnabled = false
local function UpdateESP(state)
    for _, obj in pairs(espObjects) do obj:Destroy() end
    espObjects = {}
    if not state then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local roleColor = Color3.fromRGB(200,200,200)
        local roleText = ""
        local isMurderer = false
        local isSheriff = false
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if string.find(name, "knife") or string.find(name, "dagger") then
                    roleColor = Color3.fromRGB(255, 0, 0)
                    roleText = "🔪 Murderer"
                    isMurderer = true
                elseif string.find(name, "gun") or string.find(name, "revolver") then
                    roleColor = Color3.fromRGB(0, 150, 255)
                    roleText = "🔫 Sheriff"
                    isSheriff = true
                end
            end
        end
        if not isMurderer and not isSheriff then
            roleColor = Color3.fromRGB(0, 255, 0)
            roleText = "👤 Innocent"
        end
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = roleColor
        box.Transparency = 0.2
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Parent = root
        table.insert(espObjects, box)
        local line = Instance.new("LineHandleAdornment")
        line.Length = 0.5
        line.Color3 = roleColor
        line.Thickness = 2
        line.AlwaysOnTop = true
        line.ZIndex = 5
        line.Parent = root
        table.insert(espObjects, line)
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 220, 0, 70)
        bill.StudsOffset = Vector3.new(0, 4, 0)
        bill.AlwaysOnTop = true
        bill.Parent = root
        table.insert(espObjects, bill)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        local dist = 0
        if Player.Character and Player.Character.HumanoidRootPart then
            dist = (root.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        end
        nameLabel.Text = player.Name .. " [" .. tostring(math.floor(dist)) .. "m]"
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextStrokeTransparency = 0.4
        nameLabel.Parent = bill
        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
        roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = roleText
        roleLabel.TextColor3 = roleColor
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.TextSize = 15
        roleLabel.TextStrokeTransparency = 0.4
        roleLabel.Parent = bill
    end
end

local chamsObjects = {}
local chamsEnabled = false
local function UpdateChams(state)
    for _, obj in pairs(chamsObjects) do obj:Destroy() end
    chamsObjects = {}
    if not state then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local char = player.Character
        if not char then continue end
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local hl = Instance.new("Highlight")
                hl.Adornee = part
                hl.FillColor = Color3.fromRGB(255, 0, 200)
                hl.FillTransparency = 0.35
                hl.OutlineColor = Color3.fromRGB(0, 200, 255)
                hl.OutlineTransparency = 0.15
                hl.Parent = part
                table.insert(chamsObjects, hl)
            end
        end
    end
end

local fullbrightEnabled = false
local function UpdateFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 2
        Lighting.Ambient = Color3.fromRGB(128,128,128)
    else
        Lighting.Brightness = 0
        Lighting.ExposureCompensation = 0
        Lighting.Ambient = Color3.fromRGB(0,0,0)
    end
end
-- =============================================
-- MM2 ULTIMATE HUB v3 (PART 2/3)
-- Aimbot, AutoFarm, Teleports, Movement (Fly, Noclip, Infinite Jump)
-- =============================================

-- ===== AIMBOT =====
local aimbotEnabled = false
local silentAimEnabled = false
local function UpdateAimbot(state) aimbotEnabled = state end
local function UpdateSilentAim(state) silentAimEnabled = state end

-- ===== ФАРМ МОНЕТ =====
local autoFarmEnabled = false
local farmConnection = nil
local function StartAutoFarm(state)
    autoFarmEnabled = state
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
    if not state then return end
    farmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        local myChar = Player.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local nearestCoin = nil
        local nearestDist = Config.FarmRadius
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") and v.Name and string.find(v.Name:lower(), "coin") then
                if v.Parent and v.Parent:IsA("Folder") then
                    local dist = (v.Position - myRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestCoin = v
                    end
                end
            end
        end
        if nearestCoin then
            myRoot.CFrame = nearestCoin.CFrame * CFrame.new(0, 2, 0)
        end
    end)
end

-- ===== ТЕЛЕПОРТЫ =====
local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == Player then return end
    local char = targetPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local myChar = Player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    myRoot.CFrame = root.CFrame * CFrame.new(0, 2, 0)
end

local function GetRolePlayers(role)
    local result = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local char = player.Character
        if not char then continue end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if role == "murderer" and (string.find(name, "knife") or string.find(name, "dagger")) then
                    table.insert(result, player)
                elseif role == "sheriff" and (string.find(name, "gun") or string.find(name, "revolver")) then
                    table.insert(result, player)
                end
            end
        end
    end
    return result
end

-- ===== ДВИЖЕНИЕ (Fly, Noclip, Infinite Jump) =====
local flyEnabled = false
local flyConnection = nil
local noclipEnabled = false
local infiniteJumpEnabled = false

local function ToggleFly(state)
    flyEnabled = state
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if not state then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
        end
        return
    end
    local char = Player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.PlatformStand = true
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not Player.Character then return end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local moveDir = Vector3.new()
        if UserInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1,0,1) end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1,0,1) end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Config.FlySpeed
            root.Velocity = moveDir
        else
            root.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function ToggleNoclip(state)
    noclipEnabled = state
    if state then
        local char = Player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        Player.CharacterAdded:Connect(function(char)
            if noclipEnabled then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end

local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    if state then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 100
        end
        Player.CharacterAdded:Connect(function(char)
            if infiniteJumpEnabled then
                local humanoid = char:WaitForChild("Humanoid")
                humanoid.JumpPower = 100
            end
        end)
    else
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Config.JumpPowerValue
        end
    end
end
-- =============================================
-- MM2 ULTIMATE HUB v3 (PART 3/3)
-- Speed Slider, Kill All, Auto Shoot, UI, Loops, Events
-- =============================================

-- ===== SPEED SLIDER =====
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 65)
speedFrame.Position = UDim2.new(0, 0, 0, 730)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = ScrollingFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0.4, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16 | Jump: 50"
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 17
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0.3, 0)
sliderBg.Position = UDim2.new(0, 10, 0.5, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local dragging = false
local function updateSpeedFromPosition(inputPos)
    local absX = sliderBg.AbsolutePosition.X
    local width = sliderBg.AbsoluteSize.X
    local rel = math.clamp((inputPos.X - absX) / width, 0, 1)
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    local spd = math.floor(16 + rel * 84)
    Config.SpeedValue = spd
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = spd
    end
    speedLabel.Text = "Speed: " .. tostring(spd) .. " | Jump: " .. tostring(Config.JumpPowerValue)
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSpeedFromPosition(input.Position)
    end
end)
sliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        updateSpeedFromPosition(input.Position)
    end
end)

-- ===== УБИЙСТВО ВСЕХ И АВТОСТРЕЛЬБА =====
local function KillAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.Health = 0 end
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part:BreakJoints() end
            end
        end
    end
end

local autoShootEnabled = false
local autoShootConnection = nil
local function ToggleAutoShoot(state)
    autoShootEnabled = state
    if autoShootConnection then autoShootConnection:Disconnect() autoShootConnection = nil end
    if not state then return end
    autoShootConnection = RunService.Heartbeat:Connect(function()
        if not autoShootEnabled then return end
        local myChar = Player.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local closest = nil
        local closestDist = 60
        for _, player in ipairs(Players:GetPlayers()) do
            if player == Player then continue end
            local char = player.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = char
            end
        end
        if closest then
            for _, tool in pairs(myChar:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name:lower(), "gun") or string.find(tool.Name:lower(), "revolver")) then
                    tool:Activate()
                end
            end
        end
    end)
end

-- ===== ИНТЕРФЕЙС (КНОПКИ) =====
CreateSection("VISUAL", 0)
CreateToggle("ESP", 25, false, function(s) espEnabled=s; UpdateESP(s) end)
CreateToggle("Chams", 58, false, function(s) chamsEnabled=s; UpdateChams(s) end)
CreateToggle("FullBright", 91, false, function(s) fullbrightEnabled=s; UpdateFullbright(s) end)
CreateSection("AIM", 126)
CreateToggle("Aimbot", 151, false, function(s) UpdateAimbot(s) end)
CreateToggle("Silent Aim", 184, false, function(s) UpdateSilentAim(s) end)
CreateSection("FARM", 219)
CreateToggle("Auto Farm", 244, false, function(s) StartAutoFarm(s) end)
CreateToggle("Auto Shoot", 277, false, function(s) ToggleAutoShoot(s) end)
CreateSection("TELEPORT", 312)
CreateButton("Murderer", 337, Color3.fromRGB(200, 50, 50), function()
    local murderers = GetRolePlayers("murderer")
    if #murderers > 0 then TeleportToPlayer(murderers[1]) end
end)
CreateButton("Sheriff", 372, Color3.fromRGB(50, 150, 255), function()
    local sheriffs = GetRolePlayers("sheriff")
    if #sheriffs > 0 then TeleportToPlayer(sheriffs[1]) end
end)
CreateButton("Lobby", 407, Color3.fromRGB(100, 100, 100), function()
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = lobby.CFrame * CFrame.new(0, 2, 0)
        end
    end
end)
CreateSection("MOVEMENT", 442)
CreateToggle("Fly", 467, false, function(s) ToggleFly(s) end)
CreateToggle("Noclip", 500, false, function(s) ToggleNoclip(s) end)
CreateToggle("Inf Jump", 533, false, function(s) ToggleInfiniteJump(s) end)
CreateSection("KILL", 568)
CreateButton("Kill All", 593, Color3.fromRGB(200, 30, 30), KillAllPlayers)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.15, 0, 0.08, 0)
closeBtn.Position = UDim2.new(0.85, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = MainFrame
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== ОБНОВЛЕНИЯ ИГРОКОВ =====
Players.PlayerAdded:Connect(function()
    if espEnabled then UpdateESP(true) end
    if chamsEnabled then UpdateChams(true) end
end)
Players.PlayerRemoving:Connect(function()
    if espEnabled then UpdateESP(true) end
    if chamsEnabled then UpdateChams(true) end
end)

-- ===== AIMBOT LOOP =====
RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if aimbotEnabled then
        local target = nil
        local closest = Config.AimbotFOV
        for _, player in ipairs(Players:GetPlayers()) do
            if player == Player then continue end
            local head = player.Character and player.Character:FindFirstChild("Head")
            if not head then continue end
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if dist < closest then
                closest = dist
                target = head
            end
        end
        if target then
            local currentCF = camera.CFrame
            local newCF = CFrame.new(currentCF.Position, target.Position)
            local newAngles = newCF:ToEulerAnglesYXZ()
            local currentAngles = currentCF:ToEulerAnglesYXZ()
            local smooth = currentAngles + (newAngles - currentAngles) * Config.AimbotSmoothness
            camera.CFrame = CFrame.new(currentCF.Position) * CFrame.Angles(smooth.Y, smooth.X, 0)
        end
    end
    if silentAimEnabled then
        local target = nil
        local closest = 300
        for _, player in ipairs(Players:GetPlayers()) do
            if player == Player then continue end
            local head = player.Character and player.Character:FindFirstChild("Head")
            if not head then continue end
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if dist < closest then
                closest = dist
                target = head
            end
        end
        if target then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
    end
end)

-- ===== ПРИ ПЕРЕРОЖДЕНИИ =====
Player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Config.SpeedValue
    if infiniteJumpEnabled then
        humanoid.JumpPower = 100
    else
        humanoid.JumpPower = Config.JumpPowerValue
    end
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if flyEnabled then
        ToggleFly(false)
        ToggleFly(true)
    end
end)

-- ===== АНТИ-АФК =====
pcall(function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

print("MM2 ULTIMATE HUB v3 loaded.")