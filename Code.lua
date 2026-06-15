-- ====================================================================
--  PART 1/3: SERVICES, CONFIG, MAIN GUI, TABS, CHECKBOX WIDGET
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SimpleNeonSense") then
    CoreGui.SimpleNeonSense:Destroy()
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
    SelectedPlayer = "", Target = false,
    GodModeToggle = false, GodModeType = "Loop",
    SpinBot = false, SpinSpeed = 30,
    FlyMode = false, FlySpeedValue = 40,
    OnePunchFling = false,
    ESPToggle = false,
    ESPColor = "WHITE",
    MM2Mod = false,
    MM2Roles = false,
    MM2Gun = false,
    MM2Shot = false
}

local FILE_NAME = "SimpleNeon_Config.json"
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

_G.ScreenGui = Instance.new("ScreenGui")
_G.ScreenGui.Name = "SimpleNeonSense"
_G.ScreenGui.Parent = CoreGui
_G.ScreenGui.ResetOnSpawn = false
_G.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0, 140)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "⚙️"
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.fromRGB(186, 85, 211)
OpenButton.TextStrokeTransparency = 0
OpenButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
OpenButton.ZIndex = 11
OpenButton.Parent = _G.ScreenGui
makeDraggable(OpenButton)
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenButton).Color = Color3.fromRGB(186, 85, 211)
Instance.new("UIStroke", OpenButton).Thickness = 1.5

_G.ShotButton = Instance.new("TextButton")
_G.ShotButton.Size = UDim2.new(0, 60, 0, 60)
_G.ShotButton.Position = UDim2.new(0, 15, 0, 210)
_G.ShotButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
_G.ShotButton.Text = "SHOT"
_G.ShotButton.TextSize = 12
_G.ShotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
_G.ShotButton.Font = Enum.Font.SourceSans
_G.ShotButton.TextStrokeTransparency = 0
_G.ShotButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_G.ShotButton.ZIndex = 11
_G.ShotButton.Visible = false
_G.ShotButton.Parent = _G.ScreenGui
makeDraggable(_G.ShotButton)
Instance.new("UICorner", _G.ShotButton).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", _G.ShotButton).Color = Color3.fromRGB(50, 255, 50)
Instance.new("UIStroke", _G.ShotButton).Thickness = 1.2

_G.TpGunButton = Instance.new("TextButton")
_G.TpGunButton.Size = UDim2.new(0, 60, 0, 60)
_G.TpGunButton.Position = UDim2.new(0, 15, 0, 285)
_G.TpGunButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
_G.TpGunButton.Text = "TP GUN"
_G.TpGunButton.TextSize = 11
_G.TpGunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
_G.TpGunButton.Font = Enum.Font.SourceSansBold
_G.TpGunButton.TextStrokeTransparency = 0
_G.TpGunButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
_G.TpGunButton.ZIndex = 11
_G.TpGunButton.Visible = false
_G.TpGunButton.Parent = _G.ScreenGui
makeDraggable(_G.TpGunButton)
Instance.new("UICorner", _G.TpGunButton).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", _G.TpGunButton).Color = Color3.fromRGB(50, 150, 255)
Instance.new("UIStroke", _G.TpGunButton).Thickness = 1.2

_G.MainFrame = Instance.new("Frame")
_G.MainFrame.Size = UDim2.new(0, 360, 0, 240)
_G.MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
_G.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
_G.MainFrame.Visible = false
_G.MainFrame.ZIndex = 10
_G.MainFrame.Parent = _G.ScreenGui
makeDraggable(_G.MainFrame)
Instance.new("UICorner", _G.MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", _G.MainFrame).Color = Color3.fromRGB(186, 85, 211)
Instance.new("UIStroke", _G.MainFrame).Thickness = 1.5

_G.TopBar = Instance.new("Frame", _G.MainFrame)
_G.TopBar.Size = UDim2.new(1, 0, 0, 35)
_G.TopBar.BackgroundTransparency = 1
_G.TopBar.ZIndex = 11
local TopLayout = Instance.new("UIListLayout", _G.TopBar)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 10)

_G.Container = Instance.new("Frame", _G.MainFrame)
_G.Container.Size = UDim2.new(1, -20, 1, -50)
_G.Container.Position = UDim2.new(0, 10, 0, 40)
_G.Container.BackgroundTransparency = 1
_G.Container.ZIndex = 11

_G.MM2Window = Instance.new("Frame")
_G.MM2Window.Size = UDim2.new(0, 210, 0, 170)
_G.MM2Window.Position = UDim2.new(0.5, 190, 0.5, -85)
_G.MM2Window.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
_G.MM2Window.Visible = false
_G.MM2Window.ZIndex = 20
_G.MM2Window.Parent = _G.ScreenGui
makeDraggable(_G.MM2Window)
Instance.new("UICorner", _G.MM2Window).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", _G.MM2Window).Color = Color3.fromRGB(255, 65, 65)
Instance.new("UIStroke", _G.MM2Window).Thickness = 1.5

local MM2Title = Instance.new("TextLabel", _G.MM2Window)
MM2Title.Size = UDim2.new(1, 0, 0, 30)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 DASHBOARD"
MM2Title.TextColor3 = Color3.fromRGB(255, 65, 65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 12
MM2Title.TextStrokeTransparency = 0
MM2Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

_G.MM2Content = Instance.new("Frame", _G.MM2Window)
_G.MM2Content.Size = UDim2.new(1, -10, 1, -40)
_G.MM2Content.Position = UDim2.new(0, 5, 0, 35)
_G.MM2Content.BackgroundTransparency = 1
local MM2Layout = Instance.new("UIListLayout", _G.MM2Content)
MM2Layout.Padding = UDim.new(0, 6)

local MM2CloseBtn = Instance.new("TextButton", _G.MM2Window)
MM2CloseBtn.Size = UDim2.new(0, 30, 0, 30)
MM2CloseBtn.Position = UDim2.new(1, -35, 0, 2)
MM2CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
MM2CloseBtn.Text = "X"
MM2CloseBtn.TextSize = 18
MM2CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MM2CloseBtn.Font = Enum.Font.SourceSansBold
MM2CloseBtn.TextStrokeTransparency = 0
MM2CloseBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
MM2CloseBtn.ZIndex = 25
Instance.new("UICorner", MM2CloseBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", MM2CloseBtn).Color = Color3.fromRGB(200, 0, 0)
Instance.new("UIStroke", MM2CloseBtn).Thickness = 2

local tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton", _G.TopBar)
    btn.Size = UDim2.new(0, 70, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("Frame", _G.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 12
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            t.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            t.page.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(186, 85, 211)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
    table.insert(tabs, {btn = btn, page = page})
    return page
end

local pVisual = createTab("Visual")
local pGame = createTab("Game")
local pSettings = createTab("Settings")
tabs[1].btn.BackgroundColor3 = Color3.fromRGB(186, 85, 211)
tabs[1].btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabs[1].page.Visible = true

function createCheckbox(parent, configKey, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 12

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 110, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
    toggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 12
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", toggleBtn)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, _G.Config[configKey] and 20 or 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.ZIndex = 13

    local state = _G.Config[configKey]
    local stateCallback = nil
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        _G.Config[configKey] = state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 20 or 2, 0.5, -7)}):Play()
        _G.saveSettings()
        if stateCallback then stateCallback(state) end
    end)
    return {OnToggle = function(cb) stateCallback = cb end}
end
-- ====================================================================
--  PART 2/3: SLIDER WIDGET, FILLING TABS, GODMODE, SETTINGS, MM2 TOGGLES
-- ====================================================================
function createFeatureWithLeftSlider(parent, configKey, speedKey, text, min, max)
    local BigWrapper = Instance.new("Frame", parent)
    BigWrapper.Size = UDim2.new(1, 0, 0, 30)
    BigWrapper.BackgroundTransparency = 1
    BigWrapper.ClipsDescendants = true
    BigWrapper.ZIndex = 12

    local TopRow = Instance.new("Frame", BigWrapper)
    TopRow.Size = UDim2.new(1, 0, 0, 30)
    TopRow.BackgroundTransparency = 1
    TopRow.ZIndex = 12

    local Label = Instance.new("TextLabel", TopRow)
    Label.Size = UDim2.new(0, 90, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 12

    local ValueLabel = Instance.new("TextLabel", TopRow)
    ValueLabel.Size = UDim2.new(0, 30, 0, 20)
    ValueLabel.Position = UDim2.new(1, -35, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(_G.Config[speedKey])
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 11
    ValueLabel.TextStrokeTransparency = 0
    ValueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ValueLabel.ZIndex = 15

    local GearBtn = Instance.new("TextButton", TopRow)
    GearBtn.Size = UDim2.new(0, 22, 0, 22)
    GearBtn.Position = UDim2.new(1, -65, 0, 4)
    GearBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    GearBtn.Text = "▼"
    GearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GearBtn.Font = Enum.Font.SourceSansBold
    GearBtn.TextSize = 10
    GearBtn.ZIndex = 15
    Instance.new("UICorner", GearBtn).CornerRadius = UDim.new(0, 4)

    local ToggleBtn = Instance.new("TextButton", TopRow)
    ToggleBtn.Size = UDim2.new(0, 28, 0, 16)
    ToggleBtn.Position = UDim2.new(1, -28, 0, 7)
    ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 15
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local ToggleKnob = Instance.new("Frame", ToggleBtn)
    ToggleKnob.Size = UDim2.new(0, 12, 0, 12)
    ToggleKnob.Position = UDim2.new(0, _G.Config[configKey] and 14 or 2, 0.5, -6)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(1, 0)
    ToggleKnob.ZIndex = 16

    local SliderPanel = Instance.new("Frame", BigWrapper)
    SliderPanel.Size = UDim2.new(1, 0, 0, 0)
    SliderPanel.Position = UDim2.new(0, 0, 0, 30)
    SliderPanel.BackgroundTransparency = 1
    SliderPanel.ClipsDescendants = true
    SliderPanel.ZIndex = 12

    local SliderBar = Instance.new("Frame", SliderPanel)
    SliderBar.Size = UDim2.new(1, -50, 0, 8)
    SliderBar.Position = UDim2.new(0, 25, 0.5, -4)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SliderBar.ZIndex = 15
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame", SliderBar)
    local percentage = (_G.Config[speedKey] - min) / (max - min)
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(186, 85, 211)
    SliderFill.ZIndex = 16
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local MinusBtn = Instance.new("TextButton", SliderPanel)
    MinusBtn.Size = UDim2.new(0, 18, 0, 18)
    MinusBtn.Position = UDim2.new(0, 0, 0.5, -9)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MinusBtn.Text = "<"
    MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinusBtn.Font = Enum.Font.SourceSansBold
    MinusBtn.TextSize = 12
    MinusBtn.ZIndex = 15
    Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 4)

    local PlusBtn = Instance.new("TextButton", SliderPanel)
    PlusBtn.Size = UDim2.new(0, 18, 0, 18)
    PlusBtn.Position = UDim2.new(1, -18, 0.5, -9)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlusBtn.Text = ">"
    PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlusBtn.Font = Enum.Font.SourceSansBold
    PlusBtn.TextSize = 12
    PlusBtn.ZIndex = 15
    Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)

    local function updateValue(val)
        val = math.clamp(val, min, max)
        _G.Config[speedKey] = val
        ValueLabel.Text = tostring(val)
        local p = (val - min) / (max - min)
        SliderFill.Size = UDim2.new(p, 0, 1, 0)
        _G.saveSettings()
    end

    local function updateSlider(input)
        local percentage2 = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (percentage2 * (max - min)))
        updateValue(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
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

    MinusBtn.MouseButton1Click:Connect(function() updateValue(_G.Config[speedKey] - 1) end)
    PlusBtn.MouseButton1Click:Connect(function() updateValue(_G.Config[speedKey] + 1) end)

    local panelOpen = false
    GearBtn.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        GearBtn.Text = panelOpen and "▲" or "▼"
        SliderPanel:TweenSize(UDim2.new(1, 0, 0, panelOpen and 30 or 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        BigWrapper:TweenSize(UDim2.new(1, 0, 0, panelOpen and 60 or 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)

    local stateCallback = nil
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
        TweenService:Create(ToggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, _G.Config[configKey] and 14 or 2, 0.5, -6)}):Play()
        _G.saveSettings()
        if stateCallback then stateCallback(_G.Config[configKey]) end
    end)
    return {OnToggle = function(callback) stateCallback = callback end}
end

-- ===== VISUAL TAB =====
createCheckbox(pVisual, "ESPToggle", "Player ESP")

-- ===== GAME TAB =====
createFeatureWithLeftSlider(pGame, "Speedhack", "SpeedValue", "WalkSpeed", 16, 250)
createFeatureWithLeftSlider(pGame, "FlyMode", "FlySpeedValue", "Fly Mode", 10, 200)
createFeatureWithLeftSlider(pGame, "SpinBot", "SpinSpeed", "Spin Bot", 10, 150)
createCheckbox(pGame, "Noclip", "Noclip")
createCheckbox(pGame, "OnePunchFling", "One Punch Fling")

-- God Mode
local godFrame = Instance.new("Frame", pGame)
godFrame.Size = UDim2.new(1, 0, 0, 30)
godFrame.BackgroundTransparency = 1
godFrame.ZIndex = 12

local godLabel = Instance.new("TextLabel", godFrame)
godLabel.Size = UDim2.new(0, 90, 1, 0)
godLabel.BackgroundTransparency = 1
godLabel.Text = "God Mode"
godLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
godLabel.Font = Enum.Font.SourceSans
godLabel.TextSize = 12
godLabel.TextXAlignment = Enum.TextXAlignment.Left
godLabel.ZIndex = 12

local godTypeBtn = Instance.new("TextButton", godFrame)
godTypeBtn.Size = UDim2.new(0, 50, 0, 20)
godTypeBtn.Position = UDim2.new(0, 95, 0.5, -10)
godTypeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
godTypeBtn.Text = _G.Config.GodModeType == "Loop" and "Loop" or "Block"
godTypeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
godTypeBtn.Font = Enum.Font.SourceSans
godTypeBtn.TextSize = 11
godTypeBtn.ZIndex = 12
Instance.new("UICorner", godTypeBtn).CornerRadius = UDim.new(0, 4)
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

local godToggleBtn = Instance.new("TextButton", godFrame)
godToggleBtn.Size = UDim2.new(0, 36, 0, 18)
godToggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
godToggleBtn.BackgroundColor3 = _G.Config.GodModeToggle and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
godToggleBtn.Text = ""
godToggleBtn.ZIndex = 12
Instance.new("UICorner", godToggleBtn).CornerRadius = UDim.new(1, 0)
local godKnob = Instance.new("Frame", godToggleBtn)
godKnob.Size = UDim2.new(0, 14, 0, 14)
godKnob.Position = UDim2.new(0, _G.Config.GodModeToggle and 20 or 2, 0.5, -7)
godKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", godKnob).CornerRadius = UDim.new(1, 0)
godKnob.ZIndex = 13
local godState = _G.Config.GodModeToggle
godToggleBtn.MouseButton1Click:Connect(function()
    godState = not godState
    _G.Config.GodModeToggle = godState
    godToggleBtn.BackgroundColor3 = godState and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(50, 50, 50)
    TweenService:Create(godKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, godState and 20 or 2, 0.5, -7)}):Play()
    _G.saveSettings()
end)

createCheckbox(pGame, "MM2Mod", "Murder Myst 2")

-- ===== SETTINGS TAB =====
local RejoinBtn = Instance.new("TextButton", pSettings)
RejoinBtn.Size = UDim2.new(1, 0, 0, 30)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
RejoinBtn.Text = "Private Server"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.SourceSans
RejoinBtn.TextSize = 12
RejoinBtn.TextStrokeTransparency = 0
RejoinBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
RejoinBtn.ZIndex = 12
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", RejoinBtn).Color = Color3.fromRGB(186, 85, 211)
RejoinBtn.MouseButton1Click:Connect(function()
    local reserved = TeleportService:ReserveServer(game.PlaceId)
    if reserved and reserved ~= "" then
        TeleportService:TeleportToPrivateServer(game.PlaceId, reserved, {LocalPlayer})
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

local ResetBtn = Instance.new("TextButton", pSettings)
ResetBtn.Size = UDim2.new(1, 0, 0, 30)
ResetBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ResetBtn.Text = "Reset & Close"
ResetBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ResetBtn.Font = Enum.Font.SourceSans
ResetBtn.TextSize = 12
ResetBtn.TextStrokeTransparency = 0
ResetBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ResetBtn.ZIndex = 12
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", ResetBtn).Color = Color3.fromRGB(255, 50, 50)
ResetBtn.MouseButton1Click:Connect(function()
    if delfile and isfile("SimpleNeon_Config.json") then
        delfile("SimpleNeon_Config.json")
    end
    if _G.ScreenGui then
        _G.ScreenGui:Destroy()
    end
end)

-- ===== MM2 CONTENT =====
local rolesCheat = createCheckbox(_G.MM2Content, "MM2Roles", "Roles Chams")
local gunEspCheat = createCheckbox(_G.MM2Content, "MM2Gun", "Gun Chams")
local shotCheat = createCheckbox(_G.MM2Content, "MM2Shot", "Auto Shot")
local tpGunToggle = createCheckbox(_G.MM2Content, "Target", "TP Gun")

shotCheat.OnToggle(function(state)
    _G.ShotButton.Visible = state
end)
tpGunToggle.OnToggle(function(state)
    _G.TpGunButton.Visible = state
end)

_G.Config.MM2Shot = false
_G.Config.Target = false
_G.ShotButton.Visible = false
_G.TpGunButton.Visible = false

MM2CloseBtn.MouseButton1Click:Connect(function()
    _G.Config.MM2Mod = false
    _G.Config.MM2Roles = false
    _G.Config.MM2Gun = false
    _G.Config.MM2Shot = false
    _G.Config.Target = false
    _G.MM2Window.Visible = false
    _G.ShotButton.Visible = false
    _G.TpGunButton.Visible = false
    _G.saveSettings()
end)
-- ====================================================================
--  PART 3/3: GAME LOGIC, AUTO SHOT, TP GUN, ESP, MENU OPEN
-- ====================================================================
local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then
                return p.Character.HumanoidRootPart
            end
        end
    end
    return nil
end

local function findDroppedGun()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            local handle = obj:FindFirstChild("Handle")
            if handle then return handle end
        end
    end
    return nil
end

local function getClosestPlayer()
    local closest, maxDist = nil, 50
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < maxDist then
                closest = p.Character.HumanoidRootPart
                maxDist = dist
            end
        end
    end
    return closest
end

RunService.Stepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if hum then
        if _G.Config.Speedhack and not _G.Config.FlyMode then
            hum.WalkSpeed = _G.Config.SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end

    if _G.Config.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if _G.Config.SpinBot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Config.SpinSpeed), 0)
    else
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end

    if _G.Config.FlyMode then
        if not root:FindFirstChild("FlyVelocity") then
            local fv = Instance.new("BodyVelocity")
            fv.Name = "FlyVelocity"
            fv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = root
        end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
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

RunService.Heartbeat:Connect(function()
    if not _G.Config.OnePunchFling or not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local targetRoot = getClosestPlayer()
    if targetRoot then
        local dir = (targetRoot.Position - myRoot.Position).Unit
        targetRoot.AssemblyLinearVelocity = dir * 100 + Vector3.new(0, 500, 0)
        task.wait(0.03)
    end
end)

_G.ShotButton.MouseButton1Click:Connect(function()
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

    local murdererRoot = getMurderer()
    if not murdererRoot then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    myRoot.CFrame = CFrame.new(myRoot.Position, murdererRoot.Position)
    task.wait(0.08)

    local fired = false
    local remote = gun:FindFirstChild("Fire") or gun:FindFirstChild("Shoot")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(murdererRoot.Position)
            fired = true
        end)
    end
    if not fired then
        pcall(function() gun:Activate() end)
    end
    task.wait(0.2)
end)

_G.TpGunButton.MouseButton1Click:Connect(function()
    if not _G.Config.Target or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local droppedGun = findDroppedGun()
    if droppedGun and droppedGun:IsA("BasePart") then
        local oldCF = root.CFrame
        root.CFrame = droppedGun.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.5)
        root.CFrame = oldCF
    end
end)

local function getMM2Color(player)
    if not player.Character then return Color3.fromRGB(255, 255, 255) end
    if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return Color3.fromRGB(255, 50, 50)
    end
    if player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return Color3.fromRGB(50, 150, 255)
    end
    return Color3.fromRGB(255, 255, 255)
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
                highlight.FillColor = Color3.fromRGB(186, 85, 211)
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

RunService.Heartbeat:Connect(function()
    local droppedGun = findDroppedGun()
    if droppedGun and droppedGun:IsA("BasePart") and _G.Config.MM2Gun then
        if not droppedGun:FindFirstChild("GunESP") then
            local hl = Instance.new("BoxHandleAdornment", droppedGun)
            hl.Name = "GunESP"
            hl.AlwaysOnTop = true
            hl.Color3 = Color3.fromRGB(50, 255, 50)
            hl.Size = droppedGun.Size * 1.5
            hl.Adornee = droppedGun
            hl.Transparency = 0.3
            hl.ZIndex = 6
        end
        if not droppedGun:FindFirstChild("3D_GunLabel") then
            local bg = Instance.new("BillboardGui", droppedGun)
            bg.Name = "3D_GunLabel"
            bg.Size = UDim2.new(0, 60, 0, 25)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.Adornee = droppedGun
            local lbl = Instance.new("TextLabel", bg)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "GUN"
            lbl.TextColor3 = Color3.fromRGB(50, 255, 50)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.TextStrokeTransparency = 0
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        end
    end
end)

OpenButton.MouseButton1Click:Connect(function()
    local state = not _G.MainFrame.Visible
    _G.MainFrame.Visible = state
    _G.MM2Window.Visible = (_G.Config.MM2Mod and state) or false
    _G.ShotButton.Visible = _G.Config.MM2Shot and _G.Config.MM2Mod and state
    _G.TpGunButton.Visible = _G.Config.Target and _G.Config.MM2Mod and state
end)

game:BindToClose(function()
    _G.saveSettings()
end)
