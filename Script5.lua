-- ====================================================================
--  MODERN NEON MM2 GUI (POCO X6 PRO OPTIMIZED)
--  Все функции сохранены, UI переработан
-- ====================================================================

-- СЕРВИСЫ
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- УДАЛЯЕМ СТАРЫЙ GUI
if CoreGui:FindFirstChild("ModernNeonMM2") then
    CoreGui.ModernNeonMM2:Destroy()
end

-- УБОРКА МУСОРА В ПЕРСОНАЖЕ
local function cleanChar(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child.Name == "FlyVelocity" or child.Name == "FlingForce" then
                child:Destroy()
            end
        end
    end
    for _, child in pairs(char:GetDescendants()) do
        if (child:IsA("Highlight") and (child.Name == "NeonESP" or child.Name == "GunESP")) or child.Name == "GunLabel" or child.Name == "3D_GunLabel" then
            child:Destroy()
        end
    end
end
cleanChar(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(cleanChar)

-- КОНФИГ И СОХРАНЕНИЕ
_G.Config = {
    Speedhack = false, SpeedValue = 16,
    Noclip = false,
    GodModeToggle = false, GodModeType = "Loop",
    SpinBot = false, SpinSpeed = 30,
    FlyMode = false, FlySpeedValue = 40,
    OnePunchFling = false,
    ESPToggle = false,
    ESPColor = "WHITE",
    MM2Mod = false,
    MM2Roles = false,
    MM2Gun = false,
    MM2Shot = false,
    Target = false
}

local FILE_NAME = "ModernNeon_Config.json"
function _G.saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

if readfile and isfile and isfile(FILE_NAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
    if success then
        for k, v in pairs(decoded) do
            _G.Config[k] = v
        end
    end
end

-- ====================================================================
--  UI КОМПОНЕНТЫ
-- ====================================================================

-- Тень для фрейма
local function addShadow(frame, radius, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Image = "rbxassetid://5553946656"
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(Vector2.new(128,128), Vector2.new(384,384))
    shadow.Size = UDim2.new(1, radius*2, 1, radius*2)
    shadow.Position = UDim2.new(0, -radius, 0, -radius)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
    return shadow
end

-- Перетаскивание GUI
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
-- ====================================================================
--  СОЗДАНИЕ ГЛАВНОГО ЭКРАНА
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernNeonMM2"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Кнопка открытия (плавающая)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 52, 0, 52)
OpenBtn.Position = UDim2.new(0, 15, 0, 140)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "⚡"
OpenBtn.TextSize = 28
OpenBtn.TextColor3 = Color3.fromRGB(186, 85, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.ZIndex = 15
OpenBtn.Parent = ScreenGui
makeDraggable(OpenBtn)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local BStroke = Instance.new("UIStroke", OpenBtn)
BStroke.Color = Color3.fromRGB(186, 85, 255)
BStroke.Thickness = 2

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Visible = false
MainFrame.ZIndex = 12
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
addShadow(MainFrame, 8, 0.6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(186, 85, 255)

-- Анимация появления/скрытия
local function setVisibility(frame, visible)
    if visible then
        frame.Visible = true
        frame.Size = UDim2.new(0, 340, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 260)}):Play()
    else
        TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 340, 0, 0)}):Play()
        task.wait(0.15)
        frame.Visible = false
    end
end

-- Табы
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 13

local TabsLayout = Instance.new("UIListLayout", TabContainer)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 8)

local contentFrame = Instance.new("Frame", MainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 13

local tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0, 80, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.ZIndex = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", contentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.ZIndex = 14
    page.Visible = false
    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            t.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            t.page.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(186, 85, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    table.insert(tabs, {btn = btn, page = page})
    return page
end

local pPlayer = createTab("Player")
local pOther = createTab("Other")
local pSettings = createTab("Settings")

-- Активируем первую вкладку
tabs[1].btn.BackgroundColor3 = Color3.fromRGB(186, 85, 255)
tabs[1].btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabs[1].page.Visible = true

-- ====================================================================
--  ЭЛЕМЕНТЫ УПРАВЛЕНИЯ (ВИДЖЕТЫ)
-- ====================================================================

-- Стильный тогл (ползунок)
function createToggle(parent, configKey, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 15

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 15

    local toggleFrame = Instance.new("Frame", frame)
    toggleFrame.Size = UDim2.new(0, 40, 0, 20)
    toggleFrame.Position = UDim2.new(1, -50, 0.5, -10)
    toggleFrame.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 255) or Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)
    toggleFrame.ZIndex = 15

    local knob = Instance.new("Frame", toggleFrame)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, _G.Config[configKey] and 22 or 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.ZIndex = 16

    local state = _G.Config[configKey]
    local function updateVisual()
        toggleFrame.BackgroundColor3 = state and Color3.fromRGB(186, 85, 255) or Color3.fromRGB(60, 60, 60)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            _G.Config[configKey] = state
            updateVisual()
            _G.saveSettings()
        end
    end)
    return {OnToggle = function(cb) end}
end

-- Слайдер с числом и кнопкой настройки
function createSliderWithButton(parent, configKey, speedKey, text, min, max)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundTransparency = 1
    container.ZIndex = 15

    local header = Instance.new("Frame", container)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.ZIndex = 15

    local label = Instance.new("TextLabel", header)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", header)
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(1, -40, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(_G.Config[speedKey])
    valueLabel.TextColor3 = Color3.fromRGB(186, 85, 255)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local gearBtn = Instance.new("TextButton", header)
    gearBtn.Size = UDim2.new(0, 24, 0, 24)
    gearBtn.Position = UDim2.new(1, -80, 0.5, -12)
    gearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    gearBtn.Text = "⚙"
    gearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    gearBtn.Font = Enum.Font.SourceSans
    gearBtn.TextSize = 14
    gearBtn.ZIndex = 16
    Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 6)

    local sliderBar = Instance.new("Frame", container)
    sliderBar.Size = UDim2.new(1, 0, 0, 8)
    sliderBar.Position = UDim2.new(0, 0, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBar.ZIndex = 15
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBar)
    local percentage = (_G.Config[speedKey] - min) / (max - min)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(186, 85, 255)
    sliderFill.ZIndex = 16
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local function updateSlider(input)
        local barSize = sliderBar.AbsoluteSize.X
        local pos = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, barSize)
        local perc = pos / barSize
        local val = math.floor(min + perc * (max - min))
        _G.Config[speedKey] = val
        valueLabel.Text = tostring(val)
        sliderFill.Size = UDim2.new(perc, 0, 1, 0)
        _G.saveSettings()
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    -- Тогл активации
    local toggleBtn = Instance.new("TextButton", container)
    toggleBtn.Size = UDim2.new(0, 30, 0, 18)
    toggleBtn.Position = UDim2.new(0, 110, 0, 6)
    toggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 255) or Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 15
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleKnob = Instance.new("Frame", toggleBtn)
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = UDim2.new(0, _G.Config[configKey] and 14 or 2, 0.5, -7)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)
    toggleKnob.ZIndex = 16

    local toggleState = _G.Config[configKey]
    toggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        _G.Config[configKey] = toggleState
        toggleBtn.BackgroundColor3 = toggleState and Color3.fromRGB(186, 85, 255) or Color3.fromRGB(60, 60, 60)
        TweenService:Create(toggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, toggleState and 14 or 2, 0.5, -7)}):Play()
        _G.saveSettings()
    end)
end-- ====================================================================
--  ЗАПОЛНЯЕМ ВКЛАДКИ
-- ====================================================================

-- PLAYER
createSliderWithButton(pPlayer, "Speedhack", "SpeedValue", "WalkSpeed", 16, 250)
createSliderWithButton(pPlayer, "FlyMode", "FlySpeedValue", "Fly Speed", 10, 200)
createSliderWithButton(pPlayer, "SpinBot", "SpinSpeed", "Spin Bot", 10, 150)
createToggle(pPlayer, "Noclip", "Noclip")

-- OTHER
createToggle(pOther, "OnePunchFling", "One Punch Fling")
createToggle(pOther, "ESPToggle", "ESP (all)")
-- Godmode
local godFrame = Instance.new("Frame", pOther)
godFrame.Size = UDim2.new(1, 0, 0, 60)
godFrame.BackgroundTransparency = 1
godFrame.ZIndex = 15
local godLabel = Instance.new("TextLabel", godFrame)
godLabel.Size = UDim2.new(1, 0, 0, 25)
godLabel.BackgroundTransparency = 1
godLabel.Text = "God Mode"
godLabel.TextColor3 = Color3.fromRGB(255,255,255)
godLabel.Font = Enum.Font.SourceSans
godLabel.TextSize = 13
godLabel.TextXAlignment = Enum.TextXAlignment.Left

local godTypeBtn = Instance.new("TextButton", godFrame)
godTypeBtn.Size = UDim2.new(0, 60, 0, 24)
godTypeBtn.Position = UDim2.new(0, 100, 0, 30)
godTypeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
godTypeBtn.Text = _G.Config.GodModeType == "Loop" and "Loop" or "Block"
godTypeBtn.TextColor3 = Color3.fromRGB(255,255,255)
godTypeBtn.Font = Enum.Font.SourceSans
godTypeBtn.TextSize = 12
Instance.new("UICorner", godTypeBtn).CornerRadius = UDim.new(0, 6)
godTypeBtn.ZIndex = 15
godTypeBtn.MouseButton1Click:Connect(function()
    if _G.Config.GodModeType == "Loop" then
        _G.Config.GodModeType = "Block"
        godTypeBtn.Text = "Block"
    else
        _G.Config.GodModeType = "Loop"
        godTypeBtn.Text = "Loop"
    end
    _G.saveSettings()
end)

local godToggle = createToggle(godFrame, "GodModeToggle", "Activate")

-- SETTINGS
local rejoinBtn = Instance.new("TextButton", pSettings)
rejoinBtn.Size = UDim2.new(1, -20, 0, 35)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rejoinBtn.Text = "Private Server"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Font = Enum.Font.SourceSansBold
rejoinBtn.TextSize = 13
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 8)
local rjStroke = Instance.new("UIStroke", rejoinBtn)
rjStroke.Color = Color3.fromRGB(186, 85, 255)
rjStroke.Thickness = 1.5
rejoinBtn.MouseButton1Click:Connect(function()
    local reserved = TeleportService:ReserveServer(game.PlaceId)
    if reserved and reserved ~= "" then
        TeleportService:TeleportToPrivateServer(game.PlaceId, reserved, {LocalPlayer})
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

local resetBtn = Instance.new("TextButton", pSettings)
resetBtn.Size = UDim2.new(1, -20, 0, 35)
resetBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
resetBtn.Text = "Reset & Close"
resetBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 13
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
local rsStroke = Instance.new("UIStroke", resetBtn)
rsStroke.Color = Color3.fromRGB(255, 50, 50)
rsStroke.Thickness = 1.5
resetBtn.MouseButton1Click:Connect(function()
    if delfile and isfile(FILE_NAME) then delfile(FILE_NAME) end
    if ScreenGui then ScreenGui:Destroy() end
end)

-- ====================================================================
--  MM2 ОКНО (ПОЯВЛЯЕТСЯ ПРИ АКТИВАЦИИ MM2Mod)
-- ====================================================================
local MM2Window = Instance.new("Frame")
MM2Window.Size = UDim2.new(0, 220, 0, 160)
MM2Window.Position = UDim2.new(0.5, 180, 0.5, -80)
MM2Window.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MM2Window.Visible = false
MM2Window.ZIndex = 20
MM2Window.Parent = ScreenGui
makeDraggable(MM2Window)
Instance.new("UICorner", MM2Window).CornerRadius = UDim.new(0, 8)
addShadow(MM2Window, 6, 0.6)
Instance.new("UIStroke", MM2Window).Color = Color3.fromRGB(255, 65, 65)

local MM2Title = Instance.new("TextLabel", MM2Window)
MM2Title.Size = UDim2.new(1, 0, 0, 30)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 DASHBOARD"
MM2Title.TextColor3 = Color3.fromRGB(255, 65, 65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 14
MM2Title.ZIndex = 21

local MM2Content = Instance.new("Frame", MM2Window)
MM2Content.Size = UDim2.new(1, -10, 1, -40)
MM2Content.Position = UDim2.new(0, 5, 0, 35)
MM2Content.BackgroundTransparency = 1
MM2Content.ZIndex = 21
local MM2Layout = Instance.new("UIListLayout", MM2Content)
MM2Layout.Padding = UDim.new(0, 6)

-- MM2 кнопки
createToggle(MM2Content, "MM2Roles", "Roles Chams")
createToggle(MM2Content, "MM2Gun", "Gun Chams")
createToggle(MM2Content, "MM2Shot", "Auto Shot")
createToggle(MM2Content, "Target", "TP Gun")

local closeMM2 = Instance.new("TextButton", MM2Window)
closeMM2.Size = UDim2.new(0, 30, 0, 30)
closeMM2.Position = UDim2.new(1, -35, 0, 0)
closeMM2.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeMM2.Text = "✕"
closeMM2.TextColor3 = Color3.fromRGB(255, 255, 255)
closeMM2.Font = Enum.Font.SourceSansBold
closeMM2.TextSize = 18
closeMM2.ZIndex = 22
Instance.new("UICorner", closeMM2).CornerRadius = UDim.new(0, 5)
closeMM2.MouseButton1Click:Connect(function()
    _G.Config.MM2Mod = false
    _G.Config.MM2Roles = false
    _G.Config.MM2Gun = false
    _G.Config.MM2Shot = false
    _G.Config.Target = false
    MM2Window.Visible = false
    _G.saveSettings()
end)

-- Кнопки SHOT и TP GUN (плавающие)
local shotBtn = Instance.new("TextButton")
shotBtn.Size = UDim2.new(0, 60, 0, 60)
shotBtn.Position = UDim2.new(0, 15, 0, 210)
shotBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
shotBtn.Text = "SHOT"
shotBtn.TextSize = 12
shotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shotBtn.Font = Enum.Font.SourceSansBold
shotBtn.ZIndex = 15
shotBtn.Visible = false
shotBtn.Parent = ScreenGui
makeDraggable(shotBtn)
Instance.new("UICorner", shotBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", shotBtn).Color = Color3.fromRGB(50, 255, 50)

local tpGunBtn = Instance.new("TextButton")
tpGunBtn.Size = UDim2.new(0, 60, 0, 60)
tpGunBtn.Position = UDim2.new(0, 15, 0, 280)
tpGunBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tpGunBtn.Text = "TP GUN"
tpGunBtn.TextSize = 11
tpGunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpGunBtn.Font = Enum.Font.SourceSansBold
tpGunBtn.ZIndex = 15
tpGunBtn.Visible = false
tpGunBtn.Parent = ScreenGui
makeDraggable(tpGunBtn)
Instance.new("UICorner", tpGunBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", tpGunBtn).Color = Color3.fromRGB(50, 150, 255)

local function updateShotButton()
    shotBtn.Visible = _G.Config.MM2Shot and _G.Config.MM2Mod
end
local function updateTpButton()
    tpGunBtn.Visible = _G.Config.Target and _G.Config.MM2Mod
end
-- ====================================================================
--  ЛОГИКА ЧИТОВ
-- ====================================================================
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    -- Speedhack
    if hum then
        if _G.Config.Speedhack and not _G.Config.FlyMode then
            hum.WalkSpeed = _G.Config.SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end

    -- Noclip
    if _G.Config.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Spinbot
    if _G.Config.SpinBot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Config.SpinSpeed), 0)
    end

    -- Fly
    if _G.Config.FlyMode then
        if not root:FindFirstChild("FlyVelocity") then
            local fv = Instance.new("BodyVelocity")
            fv.Name = "FlyVelocity"
            fv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = root
        end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0,0,0)
        if hum and hum.MoveDirection.Magnitude > 0 then
            moveDir = hum.MoveDirection
            local look = cam.CFrame.LookVector
            moveDir = Vector3.new(moveDir.X, look.Y, moveDir.Z)
        end
        if moveDir.Magnitude > 0 then
            root.FlyVelocity.Velocity = moveDir.Unit * _G.Config.FlySpeedValue
        else
            root.FlyVelocity.Velocity = Vector3.new(0, 0.05, 0)
        end
    else
        if root:FindFirstChild("FlyVelocity") then
            root.FlyVelocity:Destroy()
        end
    end
end)

-- Godmode
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if _G.Config.GodModeToggle then
        if _G.Config.GodModeType == "Loop" then
            spawn(function()
                while _G.Config.GodModeToggle and char.Parent and hum and hum.Health > 0 do
                    hum.Health = hum.MaxHealth
                    task.wait(0.1)
                end
            end)
        elseif _G.Config.GodModeType == "Block" then
            hum.HealthChanged:Connect(function()
                if _G.Config.GodModeToggle and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
    end
end)

-- One Punch Fling (Heartbeat)
RunService.Heartbeat:Connect(function()
    if not _G.Config.OnePunchFling or not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local targetRoot = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < 50 then
                targetRoot = p.Character.HumanoidRootPart
                break
            end
        end
    end
    if targetRoot then
        local dir = (targetRoot.Position - myRoot.Position).Unit
        targetRoot.AssemblyLinearVelocity = dir * 100 + Vector3.new(0, 500, 0)
        task.wait(0.02)
    end
end)

-- Auto Shot (кнопка SHOT)
shotBtn.MouseButton1Click:Connect(function()
    if not _G.Config.MM2Shot or not LocalPlayer.Character then return end
    local myChar = LocalPlayer.Character
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local gun = myChar:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return end
    if gun.Parent == LocalPlayer.Backpack then
        hum:EquipTool(gun)
        task.wait(0.15)
    end
    local murdererRoot = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
            murdererRoot = p.Character:FindFirstChild("HumanoidRootPart")
            break
        end
    end
    if not murdererRoot then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    myRoot.CFrame = CFrame.new(myRoot.Position, murdererRoot.Position)
    task.wait(0.08)
    local fired = false
    local remote = gun:FindFirstChild("Fire") or gun:FindFirstChild("Shoot")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(murdererRoot.Position) end)
        fired = true
    end
    if not fired then
        pcall(function() gun:Activate() end)
    end
    task.wait(0.2)
end)

-- TP Gun
tpGunBtn.MouseButton1Click:Connect(function()
    if not _G.Config.Target or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local droppedGun = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") then
            droppedGun = obj.Handle
            break
        end
    end
    if droppedGun and droppedGun:IsA("BasePart") then
        local oldCF = root.CFrame
        root.CFrame = droppedGun.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.5)
        root.CFrame = oldCF
    end
end)
-- ESP
local function getMM2Color(player)
    if not player.Character then return Color3.fromRGB(255, 255, 255) end
    if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return Color3.fromRGB(255, 50, 50) -- убийца
    end
    if player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return Color3.fromRGB(50, 150, 255) -- шериф
    end
    return Color3.fromRGB(255, 255, 255) -- невинный
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Character then return end
        local highlight = player.Character:FindFirstChild("NeonESP")
        if _G.Config.MM2Roles or _G.Config.ESPToggle then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "NeonESP"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0.1
                highlight.Parent = player.Character
            end
            if _G.Config.MM2Roles then
                local rColor = getMM2Color(player)
                highlight.FillColor = rColor
                highlight.OutlineColor = rColor
            else
                highlight.FillColor = Color3.fromRGB(186, 85, 255)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        else
            if highlight then highlight:Destroy() end
        end
    end)
    player.CharacterAdded:Connect(function()
        connection:Disconnect()
        applyPlayerESP(player)
    end)
end

Players.PlayerAdded:Connect(applyPlayerESP)
for _, p in pairs(Players:GetPlayers()) do applyPlayerESP(p) end

-- Gun ESP
RunService.Heartbeat:Connect(function()
    local gunDrop = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") then
            gunDrop = obj
            break
        end
    end
    if gunDrop and _G.Config.MM2Gun then
        local handle = gunDrop.Handle
        if not handle:FindFirstChild("GunESP") then
            local hl = Instance.new("BoxHandleAdornment", handle)
            hl.Name = "GunESP"
            hl.AlwaysOnTop = true
            hl.Color3 = Color3.fromRGB(50, 255, 50)
            hl.Size = handle.Size * 1.5
            hl.Adornee = handle
            hl.Transparency = 0.3
            hl.ZIndex = 6
        end
        if not handle:FindFirstChild("3D_GunLabel") then
            local bg = Instance.new("BillboardGui", handle)
            bg.Name = "3D_GunLabel"
            bg.Size = UDim2.new(0, 60, 0, 25)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.Adornee = handle
            local lbl = Instance.new("TextLabel", bg)
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "GUN"
            lbl.TextColor3 = Color3.fromRGB(50,255,50)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.TextStrokeTransparency = 0
            lbl.TextStrokeColor3 = Color3.new(0,0,0)
        end
    end
end)

-- ====================================================================
--  ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ
-- ====================================================================
OpenBtn.MouseButton1Click:Connect(function()
    local newState = not MainFrame.Visible
    if newState then
        setVisibility(MainFrame, true)
        if _G.Config.MM2Mod then
            MM2Window.Visible = true
            MM2Window.Size = UDim2.new(0, 220, 0, 0)
            TweenService:Create(MM2Window, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 220, 0, 160)}):Play()
        end
    else
        setVisibility(MainFrame, false)
        MM2Window.Visible = false
    end
    updateShotButton()
    updateTpButton()
end)

-- Обновление видимости MM2 окна при изменении конфига
RunService.Heartbeat:Connect(function()
    if _G.Config.MM2Mod and MainFrame.Visible and not MM2Window.Visible then
        MM2Window.Visible = true
        TweenService:Create(MM2Window, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, 160)}):Play()
    elseif not _G.Config.MM2Mod and MM2Window.Visible then
        MM2Window.Visible = false
    end
    updateShotButton()
    updateTpButton()
end)

-- Сохранение при закрытии игры
game:BindToClose(function()
    _G.saveSettings()
end)
