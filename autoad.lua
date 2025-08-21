script_name("AutoAdvert")
script_author("AloxinBay")
script_version(1.0)

require 'moonloader'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
-- кфг
local config = {
    ads = {
        vr = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        },
        fam = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        },
        al = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        },
        rb = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        },
        s = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        },
        b = {
            enabled = false,
            message = "",
            interval = 20,
            last_time = 0
        }
    }
}

local window = imgui.ImBool(false)
local current_tab = 1

local vr_message = imgui.ImBuffer(256)
local vr_interval = imgui.ImInt(20)
local vr_enabled = imgui.ImBool(false)

local fam_message = imgui.ImBuffer(256)
local fam_interval = imgui.ImInt(20)
local fam_enabled = imgui.ImBool(false)

local al_message = imgui.ImBuffer(256)
local al_interval = imgui.ImInt(20)
local al_enabled = imgui.ImBool(false)

local rb_message = imgui.ImBuffer(256)
local rb_interval = imgui.ImInt(20)
local rb_enabled = imgui.ImBool(false)

local s_message = imgui.ImBuffer(256)
local s_interval = imgui.ImInt(20)
local s_enabled = imgui.ImBool(false)

local b_message = imgui.ImBuffer(256)
local b_interval = imgui.ImInt(20)
local b_enabled = imgui.ImBool(false)

function validateInterval(interval)
    if interval < 20 then
        return 20
    elseif interval > 2000000 then
        return 2000000
    end
    return interval
end

function saveConfig()
    config.ads.vr.message = u8:decode(vr_message.v)
    config.ads.vr.interval = validateInterval(vr_interval.v)
    config.ads.vr.enabled = vr_enabled.v
    
    config.ads.fam.message = u8:decode(fam_message.v)
    config.ads.fam.interval = validateInterval(fam_interval.v)
    config.ads.fam.enabled = fam_enabled.v
    
    config.ads.al.message = u8:decode(al_message.v)
    config.ads.al.interval = validateInterval(al_interval.v)
    config.ads.al.enabled = al_enabled.v
    
    config.ads.rb.message = u8:decode(rb_message.v)
    config.ads.rb.interval = validateInterval(rb_interval.v)
    config.ads.rb.enabled = rb_enabled.v

    config.ads.s.message = u8:decode(s_message.v)
    config.ads.s.interval = validateInterval(s_interval.v)
    config.ads.s.enabled = s_enabled.v

    config.ads.b.message = u8:decode(b_message.v)
    config.ads.b.interval = validateInterval(b_interval.v)
    config.ads.b.enabled = b_enabled.v
    
    vr_interval.v = config.ads.vr.interval
    fam_interval.v = config.ads.fam.interval
    al_interval.v = config.ads.al.interval
    rb_interval.v = config.ads.rb.interval
    s_interval.v = config.ads.s.interval
    b_interval.v = config.ads.s.interval
end

function loadConfig()
    vr_message.v = u8(config.ads.vr.message)
    vr_interval.v = config.ads.vr.interval
    vr_enabled.v = config.ads.vr.enabled
    
    fam_message.v = u8(config.ads.fam.message)
    fam_interval.v = config.ads.fam.interval
    fam_enabled.v = config.ads.fam.enabled
    
    al_message.v = u8(config.ads.al.message)
    al_interval.v = config.ads.al.interval
    al_enabled.v = config.ads.al.enabled

    rb_message.v = u8(config.ads.rb.message)
    rb_interval.v = config.ads.rb.interval
    rb_enabled.v = config.ads.rb.enabled
    
    s_message.v = u8(config.ads.s.message)
    s_interval.v = config.ads.s.interval
    s_enabled.v = config.ads.s.enabled

    b_message.v = u8(config.ads.s.message)
    b_interval.v = config.ads.s.interval
    b_enabled.v = config.ads.s.enabled
end

function sendAd(adType, message)
    if message and message ~= "" then
        local command = ""
        if adType == "vr" then
            command = "/vr " .. message
        elseif adType == "fam" then
            command = "/fam " .. message
        elseif adType == "s" then
            command = "/s " .. message
        elseif adType == "b" then
            command = "/b " .. message
        elseif adType == "al" then
            command = "/al " .. message
        elseif adType == "rb" then
            command = "/rb " .. message
        end
        
        if command ~= "" then
            sampSendChat(command)
            sampAddChatMessage("{00FF00}[AutoAdvert] advert send: " .. command, -1)
        end
    end
end

function drawAdSettings(title, message_buffer, interval_buffer, enabled_buffer, adType)
    imgui.Text(title)
    imgui.Separator()
    imgui.Spacing()
    
    imgui.Checkbox("Включить автоматическую отправку", enabled_buffer)
    imgui.Spacing()
    
    imgui.Text("Сообщение для рекламы:")
    imgui.PushItemWidth(-1)
    imgui.InputTextMultiline('##' .. adType .. '_message', message_buffer, imgui.ImVec2(-1, 80))
    imgui.PopItemWidth()
    imgui.Spacing()
    
    imgui.Text("Интервал отправки (секунды):")
    imgui.PushItemWidth(200)
    imgui.InputInt('##' .. adType .. '_interval', interval_buffer)
    imgui.PopItemWidth()
    
    if interval_buffer.v < 20 then
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), "Минимум: 20 сек")
    elseif interval_buffer.v > 2000000 then
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), "Максимум: 2000000 сек")
    end
    
    imgui.Spacing()
    if imgui.Button("Тестовая отправка##" .. adType, imgui.ImVec2(150, 30)) then
        if message_buffer.v ~= "" then
            sendAd(adType, u8:decode(message_buffer.v))
        else
            sampAddChatMessage("{FF0000}[AutoAdvert] Enter a message for advert!", -1)
        end
    end
    
    imgui.Spacing()
    imgui.Spacing()
end

function main()
    while not isSampAvailable() do wait(0) end
    -- команда для открытия
    sampRegisterChatCommand('autoadvert', function()
        window.v = not window.v
    end)
    
    loadConfig()
    
    lua_thread.create(function()
        while true do
            wait(1000)
            
            local current_time = os.time()
            
            for adType, adData in pairs(config.ads) do
                if adData.enabled and adData.message ~= "" then
                    if current_time - adData.last_time >= adData.interval then
                        sendAd(adType, adData.message)
                        adData.last_time = current_time
                    end
                end
            end
        end
    end)
    
    wait(-1)
end

function imgui.OnDrawFrame()
    if window.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowSize(imgui.ImVec2(630, 550), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2 - 300, sh/2 - 300), imgui.Cond.FirstUseEver)
        -- нейм вкладки
        if imgui.Begin("Автоматическая реклама", window, imgui.WindowFlags.NoResize) then
            
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize("Настройки автоматической рекламы").x) / 2)
            imgui.Text("Настройки автоматической рекламы")
            imgui.Separator()
            imgui.Spacing()
            -- нейм вкладкок , открытие
            if imgui.Button("Вип чат (/vr)", imgui.ImVec2(90, 30)) then
                current_tab = 1
            end
            imgui.SameLine()
            if imgui.Button("Семья (/fam)", imgui.ImVec2(100, 30)) then
                current_tab = 2
            end
            imgui.SameLine()
            if imgui.Button("Альянс (/al)", imgui.ImVec2(100, 30)) then
                current_tab = 3
            end
            imgui.SameLine()
            if imgui.Button("Организация (/rb)", imgui.ImVec2(125, 30)) then
                current_tab = 4
            end
            imgui.SameLine()
            if imgui.Button("Кричать (/s)", imgui.ImVec2(83, 30)) then
                current_tab = 5
            end
            imgui.SameLine()
            if imgui.Button("Нрп чат (/b)", imgui.ImVec2(83, 30)) then
                current_tab = 6
            end
            
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            
            if current_tab == 1 then
                drawAdSettings("Обычная реклама (/vr)", vr_message, vr_interval, vr_enabled, "vr")
            elseif current_tab == 2 then
                drawAdSettings("Реклама в семье (/fam)", fam_message, fam_interval, fam_enabled, "fam")
            elseif current_tab == 3 then
                drawAdSettings("Реклама в альянсе (/al)", al_message, al_interval, al_enabled, "al")
            elseif current_tab == 4 then
                drawAdSettings("Реклама в организации (/rb)", rb_message, rb_interval, rb_enabled, "rb")
            elseif current_tab == 5 then
                drawAdSettings("Кричит текст (/s)", s_message, s_interval, s_enabled, "s")
            elseif current_tab == 6 then
                drawAdSettings("Пишет в НРП чат (/b)", s_message, s_interval, s_enabled, "b")
            end
            
            imgui.Separator()
            imgui.Spacing()
            
            if imgui.Button("Сохранить настройки", imgui.ImVec2(150, 30)) then
                saveConfig()
                sampAddChatMessage("{00FF00}[AutoAdvert] successful save!", -1)
            end
            
            imgui.SameLine()
            
            if imgui.Button("Остановить всё", imgui.ImVec2(150, 30)) then
                vr_enabled.v = false
                fam_enabled.v = false
                al_enabled.v = false
                rb_enabled.v = false
                s_enabled.v = false
                saveConfig()
                sampAddChatMessage("{FFFF00}[AutoAdvert] all advert stop!", -1)
            end
            
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            
            -- инфо в нижней части
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "Команда для открытия меню: /autoadvert")
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "Минимальный интервал: 20 секунд")
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "Максимальный интервал: 2000000 секунд")
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "")
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "Владелец : https://youtube.com/@aloxinbay")
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "Сделано для вкладки 'Моды' в оффициальном лаунчере ArizonaRP Games")
            
        end
        imgui.End()
    end
end

function onD3DPresent()
    imgui.Process = window.v
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        saveConfig()
    end
end
