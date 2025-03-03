local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

function Library:CreateWindow(title)
    local Window = {}
    
    -- Основной UI
    local FluentUI = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    
    FluentUI.Name = "FluentUI"
    FluentUI.Parent = CoreGui
    FluentUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Main.Name = "Main"
    Main.Parent = FluentUI
    Main.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.Size = UDim2.new(0, 400, 0, 300)
    
    -- Добавляем тень
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    
    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    -- Делаем окно перетаскиваемым
    local dragging
    local dragInput
    local dragStart
    local startPos
    
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
    
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = Container
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Font = Enum.Font.Gotham
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.AutoButtonColor = false
        
        -- Эффекты наведения
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return Button
    end
    
    function Window:AddToggle(text, default, callback)
        local Toggle = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local enabled = default or false
        
        Toggle.Name = "Toggle"
        Toggle.Parent = Container
        Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 30)
        
        Title.Name = "Title"
        Title.Parent = Toggle
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 30, 0, 20)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
            }):Play()
            callback(enabled)
        end)
        
        return Toggle
    end
    
    return Window
end

return Library
