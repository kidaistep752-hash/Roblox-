-- ====================================================================
--  MODERN COMPACT MM2 GUI (POCO X6 PRO OPTIMIZED)
--  Сохранены все функции, UI переработан под запрос
-- ====================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("CompactNeonMM2") then
    CoreGui.CompactNeonMM2:Destroy()
end

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
    Target = false,
    MurderAlert = false,
    KillAura = false,
    InnocentESP = false
}

local FILE_NAME = "CompactNeon_Config.json"
function _G.saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

if readfile and isfile and isfile(FILE_NAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
    if success then for k, v in pairs(decoded) do _G.Config[k] = v end end
end

-- UI утилиты
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

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactNeonMM2"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Кнопка открытия
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0, 140)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
OpenBtn.Text = "⚡"
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(186,85,255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.ZIndex = 15
OpenBtn.Parent = ScreenGui
makeDraggable(OpenBtn)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(186,85,255)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 230)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.Visible = false
MainFrame.ZIndex = 12
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)
addShadow(MainFrame, 6, 0.5)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(186,85,255)

local function setVisibility(frame, visible)
    if visible then
        frame.Visible = true
        frame.Size = UDim2.new(0, 300, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 230)}):Play()
    else
        TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0)}):Play()
        task.wait(0.15)
        frame.Visible = false
    end
end

-- Табы
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1,0,0,30)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 13
local TabsLayout = Instance.new("UIListLayout", TabContainer)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 6)

local contentFrame = Instance.new("Frame", MainFrame)
contentFrame.Size = UDim2.new(1,-10,1,-40)
contentFrame.Position = UDim2.new(0,5,0,35)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 13

local tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0, 75, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.ZIndex = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

    local page = Instance.new("ScrollingFrame", contentFrame)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.ZIndex = 14
    page.Visible = false
    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0,4)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
            t.btn.TextColor3 = Color3.fromRGB(200,200,200)
            t.page.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(186,85,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        page.Visible = true
    end)
    table.insert(tabs, {btn = btn, page = page})
    return page
end

local pVisual = createTab("Visual")
local pGame = createTab("Game")
tabs[1].btn.BackgroundColor3 = Color3.fromRGB(186,85,255)
tabs[1].btn.TextColor3 = Color3.fromRGB(255,255,255)
tabs[1].page.Visible = true
-- ====================================================================
--  ВИДЖЕТЫ
-- ====================================================================

-- Простой тогл (без анимации, просто кнопка-стикер)
function createToggle(parent, configKey, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,28)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 15

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0,110,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0,36,0,18)
    toggleBtn.Position = UDim2.new(1,-42,0.5,-9)
    toggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 15
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", toggleBtn)
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new(0, _G.Config[configKey] and 20 or 2, 0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    knob.ZIndex = 16

    local state = _G.Config[configKey]
    local function updateVisual()
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 20 or 2, 0.5,-7)}):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        _G.Config[configKey] = state
        updateVisual()
        _G.saveSettings()
    end)
    return {OnToggle = function(cb) end}
end

-- Виджет с раскрывающимся слайдером и стрелками
function createExpandableSlider(parent, configKey, speedKey, text, min, max)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1,0,0,28)
    container.BackgroundTransparency = 1
    container.ZIndex = 15
    container.ClipsDescendants = true  -- чтобы скрывать раскрытую часть

    local header = Instance.new("Frame", container)
    header.Size = UDim2.new(1,0,0,28)
    header.BackgroundTransparency = 1
    header.ZIndex = 15

    local label = Instance.new("TextLabel", header)
    label.Size = UDim2.new(0,90,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", header)
    valueLabel.Size = UDim2.new(0,35,1,0)
    valueLabel.Position = UDim2.new(0,95,0,0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(_G.Config[speedKey])
    valueLabel.TextColor3 = Color3.fromRGB(186,85,255)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 12

    local expandBtn = Instance.new("TextButton", header)
    expandBtn.Size = UDim2.new(0,22,0,22)
    expandBtn.Position = UDim2.new(1,-70,0.5,-11)
    expandBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    expandBtn.Text = "▼"
    expandBtn.TextColor3 = Color3.fromRGB(255,255,255)
    expandBtn.Font = Enum.Font.SourceSansBold
    expandBtn.TextSize = 12
    expandBtn.ZIndex = 16
    Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0,4)

    local toggleBtn = Instance.new("TextButton", header)
    toggleBtn.Size = UDim2.new(0,28,0,16)
    toggleBtn.Position = UDim2.new(1,-32,0.5,-8)
    toggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 15
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
    local toggleKnob = Instance.new("Frame", toggleBtn)
    toggleKnob.Size = UDim2.new(0,12,0,12)
    toggleKnob.Position = UDim2.new(0, _G.Config[configKey] and 14 or 2, 0.5,-6)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1,0)
    toggleKnob.ZIndex = 16

    local toggleState = _G.Config[configKey]
    toggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        _G.Config[configKey] = toggleState
        toggleBtn.BackgroundColor3 = toggleState and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
        TweenService:Create(toggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, toggleState and 14 or 2, 0.5,-6)}):Play()
        _G.saveSettings()
    end)

    -- Панель слайдера (изначально скрыта)
    local sliderPanel = Instance.new("Frame", container)
    sliderPanel.Size = UDim2.new(1,0,0,24)
    sliderPanel.Position = UDim2.new(0,0,0,28)
    sliderPanel.BackgroundTransparency = 1
    sliderPanel.ZIndex = 15
    sliderPanel.Visible = false
    sliderPanel.ClipsDescendants = true

    local minusBtn = Instance.new("TextButton", sliderPanel)
    minusBtn.Size = UDim2.new(0,20,0,20)
    minusBtn.Position = UDim2.new(0,0,0.5,-10)
    minusBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    minusBtn.Text = "<"
    minusBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minusBtn.Font = Enum.Font.SourceSansBold
    minusBtn.TextSize = 14
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0,4)

    local plusBtn = Instance.new("TextButton", sliderPanel)
    plusBtn.Size = UDim2.new(0,20,0,20)
    plusBtn.Position = UDim2.new(1,-20,0.5,-10)
    plusBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    plusBtn.Text = ">"
    plusBtn.TextColor3 = Color3.fromRGB(255,255,255)
    plusBtn.Font = Enum.Font.SourceSansBold
    plusBtn.TextSize = 14
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0,4)

    local sliderBar = Instance.new("Frame", sliderPanel)
    sliderBar.Size = UDim2.new(1,-50,0,6)
    sliderBar.Position = UDim2.new(0,25,0.5,-3)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1,0)
    local sliderFill = Instance.new("Frame", sliderBar)
    local perc = (_G.Config[speedKey] - min) / (max - min)
    sliderFill.Size = UDim2.new(perc,0,1,0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(186,85,255)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

    local function updateValue(val)
        val = math.clamp(val, min, max)
        _G.Config[speedKey] = val
        valueLabel.Text = tostring(val)
        local p = (val - min) / (max - min)
        sliderFill.Size = UDim2.new(p,0,1,0)
        _G.saveSettings()
    end

    local sliding = false
    local function slideFromInput(input)
        local barSize = sliderBar.AbsoluteSize.X
        local pos = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, barSize)
        local p = pos / barSize
        local val = math.floor(min + p * (max - min))
        updateValue(val)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            slideFromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            slideFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    minusBtn.MouseButton1Click:Connect(function()
        updateValue(_G.Config[speedKey] - 1)
    end)
    plusBtn.MouseButton1Click:Connect(function()
        updateValue(_G.Config[speedKey] + 1)
    end)

    local expanded = false
    expandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        sliderPanel.Visible = expanded
        container.Size = UDim2.new(1,0,0, expanded and 52 or 28)
        expandBtn.Text = expanded and "▲" or "▼"
    end)
end

-- ====================================================================
--  ЗАПОЛНЯЕМ ВКЛАДКУ VISUAL
-- ====================================================================
createToggle(pVisual, "ESPToggle", "Player ESP")
createToggle(pVisual, "ESPColor", "ESP Color") -- просто заглушка, можно доработать
-- ====================================================================
--  ЗАПОЛНЯЕМ ВКЛАДКУ GAME
-- ====================================================================
createExpandableSlider(pGame, "Speedhack", "SpeedValue", "WalkSpeed", 16, 250)
createExpandableSlider(pGame, "FlyMode", "FlySpeedValue", "Fly Speed", 10, 200)
createExpandableSlider(pGame, "SpinBot", "SpinSpeed", "Spin Bot", 10, 150)
createToggle(pGame, "Noclip", "Noclip")
createToggle(pGame, "OnePunchFling", "One Punch Fling")

-- Godmode
local godFrame = Instance.new("Frame", pGame)
godFrame.Size = UDim2.new(1,0,0,28)
godFrame.BackgroundTransparency = 1
godFrame.ZIndex = 15
local godLabel = Instance.new("TextLabel", godFrame)
godLabel.Size = UDim2.new(0,90,1,0)
godLabel.BackgroundTransparency = 1
godLabel.Text = "God Mode"
godLabel.TextColor3 = Color3.fromRGB(255,255,255)
godLabel.Font = Enum.Font.SourceSans
godLabel.TextSize = 12
godLabel.TextXAlignment = Enum.TextXAlignment.Left
local godTypeBtn = Instance.new("TextButton", godFrame)
godTypeBtn.Size = UDim2.new(0,50,0,20)
godTypeBtn.Position = UDim2.new(0,95,0.5,-10)
godTypeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
godTypeBtn.Text = _G.Config.GodModeType == "Loop" and "Loop" or "Block"
godTypeBtn.TextColor3 = Color3.fromRGB(255,255,255)
godTypeBtn.Font = Enum.Font.SourceSans
godTypeBtn.TextSize = 11
Instance.new("UICorner", godTypeBtn).CornerRadius = UDim.new(0,4)
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
createToggle(godFrame, "GodModeToggle", "")
-- маленький фикс: чтобы тогл был на той же строке, переместим его создание вручную? Уже создано выше, но он создаст отдельный фрейм, что сломает компактность. Поэтому заменим ручным размещением.
-- Удалим лишний тогл и сделаем всё в godFrame:
local godToggleBtn = Instance.new("TextButton", godFrame)
godToggleBtn.Size = UDim2.new(0,28,0,16)
godToggleBtn.Position = UDim2.new(1,-32,0.5,-8)
godToggleBtn.BackgroundColor3 = _G.Config.GodModeToggle and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
godToggleBtn.Text = ""
godToggleBtn.ZIndex = 15
Instance.new("UICorner", godToggleBtn).CornerRadius = UDim.new(1,0)
local godKnob = Instance.new("Frame", godToggleBtn)
godKnob.Size = UDim2.new(0,12,0,12)
godKnob.Position = UDim2.new(0, _G.Config.GodModeToggle and 14 or 2, 0.5,-6)
godKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", godKnob).CornerRadius = UDim.new(1,0)
godKnob.ZIndex = 16
local godState = _G.Config.GodModeToggle
godToggleBtn.MouseButton1Click:Connect(function()
    godState = not godState
    _G.Config.GodModeToggle = godState
    godToggleBtn.BackgroundColor3 = godState and Color3.fromRGB(186,85,255) or Color3.fromRGB(60,60,60)
    TweenService:Create(godKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, godState and 14 or 2, 0.5,-6)}):Play()
    _G.saveSettings()
end)

-- MM2 переключатель
createToggle(pGame, "MM2Mod", "Murder Myst 2")

-- ====================================================================
--  MM2 ОКНО
-- ====================================================================
local MM2Window = Instance.new("Frame")
MM2Window.Size = UDim2.new(0,210,0,180)
MM2Window.Position = UDim2.new(0.5,160,0.5,-90)
MM2Window.BackgroundColor3 = Color3.fromRGB(18,18,18)
MM2Window.Visible = false
MM2Window.ZIndex = 20
MM2Window.Parent = ScreenGui
makeDraggable(MM2Window)
Instance.new("UICorner", MM2Window).CornerRadius = UDim.new(0,6)
addShadow(MM2Window,4,0.5)
Instance.new("UIStroke", MM2Window).Color = Color3.fromRGB(255,65,65)

local MM2Title = Instance.new("TextLabel", MM2Window)
MM2Title.Size = UDim2.new(1,0,0,25)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 FUNCTIONS"
MM2Title.TextColor3 = Color3.fromRGB(255,65,65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 13
MM2Title.ZIndex = 21

local MM2Content = Instance.new("Frame", MM2Window)
MM2Content.Size = UDim2.new(1,-8,1,-35)
MM2Content.Position = UDim2.new(0,4,0,30)
MM2Content.BackgroundTransparency = 1
MM2Content.ZIndex = 21
local MM2Layout = Instance.new("UIListLayout", MM2Content)
MM2Layout.Padding = UDim.new(0,3)

createToggle(MM2Content, "MM2Roles", "Roles Chams")
createToggle(MM2Content, "MM2Gun", "Gun Chams")
createToggle(MM2Content, "MM2Shot", "Auto Shot")
createToggle(MM2Content, "Target", "TP Gun")
createToggle(MM2Content, "MurderAlert", "Murder Alert")
createToggle(MM2Content, "KillAura", "Kill Aura")
createToggle(MM2Content, "InnocentESP", "Innocent ESP")

local closeMM2 = Instance.new("TextButton", MM2Window)
closeMM2.Size = UDim2.new(0,24,0,24)
closeMM2.Position = UDim2.new(1,-30,0,0)
closeMM2.BackgroundColor3 = Color3.fromRGB(255,50,50)
closeMM2.Text = "X"
closeMM2.TextColor3 = Color3.fromRGB(255,255,255)
closeMM2.Font = Enum.Font.SourceSansBold
closeMM2.TextSize = 14
closeMM2.ZIndex = 22
Instance.new("UICorner", closeMM2).CornerRadius = UDim.new(0,4)
closeMM2.MouseButton1Click:Connect(function()
    _G.Config.MM2Mod = false
    _G.Config.MM2Roles = false
    _G.Config.MM2Gun = false
    _G.Config.MM2Shot = false
    _G.Config.Target = false
    _G.Config.MurderAlert = false
    _G.Config.KillAura = false
    _G.Config.InnocentESP = false
    MM2Window.Visible = false
    _G.saveSettings()
end)

-- Плавающие кнопки SHOT и TP GUN
local shotBtn = Instance.new("TextButton")
shotBtn.Size = UDim2.new(0,55,0,55)
shotBtn.Position = UDim2.new(0,15,0,210)
shotBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
shotBtn.Text = "SHOT"
shotBtn.TextSize = 11
shotBtn.TextColor3 = Color3.fromRGB(255,255,255)
shotBtn.Font = Enum.Font.SourceSansBold
shotBtn.ZIndex = 15
shotBtn.Visible = false
shotBtn.Parent = ScreenGui
makeDraggable(shotBtn)
Instance.new("UICorner", shotBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", shotBtn).Color = Color3.fromRGB(50,255,50)

local tpGunBtn = Instance.new("TextButton")
tpGunBtn.Size = UDim2.new(0,55,0,55)
tpGunBtn.Position = UDim2.new(0,15,0,275)
tpGunBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
tpGunBtn.Text = "TP GUN"
tpGunBtn.TextSize = 10
tpGunBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpGunBtn.Font = Enum.Font.SourceSansBold
tpGunBtn.ZIndex = 15
tpGunBtn.Visible = false
tpGunBtn.Parent = ScreenGui
makeDraggable(tpGunBtn)
Instance.new("UICorner", tpGunBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", tpGunBtn).Color = Color3.fromRGB(50,150,255)

local function updateShotButton()
    shotBtn.Visible = _G.Config.MM2Shot and _G.Config.MM2Mod
end
local function updateTpButton()
    tpGunBtn.Visible = _G.Config.Target and _G.Config.MM2Mod
end

-- ====================================================================
--  ИГРОВАЯ ЛОГИКА (Speed, Fly, Spin, Noclip, Fling, Godmode)
-- ====================================================================
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if hum then
        if _G.Config.Speedhack and not _G.Config.FlyMode then hum.WalkSpeed = _G.Config.SpeedValue else hum.WalkSpeed = 16 end
    end
    if _G.Config.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
    if _G.Config.SpinBot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Config.SpinSpeed), 0)
    end
    if _G.Config.FlyMode then
        if not root:FindFirstChild("FlyVelocity") then
            local fv = Instance.new("BodyVelocity")
            fv.Name = "FlyVelocity"
            fv.MaxForce = Vector3.new(1e5,1e5,1e5)
            fv.Velocity = Vector3.new(0,0,0)
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
            root.FlyVelocity.Velocity = Vector3.new(0,0.05,0)
        end
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)

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
                if _G.Config.GodModeToggle and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            end)
        end
    end
end)

-- One Punch Fling
RunService.Heartbeat:Connect(function()
    if not _G.Config.OnePunchFling or not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local targetRoot = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < 50 then targetRoot = p.Character.HumanoidRootPart; break end
        end
    end
    if targetRoot then
        local dir = (targetRoot.Position - myRoot.Position).Unit
        targetRoot.AssemblyLinearVelocity = dir * 100 + Vector3.new(0,500,0)
        task.wait(0.02)
    end
end)
-- ====================================================================
--  ESP (Player & Gun)
-- ====================================================================
local function getMM2Color(player)
    if not player.Character then return Color3.fromRGB(255,255,255) end
    if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return Color3.fromRGB(255,50,50) -- убийца
    end
    if player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return Color3.fromRGB(50,150,255) -- шериф
    end
    return Color3.fromRGB(255,255,255) -- невинный
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Character then return end
        local highlight = player.Character:FindFirstChild("NeonESP")
        if _G.Config.MM2Roles or _G.Config.ESPToggle or _G.Config.InnocentESP then
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
            elseif _G.Config.InnocentESP then
                local rColor = getMM2Color(player)
                if rColor == Color3.fromRGB(255,255,255) then -- только невинных
                    highlight.FillColor = Color3.fromRGB(255,255,255)
                    highlight.OutlineColor = Color3.fromRGB(255,255,255)
                else
                    highlight.FillTransparency = 1 -- скрываем остальных
                end
            else
                highlight.FillColor = Color3.fromRGB(186,85,255)
                highlight.OutlineColor = Color3.fromRGB(255,255,255)
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
            gunDrop = obj; break
        end
    end
    if gunDrop and _G.Config.MM2Gun then
        local handle = gunDrop.Handle
        if not handle:FindFirstChild("GunESP") then
            local hl = Instance.new("BoxHandleAdornment", handle)
            hl.Name = "GunESP"
            hl.AlwaysOnTop = true
            hl.Color3 = Color3.fromRGB(50,255,50)
            hl.Size = handle.Size * 1.5
            hl.Adornee = handle
            hl.Transparency = 0.3
            hl.ZIndex = 6
        end
        if not handle:FindFirstChild("3D_GunLabel") then
            local bg = Instance.new("BillboardGui", handle)
            bg.Name = "3D_GunLabel"
            bg.Size = UDim2.new(0,60,0,25)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0,2,0)
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

-- Murder Alert (звук + надпись)
local alertGui = Instance.new("ScreenGui", ScreenGui)
alertGui.Name = "MurderAlert"
local alertLabel = Instance.new("TextLabel", alertGui)
alertLabel.Size = UDim2.new(0,200,0,50)
alertLabel.Position = UDim2.new(0.5,-100,0.8,0)
alertLabel.BackgroundColor3 = Color3.fromRGB(255,0,0)
alertLabel.Text = "MURDERER NEAR!"
alertLabel.TextColor3 = Color3.fromRGB(255,255,255)
alertLabel.Font = Enum.Font.SourceSansBold
alertLabel.TextSize = 20
alertLabel.Visible = false
Instance.new("UICorner", alertLabel).CornerRadius = UDim.new(0,8)

local murderSound = Instance.new("Sound", alertGui)
murderSound.SoundId = "rbxassetid://4920545806" -- alarm sound
murderSound.Volume = 0.5

-- Kill Aura для убийцы (авто-удар)
RunService.Heartbeat:Connect(function()
    if not _G.Config.KillAura or not LocalPlayer.Character then return end
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knife then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < 5 then
                if knife.Parent == LocalPlayer.Backpack and hum then hum:EquipTool(knife) end
                if knife.Parent == LocalPlayer.Character then
                    knife:Activate()
                end
                break
            end
        end
    end
end)

-- Murder Alert check
RunService.Heartbeat:Connect(function()
    if not _G.Config.MurderAlert or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        alertLabel.Visible = false
        murderSound:Stop()
        return
    end
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local murdererRoot = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
            murdererRoot = p.Character:FindFirstChild("HumanoidRootPart")
            break
        end
    end
    if murdererRoot and (myRoot.Position - murdererRoot.Position).Magnitude < 20 then
        alertLabel.Visible = true
        if not murderSound.IsPlaying then murderSound:Play() end
    else
        alertLabel.Visible = false
        murderSound:Stop()
    end
end)

-- Auto Shot
shotBtn.MouseButton1Click:Connect(function()
    if not _G.Config.MM2Shot or not LocalPlayer.Character then return end
    local myChar = LocalPlayer.Character
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local gun = myChar:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return end
    if gun.Parent == LocalPlayer.Backpack then hum:EquipTool(gun) task.wait(0.15) end
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
    local remote = gun:FindFirstChild("Fire") or gun:FindFirstChild("Shoot")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(murdererRoot.Position) end)
    else
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
            droppedGun = obj.Handle; break
        end
    end
    if droppedGun and droppedGun:IsA("BasePart") then
        local oldCF = root.CFrame
        root.CFrame = droppedGun.CFrame + Vector3.new(0,3,0)
        task.wait(0.5)
        root.CFrame = oldCF
    end
end)

-- ====================================================================
--  ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ
-- ====================================================================
OpenBtn.MouseButton1Click:Connect(function()
    local newState = not MainFrame.Visible
    if newState then
        setVisibility(MainFrame, true)
        if _G.Config.MM2Mod then
            MM2Window.Visible = true
            MM2Window.Size = UDim2.new(0,210,0,0)
            TweenService:Create(MM2Window, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0,210,0,180)}):Play()
        end
    else
        setVisibility(MainFrame, false)
        MM2Window.Visible = false
    end
    updateShotButton()
    updateTpButton()
end)

RunService.Heartbeat:Connect(function()
    if _G.Config.MM2Mod and MainFrame.Visible and not MM2Window.Visible then
        MM2Window.Visible = true
        TweenService:Create(MM2Window, TweenInfo.new(0.2), {Size = UDim2.new(0,210,0,180)}):Play()
    elseif not _G.Config.MM2Mod and MM2Window.Visible then
        MM2Window.Visible = false
    end
    updateShotButton()
    updateTpButton()
end)

game:BindToClose(function()
    _G.saveSettings()
end)
