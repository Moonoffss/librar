local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Константы для цветов и анимаций
local COLORS = {
    Background = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(45, 45, 45),
    Hover = Color3.fromRGB(55, 55, 55),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200)
}

local TWEEN_INFO = {
    Short = TweenInfo.new(0.2),
    Medium = TweenInfo.new(0.3),
    Long = TweenInfo.new(0.5)
}

function Library:CreateWindow(title)
    local Window = {}
    
    -- Основной UI
    local FluentUI = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local UIPadding = Instance.new("UIPadding")
    
    FluentUI.Name = "FluentUI"
    FluentUI.Parent = CoreGui
    FluentUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Main.Name = "Main"
    Main.Parent = FluentUI
    Main.BackgroundColor3 = COLORS.Background
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.ClipsDescendants = true
    
    -- Добавляем тень и закругление углов
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    
    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.Size = UDim2.new(1, -30, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = COLORS.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = COLORS.Accent
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    UIPadding.Parent = Container
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    
    -- Автоматическое обновление размера скролла
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Делаем окно перетаскиваемым
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            update(dragInput)
        end
    end)
    
    -- Кнопка
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        local ButtonCorner = Instance.new("UICorner")
        local ButtonPadding = Instance.new("UIPadding")
        
        Button.Name = "Button"
        Button.Parent = Container
        Button.BackgroundColor3 = COLORS.Secondary
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.Font = Enum.Font.Gotham
        Button.Text = text
        Button.TextColor3 = COLORS.Text
        Button.TextSize = 13
        Button.AutoButtonColor = false
        
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        ButtonPadding.Parent = Button
        ButtonPadding.PaddingLeft = UDim.new(0, 10)
        
        -- Эффекты наведения и нажатия
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Hover}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Secondary}):Play()
        end)
        
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Accent}):Play()
        end)
        
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Hover}):Play()
            callback()
        end)
        
        return Button
    end
    
    -- Переключатель
    function Window:AddToggle(text, default, callback)
        local Toggle = Instance.new("Frame")
        local ToggleCorner = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local ToggleButtonCorner = Instance.new("UICorner")
        local ToggleInner = Instance.new("Frame")
        local ToggleInnerCorner = Instance.new("UICorner")
        
        local enabled = default or false
        
        Toggle.Name = "Toggle"
        Toggle.Parent = Container
        Toggle.BackgroundColor3 = COLORS.Secondary
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 32)
        
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = Toggle
        
        Title.Name = "Title"
        Title.Parent = Toggle
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(1, -60, 1, 0)
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = COLORS.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle
        ToggleButton.BackgroundColor3 = enabled and COLORS.Accent or COLORS.Secondary
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 30, 0, 20)
        ToggleButton.AutoButtonColor = false
        ToggleButton.Text = ""
        
        ToggleButtonCorner.CornerRadius = UDim.new(0, 10)
        ToggleButtonCorner.Parent = ToggleButton
        
        ToggleInner.Name = "ToggleInner"
        ToggleInner.Parent = ToggleButton
        ToggleInner.AnchorPoint = Vector2.new(0, 0.5)
        ToggleInner.BackgroundColor3 = COLORS.Text
        ToggleInner.Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        ToggleInner.Size = UDim2.new(0, 16, 0, 16)
        
        ToggleInnerCorner.CornerRadius = UDim.new(1, 0)
        ToggleInnerCorner.Parent = ToggleInner
        
        local function updateToggle()
            TweenService:Create(ToggleButton, TWEEN_INFO.Short, {
                BackgroundColor3 = enabled and COLORS.Accent or COLORS.Secondary
            }):Play()
            
            TweenService:Create(ToggleInner, TWEEN_INFO.Short, {
                Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            }):Play()
            
            callback(enabled)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            updateToggle()
        end)
        
        -- Эффекты наведения
        Toggle.MouseEnter:Connect(function()
            TweenService:Create(Toggle, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Hover}):Play()
        end)
        
        Toggle.MouseLeave:Connect(function()
            TweenService:Create(Toggle, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Secondary}):Play()
        end)
        
        return Toggle
    end
    
    -- Слайдер
    function Window:AddSlider(text, min, max, default, callback)
        local Slider = Instance.new("Frame")
        local SliderCorner = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local SliderBar = Instance.new("Frame")
        local SliderBarCorner = Instance.new("UICorner")
        local SliderFill = Instance.new("Frame")
        local SliderFillCorner = Instance.new("UICorner")
        local Value = Instance.new("TextLabel")
        
        local value = default or min
        local dragging = false
        
        Slider.Name = "Slider"
        Slider.Parent = Container
        Slider.BackgroundColor3 = COLORS.Secondary
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 45)
        
        SliderCorner.CornerRadius = UDim.new(0, 6)
        SliderCorner.Parent = Slider
        
        Title.Name = "Title"
        Title.Parent = Slider
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(1, -20, 0, 25)
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = COLORS.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderBar.Name = "SliderBar"
        SliderBar.Parent = Slider
        SliderBar.BackgroundColor3 = COLORS.Background
        SliderBar.Position = UDim2.new(0, 10, 0, 25)
        SliderBar.Size = UDim2.new(1, -70, 0, 10)
        
        SliderBarCorner.CornerRadius = UDim.new(0, 5)
        SliderBarCorner.Parent = SliderBar
        
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = COLORS.Accent
        SliderFill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
        
        SliderFillCorner.CornerRadius = UDim.new(0, 5)
        SliderFillCorner.Parent = SliderFill
        
        Value.Name = "Value"
        Value.Parent = Slider
        Value.BackgroundTransparency = 1
        Value.Position = UDim2.new(1, -55, 0, 0)
        Value.Size = UDim2.new(0, 45, 0, 25)
        Value.Font = Enum.Font.GothamBold
        Value.Text = tostring(value)
        Value.TextColor3 = COLORS.TextDark
        Value.TextSize = 13
        
        local function updateSlider(input)
            local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
            SliderFill.Size = pos
            
            local newValue = math.floor(min + ((max - min) * pos.X.Scale))
            Value.Text = tostring(newValue)
            
            if value ~= newValue then
                value = newValue
                callback(value)
            end
        end
        
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        SliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        -- Эффекты наведения
        Slider.MouseEnter:Connect(function()
            TweenService:Create(Slider, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Hover}):Play()
        end)
        
        Slider.MouseLeave:Connect(function()
            TweenService:Create(Slider, TWEEN_INFO.Short, {BackgroundColor3 = COLORS.Secondary}):Play()
        end)
        
        return Slider
    end
    
    return Window
end

return Library
