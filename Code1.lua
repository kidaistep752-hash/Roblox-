--[[ MODERN ROBLOX MOBILE GUI - PART 1/4 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

local guiVisible = false
local flyEnabled = false
local flyBodyVelocity = nil
local noclipEnabled = false
local noclipConnection = nil
local infJump = false
local noFall = false
local afkEnabled = true
local afkConnection = nil
local espEnabled = false
local nameEnabled = true
local tracerEnabled = false
local chamsEnabled = false
local espColor = Color3.fromRGB(0, 150, 255)
local espObjects = {}
local clickTeleport = false
local clickTeleportConnection = nil
local chamsMaterials = {}
local boostValue = 1.5

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(1, -70, 0, 80)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Text = "MENU"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0
toggleButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleButton

local btnShadow = Instance.new("Frame")
btnShadow.Size = UDim2.new(0, 55, 0, 55)
btnShadow.Position = UDim2.new(1, -68, 0, 82)
btnShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btnShadow.BackgroundTransparency = 0.5
btnShadow.BorderSizePixel = 0
btnShadow.Parent = screenGui

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(1, 0)
shadowCorner.Parent = btnShadow

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 520)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local shadowFrame = Instance.new("Frame")
shadowFrame.Size = UDim2.new(0, 380, 0, 520)
shadowFrame.Position = UDim2.new(0.5, -188, 0.5, -258)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.6
shadowFrame.BorderSizePixel = 0
shadowFrame.Visible = false
shadowFrame.Parent = screenGui

local shadowCorner2 = Instance.new("UICorner")
shadowCorner2.CornerRadius = UDim.new(0, 16)
shadowCorner2.Parent = shadowFrame

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

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MENU v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.BackgroundTransparency = 0.3
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
    guiVisible = false
    mainFrame.Visible = false
    shadowFrame.Visible = false
end)

toggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    shadowFrame.Visible = guiVisible
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tabBar.BackgroundTransparency = 0.3
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabs = {"Player", "Visuals", "Game", "Other", "Settings"}
local tabButtons = {}
local selectedTab = nil

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
end

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -2, 1, -6)
    btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.BackgroundTransparency = 0.5
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 8)
    btnCorner2.Parent = btn
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

tabButtons["Player"].BackgroundColor3 = Color3.fromRGB(80, 80, 200)
tabButtons["Player"].TextColor3 = Color3.fromRGB(255, 255, 255)
tabFrames["Player"].Visible = true
selectedTab = "Player"
--[[ MODERN ROBLOX MOBILE GUI - PART 2/4 ]]
local function createScrollingContainer(parent)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.Parent = parent
    
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
    
    return scrollFrame
end

for _, tabName in ipairs(tabs) do
    local frame = tabFrames[tabName]
    local scroll = createScrollingContainer(frame)
end

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
--[[ MODERN ROBLOX MOBILE GUI - PART 3/4 ]]
local playerFrame = tabFrames["Player"]

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

createSection(playerFrame, "PLAYER OPTIONS")

local espToggle, getEsp = createToggle(playerFrame, "ESP Boxes", false)
local nameToggle, getName = createToggle(playerFrame, "Nametags", true)
local tracerToggle, getTracer = createToggle(playerFrame, "Tracers", false)
local speedSlider, getSpeed = createSlider(playerFrame, "Walk Speed", 10, 50, 16)
local jumpSlider, getJump = createSlider(playerFrame, "Jump Power", 30, 100, 50)
createButton(playerFrame, "Toggle Noclip")

local visualsFrame = tabFrames["Visuals"]
createSection(visualsFrame, "VISUAL SETTINGS")

local chamsToggle, getChams = createToggle(visualsFrame, "Chams (Glow)", false)
local brightToggle, getBright = createToggle(visualsFrame, "Full Bright", false)
local fogToggle, getFog = createToggle(visualsFrame, "Disable Fog", false)
local fovSlider, getFov = createSlider(visualsFrame, "Field of View", 40, 120, 70)
local zoomSlider, getZoom = createSlider(visualsFrame, "Camera Zoom", 1, 10, 4)

createSection(visualsFrame, "COLOR OPTIONS")

local colorFrame = Instance.new("Frame")
colorFrame.Size = UDim2.new(1, 0, 0, 40)
colorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
colorFrame.BackgroundTransparency = 0.4
colorFrame.BorderSizePixel = 0
colorFrame.Parent = visualsFrame

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 6)
colorCorner.Parent = colorFrame

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -16, 1, 0)
colorLabel.Position = UDim2.new(0, 12, 0, 0)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "ESP Color: Blue"
colorLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
colorLabel.TextSize = 13
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = colorFrame

local colorNames = {"Red", "Blue", "Green", "Yellow", "Purple"}
local colorValues = {
    Red = Color3.fromRGB(255, 0, 0),
    Blue = Color3.fromRGB(0, 150, 255),
    Green = Color3.fromRGB(0, 255, 0),
    Yellow = Color3.fromRGB(255, 255, 0),
    Purple = Color3.fromRGB(200, 0, 255)
}
local colorIndex = 2

colorLabel.MouseButton1Click:Connect(function()
    colorIndex = colorIndex % #colorNames + 1
    colorLabel.Text = "ESP Color: " .. colorNames[colorIndex]
    espColor = colorValues[colorNames[colorIndex]]
end)

local gameFrame = tabFrames["Game"]
createSection(gameFrame, "GAME MODIFICATIONS")

local flyToggle, getFly = createToggle(gameFrame, "Fly Mode", false)
local jumpToggle, getJumpToggle = createToggle(gameFrame, "Infinite Jump", false)
local fallToggle, getFall = createToggle(gameFrame, "No Fall Damage", false)
createButton(gameFrame, "Teleport to Center")
createSection(gameFrame, "ANTI AFK")
local afkToggle, getAfk = createToggle(gameFrame, "Anti AFK", true)

local otherFrame = tabFrames["Other"]
createSection(otherFrame, "UTILITY")
createButton(otherFrame, "Click Teleport (Tap ground)")
local boostSlider, getBoost = createSlider(otherFrame, "Speed Boost", 1, 5, 1.5)
createSection(otherFrame, "MISC")
createButton(otherFrame, "Respawn")
createButton(otherFrame, "Clear Chat")
createButton(otherFrame, "Rejoin Game")

local settingsFrame = tabFrames["Settings"]
createSection(settingsFrame, "UI SETTINGS")
local transSlider, getTrans = createSlider(settingsFrame, "GUI Transparency", 50, 100, 95)
createButton(settingsFrame, "Toggle GUI (Button)")
createSection(settingsFrame, "MOBILE SETTINGS")

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 40)
infoText.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
infoText.BackgroundTransparency = 0.4
infoText.Text = "Press MENU button to toggle"
infoText.TextColor3 = Color3.fromRGB(180, 180, 200)
infoText.TextSize = 13
infoText.Font = Enum.Font.Gotham
infoText.BorderSizePixel = 0
infoText.Parent = settingsFrame

local infoCorner2 = Instance.new("UICorner")
infoCorner2.CornerRadius = UDim.new(0, 6)
infoCorner2.Parent = infoText

createSection(settingsFrame, "ABOUT")
local aboutText = Instance.new("TextLabel")
aboutText.Size = UDim2.new(1, 0, 0, 60)
aboutText.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
aboutText.BackgroundTransparency = 0.4
aboutText.Text = "Modern GUI v2.0\nFor Roblox Mobile"
aboutText.TextColor3 = Color3.fromRGB(160, 160, 180)
aboutText.TextSize = 12
aboutText.Font = Enum.Font.Gotham
aboutText.BorderSizePixel = 0
aboutText.Parent = settingsFrame

local aboutCorner = Instance.new("UICorner")
aboutCorner.CornerRadius = UDim.new(0, 6)
aboutCorner.Parent = aboutText

transSlider.MouseButton1Click:Connect(function()
    local trans = 1 - (getTrans() / 100)
    mainFrame.BackgroundTransparency = trans
    titleBar.BackgroundTransparency = trans
    tabBar.BackgroundTransparency = trans
end)
--[[ MODERN ROBLOX MOBILE GUI - PART 4/4 ]]
local function updatePlayerInfo()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local health = LocalPlayer.Character.Humanoid.Health
        healthLabel.Text = "Health: " .. math.round(health)
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 2)
    box.Adornee = hrp
    box.Color3 = espColor
    box.Transparency = 0.6
    box.ZIndex = 0
    box.Parent = hrp
    espObjects[player] = {box = box, tracer = nil, nameLabel = nil}
    
    if nameEnabled then
        local nameBill = Instance.new("BillboardGui")
        nameBill.Size = UDim2.new(0, 100, 0, 20)
        nameBill.Adornee = hrp
        nameBill.MaxDistance = 500
        nameBill.AlwaysOnTop = true
        nameBill.Parent = hrp
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 1, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = player.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextSize = 12
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextStrokeTransparency = 0.5
        nameLbl.Parent = nameBill
        espObjects[player].nameLabel = nameBill
    end
    
    if tracerEnabled then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Length = 0
        tracer.Thickness = 2
        tracer.Color3 = espColor
        tracer.Transparency = 0.7
        tracer.ZIndex = 0
        tracer.Parent = hrp
        espObjects[player].tracer = tracer
    end
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].box then espObjects[player].box:Destroy() end
        if espObjects[player].tracer then espObjects[player].tracer:Destroy() end
        if espObjects[player].nameLabel then espObjects[player].nameLabel:Destroy() end
        espObjects[player] = nil
    end
end

local function refreshESP()
    for player, _ in pairs(espObjects) do removeESP(player) end
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    end
end

local function updateTracers()
    for player, data in pairs(espObjects) do
        if data.tracer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local camPos = Camera.CFrame.Position
            local targetPos = hrp.Position
            local direction = (targetPos - camPos).unit
            data.tracer.Direction = direction
            data.tracer.Length = (targetPos - camPos).magnitude
            data.tracer.Adornee = Camera
        end
    end
end

espToggle.MouseButton1Click:Connect(function() espEnabled = getEsp() refreshESP() end)
nameToggle.MouseButton1Click:Connect(function() nameEnabled = getName() refreshESP() end)
tracerToggle.MouseButton1Click:Connect(function() tracerEnabled = getTracer() refreshESP() end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then createESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

for _, btn in ipairs(playerFrame:GetDescendants()) do
    if btn:IsA("TextButton") and btn.Text == "Toggle Noclip" then
        btn.MouseButton1Click:Connect(toggleNoclip)
        break
    end
end

local flyUp = false
local flyForward = false

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
    if input.KeyCode == Enum.KeyCode.W then flyForward = false
