-- Загрузка библиотеки Orion UI с закругленным и анимированным интерфейсом
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создание главного окна
local Window = OrionLib:MakeWindow({
    Name = "Premium Android Меню", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "AndroidMenuConfig",
    IntroText = "Загрузка GUI..."
})

-- Локальные переменные для функции Fling
local TargetPlayerName = nil
local FlingEnabled = false
local FlingConnection = nil

-- Функция для получения списка актуальных ников игроков на сервере
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= game:GetService("Players").LocalPlayer and p.Name then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- ==========================================
-- ВКЛАДКА: PLAYER (ИГРОК)
-- ==========================================
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSection({
    Name = "Функции выталкивания"
})

-- Галочка (Toggle) для включения/выключения функции Fling
PlayerTab:AddToggle({
    Name = "Включить Fling",
    Default = false,
    Callback = function(Value)
        FlingEnabled = Value
        
        -- Сразу отключаем старое подключение, если оно было
        if FlingConnection then 
            FlingConnection:Disconnect() 
            FlingConnection = nil
        end
        
        if FlingEnabled then
            -- Проверяем, выбрана ли цель
            if not TargetPlayerName or TargetPlayerName == "Никто" then
                OrionLib:MakeNotification({
                    Name = "Ошибка",
                    Content = "Сначала выберите игрока из списка ниже!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                return
            end

            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer
            
            -- Основной цикл флинга, привязанный к физике персонажа
            FlingConnection = RunService.Stepped:Connect(function()
                if not FlingEnabled then return end
                
                local Target = Players:FindFirstChild(TargetPlayerName)
                local MyChar = LocalPlayer.Character
                local TargetChar = Target and Target.Character
                
                -- Проверяем, живы ли оба персонажа и есть ли у них RootPart
                if MyChar and TargetChar and MyChar:FindFirstChild("HumanoidRootPart") and TargetChar:FindFirstChild("HumanoidRootPart") then
                    local myRoot = MyChar.HumanoidRootPart
                    local targetRoot = TargetChar.HumanoidRootPart
                    
                    -- Делаем наши хитбоксы неосязаемыми, чтобы нас не откинуло вместе с ним
                    for _, part in ipairs(MyChar:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- Накачиваем наш RootPart дикой угловой и линейной скоростью
                    myRoot.Velocity = Vector3.new(99999, 99999, 99999)
                    
                    -- Проверяем наличие сил вращения, чтобы не спавнить их бесконечно
                    local bAV = myRoot:FindFirstChild("FlingRotator")
                    if not bAV then
                        bAV = Instance.new("BodyAngularVelocity")
                        bAV.Name = "FlingRotator"
                        bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bAV.AngularVelocity = Vector3.new(0, 99999, 0)
                        bAV.Parent = myRoot
                    end
                    
                    -- Телепортируем себя в хитбокс врага для удара
                    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0)
                end
            end)
        else
            -- Очистка при выключении галочки
            if FlingConnection then
                FlingConnection:Disconnect()
                FlingConnection = nil
            end
            
            -- Возвращаем физику и убираем скорость
            local MyChar = game:GetService("Players").LocalPlayer.Character
            if MyChar and MyChar:FindFirstChild("HumanoidRootPart") then
                local myRoot = MyChar.HumanoidRootPart
                myRoot.Velocity = Vector3.new(0, 0, 0)
                local bAV = myRoot:FindFirstChild("FlingRotator")
                if bAV then bAV:Destroy() end
            end
        end
    end    
})

-- Выпадающее меню выбора игрока
local DropdownElement = PlayerTab:AddDropdown({
    Name = "Выберите цель для Fling",
    Default = "Никто",
    Options = GetPlayerNames(),
    Callback = function(Value)
        TargetPlayerName = Value
    end
})

-- Функция безопасного обновления списка
local function RefreshList()
    if DropdownElement then
        pcall(function()
            DropdownElement:Refresh(GetPlayerNames(), true)
        end)
    end
end

-- Автоматическое обновление списка игроков при изменении состава сервера
game:GetService("Players").PlayerAdded:Connect(RefreshList)
game:GetService("Players").PlayerRemoving:Connect(RefreshList)


-- ==========================================
-- ОСТАЛЬНЫЕ ВКЛАДКИ (ПУСТЫЕ ШАБЛОНЫ ПОД ЗАПРОС)
-- ==========================================
local GameTab = Window:MakeTab({ Name = "Game", Icon = "rbxassetid://4483362458", PremiumOnly = false })
GameTab:AddSection({ Name = "Настройки игрового мира" })

local VisualTab = Window:MakeTab({ Name = "Visual", Icon = "rbxassetid://4483345998", PremiumOnly = false })
VisualTab:AddSection({ Name = "Подсветка и Chams" })

local OtherTab = Window:MakeTab({ Name = "Other", Icon = "rbxassetid://4483362748", PremiumOnly = false })
OtherTab:AddSection({ Name = "Дополнительные утилиты" })

local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483364237", PremiumOnly = false })
SettingsTab:AddButton({
    Name = "Закрыть чит-меню",
    Callback = function()
        if FlingConnection then FlingConnection:Disconnect() end
        OrionLib:Destroy()
    end
})

-- Запуск интерфейса
OrionLib:Init()
