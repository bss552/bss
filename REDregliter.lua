local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Конфигурация
local Config = {
    GlitterArgs = { { Name = "Glitter" } },
    Fields = {
        ["2908769124"] = { -- 🍄 Mushroom Field
            name = "Mushroom",
            position = Vector3.new(-96, 4, 110),
            flightTime = 3.5
        }
    },
    Settings = {
        WaitTime = 14 * 60, -- 14 минут ожидания
        ScanDelay = 5,      -- Проверка каждые 5 сек
        FreezeAfter = 1     -- Стоять 1 сек после Glitter
    }
}

-- Система
local ActiveBoosts = {}
local GlitterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")
local isFlying = false

-- Логирование
local function Log(message)
    print("[FLIGHT SYSTEM]: " .. os.date("%H:%M:%S") .. " | " .. message)
end

-- Плавный полет с защитой
local function SmoothFlight(targetPosition, duration)
    if isFlying then return false end
    isFlying = true
    
    local startPos = rootPart.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local progress = math.min(1, (currentTime - startTime) / duration)
        
        if progress >= 1 then
            connection:Disconnect()
            isFlying = false
            rootPart.CFrame = CFrame.new(targetPosition)
        else
            rootPart.CFrame = CFrame.new(startPos:Lerp(targetPosition, progress))
        end
    end)
    
    task.wait(duration)
    if connection then
        connection:Disconnect()
    end
    isFlying = false
    return true
end

-- Основная функция буста
local function UseBoost(boostData)
    Log("Начинаю полет на " .. boostData.name)
    
    -- Плавный полет
    local success = SmoothFlight(boostData.position, boostData.flightTime)
    
    if success then
        -- Фиксация после прилета
        rootPart.Anchored = true
        Log("Прибыл на поле, фиксирую позицию")
        
        -- Использование Glitter
        local glitterSuccess = pcall(function()
            GlitterEvent:FireServer(unpack(Config.GlitterArgs))
        end)
        
        if glitterSuccess then
            Log("Glitter успешно использован")
        else
            Log("Ошибка при использовании Glitter")
        end
        
        -- Ожидание перед разблокировкой
        task.wait(Config.Settings.FreezeAfter)
        rootPart.Anchored = false
        Log("Завершено")
    else
        Log("Ошибка полета")
    end
end

-- Сканер бустов
local function ScanBoosts()
    local success, gui = pcall(function()
        return player:WaitForChild("PlayerGui")
    end)
    
    if not success then
        return
    end
    
    for _, element in ipairs(gui:GetDescendants()) do
        if element:IsA("ImageButton") and not element:FindFirstChild("Processed") then
            local image = tostring(element.Image)
            local id = image:match("rbxassetid://(%d+)")
            
            if id and Config.Fields[id] and not ActiveBoosts[id] then
                local marker = Instance.new("BoolValue")
                marker.Name = "Processed"
                marker.Parent = element
                
                ActiveBoosts[id] = true
                Log("Обнаружен буст: " .. Config.Fields[id].name)
                
                task.delay(Config.Settings.WaitTime, function()
                    UseBoost(Config.Fields[id])
                    ActiveBoosts[id] = nil
                end)
            end
        end
    end
end

-- Обработчик респавна
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Главный цикл
while true do
    local success, error = pcall(ScanBoosts)
    if not success then
        warn("Ошибка в ScanBoosts: " .. tostring(error))
    end
    task.wait(Config.Settings.ScanDelay)
end
