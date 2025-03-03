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
    Background = Color3.fromRGB(15, 15, 15),
    Foreground = Color3.fromRGB(20, 20, 20),
    DarkForeground = Color3.fromRGB(13, 13, 13),
    AccentColor = Color3.fromRGB(114, 111, 181),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    BorderColor = Color3.fromRGB(30, 30, 30),
    PlaceholderColor = Color3.fromRGB(60, 60, 60),
    HoverColor = Color3.fromRGB(25, 25, 25),
    ErrorColor = Color3.fromRGB(255, 64, 64),
    OutlineColor = Color3.fromRGB(35, 35, 35),
    ToggleBackground = Color3.fromRGB(20, 20, 20),
    ToggleEnabled = Color3.fromRGB(114, 111, 181),
    ToggleDisabled = Color3.fromRGB(50, 50, 50)
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
    
    -- Контейнер с обводкой для кнопки
    local buttonOutline = Create("Frame", {
        Name = name .. "ButtonOutline",
        Parent = self.TabButtons,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = THEME.OutlineColor,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = buttonOutline,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Кнопка вкладки
    tab.Button = Create("TextButton", {
        Name = name .. "Button",
        Parent = buttonOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = tab.Button,
        CornerRadius = UDim.new(0, 7)
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
    
    -- Эффект при наведении
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, {BackgroundColor3 = THEME.HoverColor})
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, {BackgroundColor3 = THEME.Background})
        end
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
        
        -- Создаем левую и правую колонки
        tab.LeftColumn = Create("Frame", {
            Parent = tab.SectionsContainer,
            Size = UDim2.new(0.5, -5, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        tab.RightColumn = Create("Frame", {
            Parent = tab.SectionsContainer,
            Size = UDim2.new(0.5, -5, 0, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- Добавляем UIListLayout для каждой колонки
        Create("UIListLayout", {
            Parent = tab.LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        Create("UIListLayout", {
            Parent = tab.RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        tab.SectionCount = 0
    end
    
    -- Определяем, в какую колонку добавить секцию
    local parent = tab.SectionCount % 2 == 0 and tab.LeftColumn or tab.RightColumn
    tab.SectionCount = tab.SectionCount + 1
    
    -- Создаем контейнер с обводкой
    local outlineContainer = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = THEME.OutlineColor,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Create("UICorner", {
        Parent = outlineContainer,
        CornerRadius = UDim.new(0, 8)
    })
    
    section.Container = Create("Frame", {
        Parent = outlineContainer,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = THEME.DarkForeground,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Create("UICorner", {
        Parent = section.Container,
        CornerRadius = UDim.new(0, 7)
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
    
    Create("UIPadding", {
        Parent = section.Content,
        PaddingBottom = UDim.new(0, 10)
    })
    
    return section
end

function Library:CreateToggle(section, name, default, callback)
    local toggle = {
        Value = default or false,
        Keybind = nil
    }
    
    toggle.Container = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1
    })
    
    -- Текст
    Create("TextLabel", {
        Parent = toggle.Container,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 13
    })
    
    -- Переключатель
    toggle.Button = Create("Frame", {
        Parent = toggle.Container,
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -36, 0.5, -9),
        BackgroundColor3 = toggle.Value and THEME.ToggleEnabled or THEME.ToggleDisabled,
        BorderSizePixel = 0
    })
    
    -- Индикатор
    toggle.Indicator = Create("Frame", {
        Parent = toggle.Button,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(toggle.Value and 1 or 0, toggle.Value and -16 or 2, 0.5, -7),
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
    
    -- Функция для установки значения
    function toggle:SetValue(value)
        toggle.Value = value
        Tween(toggle.Button, {BackgroundColor3 = value and THEME.ToggleEnabled or THEME.ToggleDisabled})
        Tween(toggle.Indicator, {Position = UDim2.new(value and 1 or 0, value and -16 or 2, 0.5, -7)})
        if callback then
            callback(value)
        end
    end
    
    -- Обработка нажатия
    toggle.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:SetValue(not toggle.Value)
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
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Эффект свечения
    local glow = Create("ImageLabel", {
        Parent = button.Container,
        Size = UDim2.new(1.1, 0, 1.2, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7603818835",
        ImageColor3 = THEME.AccentColor,
        ImageTransparency = 1
    })
    
    -- Эффекты при наведении и нажатии
    button.Container.MouseEnter:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.HoverColor})
        Tween(glow, {ImageTransparency = 0.8})
    end)
    
    button.Container.MouseLeave:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.Foreground})
        Tween(glow, {ImageTransparency = 1})
    end)
    
    button.Container.MouseButton1Down:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.PlaceholderColor})
        Tween(glow, {ImageTransparency = 0.7})
    end)
    
    button.Container.MouseButton1Up:Connect(function()
        Tween(button.Container, {BackgroundColor3 = THEME.HoverColor})
        Tween(glow, {ImageTransparency = 0.8})
        if callback then
            callback()
        end
    end)
    
    return button
end

function Library:CreateDropdown(section, name, options, default, callback)
    local dropdown = {
        Value = default or options[1],
        Options = options,
        Open = false
    }
    
    dropdown.Container = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1
    })
    
    -- Текст
    Create("TextLabel", {
        Parent = dropdown.Container,
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 13
    })
    
    -- Кнопка дропдауна
    dropdown.Button = Create("TextButton", {
        Parent = dropdown.Container,
        Size = UDim2.new(0, 100, 0, 20),
        Position = UDim2.new(1, -100, 0.5, -10),
        BackgroundColor3 = THEME.DarkForeground,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    
    -- Текст значения
    local valueText = Create("TextLabel", {
        Parent = dropdown.Button,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = dropdown.Value,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    
    -- Иконка
    local icon = Create("ImageLabel", {
        Parent = dropdown.Button,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -16, 0.5, -6),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072706663",
        ImageColor3 = THEME.TextColor
    })
    
    -- Скругление углов
    Create("UICorner", {
        Parent = dropdown.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Список опций
    dropdown.OptionList = Create("Frame", {
        Parent = dropdown.Button,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = THEME.DarkForeground,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    })
    
    Create("UICorner", {
        Parent = dropdown.OptionList,
        CornerRadius = UDim.new(0, 4)
    })
    
    local optionLayout = Create("UIListLayout", {
        Parent = dropdown.OptionList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    -- Создаем опции
    for _, option in ipairs(options) do
        local optionButton = Create("TextButton", {
            Parent = dropdown.OptionList,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = THEME.DarkForeground,
            BorderSizePixel = 0,
            Text = option,
            TextColor3 = THEME.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 11
        })
        
        optionButton.MouseEnter:Connect(function()
            Tween(optionButton, {BackgroundColor3 = THEME.HoverColor})
        end)
        
        optionButton.MouseLeave:Connect(function()
            Tween(optionButton, {BackgroundColor3 = THEME.DarkForeground})
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.Value = option
            valueText.Text = option
            dropdown:Toggle(false)
            if callback then
                callback(option)
            end
        end)
    end
    
    -- Функция переключения дропдауна
    function dropdown:Toggle(state)
        dropdown.Open = state
        dropdown.OptionList.Visible = state
        if state then
            dropdown.OptionList.Size = UDim2.new(1, 0, 0, #options * 26)
            Tween(icon, {Rotation = 180})
        else
            Tween(icon, {Rotation = 0})
        end
    end
    
    -- Обработка нажатия
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown:Toggle(not dropdown.Open)
    end)
    
    return dropdown
end

function Library:CreateKeybind(section, name, default, callback)
    local keybind = {
        Value = default or Enum.KeyCode.Unknown,
        Listening = false
    }
    
    keybind.Container = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    -- Текст
    Create("TextLabel", {
        Parent = keybind.Container,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Кнопка
    keybind.Button = Create("TextButton", {
        Parent = keybind.Container,
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0,
        Text = keybind.Value.Name,
        TextColor3 = THEME.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = keybind.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Обработка нажатия
    keybind.Button.MouseButton1Click:Connect(function()
        keybind.Listening = true
        keybind.Button.Text = "..."
    end)
    
    -- Обработка ввода
    UserInputService.InputBegan:Connect(function(input)
        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind.Value = input.KeyCode
            keybind.Button.Text = input.KeyCode.Name
            keybind.Listening = false
            if callback then
                callback(input.KeyCode)
            end
        end
    end)
    
    return keybind
end

function Library:CreateTextbox(section, name, placeholder, callback)
    local textbox = {}
    
    textbox.Container = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    -- Текст
    Create("TextLabel", {
        Parent = textbox.Container,
        Size = UDim2.new(1, -120, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = THEME.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    -- Поле ввода
    textbox.Input = Create("TextBox", {
        Parent = textbox.Container,
        Size = UDim2.new(0, 110, 0, 24),
        Position = UDim2.new(1, -110, 0.5, -12),
        BackgroundColor3 = THEME.Foreground,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder,
        TextColor3 = THEME.TextColor,
        PlaceholderColor3 = THEME.PlaceholderColor,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false
    })
    
    Create("UICorner", {
        Parent = textbox.Input,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Обработка изменения текста
    textbox.Input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textbox.Input.Text)
        end
    end)
    
    return textbox
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