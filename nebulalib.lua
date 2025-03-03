--[[
    Nebula Tech UI Library
    Современная UI библиотека для Roblox
    
    Особенности:
    - Минималистичный дизайн
    - Темная тема
    - Поддержка вкладок
    - ESP система
    - Настраиваемые элементы
]]

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Константы
local THEME = {
    Background = Color3.fromRGB(17, 17, 17),
    Foreground = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(114, 111, 181),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    BorderColor = Color3.fromRGB(30, 30, 30),
    PlaceholderColor = Color3.fromRGB(100, 100, 100)
}

local Library = {
    Flags = {},
    Tabs = {},
    ActiveTab = nil,
    WindowPosition = UDim2.new(0.5, -300, 0.5, -200)
}

-- Утилиты
local function Create(class, properties, children)
    local instance = Instance.new(class)
    
    for property, value in next, properties or {} do
        instance[property] = value
    end
    
    for _, child in next, children or {} do
        child.Parent = instance
    end
    
    return instance
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad),
        properties
    )
    tween:Play()
    return tween
end

-- Основные компоненты
function Library:CreateWindow(title)
    -- Основное окно
    self.MainGui = Create("ScreenGui", {
        Name = "NebulaTech",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.MainGui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = self.WindowPosition,
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Делаем окно перетаскиваемым
    local dragInput, dragStart, startPos
    
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Заголовок
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0
    })
    
    Create("TextLabel", {
        Parent = self.TitleBar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Nebula Tech",
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Контейнер для вкладок
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 150, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0
    })
    
    self.TabButtons = Create("ScrollingFrame", {
        Name = "TabButtons",
        Parent = self.TabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = self.TabButtons,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Контейнер для содержимого
    self.ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -150, 1, -30),
        Position = UDim2.new(0, 150, 0, 30),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0
    })
    
    return self
end

function Library:CreateTab(name, icon)
    local tab = {
        Name = name,
        Sections = {},
        Visible = false
    }
    
    -- Кнопка вкладки
    tab.Button = Create("TextButton", {
        Name = name .. "Button",
        Parent = self.TabButtons,
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    
    -- Иконка (если есть)
    if icon then
        Create("ImageLabel", {
            Parent = tab.Button,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 5, 0.5, -10),
            BackgroundTransparency = 1,
            Image = icon
        })
    end
    
    -- Текст вкладки
    Create("TextLabel", {
        Parent = tab.Button,
        Size = UDim2.new(1, icon and -30 or -10, 1, 0),
        Position = UDim2.new(0, icon and 30 or 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Контейнер содержимого вкладки
    tab.Container = Create("ScrollingFrame", {
        Name = name .. "Container",
        Parent = self.ContentContainer,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = tab.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    -- Обработка нажатия
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Если это первая вкладка, делаем её активной
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Library:SelectTab(tab)
    if self.ActiveTab == tab then return end
    
    -- Скрываем предыдущую вкладку
    if self.ActiveTab then
        self.ActiveTab.Container.Visible = false
        Tween(self.ActiveTab.Button, {BackgroundColor3 = THEME.Background})
    end
    
    -- Показываем новую вкладку
    self.ActiveTab = tab
    tab.Container.Visible = true
    Tween(tab.Button, {BackgroundColor3 = THEME.AccentColor})
end

function Library:CreateSection(tab, name)
    local section = {}
    
    -- Находим или создаем контейнер для секций
    if not tab.SectionsContainer then
        tab.SectionsContainer = Create("Frame", {
            Parent = tab.Container,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- Добавляем горизонтальный layout
        Create("UIGridLayout", {
            Parent = tab.SectionsContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            CellSize = UDim2.new(0.5, -5, 0, 0), -- Две секции в ряд
            CellPadding = UDim2.new(0, 10, 0, 10)
        })
    end
    
    section.Container = Create("Frame", {
        Parent = tab.SectionsContainer,
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0)
    })
    
    -- Скругление углов для секции
    Create("UICorner", {
        Parent = section.Container,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Заголовок секции
    Create("TextLabel", {
        Parent = section.Container,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    
    -- Контейнер для элементов
    section.Content = Create("Frame", {
        Parent = section.Container,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = section.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Добавляем отступ снизу
    Create("UIPadding", {
        Parent = section.Container,
        PaddingBottom = UDim.new(0, 10)
    })
    
    return section
end

function Library:CreateToggle(section, name, default, callback)
    local toggle = {
        Value = default or false
    }
    
    toggle.Container = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    -- Текст
    Create("TextLabel", {
        Parent = toggle.Container,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Переключатель
    toggle.Button = Create("Frame", {
        Parent = toggle.Container,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = toggle.Value and THEME.AccentColor or THEME.PlaceholderColor,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Индикатор
    toggle.Indicator = Create("Frame", {
        Parent = toggle.Button,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(toggle.Value and 1 or 0, toggle.Value and -18 or 2, 0.5, -8),
        BackgroundColor3 = THEME.TextColor,
        BorderSizePixel = 0
    })
    
    -- Скругление углов
    Create("UICorner", {
        Parent = toggle.Button,
        CornerRadius = UDim.new(1, 0)
    })
    
    Create("UICorner", {
        Parent = toggle.Indicator,
        CornerRadius = UDim.new(1, 0)
    })
    
    -- Обработка нажатия
    toggle.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle.Value = not toggle.Value
            
            -- Анимация
            Tween(toggle.Button, {BackgroundColor3 = toggle.Value and THEME.AccentColor or THEME.PlaceholderColor})
            Tween(toggle.Indicator, {Position = UDim2.new(toggle.Value and 1 or 0, toggle.Value and -18 or 2, 0.5, -8)})
            
            if callback then
                callback(toggle.Value)
            end
        end
    end)
    
    return toggle
end

function Library:CreateButton(section, name, callback)
    local button = {}
    
    button.Container = Create("TextButton", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = THEME.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    -- Скругление углов
    Create("UICorner", {
        Parent = button.Container,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Эффект при наведении и нажатии
    button.Container.MouseEnter:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.AccentColor})
    end)
    
    button.Container.MouseLeave:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.Foreground})
    end)
    
    button.Container.MouseButton1Down:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.PlaceholderColor})
    end)
    
    button.Container.MouseButton1Up:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.AccentColor})
        if callback then
            callback()
        end
    end)
    
    return button
end

-- ESP система
local ESPSystem = {
    Enabled = false,
    ShowNames = false,
    ShowWeapons = false,
    ThroughWalls = false,
    SharedESP = false,
    
    Objects = {},
    Connections = {}
}

function ESPSystem:Toggle(enabled)
    self.Enabled = enabled
    
    if enabled then
        self:Start()
    else
        self:Stop()
    end
end

function ESPSystem:Start()
    -- Очищаем предыдущие подключения
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    table.clear(self.Connections)
    
    -- Создаем ESP для существующих игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateESP(player)
        end
    end
    
    -- Подключаем обработку новых игроков
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        self:CreateESP(player)
    end))
    
    -- Подключаем обработку удаления игроков
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end))
    
    -- Обновление ESP
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:Update()
    end))
end

function ESPSystem:Stop()
    -- Отключаем все подключения
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    table.clear(self.Connections)
    
    -- Удаляем все ESP объекты
    for player, esp in pairs(self.Objects) do
        self:RemoveESP(player)
    end
end

function ESPSystem:CreateESP(player)
    if self.Objects[player] then return end
    
    local esp = {}
    
    -- Создаем основной контейнер
    esp.Container = Create("BillboardGui", {
        Parent = CoreGui,
        Name = player.Name .. "_ESP",
        Size = UDim2.new(4, 0, 5.5, 0),
        AlwaysOnTop = true,
        Enabled = self.Enabled
    })
    
    -- Имя игрока
    esp.Name = Create("TextLabel", {
        Parent = esp.Container,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, -20),
        BackgroundTransparency = 1,
        Text = player.Name,
        TextColor3 = THEME.TextColor,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Visible = self.ShowNames
    })
    
    -- Оружие
    esp.Weapon = Create("TextLabel", {
        Parent = esp.Container,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Weapon",
        TextColor3 = THEME.TextColor,
        TextStrokeTransparency = 0,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Visible = self.ShowWeapons
    })
    
    self.Objects[player] = esp
end

function ESPSystem:RemoveESP(player)
    local esp = self.Objects[player]
    if esp then
        esp.Container:Destroy()
        self.Objects[player] = nil
    end
end

function ESPSystem:Update()
    for player, esp in pairs(self.Objects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            esp.Container.Adornee = player.Character.HumanoidRootPart
            esp.Container.Enabled = self.Enabled and (self.ThroughWalls or self:IsVisible(player.Character))
            esp.Name.Visible = self.ShowNames
            esp.Weapon.Visible = self.ShowWeapons
            
            -- Обновляем информацию об оружии (пример)
            local weapon = player.Character:FindFirstChild("Weapon")
            if weapon then
                esp.Weapon.Text = weapon.Name
            end
        else
            esp.Container.Enabled = false
        end
    end
end

function ESPSystem:IsVisible(character)
    local camera = workspace.CurrentCamera
    local ray = Ray.new(
        camera.CFrame.Position,
        (character.HumanoidRootPart.Position - camera.CFrame.Position).Unit * 1000
    )
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character})
    return hit and hit:IsDescendantOf(character)
end

-- Добавляем ESP в библиотеку
Library.ESP = ESPSystem

return Library 