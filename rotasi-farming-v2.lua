Farm_settings = {
    seed_id = 5667,
    world = { "MZHEP", "NZFDA", "JZYTC", "THZUA", "HNRUI", "HNUNA", "VAKBP", "GJKCD", "FEGYK", "VRFSX", "DVGHO",
        "ZBJEE" },
    door_id = "ISARIAMA",
    is_looping = false
}

PNB_settings = {
    position = { x = 1, y = 7 },
    break_tile = 5,
    delay = 170 -- Miliseconds
}

Harvest_settings = {
    max_block_in_bp = 150,
    delay = 120 -- Miliseconds
}

Plant_settings = {
    delay = 90 -- Miliseconds
}

Whitelist_settings = {
    auto_leave = true,
    player_name = "Hamzama",
    exit_time = 15, -- Seconds
    auto_ban = false
}

Trash_settings = {
    trash_list = { 5040, 5042, 5044, 5032, 5034, 5036, 5038, 5024, 5026, 5028, 5030, 7164, 7162, 1058, 1094 },
    max_item_in_bp = 1
}

Gems_settings = {
    auto_buy = true,
    menu_pack = "main",
    name_pack = "mooncake_mag",
    price_pack = 5000,
    item_pack_id = { 1828, 1096, 1098, 10228 }
}

Storage_settings = {
    world_seed = "GASJUM",
    world_seed_id = 16,
    world_pack = "GASJUM",
    world_pack_id = 2796,
    world_door_id = "PENGAMANAN" -- Optional / Boleh diisi atau tidak
}

Discord_settings = {
    chat_id = 1012395778179870871,
    webhook_id_token = "1012394407829446766/4RzEvyTv-NN9TWg0Tt6uyDCwtDhsM5qX7HpF8cZ_Y6hG5BEqxKlobtU2rYvDxNfOt5Co",
    hour_diff = 7 -- Hour Different / Selisih waktu RDP
}
-- =========================================================== --
Owner = "MugoBati"
Isowner = false
Prosesworld = ""
Last_tile_x = 0
Last_tile_y = 0
Result_spent_time = ""
Start_ready_tree = {}
Tag_owner = ""

function getIP()
    local cmd = io.popen('powershell -command "(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content"')
    IP = cmd:read("*l")
    cmd:close()
    return IP
end

function getCPU()
    local cmd = io.popen('powershell -command "(Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average).Average"')
    CPU = cmd:read("*l")
    cmd:close()
    return CPU
end

function getRAM()
    local cmd = io.popen('powershell -command "$CompObject = Get-WmiObject -Class WIN32_OperatingSystem; $Ram = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize); [Math]::Floor($Ram)"')
    RAM = cmd:read("*l")
    cmd:close()
    return RAM
end

function sendWH(activity)
    local sec = (os.clock() - startTime)
    local days = math.floor(sec / 86400)
    local hours = math.floor((sec % 86400) / 3600)
    local minutes = math.floor((sec % 3600) / 60)

    title = "Rotation Log (" .. getBot().name .. ")"
    desc = [[*[]] ..
        os.date("%A, %d %B %Y / %H:%M", os.time() + Discord_settings.hour_diff * 60 * 60) ..
        [[]*\n| <:gt_megaphone:1012407972363780096> **Bot Activity:** ]] .. activity .. [[]]
    textField = [[{"name": "Bot Information", "value": "| <:signalstatus:1012408086448844862> **Status:** ]] ..
        getBot().status:gsub("^%l", string.upper) ..
        [[ | <:gt_globe:1012404354948546692> **Current World:** ]] ..
        getBot().world ..
        [[\n| <:gt_yellow_gems:1012408013832867871> **Gems:** ]] ..
        format_int(findItem(112)) .. [[ | <:yellow_clock:1013496295912128583> **Uptime:** ]] ..
        days .. [[ Days, ]] .. hours .. [[ Hours, ]] .. minutes .. [[ Minutes", "inline": "false"},
    {"name": "World Information", "value": "| :seedling: **Ready Trees:** ]] ..
        format_int(fgTree(Farm_settings.seed_id)) .. [[", "inline": "false"},
    {"name": "World Spent Time", "value": "]] .. Result_spent_time .. [[", "inline": "false"},
    {"name": "PC Information", "value": "| <:placeholder:1012409781564231781> **IPv4:** ]] ..
        getIP() ..
        [[ | <:cpu:1012408123450982460> **CPU Usage:** ]] ..
        getCPU() .. [[%\n| <:pc_ram:1012408152823713833> **RAM Usage:** ]] .. getRAM() .. [[% |", "inline": "false"}]]
    textFooter = [[{"text": "Copyright 2022. Made with Love by WANI CodeWriter"}]]
    wh = {}
    wh.url = "https://discord.com/api/webhooks/" ..
        Discord_settings.webhook_id_token .. "/messages/" .. Discord_settings.chat_id
    wh.content = Tag_owner
    wh.embed = '{"title": "' ..
        title .. '", "description": "' .. desc .. '", "footer": ' .. textFooter .. ', "fields": [' .. textField .. ']}'
    wh.edit = true
    webhook(wh)
end

function format_int(number)

    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")

    -- reverse the int-string back remove an optional comma and put the
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Join world
local function joinWorld(name, doorid)
    sendPacket(3, "action|join_request\nname|" .. name .. "|" .. doorid)
    sleep(7000)
    if getBot().world == "EXIT" then
        repeat
            sendPacket(3, "action|join_request\nname|" .. name .. "|" .. doorid)
            sleep(10000)
        until getBot().world ~= "EXIT"
    end
end

function ApplyAccess()
    for _, plr in pairs(getPlayers()) do
        if plr.name:upper() == getBot().name:upper() then
            sendPacket(2, "action|wrench\n|netid|" .. plr.netid)
            sleep(2000)
            sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. plr.netid .. "|buttonClicked|acceptlock")
            sleep(2000)
            sendPacket(2, "action|dialog_return\ndialog_name|acceptaccess")
        end
    end
end

function fgTree(itemid)
    local count = 0
    for _, tile in pairs(getTiles()) do
        if tile.fg == itemid and getTile(tile.x, tile.y).ready then
            count = count + 1
        end
    end
    return count
end

-- Reconnect Bot
local function reconnect()
    local leave_time = Whitelist_settings.exit_time * 1000
    if getBot().status ~= "online" then
        Tag_owner = "<@977075047854374933>"
        sleep(100)
        sendWH("Oops, Bot disconnected")
        repeat
            sleep(5000)
        until getBot().status == "online"
        Tag_owner = ""
        sleep(100)
        sendWH("Bot connected.")
        sleep(7000)
        joinWorld(Prosesworld, Farm_settings.door_id)
        sleep(3000)
        findPath(Last_tile_x, Last_tile_y)
        sleep(2000)
    elseif Whitelist_settings.auto_leave then
        for _, player in pairs(getPlayers()) do
            if player.name ~= getBot().name and player.name ~= Owner and player.name ~= Whitelist_settings.player_name then
                sleep(1000)
                joinWorld(Storage_settings.world_pack, Storage_settings.world_door_id)
                sendWH("Stranger joined the world.")
                sleep(leave_time)
                joinWorld(Prosesworld, Farm_settings.door_id)
                findPath(Last_tile_x, Last_tile_y)
                sleep(1000)
            end
        end
    end
end

local function dropItem(itemID, count)
    if findItem(itemID) >= count then
        sendPacket(2, "action|drop\nitemID|" .. itemID)
        sleep(500)
        sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. itemID .. "|\ncount|" .. count)
        sleep(1000)
    end
end

local function dropAnotherWorld(itemid)
    sleep(1000)
    move(-1, 0)
    reconnect()
    sleep(1000)
    drop(itemid)
    sleep(3000)
    reconnect()
    move(2, 0)
end

local function dropTrash()
    for a, trash in pairs(Trash_settings.trash_list) do
        if findItem(trash) > Trash_settings.max_item_in_bp then
            sendPacket(2, "action|trash\n|itemID|" .. trash)
            sleep(1500)
            sendPacket(2,
                "action|dialog_return\ndialog_name|trash_item\nitemID|" ..
                trash .. "|\ncount|" .. findItem(trash))
            sleep(2500)
        end
    end
end

local function fgBlock(itemid)
    local count = 0
    for _, tile in pairs(getTiles()) do
        if tile.fg == itemid or tile.bg == itemid then
            count = count + 1
        end
    end
    return count
end

local function breakFgBlock()
    for _, tile in pairs(getTiles()) do
        if tile.fg == Farm_settings.seed_id - 1 or tile.bg == Farm_settings.seed_id - 1 then
            if getTile(tile.x, tile.y).fg ~= 0 then
                if getTile(tile.x + 1, tile.y).fg == 102 then
                    findPath(tile.x, tile.y - 1)
                elseif getTile(tile.x + 1, tile.y).fg ~= 102 then
                    findPath(tile.x + 1, tile.y)
                end
                sleep(120)
                while getTile(tile.x, tile.y).fg > 0 do
                    if getTile(tile.x + 1, tile.y).fg == 102 then
                        punch(0, 1)
                    elseif getTile(tile.x + 1, tile.y).fg ~= 102 then
                        punch(-1, 0)
                    end
                    sleep(PNB_settings.delay)
                    if getTile(tile.x, tile.y).fg == 0 then
                        collect(2)
                        sleep(50)
                        collect(2)
                        sleep(50)
                    end
                end
            end
        end
    end
end

local function harvest()
    for _, tile in pairs(getTiles()) do
        if tile.fg == Farm_settings.seed_id and findItem(Farm_settings.seed_id - 1) < Harvest_settings.max_block_in_bp then
            if getTile(tile.x, tile.y).ready then
                Last_tile_x = math.floor(getBot().x / 32)
                Last_tile_y = math.floor(getBot().y / 32)
                reconnect()
                findPath(tile.x, tile.y)
                sleep(100)
                reconnect()
                punch(0, 0)
                sleep(Harvest_settings.delay)
                reconnect()
                collect(6)
                reconnect()
                if findItem(Farm_settings.seed_id) > 0 then
                    repeat
                        place(Farm_settings.seed_id, 0, 0)
                        sleep(70)
                    until getTile(tile.x, tile.y).fg == Farm_settings.seed_id
                end
                reconnect()
            end
        end
    end
end

function planting()
    for _, tile in pairs(getTiles()) do
        if tile.fg ~= 0 and tile.y > 1 and findItem(Farm_settings.seed_id) > 0 and getTile(tile.x, tile.y - 1).fg == 0
            and
            getTile(tile.x, tile.y).fg ~= Farm_settings.seed_id and
            getTile(tile.x, tile.y).fg ~= Farm_settings.seed_id - 1 and
            getTile(tile.x - 1, tile.y - 1).fg ~= 6 and getTile(tile.x + 1, tile.y - 1).fg ~= 6 then
            Last_tile_x = math.floor(getBot().x / 32)
            Last_tile_y = math.floor(getBot().y / 32)
            findPath(tile.x, tile.y - 1)
            sleep(100)
            reconnect()
            place(Farm_settings.seed_id, 0, 0)
            sleep(Plant_settings.delay)
            reconnect()
        end
    end
end

local function breaking(blockid)
    if PNB_settings.break_tile == 1 then
        place(blockid, -1, 0)
        sleep(120)
    elseif PNB_settings.break_tile == 2 then
        if findItem(Farm_settings.seed_id - 1) >= 2 then
            repeat
                place(blockid, -1, -2)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg ~= 0
            repeat
                place(blockid, -1, -1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg ~= 0
        end
    elseif PNB_settings.break_tile == 3 then
        if findItem(Farm_settings.seed_id - 1) >= 3 then
            repeat
                place(blockid, -1, -2)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg ~= 0
            repeat
                place(blockid, -1, -1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg ~= 0
            repeat
                place(blockid, -1, 0)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg ~= 0
        end
    elseif PNB_settings.break_tile == 4 then
        if findItem(Farm_settings.seed_id - 1) >= 4 then
            repeat
                place(blockid, -1, -2)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg ~= 0
            repeat
                place(blockid, -1, -1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg ~= 0
            repeat
                place(blockid, -1, 0)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg ~= 0
            repeat
                place(blockid, -1, 1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 1).fg ~= 0
        end
    elseif PNB_settings.break_tile == 5 then
        if findItem(Farm_settings.seed_id - 1) >= 5 then
            repeat
                place(blockid, -1, -2)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg ~= 0
            repeat
                place(blockid, -1, -1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg ~= 0
            repeat
                place(blockid, -1, 0)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg ~= 0
            repeat
                place(blockid, -1, 1)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 1).fg ~= 0
            repeat
                place(blockid, -1, 2)
                sleep(120)
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 2).fg ~= 0
        end
    end

    if PNB_settings.break_tile == 1 then
        repeat
            punch(-1, 0)
            sleep(PNB_settings.delay)
            reconnect()
        until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg == 0
    elseif PNB_settings.break_tile == 2 then
        if findItem(Farm_settings.seed_id - 1) >= 2 then
            repeat
                punch(-1, -2)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg == 0
            repeat
                punch(-1, -1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg == 0
        end
    elseif PNB_settings.break_tile == 3 then
        if findItem(Farm_settings.seed_id - 1) >= 3 then
            repeat
                punch(-1, -2)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg == 0
            repeat
                punch(-1, -1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg == 0
            repeat
                punch(-1, 0)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg == 0
        end
    elseif PNB_settings.break_tile == 4 then
        if findItem(Farm_settings.seed_id - 1) >= 4 then
            repeat
                punch(-1, -2)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg == 0
            repeat
                punch(-1, -1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg == 0
            repeat
                punch(-1, 0)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg == 0
            repeat
                punch(-1, 1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 1).fg == 0
        end
    elseif PNB_settings.break_tile == 5 then
        if findItem(Farm_settings.seed_id - 1) >= 5 then
            repeat
                punch(-1, -2)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 2).fg == 0
            repeat
                punch(-1, -1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) - 1).fg == 0
            repeat
                punch(-1, 0)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32)).fg == 0
            repeat
                punch(-1, 1)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 1).fg == 0
            repeat
                punch(-1, 2)
                sleep(PNB_settings.delay)
                reconnect()
            until getTile(math.floor(getposx() / 32) - 1, math.floor(getposy() / 32) + 2).fg == 0
        end
    end

    sleep(50)
    collect(5)
    sleep(50)
    if findItem(Farm_settings.seed_id) >= 190 then
        sleep(1000)
        joinWorld(Storage_settings.world_seed, Storage_settings.world_door_id)
        collectSet(false, 0)
        sleep(2000)
        for _, tile in pairs(getTiles()) do
            if tile.bg == Storage_settings.world_seed_id or tile.fg == Storage_settings.world_seed_id then
                findPath(tile.x, tile.y)
                sleep(1000)
                if findItem(Farm_settings.seed_id) >= 190 then
                    dropAnotherWorld(Farm_settings.seed_id)
                else
                    break
                end
            end
        end
        joinWorld(Prosesworld, Farm_settings.door_id)
        collectSet(true, 5)
        sleep(2000)
        findPath(PNB_settings.position.x, PNB_settings.position.y)
    end
end

local function buypack()
    dropTrash()
    sleep(1000)
    say("Buying " .. Gems_settings.name_pack)
    sleep(1000)
    while findItem(112) >= Gems_settings.price_pack do
        Last_tile_x = math.floor(getBot().x / 32)
        Last_tile_y = math.floor(getBot().y / 32)
        sendPacket(2, "action|buy\nitem|" .. Gems_settings.menu_pack)
        sleep(350)
        reconnect()
        sendPacket(2, "action|buy\nitem|" .. Gems_settings.name_pack)
        sleep(450)
        reconnect()
    end
    collectSet(false, 0)
    sleep(1000)
    sendWH("Bot has bought " .. Gems_settings.name_pack .. ".")
    joinWorld(Storage_settings.world_pack, Storage_settings.world_door_id)
    for _, tile in pairs(getTiles()) do
        if tile.bg == Storage_settings.world_pack_id then
            findPath(tile.x, tile.y)
            sleep(1000)
            for _, id_pack in pairs(Gems_settings.item_pack_id) do
                if findItem(id_pack) >= 1 then
                    move(-1, 0)
                    sleep(2000)
                    drop(id_pack)
                    sleep(2000)
                    move(2, 0)
                end
            end
        end
    end
    joinWorld(Prosesworld, Farm_settings.door_id)
    collectSet(true, 5)
    sleep(2000)
    reconnect()
end

local function start()
    while fgTree(Farm_settings.seed_id) > 0 do
        dropTrash()
        sleep(1000)
        if findItem(Farm_settings.seed_id) >= 190 then
            sleep(3000)
            joinWorld(Storage_settings.world_seed, Storage_settings.world_seed_id)
            dropAnotherWorld(Farm_settings.seed_id)
            joinWorld(Prosesworld, Farm_settings.door_id)
        end
        if Gems_settings.auto_buy and findItem(112) >= Gems_settings.price_pack then
            buypack()
        end
        for _, pack in pairs(Gems_settings.item_pack_id) do
            if findItem(pack) >= 1 then
                collectSet(false, 0)
                sleep(1000)
                joinWorld(Storage_settings.world_pack, Storage_settings.world_door_id)
                for _, tile in pairs(getTiles()) do
                    if tile.bg == Storage_settings.world_pack_id then
                        findPath(tile.x, tile.y)
                        sleep(1000)
                        for _, id_pack in pairs(Gems_settings.item_pack_id) do
                            if findItem(id_pack) >= 1 then
                                move(-1, 0)
                                sleep(2000)
                                drop(id_pack)
                                sleep(2000)
                                move(2, 0)
                            end
                        end
                        break
                    end
                end
                joinWorld(Prosesworld, Farm_settings.door_id)
                collectSet(true, 5)
                sleep(1000)
            end
        end

        collectSet(true, 5)
        sleep(500)

        if findItem(Farm_settings.seed_id) >= 120 then
            sendWH("Planting " .. findItem(Farm_settings.seed_id) .. " seeds.")
            while planting() do
                planting()
            end
        end

        if findItem(Farm_settings.seed_id - 1) >= PNB_settings.break_tile then
            findPath(PNB_settings.position.x, PNB_settings.position.y)
            sleep(120)
            Last_tile_x = PNB_settings.position.x
            Last_tile_y = PNB_settings.position.y
            sendWH("Breaking " .. findItem(Farm_settings.seed_id - 1) .. " blocks.")
            while findItem(Farm_settings.seed_id - 1) >= PNB_settings.break_tile do
                breaking(Farm_settings.seed_id - 1)
            end
            dropTrash()
        end

        sendWH("Harvesting trees.")
        while harvest() do
            harvest()
        end

        findPath(PNB_settings.position.x, PNB_settings.position.y)
        sleep(120)
        Last_tile_x = PNB_settings.position.x
        Last_tile_y = PNB_settings.position.y
        sendWH("Breaking " .. findItem(Farm_settings.seed_id - 1) .. " blocks.")
        while findItem(Farm_settings.seed_id - 1) >= PNB_settings.break_tile do
            breaking(Farm_settings.seed_id - 1)
        end
        dropTrash()
        sendWH("Planting " .. findItem(Farm_settings.seed_id) .. " seeds.")
        while planting() do
            planting()
        end
        collectSet(false, 0)
    end

    if fgTree(Farm_settings.seed_id) < 1 then
        while fgBlock(Farm_settings.seed_id - 1) > 0 do
            while breakFgBlock() do
                breakFgBlock()
            end
        end
        if findItem(Farm_settings.seed_id - 1) >= PNB_settings.break_tile then
            findPath(PNB_settings.position.x, PNB_settings.position.y)
            sleep(120)
            sendWH("Breaking " .. findItem(Farm_settings.seed_id - 1) .. " blocks.")
            collectSet(true, 5)
            sleep(500)
            while findItem(Farm_settings.seed_id - 1) >= PNB_settings.break_tile do
                breaking(Farm_settings.seed_id - 1)
            end
            dropTrash()
        end

        sendWH("Planting " .. findItem(Farm_settings.seed_id) .. " seeds.")
        while planting() do
            planting()
        end
        collectSet(false, 0)
        sleep(500)

        if Gems_settings.auto_buy and findItem(112) >= Gems_settings.price_pack then
            buypack()
        end

        if findItem(Farm_settings.seed_id) > 0 then
            joinWorld(Storage_settings.world_seed, Storage_settings.world_seed_id)
            dropAnotherWorld(Farm_settings.seed_id)
            dropTrash()
            joinWorld(Prosesworld, Farm_settings.door_id)
        end
    end
end

local function main(totalworld)
    Result_spent_time = [[ ]] ..
        getBot().world .. [[ (0 Hours, 0 Minutes | ]] ..
        format_int(fgTree(Farm_settings.seed_id)) .. [[)\n ]]
    if not Isowner then
        sendWH("Looking **" .. Owner .. "** in the World!")
        sleep(200)
        repeat
            for _, player in pairs(getPlayers()) do
                if player.name ~= Owner then
                    say("`0Looking `2" .. Owner .. " `0!")
                    sleep(5000)
                else
                    Isowner = true
                end
            end
        until Isowner
        say("`0Yeah, `2" .. Owner .. " `0here. Let's start it!")
    end
    for i = 1, totalworld do
        Start_ready_tree[#Start_ready_tree + 1] = format_int(fgTree(Farm_settings.seed_id))
        sleep(2000)
        joinWorld(Farm_settings.world[i], Farm_settings.door_id)
        Prosesworld = Farm_settings.world[i]
        sendWH("Start to farming in this world.")
        sleep(200)
        Spent_time_start = os.clock()
        while fgBlock(Farm_settings.seed_id - 1) > 0 do
            while breakFgBlock() do
                breakFgBlock()
            end
        end

        start()

        sendWH("Bot has completed farming in this world.")
        Spent_time_end = os.clock()
        if i == 1 then
            Result_spent_time = ""
        end
        local seconds = (Spent_time_end - Spent_time_start)
        local hours = math.floor((seconds % 86400) / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        Result_spent_time = [[ ]] .. Result_spent_time .. Farm_settings.world[i] .. [[ (]] .. hours ..
            [[ Hours, ]] .. minutes .. [[ Minutes | ]] ..
            format_int(Start_ready_tree[i]) .. [[)\n ]]

        for n = 1, 10 do
            local random_world = ""
            for a = 10, 1, -1 do
                random_world = random_world .. string.char(math.random(97, 122))
            end
            joinWorld(random_world, Farm_settings.door_id)
            reconnect()
        end

    end
end

local function getArgs(str)
    local args = {}
    for i in str:gmatch('[^%s]+') do
        args[#args + 1] = i
    end
    return args
end

function cmds(v)
    local dummyvar0 = v[0]
    local dummyvar1 = v[1]
    if dummyvar0:lower() == "onconsolemessage" then
        local name = dummyvar1:lower():match('<`.[^`]+'):sub(4)
        local text = dummyvar1:lower():match('`$[^`]+'):sub(3)
        if text and text:sub(1, 1) == '!' then
            if Owner then
                if name ~= Owner:lower() then
                    return 0
                end
            end
            text = getArgs(text:sub(2))
            if text[1] == "run" then
                if Farm_settings.is_looping then
                    while true do
                        main(#Farm_settings.world)
                    end
                    removeBot(getBot().name)
                elseif Farm_settings.is_looping == false then
                    main(#Farm_settings.world)
                    removeBot(getBot().name)
                end
            elseif text[1] == "access" then
                ApplyAccess()
            elseif text[1] == "goto" then
                local pos_x = tonumber(text[2])
                local pos_y = tonumber(text[3])
                findPath(pos_x - 1, pos_y - 1)
            elseif text[1] == "drop" then
                if text[2] == nil then
                    say("/idk")
                elseif text[2] ~= nil then
                    say("Wait..")
                    sleep(1000)
                    local itemid = tonumber(text[2])
                    sleep(2000)
                    if text[3] ~= nil then
                        local amount = tonumber(text[3])
                        dropItem(itemid, amount)
                    else
                        drop(itemid)
                    end
                    sleep(1000)
                    say("Item has dropped.")
                    sleep(2500)
                end
            elseif text[1] == "collect" then
                if text[2] == nil then
                    sleep(1000)
                    collect(3)
                else
                    local range = tonumber(text[2])
                    collect(range)
                end
            elseif text[1] == "right" then
                if text[2] == nil then
                    move(1, 0)
                else
                    move(text[2], 0)
                end
            elseif text[1] == "left" then
                if text[2] == nil then
                    move(-1, 0)
                else
                    move(-text[2], 0)
                end
            elseif text[1] == "up" then
                if text[2] == nil then
                    move(0, -1)
                else
                    move(0, -text[2])
                end
            elseif text[1] == "down" then
                if text[2] == nil then
                    move(0, 1)
                else
                    move(0, text[2])
                end
            elseif text[1] == "wear" then
                if text[2] == nil then
                    sleep(1000)
                    collect(3)
                    sleep(2000)
                    wear(98)
                    sleep(2000)
                    dropItem(98, findItem(98) - 1)
                else
                    local itemid = tonumber(text[2])
                    sleep(1000)
                    collect(3)
                    sleep(1000)
                    wear(itemid)
                end
            elseif text[1] == "upbackpack" then
                say("Wait..")
                sleep(2000)
                sendPacket(2, "action|buy\nitem|upgrade_backpack")
                sleep(1000)
                say("Successfully to upgrade backpack.")
            end
        end
    end
end

addHook("ceemde", cmds)

startTime = os.clock()
say("Made with Love by `4WANI CodeWriter")
sleep(3500)
say("`0Type !run in 3 seconds")
sleep(2000)
