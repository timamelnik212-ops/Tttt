-- =============================================
-- MM2 ULTIMATE HUB v4.0 (FULL REWORK)
-- Исправлено: Аимбот на Murderer, ESP/Chams, Infinite Jump
-- Удалено: Fly
-- =============================================

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- ===== НАСТРОЙКИ =====
local Config = {
    AimbotSmoothness = 0.08,
    AimbotFOV = 500,
    SpeedValue = 16,
    JumpPowerValue = 50,
    FarmRadius = 40,
}

-- ===== КРАСИВОЕ МЕНЮ (GUI) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "MM2Hub"

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Тень
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045739"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🔥 MM2 ULTIMATE v4"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Контейнер с прокруткой
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -16, 1, -90)
ScrollingFrame.Position = UDim2.new(0, 8, 0, 55)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 750)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
ScrollingFrame.Parent = MainFrame

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ GUI =====
local function CreateSection(title, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = "▸ " .. title
    label.TextColor3 = Color3.fromRGB(0, 220, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollingFrame
    return label
end

local function CreateToggle(text, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollingFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.22, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 50, 50)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.Parent = frame
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = toggle

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
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = ScrollingFrame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== ESP (улучшенный, с автоматическим обновлением ролей) =====
local espObjects = {}
local espEnabled = false

local function GetPlayerRole(player)
    local char = player.Character
    if not char then return "👤 Innocent", Color3.fromRGB(0, 255, 0) end

    local function checkTool(tool)
        if not tool:IsA("Tool") then return nil end
        local name = tool.Name:lower()
        if string.find(name, "knife") or string.find(name, "dagger") then
            return "🔪 Murderer", Color3.fromRGB(255, 0, 0)
        elseif string.find(name, "gun") or string.find(name, "revolver") then
            return "🔫 Sheriff", Color3.fromRGB(0, 150, 255)
        end
        return nil
    end

    for _, tool in pairs(char:GetChildren()) do
        local role, color = checkTool(tool)
        if role then return role, color end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            local role, color = checkTool(tool)
            if role then return role, color end
        end
    end

    return "👤 Innocent", Color3.fromRGB(0, 255, 0)
end

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

        local roleText, roleColor = GetPlayerRole(player)

        -- Highlight для Chams (теперь часть ESP)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = roleColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        table.insert(espObjects, highlight)

        -- Billboard с именем и ролью
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 220, 0, 60)
        bill.StudsOffset = Vector3.new(0, 3.5, 0)
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
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 15
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Parent = bill

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
        roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = roleText
        roleLabel.TextColor3 = roleColor
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.TextSize = 14
        roleLabel.TextStrokeTransparency = 0.3
        roleLabel.Parent = bill
    end
end

-- Автообновление ESP при появлении/исчезновении игроков или смене роли
local function RefreshESP()
    if espEnabled then UpdateESP(true) end
end

Players.PlayerAdded:Connect(RefreshESP)
Players.PlayerRemoving:Connect(RefreshESP)
-- Также обновляем при смене инструментов (примерно раз в секунду)
game:GetService("RunService").Heartbeat:Connect(function()
    if espEnabled then
        -- Проверяем, не изменилась ли роль у кого-то
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                -- Можно добавить более точную проверку, но для простоты просто пересоздаём ESP
                UpdateESP(true)
                break
            end
        end
    end
end)

-- ===== CHAMS (отдельно, но теперь интегрированы в ESP) =====
-- Chams теперь часть ESP, поэтому отдельная функция не нужна.
-- Но оставляем для совместимости с меню.
local chamsEnabled = false
local function UpdateChams(state)
    chamsEnabled = state
    -- Chams теперь включены в ESP, просто обновляем ESP
    if espEnabled then UpdateESP(true) end
end

-- ===== FULLBRIGHT =====
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
-- Часть 2: Аимбот (только на Murderer), Farm, Teleports, Noclip, Infinite Jump
-- =============================================

-- ===== АИМБОТ (наводится ТОЛЬКО на убийцу) =====
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

-- ===== ТЕЛЕПОРТЫ (исправлены) =====
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
        local function hasWeapon(weaponType)
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name:lower()
                    if weaponType == "murderer" and (string.find(name, "knife") or string.find(name, "dagger")) then
                        return true
                    elseif weaponType == "sheriff" and (string.find(name, "gun") or string.find(name, "revolver")) then
                        return true
                    end
                end
            end
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = tool.Name:lower()
                        if weaponType == "murderer" and (string.find(name, "knife") or string.find(name, "dagger")) then
                            return true
                        elseif weaponType == "sheriff" and (string.find(name, "gun") or string.find(name, "revolver")) then
                            return true
                        end
                    end
                end
            end
            return false
        end
        if role == "murderer" and hasWeapon("murderer") then
            table.insert(result, player)
        elseif role == "sheriff" and hasWeapon("sheriff") then
            table.insert(result, player)
        end
    end
    return result
end

-- ===== NOCLIP (исправлен) =====
local noclipEnabled = false
local noclipConnection = nil

local function ApplyNoclip(char)
    if not noclipEnabled then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function ToggleNoclip(state)
    noclipEnabled = state
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if state then
        local char = Player.Character
        if char then ApplyNoclip(char) end
        noclipConnection = Player.CharacterAdded:Connect(function(char)
            ApplyNoclip(char)
        end)
    else
        local char = Player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ===== БЕСКОНЕЧНЫЙ ПРЫЖОК (исправлен, работает идеально) =====
local infiniteJumpEnabled = false

local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
end

-- Перехват события прыжка
UserInput.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Также увеличиваем JumpPower для надежности
Player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    if infiniteJumpEnabled then
        humanoid.JumpPower = 100
    else
        humanoid.JumpPower = Config.JumpPowerValue
    end
end)

-- =============================================
-- Часть 3: Slider, KillAll, AutoShoot, UI, циклы аимбота, CharacterAdded
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
speedLabel.TextSize = 15
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0.3, 0)
sliderBg.Position = UDim2.new(0, 10, 0.5, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame
local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = sliderFill

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

-- ===== KILL ALL & AUTO SHOOT =====
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
CreateToggle("ESP + Chams", 30, false, function(s) espEnabled=s; UpdateESP(s) end)
CreateToggle("FullBright", 65, false, function(s) fullbrightEnabled=s; UpdateFullbright(s) end)
CreateSection("AIM", 105)
CreateToggle("Aimbot (на Murderer)", 135, false, function(s) UpdateAimbot(s) end)
CreateToggle("Silent Aim", 170, false, function(s) UpdateSilentAim(s) end)
CreateSection("FARM", 210)
CreateToggle("Auto Farm", 240, false, function(s) StartAutoFarm(s) end)
CreateToggle("Auto Shoot", 275, false, function(s) ToggleAutoShoot(s) end)
CreateSection("TELEPORT", 315)
CreateButton("К Murderer", 345, Color3.fromRGB(200, 50, 50), function()
    local murderers = GetRolePlayers("murderer")
    if #murderers > 0 then TeleportToPlayer(murderers[1]) end
end)
CreateButton("К Sheriff", 383, Color3.fromRGB(50, 150, 255), function()
    local sheriffs = GetRolePlayers("sheriff")
    if #sheriffs > 0 then TeleportToPlayer(sheriffs[1]) end
end)
CreateButton("В лобби", 421, Color3.fromRGB(100, 100, 100), function()
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = lobby.CFrame * CFrame.new(0, 2, 0)
        end
    end
end)
CreateSection("MOVEMENT", 465)
CreateToggle("Noclip", 495, false, function(s) ToggleNoclip(s) end)
CreateToggle("Infinite Jump", 530, false, function(s) ToggleInfiniteJump(s) end)
CreateSection("KILL", 570)
CreateButton("Kill All", 600, Color3.fromRGB(200, 30, 30), KillAllPlayers)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.15, 0, 0.08, 0)
closeBtn.Position = UDim2.new(0.85, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== УЛУЧШЕННЫЙ AIMBOT LOOP (только на Murderer) =====
RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then return end

    -- Находим убийцу
    local murderer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        local char = player.Character
        if not char then continue end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local isMurderer = false
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if string.find(name, "knife") or string.find(name, "dagger") then
                    isMurderer = true
                    break
                end
            end
        end
        if not isMurderer then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = tool.Name:lower()
                        if string.find(name, "knife") or string.find(name, "dagger") then
                            isMurderer = true
                            break
                        end
                    end
                end
            end
        end

        if isMurderer then
            murderer = player
            break
        end
    end

    -- Аимбот на убийцу
    if aimbotEnabled and murderer then
        local char = murderer.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < Config.AimbotFOV then
                        local currentCF = camera.CFrame
                        local newCF = CFrame.new(currentCF.Position, head.Position)
                        local newAngles = newCF:ToEulerAnglesYXZ()
                        local currentAngles = currentCF:ToEulerAnglesYXZ()
                        local smooth = currentAngles + (newAngles - currentAngles) * Config.AimbotSmoothness
                        camera.CFrame = CFrame.new(currentCF.Position) * CFrame.Angles(smooth.Y, smooth.X, 0)
                    end
                end
            end
        end
    end

    -- Silent Aim (тоже на убийцу)
    if silentAimEnabled and murderer then
        local char = murderer.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
            end
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
    if noclipEnabled then ApplyNoclip(char) end
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

print("MM2 ULTIMATE HUB v4.0 loaded.")

