--[[
    Modern Roblox Mobile Script GUI
    Part 1/4 - Core Setup & UI Framework
    Lines: ~320
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- // GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- // Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 520)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BackgroundTransparency = 0.95
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local shadowFrame = Instance.new("Frame")
shadowFrame.Size = UDim2.new(0, 380, 0, 520)
shadowFrame.Position = UDim2.new(0.5, -188, 0.5, -258)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.5
shadowFrame.BorderSizePixel = 0
shadowFrame.Parent = screenGui
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowCorner.Parent = shadowFrame

-- Drag Functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        shadowFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset - 2, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 2)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- // Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MENU v1.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    shadowFrame.Visible = false
end)

-- // Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tabBar.BackgroundTransparency = 0.5
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabs = {"Player", "Visuals", "Game", "Other", "Settings"}
local tabButtons = {}
local selectedTab = nil

-- // Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -100)
contentContainer.Position = UDim2.new(0, 10, 0, 85)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local tabFrames = {}
for _, tabName in ipairs(tabs) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = contentContainer
    tabFrames[tabName] = frame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = scrollFrame
    
    scrollFrame.ChildAdded:Connect(function()
        task.wait(0.1)
        local totalHeight = 0
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                totalHeight = totalHeight + child.Size.Y.Offset + 8
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
    end)
end

-- Create Tab Buttons
for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -2, 1, -6)
    btn.Position = UDim2.new((i-1)/#tabs, 1, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.BackgroundTransparency = 0.8
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    tabButtons[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabButtons) do
            tb.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            tb.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for _, frame in pairs(tabFrames) do
            frame.Visible = false
        end
        tabFrames[tabName].Visible = true
        selectedTab = tabName
    end)
end

-- Select first tab
tabButtons["Player"].BackgroundColor3 = Color3.fromRGB(80, 80, 200)
tabButtons["Player"].TextColor3 = Color3.fromRGB(255, 255, 255)
tabFrames["Player"].Visible = true
selectedTab = "Player"

-- // Toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.LeftShift then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            mainFrame.Visible = not mainFrame.Visible
            shadowFrame.Visible = mainFrame.Visible
        end
    end
end)

-- Mobile toggle (tap with 3 fingers)
local touchCount = 0
local touchTimer = nil
UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    touchCount = touchCount + 1
    if touchTimer then
        touchTimer:Disconnect()
        touchTimer = nil
    end
    touchTimer = task.delay(0.5, function()
        if touchCount >= 3 then
            mainFrame.Visible = not mainFrame.Visible
            shadowFrame.Visible = mainFrame.Visible
        end
        touchCount = 0
    end)
end)
--[[
    Modern Roblox Mobile Script GUI
    Part 2/4 - UI Helper Functions & Player Tab
    Lines: ~340
]]

-- // Helper Functions
local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    section.BackgroundTransparency = 0.6
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

local function createToggle(parent, labelText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 22)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 70)
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleBtn
    
    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 70)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    return toggleBtn, function() return state end
end

local function createSlider(parent, labelText, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.7, -10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.6, -24, 0, 4)
    slider.Position = UDim2.new(0, 12, 1, -10)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.BackgroundTransparency = 0.5
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    fill.BackgroundTransparency = 0.3
    fill.BorderSizePixel = 0
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local value = default
    local draggingSlider = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * pos
            value = math.round(value * 10) / 10
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    
    slider.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * pos
            value = math.round(value * 10) / 10
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    return slider, function() return value end
end

local function createButton(parent, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BackgroundTransparency = 0.4
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

-- // PLAYER TAB
local playerFrame = tabFrames["Player"]

-- Player Info Section
createSection(playerFrame, "PLAYER INFO")

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 0, 60)
infoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
infoFrame.BackgroundTransparency = 0.4
infoFrame.BorderSizePixel = 0
infoFrame.Parent = playerFrame
local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -16, 0.5, 0)
nameLabel.Position = UDim2.new(0, 8, 0, 4)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Name: " .. LocalPlayer.Name
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
nameLabel.TextSize = 14
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = infoFrame

local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(1, -16, 0.5, 0)
healthLabel.Position = UDim2.new(0, 8, 0.5, 0)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "Health: 100"
healthLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
healthLabel.TextSize = 14
healthLabel.Font = Enum.Font.Gotham
healthLabel.TextXAlignment = Enum.TextXAlignment.Left
healthLabel.Parent = infoFrame

-- Player Options
createSection(playerFrame, "PLAYER OPTIONS")

-- ESP Toggle
local espToggle, getEsp = createToggle(playerFrame, "ESP Boxes", false, function(state)
    -- ESP functionality will be in Part 3
end)

-- Nametags Toggle
local nameToggle, getName = createToggle(playerFrame, "Nametags", true, function(state)
    -- Nametag functionality
end)

-- Tracers Toggle
local tracerToggle, getTracer = createToggle(playerFrame, "Tracers", false, function(state)
    -- Tracer functionality
end)

-- Walk Speed Slider
local speedSlider, getSpeed = createSlider(playerFrame, "Walk Speed", 10, 50, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- Jump Power Slider
local jumpSlider, getJump = createSlider(playerFrame, "Jump Power", 30, 100, 50, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

-- Noclip Button
createButton(playerFrame, "Toggle Noclip", function()
    -- Noclip functionality
end)
--[[
    Modern Roblox Mobile Script GUI
    Part 4/4 - Settings Tab & Main Loop
    Lines: ~280
]]

-- // SETTINGS TAB
local settingsFrame = tabFrames["Settings"]

createSection(settingsFrame, "UI SETTINGS")

-- GUI Transparency
local transSlider, getTrans = createSlider(settingsFrame, "GUI Transparency", 50, 100, 95, function(value)
    local trans = 1 - (value / 100)
    mainFrame.BackgroundTransparency = trans
    titleBar.BackgroundTransparency = trans
    tabBar.BackgroundTransparency = trans
end)

-- Toggle Open (Shift)
createButton(settingsFrame, "Toggle GUI (Shift Key)", function()
    mainFrame.Visible = not mainFrame.Visible
    shadowFrame.Visible = mainFrame.Visible
end)

createSection(settingsFrame, "MOBILE SETTINGS")

-- Mobile Controls Info
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 40)
infoText.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
infoText.BackgroundTransparency = 0.4
infoText.Text = "3-Finger Tap to Toggle GUI"
infoText.TextColor3 = Color3.fromRGB(180, 180, 200)
infoText.TextSize = 13
infoText.Font = Enum.Font.Gotham
infoText.BorderSizePixel = 0
infoText.Parent = settingsFrame
local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoText

createSection(settingsFrame, "ABOUT")

local aboutText = Instance.new("TextLabel")
aboutText.Size = UDim2.new(1, 0, 0, 60)
aboutText.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
aboutText.BackgroundTransparency = 0.4
aboutText.Text = "Modern GUI v1.0\nFor Roblox Mobile"
aboutText.TextColor3 = Color3.fromRGB(160, 160, 180)
aboutText.TextSize = 12
aboutText.Font = Enum.Font.Gotham
aboutText.BorderSizePixel = 0
aboutText.Parent = settingsFrame
local aboutCorner = Instance.new("UICorner")
aboutCorner.CornerRadius = UDim.new(0, 6)
aboutCorner.Parent = aboutText

-- // MAIN UPDATE LOOP
local function updatePlayerInfo()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local health = LocalPlayer.Character.Humanoid.Health
        healthLabel.Text = "Health: " .. math.round(health)
    end
end

-- // ESP SYSTEM
local espObjects = {}
local espEnabled = false
local nameEnabled = true
local tracerEnabled = false

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Box ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 2)
    box.Adornee = hrp
    box.Color3 = Color3.fromRGB(255, 50, 50)
    box.Transparency = 0.6
    box.ZIndex = 0
    box.Parent = hrp
    espObjects[player] = {box = box, tracer = nil, nameLabel = nil}
    
    -- Name ESP
    if nameEnabled then
        local nameBill = Instance.new("BillboardGui")
        nameBill.Size = UDim2.new(0, 100, 0, 20)
        nameBill.Adornee = hrp
        nameBill.MaxDistance = 500
        nameBill.AlwaysOnTop = true
        nameBill.Parent = hrp
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Goth
    --[[
    Modern Roblox Mobile Script GUI
    Part 4/4 - Settings Tab & Main Loop (Продолжение)
    Lines: ~250
]]

        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Parent = nameBill
        
        espObjects[player].nameLabel = nameBill
    end
    
    -- Tracers
    if tracerEnabled then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Length = 0
        tracer.Thickness = 2
        tracer.Color3 = Color3.fromRGB(50, 200, 50)
        tracer.Transparency = 0.7
        tracer.ZIndex = 0
        tracer.Parent = hrp
        espObjects[player].tracer = tracer
    end
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].box then
            espObjects[player].box:Destroy()
        end
        if espObjects[player].tracer then
            espObjects[player].tracer:Destroy()
        end
        if espObjects[player].nameLabel then
            espObjects[player].nameLabel:Destroy()
        end
        espObjects[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if espEnabled then
                if not espObjects[player] then
                    createESP(player)
                end
            else
                if espObjects[player] then
                    removeESP(player)
                end
            end
        end
    end
end

-- Hook ESP toggle
espToggle.MouseButton1Click:Connect(function()
    espEnabled = getEsp()
    updateESP()
end)

-- Hook Nametag toggle
nameToggle.MouseButton1Click:Connect(function()
    nameEnabled = getName()
    updateESP()
end)

-- Hook Tracer toggle
tracerToggle.MouseButton1Click:Connect(function()
    tracerEnabled = getTracer()
    updateESP()
end)

-- Player added/removed
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- // TRACER UPDATE LOOP
local function updateTracers()
    for player, data in pairs(espObjects) do
        if data.tracer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local camPos = Camera.CFrame.Position
            local targetPos = hrp.Position
            
            -- Update tracer direction
            local direction = (targetPos - camPos).unit
            data.tracer.Direction = direction
            data.tracer.Length = (targetPos - camPos).magnitude
            data.tracer.Adornee = Camera
        end
    end
end

-- // NOCLIP
local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Hook noclip button (find it in Player tab)
for _, btn in ipairs(playerFrame:GetDescendants()) do
    if btn:IsA("TextButton") and btn.Text == "Toggle Noclip" then
        btn.MouseButton1Click:Connect(toggleNoclip)
        break
    end
end

-- // FLY CONTROLS (Mobile friendly)
local flyUp = false
local flyForward = false
local flyVelocity = Vector3.new(0, 0, 0)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if flyEnabled then
        if input.KeyCode == Enum.KeyCode.W then flyForward = true end
        if input.KeyCode == Enum.KeyCode.S then flyForward = false end
        if input.KeyCode == Enum.KeyCode.Space then flyUp = true end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyUp = false end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then flyForward = false end
    if input.KeyCode == Enum.KeyCode.S then flyForward = false end
    if input.KeyCode == Enum.KeyCode.Space then flyUp = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyUp = false end
end)

-- // FLY UPDATE
RunService.Heartbeat:Connect(function(deltaTime)
    if flyEnabled and flyBodyVelocity then
        local cameraLook = Camera.CFrame.LookVector
        local horizontal = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
        
        local velocity = Vector3.new(0, 0, 0)
        if flyForward then
            velocity = velocity + horizontal * 50
        end
        if flyUp then
            velocity = velocity + Vector3.new(0, 50, 0)
        end
        if not flyForward and not flyUp then
            velocity = Vector3.new(0, 0, 0)
        end
        
        flyBodyVelocity.Velocity = velocity
    end
end)

-- // CLICK TELEPORT
local clickTeleport = false
local function setupClickTeleport()
    clickTeleport = not clickTeleport
    if clickTeleport then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Touch and clickTeleport then
                local mousePos = input.Position
                local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                
                local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
                if result and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    end
end

-- Hook click teleport button
for _, btn in ipairs(otherFrame:GetDescendants()) do
    if btn:IsA("TextButton") and btn.Text == "Click Teleport (Tap ground)" then
        btn.MouseButton1Click:Connect(setupClickTeleport)
        break
    end
end

-- // SPEED BOOST
local boostValue = 1.5
boostSlider.MouseButton1Click:Connect(function()
    boostValue = getBoost()
end)

-- // CHAMS (Glow effect)
local chamsEnabled = false
local chamsMaterials = {}

local function toggleChams(state)
    chamsEnabled = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if chamsEnabled then
                        chamsMaterials[part] = part.Material
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(0, 150, 255)
                    else
                        if chamsMaterials[part] then
                            part.Material = chamsMaterials[part]
                            chamsMaterials[part] = nil
                        end
                    end
                end
            end
        end
    end
end

chamsToggle.MouseButton1Click:Connect(function()
    toggleChams(getChams())
end)

-- // CHARACTER ADDED HOOK
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    -- Reset walk speed
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = getSpeed()
        char.Humanoid.JumpPower = getJump()
    end
end)

-- // MAIN UPDATE LOOP
RunService.Heartbeat:Connect(function()
    updatePlayerInfo()
    
    -- Update ESP
    if espEnabled then
        updateESP()
        updateTracers()
    end
    
    -- Update Chams for new players
    if chamsEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not chamsMaterials[part] then
                        chamsMaterials[part] = part.Material
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(0, 150, 255)
                    end
                end
            end
        end
    end
end)

-- // SETTINGS SAVE (Simple)
local function saveSettings()
    -- In a real script, you'd save to a datastore
    print("Settings saved (simulated)")
end

-- Auto-save on close
game:BindToClose(saveSettings)

-- // KEYBOARD SHORTCUTS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1 to toggle GUI (alternative)
    if input.KeyCode == Enum.KeyCode.F1 then
        mainFrame.Visible = not mainFrame.Visible
        shadowFrame.Visible = mainFrame.Visible
    end
    
    -- F2 to toggle ESP
    if input.KeyCode == Enum.KeyCode.F2 then
        espEnabled = not espEnabled
        updateESP()
    end
end)

-- // STARTUP MESSAGE
print("Modern GUI Loaded Successfully!")
print("3-Finger Tap or Shift to toggle menu")
print("F1 - Toggle GUI | F2 - Toggle ESP")

-- Cleanup on reset
LocalPlayer.CharacterAdded:Connect(function()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    flyEnabled = false
end)

-- // END OF SCRIPT
print("All systems ready!")
