-- Spree record

-- Global var

mapName = et.trap_Cvar_Get("mapname")

spree = {
    ["killsRecord"] = 0,
    ["msg"]         = {
        ["oldShort"] = "",
        ["oldLong"]  = "",
        ["current"]  = ""
    }
}

mapSpree = {
    ["killsRecord"] = 0,
    ["msg"]         = {
        ["oldShort"] = "",
        ["oldLong"]  = "",
        ["current"]  = ""
    }
}

-- Set default client data.
clientDefaultData["nbKill"] = 0

-- Set module command.
cmdList["client"]["!spree_record"]   = "/command/client/spree_record.lua"
cmdList["client"]["!spree_restart"]  = "/command/both/spree_restart.lua"
cmdList["console"]["!spree_restart"] = "/command/both/spree_restart.lua"

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkSpreeRecordRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^" .. k_color .. spree["msg"]["current"] .. "\n")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^" .. k_color .. mapSpree["msg"]["current"] .. "\n")
    end
end

-- Write spree record of player.
--  clientNum is the client slot id.
--  kills is the kill count of spree record.
function writeSpreeRecord(clientNum, kills)
    local name = et.Q_CleanStr(et.Info_ValueForKey( et.trap_GetUserinfo(clientNum), "name"))
    local date = os.date("%x %I:%M:%S%p")

    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "sprees/spree_record.dat", et.FS_WRITE)

    if len == -1 then
        et.G_LogPrint("ERROR: sprees/spree_record.dat file not writable!\n")
    else
        local spreeRecordLine = kills .. "@" .. date .. "@" .. name
        et.trap_FS_Write(spreeRecordLine, string.len(spreeRecordLine), fd)
    end

    et.trap_FS_FCloseFile(fd)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^1New spree record: ^7" .. name .. " ^7with^3 " .. kills .. "^7 kills  ^7" .. spree["msg"]["oldShort"] .. "\n")
    loadSpreeRecord()
    setSpreeRecord(name, kills, date)
end

-- Set spree record data.
--  name is the player name.
--  kills is the kill count of spree record.
--  date is the current time and date of spree record.
function setSpreeRecord(name, kills, date)
    spree["killsRecord"]     = kills
    spree["msg"]["oldShort"] = "^3[Old: ^7" .. name .. "^3 " .. kills .. "^7 @ " .. date .. "^3]"
    spree["msg"]["oldLong"]  = "^3Spree Record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date
    spree["msg"]["current"]  = "Current spree record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date
end

-- Write map spree record of player.
--  clientNum is the client slot id.
--  kills is the kill count of map spree record.
function writeMapSpreeRecord(clientNum, kills)
    local name    = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name"))
    local date    = os.date("%x %I:%M:%S%p")

    local fdadm, len = et.trap_FS_FOpenFile(kmod_ng_path .. "sprees/" .. mapName .. ".record", et.FS_WRITE)

    if len == -1 then
        et.G_LogPrint("ERROR: sprees/" .. mapName .. ".record file not writable!\n")
    else
        local mapSpreeRecordLine = kills .. "@" .. date .. "@" .. name
        et.trap_FS_Write(mapSpreeRecordLine, string.len(mapSpreeRecordLine) ,fdadm)
    end

    et.trap_FS_FCloseFile(fdadm)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^1New Map spree record: ^7" .. name .. " ^7with^3 " .. kills .. "^7 kills on " .. mapName .."  ^7" .. mapSpree["msg"]["oldShort"] .. "\n")
    loadSpreeRecord()
    setMapSpreeRecord(mapName, name, kills, date)
end

-- Set map spree record data.
--  name is the player name.
--  kills is the kill count of map spree record.
--  date is the current time and date of map spree record.
function setMapSpreeRecord(name, kills, date)
    mapSpree["killsRecord"]     = kills
    mapSpree["msg"]["oldShort"] = "^3[Old: ^7" .. name .. "^3 " .. kills .. "^7 @ " .. date .. "^3]"
    mapSpree["msg"]["oldLong"]  = "^3Map Spree Record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date .. " on the map of " .. mapName
    mapSpree["msg"]["current"]  = "Current Map spree record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date
end

-- Load and set spree record and map spree record.
function loadSpreeRecord()
    -- Load spree record.
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "sprees/spree_record.dat", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("ERROR: sprees/spree_record.dat file not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No spree record found! \n")
        spree["msg"]["oldShort"] = "^3[Old: ^7N/A^3]"
        spree["msg"]["oldLong"]  = "^3Spree Record: ^7There is no current spree record"
        spree["killsRecord"]     = 0
    else
        local fileStr = et.trap_FS_Read(fd, len)
        local _, _, kills, date, name = string.find(fileStr, "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)")
        setSpreeRecord(name, tonumber(kills), date)
    end

    et.trap_FS_FCloseFile(fd)

    -- Load map spree record.
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "sprees/" .. mapName .. ".record", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("ERROR: sprees/" .. mapName .. ".record file not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No map spree record found! \n")
        mapSpree["msg"]["oldShort"] = "^3[Old: ^7N/A^3]"
        mapSpree["msg"]["oldLong"]  = "^3Map Spree Record: ^7There is no current spree record"
        mapSpree["killsRecord"]     = 0
    else
        local fileStr = et.trap_FS_Read(fd, len)
        local _, _, kills, date, name = string.find(fileStr, "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)")
        setMapSpreeRecord(name, tonumber(kills), date)
    end

    et.trap_FS_FCloseFile(fd)
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkSpreeRecordObituaryEnemyKill(vars)
    client[killer]["nbKill"] = client[killer]["nbKill"] + 1
end

-- Callback function when world kill a player.
--function checkSpreeRecordObituaryWorldKill(vars)
--    if client[vars["victim"]]["nbKill"] > spree["killsRecord"] then
--        writeSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
--    end
--
--    if client[vars["victim"]]["nbKill"] > mapSpree["killsRecord"] then
--        writeMapSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
--        client[vars["victim"]]["nbKill"] = 0
--    else
--        client[vars["victim"]]["nbKill"] = 0
--    end
--end

-- Callback function when victim have team kill or self kill.
--function checkSpreeRecordObituaryTkAndSelfKill(vars)
--    if client[vars["victim"]]["nbKill"] > spree["killsRecord"] then
--        writeSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
--    end
--
--    if client[vars["victim"]]["nbKill"] > mapSpree["killsRecord"] then
--        writeMapSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
--        client[vars["victim"]]["nbKill"] = 0
--    else
--        client[vars["victim"]]["nbKill"] = 0
--    end
--end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkSpreeRecordObituary(vars)
    if client[vars["victim"]]["nbKill"] > spree["killsRecord"] then
        writeSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
    end

    if client[vars["victim"]]["nbKill"] > mapSpree["killsRecord"] then
        writeMapSpreeRecord(vars["victim"], client[vars["victim"]]["nbKill"])
        client[vars["victim"]]["nbKill"] = 0
    else
        client[vars["victim"]]["nbKill"] = 0
    end
end

-- Add callback spree record function.
addCallbackFunction({
    ["RunFrameEndRound"]  = "checkSpreeRecordRunFrameEndRound",
    ["ObituaryEnemyKill"] = "checkSpreeRecordObituaryEnemyKill",
    --["ObituaryWorldKill"] = "checkSpreeRecordObituaryWorldKill",
    --["ObituaryTkAndSelfKill"] = "checkSpreeRecordObituaryTkAndSelfKill",
    ["Obituary"]          = "checkSpreeRecordObituary"
    ["ReadConfig"]        = "loadSpreeRecord"
})
