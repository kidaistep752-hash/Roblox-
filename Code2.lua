Modern Purple-Black GUI Script
-- Compatible with Roblox LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════
--           THEME COLORS
-- ══════════════════════════════════════
local Theme = {
    Background    = Color3.fromRGB(10, 5, 20),
    Panel         = Color3.fromRGB(20, 10, 35),
    Accent        = Color3.fromRGB(120, 40, 220),
    AccentLight   = Color3.fromRGB(160, 80, 255),
    AccentDark    = Color3.fromRGB(80, 20, 160),
    Text          = Color3.fromRGB(230, 220, 255),
    TextDim       = Color3.fromRGB(140, 120, 180),
    Border        = Color3.fromRGB(80, 40, 140),
    ButtonHover   = Color3.fromRGB(100, 30, 190),
    Toggle_ON     = Color3.fromRGB(120, 40, 220),
    Toggle_OFF    = Color3.fromRGB(50, 30, 70),
    Success       = Color3.fromRGB(80, 220, 140),
    Warning       = Color3.fromRGB(220, 160, 40),
    Danger        = Color3.fromRGB(220, 60, 80),
}

-- ══════════════════════════════════════
--           UTILITY FUNCTIONS
-- ══════════════════════════════════════
local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
GUI BUILDER HELPERS
-- ══════════════════════════════════════
local function NewFrame(parent, size, pos, color, name)
    local f = Instance.new("Frame")
    f.Name = name or "Frame"
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function NewLabel(parent, text, size, pos, tcolor, tsize, name)
    local l = Instance.new("TextLabel")
    l.Name = name or "Label"
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = tcolor or Theme.Text
    l.TextSize = tsize or 14
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function NewButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Accent
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentLight})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent})
    end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.AccentDark})
        task.delay(0.1, function()
            Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
        end)
        if callback then callback() end
    end)
    return btn
end

local function NewToggle(parent, label, size, pos, default, callback)
    local container = NewFrame(parent, size, pos, Color3.fromRGB(0,0,0), "ToggleContainer")
    container.BackgroundTransparency = 1

    NewLabel(container, label,
        UDim2.new(1, -56, 1, 0),
        UDim2.new(0, 0, 0, 0),
        Theme.Text, 13)

    local track = NewFrame(container,
        UDim2.new(0, 46, 0, 24),
        UDim2.new(1, -50, 0.5, -12),
        default and Theme.Toggle_ON or Theme.Toggle_OFF, "Track")
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = track

    local knob = NewFrame(track,
        UDim2.new(0, 18, 0, 18),
        UDim2.new(0, default and 24 or 4, 0.5, -9),
        Color3.fromRGB(255,255,255), "Knob")
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = track

    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(track, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Toggle_ON or Theme.Toggle_OFF})
        Tween(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 24 or 4, 0.5, -9)})
        if callback then callback(state) end
    end)
    return container, state
end

local function NewSlider(parent, label, min, max, default, size, pos, callback)
    local container = NewFrame(parent, size, pos, Color3.fromRGB(0,0,0), "SliderContainer")
    container.BackgroundTransparency = 1

    NewLabel(container, label, UDim2.new(0.6, 0, 0, 18), UDim2.new(0,0,0,0), Theme.Text, 13)
    local valLabel = NewLabel(container, tostring(default),
        UDim2.new(0.4, 0, 0, 18),
        UDim2.new(0.6, 0, 0, 0),
        Theme.AccentLight, 13, "ValLabel")
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = NewFrame(container,
        UDim2.new(1, 0, 0, 6),
        UDim2.new(0, 0, 0, 26),
        Theme.Toggle_OFF, "SliderTrack")
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = track

    local fill = NewFrame(track,
        UDim2.new((default - min)/(max - min), 0, 1, 0),
        UDim2.new(0,0,0,0),
        Theme.Accent, "Fill")
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = fill

    local knob = NewFrame(track,
        UDim2.new(0,14,0,14),
        UDim2.new((default-min)/(max-min), -7, 0.5, -7),
        Theme.AccentLight, "Knob")
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = knob

    local dragging = false
    local function update(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        local val = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        valLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; update(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    return container
end

local function NewSection(parent, title)
    local sec = NewFrame(parent, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), "Section_"..title)
    sec.BackgroundTransparency = 1
    local lbl = NewLabel(sec, "— " .. title .. " —",
        UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
        Theme.AccentLight, 11)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    return sec
end

local function Separator(parent)
    local line = NewFrame(parent, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,0), Theme.Border, "Sep")
    line.BackgroundTransparency = 0.5
    return line
end

-- ══════════════════════════════════════
--           MAIN GUI CREATION
-- ══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- ── OPEN BUTTON ──────────────────────
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 110, 0, 36)
OpenBtn.Position = UDim2.new(0, 16, 0.5, -18)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "✦  MENU"
OpenBtn.TextColor3 = Theme.Text
OpenBtn.TextSize = 14
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui

local oc = Instance.new("UICorner")
oc.CornerRadius = UDim.new(0, 10)
oc.Parent = OpenBtn

local oStroke = Instance.new("UIStroke")
oStroke.Color = Theme.AccentLight
oStroke.Thickness = 1.5
oStroke.Parent = OpenBtn

-- ── MAIN WINDOW ──────────────────────
local MainFrame = NewFrame(ScreenGui,
    UDim2.new(0, 520, 0, 400),
    UDim2.new(0.5, -260, 0.5, -200),
    Theme.Background, "MainWindow")
MainFrame.Visible = false

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 12)
mCorner.Parent = MainFrame

local mStroke = Instance.new("UIStroke")
mStroke.Color = Theme.Border
mStroke.Thickness = 1.5
mStroke.Parent = MainFrame

-- Glow effect
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 60, 1, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = Theme.Accent
glow.ImageTransparency = 0.7
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24,24,276,276)
glow.ZIndex = 0
glow.Parent = MainFrame

-- ── TITLE BAR ────────────────────────
local TitleBar = NewFrame(MainFrame,
    UDim2.new(1, 0, 0, 46),
    UDim2.new(0, 0, 0, 0),
    Theme.Panel, "TitleBar")

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = TitleBar

-- fix bottom corners of title bar
local tbFix = NewFrame(TitleBar,
    UDim2.new(1, 0, 0, 12),
    UDim2.new(0, 0, 1, -12),
    Theme.Panel, "BottomFix")

NewLabel(TitleBar, "✦  MODERN GUI",
    UDim2.new(1, -120, 1, 0),
    UDim2.new(0, 16, 0, 0),
    Theme.Text, 15, "Title")

local SubTitle = NewLabel(TitleBar, "v1.0  |  by Script",
    UDim2.new(0, 100, 1, 0),
    UDim2.new(0, 150, 0, 0),
    Theme.TextDim, 11, "Sub")

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local clCorner = Instance.new("UICorner")
clCorner.CornerRadius = UDim.new(1, 0)
clCorner.Parent = CloseBtn

MakeDraggable(MainFrame, TitleBar)

-- ── SIDEBAR (tabs) ───────────────────
local Sidebar = NewFrame(MainFrame,
    UDim2.new(0, 130, 1, -46),
    UDim2.new(0, 0, 0, 46),
    Theme.Panel, "Sidebar")

local sbBorder = NewFrame(Sidebar, UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Theme.Border, "SBorder")

local sbLayout = Instance.new("UIListLayout")
sbLayout.Padding = UDim.new(0, 4)
sbLayout.Parent = Sidebar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingTop = UDim.new(0,10)
sbPad.PaddingLeft = UDim.new(0,8)
sbPad.PaddingRight = UDim.new(0,8)
sbPad.Parent = Sidebar

-- ── CONTENT AREA ─────────────────────
local ContentArea = NewFrame(MainFrame,
    UDim2.new(1, -130, 1, -46),
    UDim2.new(0, 130, 0, 46),
    Theme.Background, "ContentArea")

-- ══════════════════════════════════════
--           TAB SYSTEM
-- ══════════════════════════════════════
local Tabs = {}
local ActiveTab = nil

local function CreateTab(icon, name)
    -- Sidebar tab button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Theme.Panel
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = icon .. "  " .. name
    tabBtn.TextColor3 = Theme.TextDim
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local tbtnCorner = Instance.new("UICorner")
    tbtnCorner.CornerRadius = UDim.new(0, 6)
    tbtnCorner.Parent = tabBtn

    local tbtnPad = Instance.new("UIPadding")
    tbtnPad.PaddingLeft = UDim.new(0, 10)
    tbtnPad.Parent = tabBtn

    -- Accent bar on left when active
    local accentBar = NewFrame(tabBtn, UDim2.new(0,3,0.5,0), UDim2.new(0,0,0.25,0), Theme.Accent, "AccentBar")
    accentBar.Visible = false
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(1,0)
    abCorner.Parent = accentBar

    -- Content page (scroll)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 14)
    pagePad.PaddingLeft = UDim.new(0, 14)
    pagePad.PaddingRight = UDim.new(0, 14)
    pagePad.PaddingBottom = UDim.new(0, 14)
    pagePad.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, pageLayout.AbsoluteContentSize.Y + 28)
    end)

    local tab = {Button = tabBtn, Page = page, AccentBar = accentBar}
    Tabs[name] = tab

    tabBtn.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end
        -- Deactivate old
        if ActiveTab and Tabs[ActiveTab] then
            local old = Tabs[ActiveTab]
            old.Page.Visible = false
            old.AccentBar.Visible = false
            Tween(old.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.TextDim})
        end
        -- Activate new
        ActiveTab = name
        page.Visible = true
        accentBar.Visible = true
        Tween(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentDark, TextColor3 = Theme.Text})
    end)

    tabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            Tween(tabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.AccentDark})
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            Tween(tabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Panel})
        end
    end)

    return page
end

-- Activate first tab
local function ActivateTab(name)
    if Tabs[name] then
        Tabs[name].Button:GetPropertyChangedSignal("BackgroundColor3"):Wait()
    end
    if ActiveTab and Tabs[ActiveTab] then
        Tabs[ActiveTab].Page.Visible = false
        Tabs[ActiveTab].AccentBar.Visible = false
        Tween(Tabs[ActiveTab].Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.TextDim})
    end
    ActiveTab = name
    Tabs[name].Page.Visible = true
    Tabs[name].AccentBar.Visible = true
    Tween(Tabs[name].Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentDark, TextColor3 = Theme.Text})
end
-- ══════════════════════════════════════
--     TAB 1 — PLAYER
-- ══════════════════════════════════════
local PlayerPage = CreateTab("👤", "Player")

NewSection(PlayerPage, "MOVEMENT")

-- Walk Speed
local walkSpeedEnabled = false
local currentSpeed = 16
NewToggle(PlayerPage, "Speed Boost", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    walkSpeedEnabled = state
    Humanoid.WalkSpeed = state and currentSpeed or 16
end)

NewSlider(PlayerPage, "Walk Speed", 1, 200, 16,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    currentSpeed = val
    if walkSpeedEnabled then Humanoid.WalkSpeed = val end
end)

Separator(PlayerPage)
NewSection(PlayerPage, "JUMP & FLY")

local jumpEnabled = false
local currentJump = 50
NewToggle(PlayerPage, "High Jump", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    jumpEnabled = state
    Humanoid.JumpPower = state and currentJump or 50
end)

NewSlider(PlayerPage, "Jump Power", 1, 300, 50,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    currentJump = val
    if jumpEnabled then Humanoid.JumpPower = val end
end)

local flying = false
local flyBody
NewToggle(PlayerPage, "Fly Mode", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    flying = state
    if state then
        flyBody = Instance.new("BodyVelocity")
        flyBody.Velocity = Vector3.new(0,0,0)
        flyBody.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyBody.Parent = RootPart

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        gyro.CFrame = RootPart.CFrame
        gyro.Name = "FlyGyro"
        gyro.Parent = RootPart

        RunService.Heartbeat:Connect(function()
            if not flying or not flyBody or not flyBody.Parent then return end
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            flyBody.Velocity = dir * 60
        end)
    else
        if flyBody then flyBody:Destroy() end
        local gyro = RootPart:FindFirstChild("FlyGyro")
        if gyro then gyro:Destroy() end
    end
end)

Separator(PlayerPage)
NewSection(PlayerPage, "HEALTH")

NewToggle(PlayerPage, "God Mode (Max HP)", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    if state then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
    end
end)

NewToggle(PlayerPage, "Anti Ragdoll", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    Humanoid.BreakJointsOnDeath = not state
end)

NewButton(PlayerPage, "⟳  Respawn Character",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    Player:LoadCharacter()
end)

-- ══════════════════════════════════════
--     TAB 2 — GAME
-- ══════════════════════════════════════
local GamePage = CreateTab("🎮", "Game")

NewSection(GamePage, "WORLD")

NewSlider(GamePage, "Gravity", 0, 300, 196,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    workspace.Gravity = val
end)

NewSlider(GamePage, "Game Speed", 0, 10, 1,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    workspace:GetPropertyChangedSignal("DistributedGameTime"):Wait()
    game:GetService("RunService"):Set3dRenderStepEnabled("update", true)
end)

Separator(GamePage)
NewSection(GamePage, "TIME OF DAY")

NewSlider(GamePage, "Clock Time (0-24)", 0, 24, 14,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    Lighting.ClockTime = val
end)

NewButton(GamePage, "🌙  Set Night",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    Tween(Lighting, TweenInfo.new(1.5), {ClockTime = 0})
end)

NewButton(GamePage, "☀️  Set Day",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    Tween(Lighting, TweenInfo.new(1.5), {ClockTime = 14})
end)

Separator(GamePage)
NewSection(GamePage, "TOOLS")

NewToggle(GamePage, "Infinite Jump", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    if state then
        UserInputService.JumpRequest:Connect(function()
            if state then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

NewButton(GamePage, "🗺️  Teleport to Spawn",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation")
    if spawn then
        RootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
    end
end)

-- ══════════════════════════════════════
--     TAB 3 — VISUAL
-- ══════════════════════════════════════
local VisualPage = CreateTab("👁", "Visual")

NewSection(VisualPage, "CAMERA")

NewSlider(VisualPage, "Field of View", 30, 120, 70,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    workspace.CurrentCamera.FieldOfView = val
end)

Separator(VisualPage)
NewSection(VisualPage, "LIGHTING FX")

NewToggle(VisualPage, "Fullbright", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    Lighting.Brightness = state and 5 or 1
    Lighting.GlobalShadows = not state
    Lighting.Ambient = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
    Lighting.OutdoorAmbient = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end)

NewToggle(VisualPage, "Blur Effect", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    local existing = Lighting:FindFirstChildOfClass("BlurEffect")
    if state then
        if not existing then
            local blur = Instance.new("BlurEffect")
            blur.Size = 10
            blur.Parent = Lighting
        end
    else
        if existing then existing:Destroy() end
    end
end)

NewSlider(VisualPage, "Ambient Brightness", 0, 10, 1,
    UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), function(val)
    Lighting.Brightness = val
end)

Separator(VisualPage)
NewSection(VisualPage, "PLAYER FX")

NewToggle(VisualPage, "Rainbow Character", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    if state then
        RunService.Heartbeat:Connect(function()
            if not state then return end
            local h = (tick() * 60) % 360 / 360
            local col = Color3.fromHSV(h, 1, 1)
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Color = col
                end
            end
        end)
    end
end)

NewToggle(VisualPage, "Transparent Character", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = state and 0.7 or 0
        end
    end
end)
TAB 4 — MISC
-- ══════════════════════════════════════
local MiscPage = CreateTab("⚡", "Misc")

NewSection(MiscPage, "EXTRAS")

NewToggle(MiscPage, "Noclip", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    RunService.Stepped:Connect(function()
        if state then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

NewToggle(MiscPage, "Anti AFK", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), false, function(state)
    if state then
        local VR = Player:FindFirstChild("VirtualUser") or Instance.new("VirtualUser", Player)
        RunService.Heartbeat:Connect(function()
            if state then
                VR:CaptureController()
                VR:ClickButton2(Vector2.new(), workspace.CurrentCamera.CFrame)
            end
        end)
    end
end)

NewButton(MiscPage, "📋  Copy Player ID",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    setclipboard(tostring(Player.UserId))
end)

Separator(MiscPage)
NewSection(MiscPage, "CHAT")

NewButton(MiscPage, "💬  Shout in Chat",
    UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), function()
    game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
        :FindFirstChild("SayMessageRequest"):FireServer("Hello from Modern GUI!", "All")
end)

-- ══════════════════════════════════════
--     TAB 5 — SETTINGS
-- ══════════════════════════════════════
local SettingsPage = CreateTab("⚙", "Settings")

NewSection(SettingsPage, "INTERFACE")

NewToggle(SettingsPage, "Show GUI Watermark", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), true, function(state)
    -- watermark logic below (toggle visibility)
    local wm = ScreenGui:FindFirstChild("Watermark")
    if wm then wm.Visible = state end
end)

NewToggle(SettingsPage, "Draggable Window", UDim2.new(1,0,0,28), UDim2.new(0,0,0,0), true, function(state)
    -- re-bind or unbind drag (already bound; UI note only)
end)

Separator(SettingsPage)
NewSection(SettingsPage, "KEYBINDS")

NewLabel(SettingsPage, "Toggle GUI:  [ RightShift ]",
    UDim2.new(1,0,0,22), UDim2.new(0,0,0,0),
    Theme.TextDim, 12)

NewLabel(SettingsPage, "Fly Up: Space  |  Down: LCtrl",
    UDim2.new(1,0,0,22), UDim2.new(0,0,0,0),
    Theme.TextDim, 12)

Separator(SettingsPage)
NewSection(SettingsPage, "CREDITS")

NewLabel(SettingsPage, "Modern Purple GUI  •  Lua Script",
    UDim2.new(1,0,0,22), UDim2.new(0,0,0,0),
    Theme.AccentLight, 12)

NewLabel(SettingsPage, "Built for Roblox  •  v1.0",
    UDim2.new(1,0,0,22), UDim2.new(0,0,0,0),
    Theme.TextDim, 11)

-- ══════════════════════════════════════
--     WATERMARK
-- ══════════════════════════════════════
local Watermark = NewFrame(ScreenGui,
    UDim2.new(0, 170, 0, 28),
    UDim2.new(1, -186, 0, 10),
    Theme.Panel, "Watermark")
local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0,8)
wmCorner.Parent = Watermark
local wmStroke = Instance.new("UIStroke")
wmStroke.Color = Theme.Border
wmStroke.Thickness = 1
wmStroke.Parent = Watermark
NewLabel(Watermark, "✦ Modern GUI  |  " .. Player.Name,
    UDim2.new(1,-16,1,0), UDim2.new(0,8,0,0),
    Theme.TextDim, 11)

-- ══════════════════════════════════════
--     OPEN / CLOSE LOGIC
-- ══════════════════════════════════════
local guiOpen = false
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function SetGUI(open)
    guiOpen = open
    if open then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        MainFrame.Position = UDim2.new(0.5,0,0.5,0)
        Tween(MainFrame, tweenInfo, {
            Size = UDim2.new(0,520,0,400),
            Position = UDim2.new(0.5,-260,0.5,-200)
        })
        OpenBtn.Text = "✕  CLOSE"
        Tween(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Danger})
    else
        Tween(MainFrame, tweenInfo, {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0.5,0,0.5,0)
        })
        task.delay(0.35, function()
            if not guiOpen then MainFrame.Visible = false end
        end)
        OpenBtn.Text = "✦  MENU"
        Tween(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent})
    end
end

OpenBtn.MouseButton1Click:Connect(function()
    SetGUI(not guiOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
    SetGUI(false)
end)

-- RightShift keybind toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        SetGUI(not guiOpen)
    end
end)

-- ══════════════════════════════════════
--     ACTIVATE DEFAULT TAB
-- ══════════════════════════════════════
task.defer(function()
    ActivateTab("Player")
end)

print("✦ Modern GUI loaded! Press RightShift to toggle.")
