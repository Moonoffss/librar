--[[
  UI Library
  Originally by bungie#0001
  Modified by Depso
  
  A modern, feature-rich UI library for Roblox games
  Supports both mouse and touch input
]]

-- Константы для валидации
local CONSTANTS = {
    MIN_BLUR_SIZE = 0,
    MAX_BLUR_SIZE = 56,
    MIN_FOV = 1,
    MAX_FOV = 120,
    DEFAULT_TWEEN_DURATION = 0.17,
    
    -- Форматы даты и времени
    DATE_FORMATS = {
        DAY = {
            FULL = "%A",    -- Полное название дня
            SHORT = "%a",   -- Сокращенное название
            MONTH = "%d",   -- День месяца
            YEAR = "%j"     -- День года
        },
        MONTH = {
            FULL = "%B",    -- Полное название месяца
            SHORT = "%b",   -- Сокращенное название
            NUMBER = "%m",  -- Номер месяца
            DAYS = "%d"     -- Количество дней
        },
        YEAR = {
            FULL = "%Y",    -- Полный год
            SHORT = "%y"    -- Короткий год
        },
        TIME = {
            HOURS_24 = "%H",  -- 24-часовой формат
            HOURS_12 = "%I",  -- 12-часовой формат
            MINUTES = "%M",   -- Минуты
            SECONDS = "%S",   -- Секунды
            AMPM = "%p",      -- AM/PM
            FULL = "%X",      -- Полное время
            ZONE = "%Z",      -- Временная зона
            UTC = "%z"        -- Смещение UTC
        },
        WEEK = {
            SUNDAY_FIRST = "%U",  -- Неделя года (воскресенье)
            MONDAY_FIRST = "%W",  -- Неделя года (понедельник)
            DAY = "%w"            -- День недели
        }
    }
}

-- Утилиты для валидации
local Validation = {
    assertType = function(value, expectedType, paramName)
        if typeof(value) ~= expectedType then
            error(string.format("Expected %s for parameter '%s', got %s", expectedType, paramName, typeof(value)), 2)
        end
    end,
    
    assertRange = function(value, min, max, paramName)
        if value < min or value > max then
            error(string.format("Value for '%s' must be between %d and %d", paramName, min, max), 2)
        end
    end,
    
    assertNotNil = function(value, paramName)
        if value == nil then
            error(string.format("Required parameter '%s' is nil", paramName), 2)
        end
    end
}

local CloneRef = cloneref or function(instance) 
    Validation.assertNotNil(instance, "instance")
    return instance 
end

--// Service Management
local Services = setmetatable({}, {
	__index = function(self, serviceName)
		local service = game:GetService(serviceName)
		return CloneRef(service)
	end,
})

-- Core services and references
local Player = Services.Players.LocalPlayer
local Mouse = CloneRef(Player:GetMouse())

-- Essential services
local UserInputService = Services.UserInputService
local TextService = Services.TextService
local TweenService = Services.TweenService
local RunService = Services.RunService
local CoreGui = RunService:IsStudio() and CloneRef(Player:WaitForChild("PlayerGui")) or Services.CoreGui
local TeleportService = Services.TeleportService
local Workspace = Services.Workspace
local CurrentCam = Workspace.CurrentCamera

-- Get hidden UI function based on environment
local hiddenUI = get_hidden_gui or gethui or function() return CoreGui end

-- Library configuration
local library = {
	title = "Bozo depso",
	company = "Company",
	
	RainbowEnabled = true,
	BlurEffect = true,
	BlurSize = CONSTANTS.MAX_BLUR_SIZE,
	FieldOfView = CurrentCam.FieldOfView,

	-- Default keybind (touch-aware)
	Key = UserInputService.TouchEnabled and Enum.KeyCode.P or Enum.KeyCode.RightShift,
	fps = 0,
	Debug = true,

	-- Theme colors
	transparency = 0,
	backgroundColor = Color3.fromRGB(31, 31, 31),
	headerColor = Color3.fromRGB(255, 255, 255),
	companyColor = Color3.fromRGB(163, 151, 255),
	acientColor = Color3.fromRGB(167, 154, 121),
	darkGray = Color3.fromRGB(27, 27, 27),
	lightGray = Color3.fromRGB(48, 48, 48),

	Font = Enum.Font.Code,

	-- State management
	_state = {
		isInitialized = false,
		activeInstances = {},
		currentPage = nil
	},

	rainbowColors = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(241, 137, 53)), 
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(241, 53, 106)), 
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(133, 53, 241)), 
			ColorSequenceKeypoint.new(1, Color3.fromRGB(53, 186, 241))
	}
}

-- Менеджер даты и времени
local DateTimeManager = {
    _cache = {},
    
    -- Получить отформатированную дату/время с кэшированием
    getFormatted = function(self, format, useCache)
        if useCache and self._cache[format] then
            if os.time() - self._cache[format].timestamp < 1 then
                return self._cache[format].value
            end
        end
        
        local result = os.date(format)
        
        if useCache then
            self._cache[format] = {
                value = result,
                timestamp = os.time()
            }
        end
        
        return result
    end,
    
    -- Получить текущее время в заданном формате
    getTime = function(self, format)
        local timeFormat = CONSTANTS.DATE_FORMATS.TIME[format:upper()] or CONSTANTS.DATE_FORMATS.TIME.HOURS_24
        return self:getFormatted(timeFormat, true)
    end,
    
    -- Получить текущую дату в заданном формате
    getDate = function(self, format, type)
        local dateFormat
        if format == "day" then
            dateFormat = CONSTANTS.DATE_FORMATS.DAY[type:upper()] or CONSTANTS.DATE_FORMATS.DAY.FULL
        elseif format == "month" then
            dateFormat = CONSTANTS.DATE_FORMATS.MONTH[type:upper()] or CONSTANTS.DATE_FORMATS.MONTH.FULL
        elseif format == "year" then
            dateFormat = CONSTANTS.DATE_FORMATS.YEAR[type:upper()] or CONSTANTS.DATE_FORMATS.YEAR.FULL
        elseif format == "week" then
            dateFormat = CONSTANTS.DATE_FORMATS.WEEK[type:upper()] or CONSTANTS.DATE_FORMATS.WEEK.MONDAY_FIRST
        end
        return self:getFormatted(dateFormat, true)
    end,
    
    -- Получить полную временную метку
    getTimestamp = function(self)
        local date = self:getDate("day", "MONTH")
        local month = self:getDate("month", "NUMBER")
        local year = self:getDate("year", "FULL")
        local time = self:getTime("FULL")
        return string.format("%s.%s.%s %s", date, month, year, time)
    end,
    
    -- Очистить кэш
    clearCache = function(self)
        table.clear(self._cache)
    end
}

-- Улучшенная функция предупреждений с временной меткой
local function Warn(message, level)
    if not library.Debug then return end
    level = level or "WARNING"
    
    local timestamp = DateTimeManager:getTimestamp()
    warn(string.format("[%s][%s] Depso: %s", timestamp, level, message))
end

-- Tween styles management
local TweenWrapper = {}

function TweenWrapper:Init()
	self.RealStyles = {
		Default = TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	}
	
	self.Styles = setmetatable({}, {
		__index = function(_, styleName)
			local style = self.RealStyles[styleName]
			if not style then
				Warn(string.format("No Tween style for %s, returning default", styleName))
				return self.RealStyles.Default
			end
			return style
		end,
	})
end

function TweenWrapper:CreateStyle(styleName, duration, ...)
	if not styleName then 
		return TweenInfo.new(0) 
	end

	local tweenInfo = TweenInfo.new(
		duration or 0.17, 
		...
	)

	self.RealStyles[styleName] = tweenInfo
	return tweenInfo
end

TweenWrapper:Init()

-- Оптимизированный менеджер твинов
local TweenManager = {
    _cache = {},
    _activeTransitions = {},
    
    createTween = function(self, instance, info, props)
        Validation.assertNotNil(instance, "instance")
        Validation.assertNotNil(info, "info")
        Validation.assertNotNil(props, "props")
        
        local cacheKey = instance:GetFullName() .. tostring(info) .. tostring(props)
        
        -- Используем кэшированный твин если возможно
        if self._cache[cacheKey] then
            return self._cache[cacheKey]
        end
        
        local tween = TweenService:Create(instance, info, props)
        self._cache[cacheKey] = tween
        
        return tween
    end,
    
    cleanup = function(self)
        for _, tween in pairs(self._cache) do
            tween:Cancel()
        end
        table.clear(self._cache)
        table.clear(self._activeTransitions)
    end,
    
    transition = function(self, instance, props, duration, style, direction)
        Validation.assertNotNil(instance, "instance")
        Validation.assertNotNil(props, "props")
        
        duration = duration or CONSTANTS.DEFAULT_TWEEN_DURATION
        style = style or Enum.EasingStyle.Sine
        direction = direction or Enum.EasingDirection.InOut
        
        -- Отменяем предыдущий твин для этого инстанса если он есть
        if self._activeTransitions[instance] then
            self._activeTransitions[instance]:Cancel()
        end
        
        local info = TweenInfo.new(duration, style, direction)
        local tween = self:createTween(instance, info, props)
        
        self._activeTransitions[instance] = tween
        tween:Play()
        
        return tween
    end
}

-- Разделяем функционал драга на подфункции
local DragHandler = {
    new = function(frame, options)
        Validation.assertNotNil(frame, "frame")
        
        local self = {
            frame = frame,
            dragLatency = (options and options.latency) or 0.06,
            isDragging = false,
            dragInput = nil,
            dragStart = nil,
            startPosition = nil
        }
        
        self.handleDragStart = function(input)
            if not self:isValidInput(input) then return end
            
            self.isDragging = true
            self.dragStart = input.Position
            self.startPosition = self.frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.isDragging = false
                end
            end)
        end
        
        self.handleDragChange = function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement 
                or self:isValidInput(input) then
                self.dragInput = input
            end
        end
        
        self.updateDragPosition = function(input)
            if input ~= self.dragInput or not self.isDragging then return end
            
            local delta = input.Position - self.dragStart
            local newPosition = UDim2.new(
                self.startPosition.X.Scale,
                self.startPosition.X.Offset + delta.X,
                self.startPosition.Y.Scale,
                self.startPosition.Y.Offset + delta.Y
            )
            
            TweenManager:transition(
                self.frame,
                {Position = newPosition},
                self.dragLatency
            )
        end
        
        self.isValidInput = function(self, input)
            return input.UserInputType == Enum.UserInputType.Touch 
                or input.UserInputType == Enum.UserInputType.MouseButton1
        end
        
        -- Подключаем обработчики
        frame.InputBegan:Connect(self.handleDragStart)
        frame.InputChanged:Connect(self.handleDragChange)
        UserInputService.InputChanged:Connect(self.updateDragPosition)
        
        return self
    end
}

-- Обновляем функцию EnableDrag
local function EnableDrag(frame, dragLatency)
    if not frame then return end
    return DragHandler.new(frame, {latency = dragLatency})
end

-- Track FPS
RunService.RenderStepped:Connect(function(deltaTime)
	library.fps = math.round(1/deltaTime)
end)

-- Utility functions
function library:RoundNumber(decimals, number)
	return tonumber(string.format("%." .. (decimals or 0) .. "f", number))
end

function library:GetUsername()
	return Player.Name
end

function library:GetUserId()
	return Player.UserId
end

function library:GetPlaceId()
	return game.PlaceId
end

function library:GetJobId()
	return game.JobId
end

function library:Rejoin()
	TeleportService:TeleportToPlaceInstance(
		self:GetPlaceId(), 
		self:GetJobId(), 
		self:GetUserId()
	)
end

function library:Copy(content) 
	local clipboardFunction = setclipboard 
		or toclipboard 
		or set_clipboard 
		or (Clipboard and Clipboard.set)
	
	if clipboardFunction then
		clipboardFunction(content)
	end
end

-- Обновляем методы библиотеки для работы с датой/временем
function library:GetTime(format)
    return DateTimeManager:getTime(format)
end

function library:GetDay(format)
    return DateTimeManager:getDate("day", format)
end

function library:GetMonth(format)
    return DateTimeManager:getDate("month", format)
end

function library:GetWeek(format)
    return DateTimeManager:getDate("week", format)
end

function library:GetYear(format)
    return DateTimeManager:getDate("year", format)
end

function library:UnlockFps(new) 
	if setfpscap then
		setfpscap(new)
	end
end

TweenWrapper:CreateStyle("Rainbow", 5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
function library:ApplyRainbow(instance, useWaveEffect)
    Validation.assertNotNil(instance, "instance")
    
    if not self.RainbowEnabled then return end
    
    if not useWaveEffect then
        local startColor = self.rainbowColors.Keypoints[1].Value
        local endColor = self.rainbowColors.Keypoints[#self.rainbowColors.Keypoints].Value
        
        instance.BackgroundColor3 = startColor
        TweenManager:transition(
            instance,
            {BackgroundColor3 = endColor},
            5,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
        return
    end
    
    local gradient = Instance.new("UIGradient")
    gradient.Parent = instance
    gradient.Offset = Vector2.new(-0.8, 0)
    gradient.Color = self.rainbowColors
    
    TweenManager:transition(
        gradient,
        {Offset = Vector2.new(0.8, 0)},
        5,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
end

--/ Watermark library
TweenWrapper:CreateStyle("wm", 0.24)
TweenWrapper:CreateStyle("wm_2", 0.04)

-- Менеджер состояния приложения
local StateManager = {
    _instances = {},
    _activeInstance = nil,
    
    -- Создать новый экземпляр
    create = function(self, config)
        local instance = setmetatable({
            id = tostring(os.time()) .. "_" .. tostring(#self._instances + 1),
            created = os.time(),
            config = config or {},
            state = {
                isInitialized = false,
                activeInstances = {},
                currentPage = nil,
                lastUpdate = os.time()
            }
        }, {
            __index = library
        })
        
        self._instances[instance.id] = instance
        return instance
    end,
    
    -- Получить активный экземпляр
    getActive = function(self)
        return self._activeInstance
    end,
    
    -- Установить активный экземпляр
    setActive = function(self, instance)
        if self._instances[instance.id] then
            self._activeInstance = instance
            return true
        end
        return false
    end,
    
    -- Удалить экземпляр
    remove = function(self, instance)
        if self._instances[instance.id] then
            if instance.Remove then
                instance:Remove()
            end
            self._instances[instance.id] = nil
            if self._activeInstance == instance then
                self._activeInstance = nil
            end
            return true
        end
        return false
    end,
    
    -- Очистить все экземпляры
    cleanup = function(self)
        for _, instance in pairs(self._instances) do
            if instance.Remove then
                instance:Remove()
            end
        end
        table.clear(self._instances)
        self._activeInstance = nil
    end
}

-- Обновляем функцию инициализации
function library:Init(Config)
    -- Проверка на повторную инициализацию
    if self.state.isInitialized then
        Warn("Library instance already initialized", "WARNING")
        return self
    end
    
    -- Применяем новую конфигурацию
    for Key, Value in next, Config do
        if self[Key] ~= nil then
            self[Key] = Value
        end
    end
    
    -- Создаем основной UI
    local watermark = Instance.new("ScreenGui", CoreGui)
    watermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Добавляем в активные инстансы
    self.state.activeInstances["watermark"] = watermark
    
    local watermarkPadding = Instance.new("UIPadding")
    watermarkPadding.Parent = watermark
    watermarkPadding.PaddingBottom = UDim.new(0, 6)
    watermarkPadding.PaddingLeft = UDim.new(0, 6)
    
    -- Отмечаем что библиотека инициализирована
    self.state.isInitialized = true
    self.state.lastUpdate = os.time()
    
    return self
end

-- Обновляем функцию удаления
function library:Remove()
    -- Очистка всех твинов перед удалением
    TweenManager:cleanup()
    
    -- Очистка кэша даты/времени
    DateTimeManager:clearCache()
    
    -- Удаление UI элементов
    for _, instance in pairs(self.state.activeInstances) do
        if typeof(instance) == "Instance" then
            instance:Destroy()
        end
    end
    
    -- Сброс состояния
    self.state.isInitialized = false
    table.clear(self.state.activeInstances)
    
    return self
end

-- Создаем новый экземпляр вместо использования глобальной переменной
local function createUI(config)
    -- Удаляем предыдущий активный экземпляр если есть
    local active = StateManager:getActive()
    if active then
        StateManager:remove(active)
    end
    
    -- Создаем новый экземпляр
    local instance = StateManager:create(config)
    StateManager:setActive(instance)
    
    -- Инициализируем UI
    instance:Init(config)
    
    return instance
end

-- Создаем начальный эффект размытия
local Blur = Instance.new("BlurEffect", CurrentCam)
Blur.Enabled = true
Blur.Size = 0

return createUI
