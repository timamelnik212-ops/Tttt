-- =============================================
-- MM2 ULTIMATE HUB v5.1 (FINAL)
-- Удалены: Aimbot, Silent Aim, ползунок скорости, изменение JumpPower
-- Добавлены: TextBox для скорости, бесконечный прыжок без изменения высоты
-- =============================================

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Config = {
    SpeedValue = 16,
    FarmRadius = 40,
}

-- ===== КОМПАКТНОЕ МЕНЮ =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "MM2Hub"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 450)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🔥 MM2 ULTIMATE v5"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -12, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 6, 0, 44)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
ScrollingFrame.Parent = MainFrame

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
local function CreateSection(title, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = "▸ " .. title
    label.TextColor3 = Color3.fromRGB(0, 220, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollingFrame
    return label
end

local function CreateToggle(text, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 26)
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
    label.TextSize = 12
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.22, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 50, 50)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 11
    toggle.Parent = frame
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
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
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = ScrollingFrame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== ESP (с подсветкой пистолета шерифа) =====
local espObjects = {}
local espEnabled = false

local function GetPlayerRole(player)
    local char = player.Character
    if not char then return "👤 Innocent", Color3.fromRGB(0, 255, 0), false end

    local function checkTool(tool)
        if not tool:IsA("Tool") then return nil end
        local name = tool.Name:lower()
        if string.find(name, "knife") or string.find(name, "dagger") then
            return "🔪 Murderer", Color3.fromRGB(255, 0, 0), true
        elseif string.find(name, "gun") or string.find(name, "revolver") then
            return "🔫 Sheriff", Color3.fromRGB(0, 150, 255), false
        end
        return nil
    end

    for _, tool in pairs(char:GetChildren()) do
        local role, color, isMurderer = checkTool(tool)
        if role then return role, color, isMurderer end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            local role, color, isMurderer = checkTool(tool)
            if role then return role, color, isMurderer end
        end
    end

    return "👤 Innocent", Color3.fromRGB(0, 255, 0), false
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

        local roleText, roleColor, isMurderer = GetPlayerRole(player)
        local humanoid = char:FindFirstChild("Humanoid")
        local isDead = humanoid and humanoid.Health <= 0

        -- Подсветка самого игрока
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.FillColor = isDead and Color3.fromRGB(100,100,100) or roleColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        table.insert(espObjects, highlight)

        -- Если игрок мёртв и он был шерифом – подсвечиваем его пистолет (если он на земле)
        if isDead and not isMurderer then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    local name = obj.Name:lower()
                    if string.find(name, "gun") or string.find(name, "revolver") then
                        -- Проверяем, не принадлежит ли этот инструмент живому игроку
                        local owner = obj:FindFirstChild("Handle") and obj.Handle:FindFirstChild("Player")
                        if not owner or owner.Value ~= player then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = obj
                            hl.FillColor = Color3.fromRGB(0, 200, 255)
                            hl.FillTransparency = 0.3
                            hl.OutlineColor = Color3.fromRGB(255,255,255)
                            hl.OutlineTransparency = 0.1
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = obj
                            table.insert(espObjects, hl)
                        end
                    end
                end
            end
        end

        -- Billboard с именем и ролью
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 200, 0, 50)
        bill.StudsOffset = Vector3.new(0, 3, 0)
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
        nameLabel.TextColor3 = isDead and Color3.fromRGB(150,150,150) or Color3.fromRGB(255,255,255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Parent = bill

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
        roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = roleText
        roleLabel.TextColor3 = roleColor
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.TextSize = 12
        roleLabel.TextStrokeTransparency = 0.3
        roleLabel.Parent = bill
    end
end

-- Автообновление ESP
local function RefreshESP()
    if espEnabled then UpdateESP(true) end
end
Players.PlayerAdded:Connect(RefreshESP)
Players.PlayerRemoving:Connect(RefreshESP)
RunService.Heartbeat:Connect(function()
    if espEnabled then UpdateESP(true) end
end)

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
-- Часть 2: Фарм, телепорты, Noclip, Infinite Jump (без изменения JumpPower)
-- =============================================

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

-- ===== NOCLIP =====
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

-- ===== БЕСКОНЕЧНЫЙ ПРЫЖОК (НЕ меняет высоту) =====
local infiniteJumpEnabled = false

local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    -- НЕ трогаем JumpPower
end

-- Перехватываем запрос на прыжок
UserInput.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Если персонаж в воздухе, принудительно начинаем прыжок заново
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
    -- =============================================
-- Часть 3: Speed (TextBox), Kill All, Auto Shoot, UI, Events (без изменения JumpPower)
-- =============================================

-- ===== SPEED (ввод числа с клавиатуры) =====
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 40)
speedFrame.Position = UDim2.new(0, 0, 0, 340) -- располагаем в секции MOVEMENT
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = ScrollingFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.3, 0, 0.7, 0)
speedBox.Position = UDim2.new(0.45, 0, 0.15, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedBox.Text = tostring(Config.SpeedValue)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.PlaceholderText = "16"
speedBox.Parent = speedFrame
local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 4)
SpeedBoxCorner.Parent = speedBox

local speedSetBtn = Instance.new("TextButton")
speedSetBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
speedSetBtn.Position = UDim2.new(0.78, 0, 0.15, 0)
speedSetBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
speedSetBtn.Text = "Set"
speedSetBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedSetBtn.Font = Enum.Font.GothamBold
speedSetBtn.TextSize = 13
speedSetBtn.Parent = speedFrame
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = speedSetBtn

local function applySpeed(value)
    local spd = tonumber(value)
    if spd and spd > 0 then
        Config.SpeedValue = spd
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = spd
        end
        speedBox.Text = tostring(spd)
    else
        speedBox.Text = tostring(Config.SpeedValue)
    end
end

speedSetBtn.MouseButton1Click:Connect(function()
    applySpeed(speedBox.Text)
end)

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        applySpeed(speedBox.Text)
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

-- ===== ИНТЕРФЕЙС =====
CreateSection("VISUAL", 0)
CreateToggle("ESP + Chams", 25, false, function(s) espEnabled=s; UpdateESP(s) end)
CreateToggle("FullBright", 55, false, function(s) fullbrightEnabled=s; UpdateFullbright(s) end)

CreateSection("FARM", 90)
CreateToggle("Auto Farm", 115, false, function(s) StartAutoFarm(s) end)
CreateToggle("Auto Shoot", 145, false, function(s) ToggleAutoShoot(s) end)

CreateSection("TELEPORT", 180)
CreateButton("К Murderer", 205, Color3.fromRGB(200, 50, 50), function()
    local murderers = GetRolePlayers("murderer")
    if #murderers > 0 then TeleportToPlayer(murderers[1]) end
end)
CreateButton("К Sheriff", 237, Color3.fromRGB(50, 150, 255), function()
    local sheriffs = GetRolePlayers("sheriff")
    if #sheriffs > 0 then TeleportToPlayer(sheriffs[1]) end
end)
CreateButton("В лобби", 269, Color3.fromRGB(100, 100, 100), function()
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = lobby.CFrame * CFrame.new(0, 2, 0)
        end
    end
end)

CreateSection("MOVEMENT", 310)
CreateToggle("Noclip", 335, false, function(s) ToggleNoclip(s) end)
CreateToggle("Infinite Jump", 365, false, function(s) ToggleInfiniteJump(s) end)
-- speedFrame вставляется автоматически (создан выше, позиция 340)

CreateSection("KILL", 420)
CreateButton("Kill All", 445, Color3.fromRGB(200, 30, 30), KillAllPlayers)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.15, 0, 0.08, 0)
closeBtn.Position = UDim2.new(0.85, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== ПРИ ПЕРЕРОЖДЕНИИ (НЕ меняем JumpPower) =====
Player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Config.SpeedValue
    -- НЕ трогаем JumpPower
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

print("MM2 ULTIMATE HUB v5.1 loaded (no jump height change).")
end)
