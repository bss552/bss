-- Script for Bee Swarm Simulator - Auto Use Micro Converter after 30 seconds of 100% full backpack
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Функция проверки что игрок находится на поле (в зоне сбора)
function isPlayerInField()
    local character = Player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Проверяем позицию игрока - на полях позиция обычно выше 0
    local position = humanoidRootPart.Position
    if position.Y < 10 then -- Если игрок под землей или в базе
        return false
    end
    
    return true
end

-- Функция для правильного парсинга чисел с запятыми
function parseNumberWithCommas(str)
    if not str then return nil end
    -- Убираем все запятые и пробелы
    local cleanStr = string.gsub(str, "[,%s]", "")
    -- Преобразуем в число
    return tonumber(cleanStr)
end

-- Функция проверки pollen capacity
function isBackpack100PercentFull()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then 
        return false 
    end
    
    -- Проверяем что игрок находится на поле
    if not isPlayerInField() then
        return false
    end
    
    -- Ищем индикатор пыльцы в MeterHUD
    local pollenMeter = playerGui:FindFirstChild("ScreenGui")
    if pollenMeter then
        pollenMeter = pollenMeter:FindFirstChild("MeterHUD")
        if pollenMeter then
            pollenMeter = pollenMeter:FindFirstChild("PollenMeter")
            if pollenMeter then
                local bar = pollenMeter:FindFirstChild("Bar")
                if bar then
                    local textLabel = bar:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        local text = tostring(textLabel.Text)
                        if text then
                            -- Обрабатываем формат с запятыми: "120,200/120,200"
                            -- Ищем два числа разделенные слэшем
                            local slashPos = string.find(text, "/")
                            if slashPos then
                                local currentStr = string.sub(text, 1, slashPos - 1) -- "120,200"
                                local maxStr = string.sub(text, slashPos + 1)        -- "120,200"
                                
                                -- Парсим числа убирая запятые
                                local current = parseNumberWithCommas(currentStr)
                                local max = parseNumberWithCommas(maxStr)
                                
                                if current and max and max > 0 then
                                    -- Проверяем 100% заполнение (current должен быть > 0 и = max)
                                    if current > 0 and current >= max then
                                        return true
                                    else
                                        return false
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return false
end

-- Функция для использования микро-конвеера через правильный RemoteEvent
function useMicroConverter()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if not events then
        return false
    end
    
    local playerActivesCommand = events:FindFirstChild("PlayerActivesCommand")
    if not playerActivesCommand then
        return false
    end
    
    -- Используем правильный RemoteEvent с правильными аргументами
    local success, errorMsg = pcall(function()
        playerActivesCommand:FireServer({Name = "Micro-Converter"})
    end)
    
    return success
end

-- Основной цикл
local backpackFullTime = 0
local lastCheckTime = tick()
local cooldown = 30 -- 30 секунд ожидания
local hasPressed = false

while true do
    local currentTime = tick()
    local deltaTime = currentTime - lastCheckTime
    lastCheckTime = currentTime
    
    local isInField = isPlayerInField()
    local is100Percent = isBackpack100PercentFull()
    
    if isInField and is100Percent then
        backpackFullTime = backpackFullTime + deltaTime
        
        -- Активируем конвеер только если прошло 30 секунд и еще не активировали в этот цикл
        if backpackFullTime >= cooldown and not hasPressed then
            local success = useMicroConverter()
            if success then
                hasPressed = true
                -- Сбрасываем таймер после успешной активации
                backpackFullTime = 0
                hasPressed = false
                wait(5) -- Ждем после успешной активации
            else
                hasPressed = false
                wait(10)
            end
        end
    else
        -- Если игрок не на поле ИЛИ pollen не 100%, сбрасываем таймер
        if backpackFullTime > 0 then
            backpackFullTime = 0
            hasPressed = false
        end
    end
    
    wait(1) -- Проверяем каждую секунду
end
