local gun = game.Players.LocalPlayer.Backpack:FindFirstChild("Gun")
if gun then
    local remotes = {}
    for _, child in pairs(gun:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            table.insert(remotes, child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    if #remotes > 0 then
        print("REMOTES FOUND: " .. table.concat(remotes, ", "))
    else
        print("NO REMOTES IN GUN")
    end
else
    print("GUN NOT FOUND")
end
-- ====================================================================
--  ИНСПЕКТОР ПИСТОЛЕТА (С UI ОКНОМ)
-- ====================================================================
local CoreGui = game:GetService("CoreGui")

local inspectWindow = Instance.new("Frame")
inspectWindow.Size = UDim2.new(0, 300, 0, 200)
inspectWindow.Position = UDim2.new(0.5, -150, 0.5, -100)
inspectWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
inspectWindow.Visible = true
inspectWindow.ZIndex = 100
inspectWindow.Parent = CoreGui
Instance.new("UICorner", inspectWindow).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", inspectWindow)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(186, 85, 211)
titleLabel.Text = "GUN INSPECTOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextStrokeTransparency = 0

local contentLabel = Instance.new("TextLabel", inspectWindow)
contentLabel.Size = UDim2.new(1, -20, 1, -50)
contentLabel.Position = UDim2.new(0, 10, 0, 40)
contentLabel.BackgroundTransparency = 1
contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
contentLabel.Font = Enum.Font.SourceSans
contentLabel.TextSize = 12
contentLabel.TextWrapped = true
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.TextYAlignment = Enum.TextYAlignment.Top
contentLabel.TextStrokeTransparency = 0

local gun = game.Players.LocalPlayer.Backpack:FindFirstChild("Gun")
if gun then
    local remotes = {}
    for _, child in pairs(gun:GetChildren()) do
        if child:IsA("RemoteEvent") then
            table.insert(remotes, "📤 " .. child.Name .. " (RemoteEvent)")
        elseif child:IsA("RemoteFunction") then
            table.insert(remotes, "📞 " .. child.Name .. " (RemoteFunction)")
        end
    end
    
    if #remotes > 0 then
        contentLabel.Text = "REMOTES:\n\n" .. table.concat(remotes, "\n")
    else
        contentLabel.Text = "NO REMOTES FOUND\n\nCheck gun structure"
    end
else
    contentLabel.Text = "GUN NOT FOUND\n\nEquip gun first!"
end

task.wait(5)
inspectWindow:Destroy()
