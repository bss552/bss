-- [[ ОБЪЕДИНЕННЫЙ СКРИПТ: Bss Edition (PRIORITY FIX) ]]

local CHANNEL_ID = "" -- Ростки
local DISCORD_TOKEN = "ODc1NzY2NDg2MjYwNjcwNDc0.GXVCL4.v1qPNYJ0fkbYIOp_OhyFaBSSQFYJn9fe1pYoPk"
local TARGET_CHANNEL = "" -- Вициусы
local STICK_CHANNEL = "1408759427619618850" -- СТИК БАГ

local PLACE_ID = 1537690962
local jumpFileName = "bss_fast_v81.json"
local statsFileName = "bss_sprout_final_v4.json"

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer
local request = (syn and syn.request) or http_request or request

local blacklist = {}
local canJump = true
local stats = {Common=0, Rare=0, Epic=0, Leg=0, Supr=0, Gummy=0, Festive=0, Moon=0, Stick=0, Vicious=0}
local history = {}
local trackedSprouts = {}
local isLooting = false

-- [[ ЗАГРУЗКА ]]
if isfile(jumpFileName) then
    pcall(function() blacklist = HttpService:JSONDecode(readfile(jumpFileName)).b or {} end)
end

local function saveStats() writefile(statsFileName, HttpService:JSONEncode({s=stats, h=history})) end
local function loadStats()
    if isfile(statsFileName) then
        local success, d = pcall(function() return HttpService:JSONDecode(readfile(statsFileName)) end)
        if success and d then
            stats = d.s or stats
            history = d.h or history
        end
    end
end
loadStats()

-- [[ GUI ]]
local sg = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0.5, -140, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
frame.BorderSizePixel = 2
frame.Active = true 
frame.Draggable = true

local titleAlways = Instance.new("TextLabel", frame)
titleAlways.Size = UDim2.new(1, -40, 0, 35)
titleAlways.Position = UDim2.new(0, 10, 0, 0)
titleAlways.BackgroundTransparency = 1
titleAlways.TextColor3 = Color3.new(1, 1, 1)
titleAlways.Font = Enum.Font.SourceSansBold
titleAlways.TextSize = 22
titleAlways.Text = "by Bss"

local contentHolder = Instance.new("Frame", frame)
contentHolder.Size = UDim2.new(1, 0, 1, -35)
contentHolder.Position = UDim2.new(0, 0, 0, 35)
contentHolder.BackgroundTransparency = 1

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.ZIndex = 5

minBtn.MouseButton1Click:Connect(function()
    contentHolder.Visible = not contentHolder.Visible
    frame:TweenSize(contentHolder.Visible and UDim2.new(0, 280, 0, 320) or UDim2.new(0, 280, 0, 35), "Out", "Quad", 0.2, true)
    minBtn.Text = contentHolder.Visible and "−" or "+"
end)

local function lbl(pos, txt, clr, sz)
    local l = Instance.new("TextLabel", contentHolder)
    l.Size = UDim2.new(1, -20, 0, 20); l.Position = pos
    l.BackgroundTransparency = 1; l.TextColor3 = clr or Color3.new(1,1,1)
    l.Font = Enum.Font.SourceSansBold; l.TextSize = sz or 14
    l.Text = txt; l.TextXAlignment = Enum.TextXAlignment.Center
    return l
end

local jumpStatus = lbl(UDim2.new(0, 10, 0, 5), "WAITING FOR POST", Color3.new(0, 0.8, 1), 18)

local function statLbl(pos, txt, clr)
    local l = lbl(pos, txt, clr, 14)
    l.Size = UDim2.new(0.5, -15, 0, 20)
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local c_txt = statLbl(UDim2.new(0, 15, 0, 40), "Common: "..stats.Common, Color3.fromRGB(180, 190, 186))
local r_txt = statLbl(UDim2.new(0.5, 5, 0, 40), "Rare: "..stats.Rare, Color3.fromRGB(168, 167, 169))
local e_txt = statLbl(UDim2.new(0, 15, 0, 60), "Epic: "..stats.Epic, Color3.fromRGB(169, 157, 5))
local l_txt = statLbl(UDim2.new(0.5, 5, 0, 60), "Leg: "..stats.Leg, Color3.fromRGB(20, 165, 199))
local g_txt = statLbl(UDim2.new(0, 15, 0, 80), "Gummy: "..stats.Gummy, Color3.fromRGB(242, 129, 255))
local f_txt = statLbl(UDim2.new(0.5, 5, 0, 80), "Festive: "..stats.Festive, Color3.fromRGB(255, 50, 50))
local s_txt = statLbl(UDim2.new(0, 15, 0, 100), "Supreme: "..stats.Supr, Color3.fromRGB(71, 255, 88))
local m_txt = statLbl(UDim2.new(0.5, 5, 0, 100), "Moon: "..stats.Moon, Color3.fromRGB(103, 162, 201))
local stick_txt = statLbl(UDim2.new(0, 15, 0, 120), "Stick Bug: "..(stats.Stick or 0), Color3.fromRGB(255, 165, 0))
local vic_txt = statLbl(UDim2.new(0.5, 5, 0, 120), "Vicious: "..(stats.Vicious or 0), Color3.fromRGB(255, 50, 50))

local h1 = lbl(UDim2.new(0, 20, 0, 185), history[1] or "-", Color3.new(0.8, 0.8, 0.8), 13)
h1.TextXAlignment = Enum.TextXAlignment.Left
local h2 = lbl(UDim2.new(0, 20, 0, 205), history[2] or "-", Color3.new(0.8, 0.8, 0.8), 13)
h2.TextXAlignment = Enum.TextXAlignment.Left
local h3 = lbl(UDim2.new(0, 20, 0, 225), history[3] or "-", Color3.new(0.8, 0.8, 0.8), 13)
h3.TextXAlignment = Enum.TextXAlignment.Left

local function updateGui()
    c_txt.Text = "Common: "..stats.Common; r_txt.Text = "Rare: "..stats.Rare
    e_txt.Text = "Epic: "..stats.Epic; l_txt.Text = "Leg: "..stats.Leg
    g_txt.Text = "Gummy: "..stats.Gummy; f_txt.Text = "Festive: "..stats.Festive
    s_txt.Text = "Supreme: "..stats.Supr; m_txt.Text = "Moon: "..stats.Moon
    stick_txt.Text = "Stick Bug: "..(stats.Stick or 0)
    vic_txt.Text = "Vicious: "..(stats.Vicious or 0)
    h1.Text = history[1] or "-"; h2.Text = history[2] or "-"; h3.Text = history[3] or "-"
end

-- [[ ДЕТЕКТ ]]
local function findMonster(name)
    local monsters = workspace:FindFirstChild("Monsters")
    if monsters then
        for _, m in pairs(monsters:GetChildren()) do
            if m.Name:find(name) then return m end
        end
    end
    return nil
end

-- [[ ПРЫЖКИ С ФИКСИРОВАННЫМ ПРИОРИТЕТОМ ]]
local function extractJobId(text)
    if not text then return nil end
    return text:match("gameInstanceId=([%w%-]+)") or text:match("%w+-%w+-%w+-%w+-%w+")
end

-- Стабільна функція перевірки каналу з обробкою помилок
local function checkChannel(channel, auth)
    local success, res = pcall(function()
        return request({
            Url = "https://discord.com/api/v9/channels/"..channel.."/messages?limit=1",
            Method = "GET",
            Headers = { ["Authorization"] = auth }
        })
    end)
    
    if success and res and res.StatusCode == 200 then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)
        if decodeSuccess and data and data[1] then
            local msg = data[1]
            local content = (msg.content or "") .. (msg.embeds and msg.embeds[1] and (msg.embeds[1].description or msg.embeds[1].url) or "")
            local jobId = extractJobId(content)
            return jobId, msg.id
        end
    end
    return nil, nil
end

-- Допоміжна функція для перевірки чи ID в блеклісті (замість table.find)
local function isBlacklisted(jobId)
    if not jobId then return true end
    for _, blId in ipairs(blacklist) do
        if blId == jobId then return true end
    end
    return false
end

-- Стабільна функція телепорту з retry логікою
local function performTeleport(jobId, targetType)
    if not jobId or jobId == game.JobId or isBlacklisted(jobId) then
        return false
    end
    
    jumpStatus.Text = "JUMPING ("..targetType..")..."
    table.insert(blacklist, jobId)
    writefile(jumpFileName, HttpService:JSONEncode({b=blacklist}))
    
    local teleportSuccess, errorMsg = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
    end)
    
    if not teleportSuccess then
        warn("[HOP ERROR] Teleport failed:", errorMsg)
        -- Видаляємо з блеклісту для можливості повторної спроби
        for i = #blacklist, 1, -1 do
            if blacklist[i] == jobId then
                table.remove(blacklist, i)
                break
            end
        end
        writefile(jumpFileName, HttpService:JSONEncode({b=blacklist}))
        return false
    end
    
    return true
end

task.spawn(function()
    while true do
        if canJump and not isLooting and not findMonster("Vicious Bee") and not findMonster("Stick Bug") then
            local targetId = nil
            local targetType = ""
            local targetMsgId = nil

            -- 1. Самый высокий приоритет: Stick Bug
            local stid, stmid = checkChannel(STICK_CHANNEL, DISCORD_TOKEN)
            local lastST = isfile("last_st_msg.txt") and readfile("last_st_msg.txt") or ""
            if stid and stmid ~= lastST and stid ~= game.JobId and not isBlacklisted(stid) then
                targetId = stid
                targetType = "STICK"
                targetMsgId = stmid
            end

            -- 2. Средний приоритет: Ростки (только если не найден Стик)
            if not targetId then
                local sid, smid = checkChannel(CHANNEL_ID, DISCORD_TOKEN)
                if sid and sid ~= game.JobId and not isBlacklisted(sid) then
                    targetId = sid
                    targetType = "SPROUT"
                    targetMsgId = smid
                end
            end

            -- 3. Низкий приоритет: Вициус (только если нет Стика и Ростка)
            if not targetId then
                local bid, bmid = checkChannel(TARGET_CHANNEL, DISCORD_TOKEN)
                local lastV = isfile("last_v_msg.txt") and readfile("last_v_msg.txt") or ""
                if bid and bmid ~= lastV and bid ~= game.JobId and not isBlacklisted(bid) then
                    targetId = bid
                    targetType = "BEE"
                    targetMsgId = bmid
                end
            end
            
            -- 4. Додаткові канали для стабільного хопу (тільки якщо немає інших цілей)
            if not targetId then
                local additionalChannels = {"1407344364736479384", "1405656120051237039"}
                for _, channelId in ipairs(additionalChannels) do
                    local aid, amid = checkChannel(channelId, DISCORD_TOKEN)
                    if aid and aid ~= game.JobId and not isBlacklisted(aid) then
                        targetId = aid
                        targetType = "EXTRA"
                        targetMsgId = amid
                        break
                    end
                end
            end

            -- ФИНАЛЬНЫЙ ПРЫЖОК (Выполняется только для одной цели)
            if targetId then
                local teleported = performTeleport(targetId, targetType)
                if teleported then
                    -- Зберігаємо ID повідомлення для Stick та Vicious
                    if targetType == "STICK" and targetMsgId then
                        writefile("last_st_msg.txt", targetMsgId)
                    elseif targetType == "BEE" and targetMsgId then
                        writefile("last_v_msg.txt", targetMsgId)
                    end
                    -- Ждем телепортации, чтобы цикл не сработал еще раз
                    task.wait(10)
                else
                    -- Якщо телепорт не вдався, чекаємо менше перед повторною спробою
                    task.wait(2)
                end
            end
        end
        task.wait(3) 
    end
end)

-- [[ ЛОГИКА ФЕРМЫ ]]
local function getSproutType(obj)
    local c = obj.Color
    local function isC(r,g,b) return math.abs(c.R*255-r)<5 and math.abs(c.G*255-g)<5 and math.abs(c.B*255-b)<5 end
    if isC(242,129,255) then return "Gummy"
    elseif isC(71,255,88) then return "Supr"
    elseif isC(103,162,201) then return "Moon"
    elseif isC(20,165,199) then return "Leg"
    elseif isC(169,157,5) then return "Epic"
    elseif isC(168,167,169) then return "Rare"
    elseif c.R > 0.8 and c.G < 0.4 then return "Festive" end
    return "Common"
end

task.spawn(function()
    local lastStickState = false
    local lastVicState = false
    while true do
        if not isLooting then
            local spr = nil
            local vic = findMonster("Vicious Bee")
            local stick = findMonster("Stick Bug")
            
            if lastStickState and not stick then
                stats.Stick = (stats.Stick or 0) + 1
                table.insert(history, 1, os.date("%H:%M").." Stick Bug")
                if #history > 3 then table.remove(history, 4) end
                saveStats(); updateGui()
            end
            lastStickState = (stick ~= nil)

            if lastVicState and not vic then
                stats.Vicious = (stats.Vicious or 0) + 1
                table.insert(history, 1, os.date("%H:%M").." Vicious Bee")
                if #history > 3 then table.remove(history, 4) end
                saveStats(); updateGui()
            end
            lastVicState = (vic ~= nil)

            local folder = workspace:FindFirstChild("Sprouts")
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
                        spr = obj
                        if not trackedSprouts[obj] then trackedSprouts[obj] = getSproutType(obj) end
                    end
                end
            end

            if spr then
                canJump = false; jumpStatus.Text = "FARMING..."
                jumpStatus.TextColor3 = Color3.new(0, 1, 0.5)
                repeat task.wait(0.5) until not spr.Parent
                isLooting = true
                local sType = trackedSprouts[spr] or "Common"
                stats[sType] = (stats[sType] or 0) + 1
                table.insert(history, 1, os.date("%H:%M").." "..sType)
                if #history > 3 then table.remove(history, 4) end
                saveStats(); updateGui()
                trackedSprouts[spr] = nil
                for i = 15, 1, -1 do
                    jumpStatus.Text = "LOOTING: "..i.."s"
                    jumpStatus.TextColor3 = Color3.new(1, 0.6, 0)
                    task.wait(1)
                end
                isLooting = false; canJump = true
            elseif stick then
                canJump = false; jumpStatus.Text = "KILLING STICK"
                jumpStatus.TextColor3 = Color3.new(1, 0.6, 0)
            elseif vic then
                canJump = false; jumpStatus.Text = "KILLING VIC"
                jumpStatus.TextColor3 = Color3.new(1, 0.2, 0.2)
            else
                canJump = true; jumpStatus.Text = "WAITING FOR POST"
                jumpStatus.TextColor3 = Color3.new(0, 0.7, 1)
            end
        end
        task.wait(0.5)
    end
end)

-- [[ LOAD ATLAS ]]
task.spawn(function()
    repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
    task.wait(2)
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Chris12089/atlasbss/main/script.lua"))() end)
end)

-- Anti-AFK
player.Idled:Connect(function() 
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
    task.wait(1) 
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
end)
