-- Revive spree

-- From Vetinari's rspree script. 
--
-- $Date: 2007-03-02 13:35:49 +0100 (Fri, 02 Mar 2007) $ 
-- $Id: rspree.lua 181 2007-03-02 12:35:49Z vetinari $
-- $Revision: 181 $
--
-- version 1.2.3
--

-- Global var

reviveSpree = {
    -- List of revive spree.
    --   key   -> revive spree amount
    --   value -> revive spree message
    ["list"] = {},
    -- Revive spree ending by enemy.
    ["endMsgByEnemy"] = et.trap_Cvar_Get("u_rs_end_by_enemy"),
    -- Revive spree ending by selfkill.
    ["endMsgBySelfkill"] = et.trap_Cvar_Get("u_rs_end_by_selfkill"),
    -- Revive spree ending by world.
    ["endMsgByWorld"] = et.trap_Cvar_Get("u_rs_end_end_by_world"),
    -- Revive spree ending by teamkill.
    ["endMsgByTeamkill"] = et.trap_Cvar_Get("u_rs_end_by_teamkill"),
    -- Revive spree message position.
    ["position"] = et.trap_Cvar_Get("u_rs_position"),
    -- Print revive spree messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_rs_msg_default")),
    -- Current highest revive spree.
    ["maxSpree"] = 0,
    -- Player ID of current highest revive spree.
    ["maxId"] = nil,
    -- List of map revive spree records.
    ["stats"] = {},
    -- New map revive spree record status.
    ["mapRecord"] = false,

    -- server records -> player stats module
    ["srvRecord"]      = tonumber(et.trap_Cvar_Get("u_srv_record")),
    ["serverRecords"]  = {},
    ["recordLastNick"] = tonumber(et.trap_Cvar_Get("u_record_last_nick")),
    ["recordsExpire"]  = 60 * 60 * 24 * tonumber(et.trap_Cvar_Get("u_records_expire"))
}

-- Set default client data.
--
-- Revive spree value.
clientDefaultData["reviveSpree"] = 0
-- Print revive spree status.
clientDefaultData["reviveSpreeMsg"] = 0

-- Set module command.
cmdList["client"]["!spree_record"] = "/command/client/revive_sprees_record.lua"

if reviveSpree["srvRecord"] == 1 then
    cmdList["client"]["!rsprees"] = "/command/both/revive_sprees_record.lua"
    cmdList["client"]["!stats"]   = "/command/client/revive_sprees_stats.lua"
end

cmdList["console"]["!rsprees"]       = "/command/console/revive_sprees.lua"
cmdList["console"]["!rspreesall"]    = "/command/console/revive_sprees_all.lua"
cmdList["console"]["!rspreerecords"] = "/command/both/revive_sprees_record.lua"

-- Set slash command of revive spree message status.
addSlashCommand("client", "rsprees", {"function", "reviveSpreeSlashCommand"})


-- Function

-- Set client data & client user info if revive spree message is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if revive spree message is enabled or not.
function setReviveSpreeMsg(clientNum, value)
    client[clientNum]["reviveSpreeMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_rspree", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Manage revive spree message status when rspree slash command is used.
--  params is parameters passed to the function executed in command file.
function reviveSpreeSlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd
    
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["reviveSpreeMsg"] == 0 then
            status = "^8off^7"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setReviveSpreeMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setReviveSpreeMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage revive spree message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function reviveSpreeUpdateClientUserinfo(vars)
    local rs = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_rspree")

    if rs == "" then
        setReviveSpreeMsg(vars["clientNum"], reviveSpree["msgDefault"])
    elseif tonumber(rs) == 0 then
        client[vars["clientNum"]]["reviveSpreeMsg"] = 0
    else
        client[vars["clientNum"]]["reviveSpreeMsg"] = 1
    end
end

-- Load all map revive spree record.
-- Exemple in revivingspree.txt file :
-- map;revive_spree;time;name
-- time is timestamp
function loadReviveSpreeStats() 
    local funcStart = et.trap_Milliseconds()
    local count     = 0
    local fd, len   = et.trap_FS_FOpenFile("revivingspree.txt", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: revivingspree.txt file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No revive spree stats defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)
        et.trap_FS_FCloseFile(fd)

        for map, rspree, time, name
          in string.gfind(fileStr, "([^;#\n]+)%;(%d+)%;(%d+)%;([^%\n]+)") do
            reviveSpree["stats"][map] = {
                tonumber(rspree),
                tonumber(time),
                name
            }

            count = count + 1
        end
    end

    et.G_LogPrintf(
        "uMod: Loading revive spree stats in %d ms (%d entrie(s))\n",
        et.trap_Milliseconds() - funcStart,
        count
    )
end

-- Load player revive stats. 
-- Exemple in rspree-records.txt file :
-- guid;multi_revive;monster_revive;revive;nick;firstseen;lastseen
-- firstseen & lastseen are timestamp
function loadReviveSpreeRecords() 
    local funcStart = et.trap_Milliseconds()
    local count     = 0
    local fd, len   = et.trap_FS_FOpenFile("rspree-records.txt", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: rspree-records.txt file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No revive spree records defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)
        et.trap_FS_FCloseFile(fd)

        local expireLimit = os.time() - reviveSpree["recordsExpire"]

        for guid, multi, monster, revive, nick, firstSeen, lastSeen
          in string.gfind(fileStr, "[^%#](%x+)%;(%d*)%;(%d*)%;(%d*)%;([^;]*)%;(%d*)%;([^%\n]*)") do
            lastSeen = tonumber(lastSeen)

            if reviveSpree["recordsExpire"] == 0 or expireLimit < lastSeen then
                reviveSpree["serverRecords"][guid] = {
                    tonumber(multi), 
                    tonumber(monster),
                    tonumber(revive),
                    nick,
                    tonumber(firstSeen),
                    lastSeen
                }

                count = count + 1
            end
        end
    end

    et.G_LogPrintf(
        "uMod: Loading revive spree records in %d ms (%d entrie(s))\n",
        et.trap_Milliseconds() - funcStart,
        count
    )
end

-- Called when qagame initializes.
-- Format revive spree list.
--  vars is the local vars of et_InitGame function.
function reviveSpreeInitGame(vars)
    loadReviveSpreeStats()

    if reviveSpree["srvRecord"] == 1 then
        loadReviveSpreeRecords()
    end

    local n = 1

    while true do
        local amount = tonumber(et.trap_Cvar_Get("u_rs_amount" .. n))
        local msg    = et.trap_Cvar_Get("u_rs_message" .. n)

        if amount ~= nil and msg ~= "" then
            reviveSpree["list"][amount] = msg
        else
            break
        end
        
        n = n + 1
    end
end

-- Callback function when qagame runs a server frame. (pending end round)
-- At end of round, display revive spree end message if needed.
-- Display revive spree record message if exist.
--  vars is the local vars passed from et_RunFrame function.
function checkReviveSpreeRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        local endReviveSpree = ""

        for p = 0, clientsLimit, 1 do
            if client[p]["reviveSpree"] >= 5 then
                if endReviveSpree ~= "" then
                    endReviveSpree = endReviveSpree .. "^7, "
                else
                    endReviveSpree = endReviveSpree .. "^7"
                end

                endReviveSpree = endReviveSpree .. client[p]["name"]
            end
        end

        if endReviveSpree ~= "" then
            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay ^1Revive spree ended due to map's end for : "
                    .. endReviveSpree .. "\n"
            )
        end

        -- Display revive spree map record.
        if reviveSpree["maxId"] ~= nil then
            local longest = ""
            local max     = findMaxReviveSpree() -- max = { count, date, name }

            if table.getn(max) == 3 then 
                if reviveSpree["mapRecord"] then
                    longest = " " .. color1 .. "This is a New map record!"
                    saveReviveSpreeStats("revivingspree.txt", reviveSpree["stats"])
                else 
                    longest = string.format(
                        " ^7[record: %d by %s^7 @%s]",
                        max[1], max[3], os.date(dateFormat, max[2])
                    )
                end
            end

            local msg = string.format(
                "^7Longest reviving spree: %s^7 with %d revives!%s",
                client[reviveSpree["maxId"]]["name"], reviveSpree["maxSpree"], longest
            )

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay \"" .. msg .. "^7\"\n")
        end

        -- Save server records if enabled.
        if reviveSpree["srvRecord"] == 1 then
            saveReviveSpreeStats("rspree-records.txt", reviveSpree["serverRecords"])
        end

        removeCallbackFunction("RunFrameEndRound", "checkReviveSpreeRunFrameEndRound")
    end
end

-- Check revive spree.
--  medic is the medic client slot id.
--  zombie is the revived client slot id.
--  tk is kill type of the revived client.
function checkReviveSpree(medic, zombie, tk)
    -- Display revive announce
    if reviveSpree["reviveAnnounce"] == 1 then
        sayClients(
            "cpm",
            string.format(
                "%s ^7was revived by %s",
                client[zombie]["name"],
                client[medic]["name"]
            ),
            "reviveSpreeMsg"
        )
    end

    -- not a tk & revive
    if not tk then
        client[medic]["reviveSpree"] = client[medic]["reviveSpree"] + 1

        local guid = string.lower(client[medic]["guid"])

        -- Set server records if enabled.
        if reviveSpree["srvRecord"] == 1 then
            if type(reviveSpree["serverRecords"][guid]) ~= "table" or
                table.getn(reviveSpree["serverRecords"][guid]) ~= 6 then
                reviveSpree["serverRecords"][guid] = {
                    --  multi ; monster ; revive ; nick ; firstseen ; lastseen 
                    0, 0, 0, client[medic]["name"], os.time(), 0
                }
            end

            reviveSpree["serverRecords"][guid][3] = reviveSpree["serverRecords"][guid][3] + 1
            reviveSpree["serverRecords"][guid][6] = os.time()

            -- If guid is seen the first time, insert the nick ... or just 
            -- set u_record_last_nick to 1 in config section to update every time.
            if reviveSpree["recordLastNick"] == 1 or
                reviveSpree["serverRecords"][guid][4] == nil then 
                reviveSpree["serverRecords"][guid][4] = client[medic]["name"]
            end
        end

        -- Check maximum revive spree and set it if needed.
        if client[medic]["reviveSpree"] > reviveSpree["maxSpree"] then
            reviveSpree["maxSpree"] = client[medic]["reviveSpree"]
            reviveSpree["maxId"]    = medic
        end

        -- Check revive spree & display it.
        if reviveSpree["list"][ client[medic]["reviveSpree"] ] then
            local msg = reviveSpree["list"][ client[medic]["reviveSpree"] ]
            msg = string.gsub(msg, "#medic#", client[medic]["name"])
            msg = string.gsub(msg, "#revive#", client[medic]["reviveSpree"])

            sayClients(
                reviveSpree["position"],
                msg,
                "reviveSpreeMsg"
            )
        end
    end
end

-- Callback function when client disconnect.
-- If victim is on revive spree, display revive spree end message.
--  vars is the local vars passed from et_ClientDisconnect function.
function reviveSpreeClientDisconnect(vars)
    if client[vars["clientNum"]]["reviveSpree"] >= 5 then
        checkReviveSpreeEnd(vars["clientNum"], vars["clientNum"])
    end
end

-- Return highest revive spree of map.
-- Exemple:
-- { revive_spree, time, name }
function findMaxReviveSpree() 
    local max = reviveSpree["stats"][mapName]

    if max == nil then
        max = {}
        --max = { 0, 0, nil }
    end

    return max
end

-- Save revive spree stats / record file.
--  file is the file name to write.
--  list is the array data to write in file.
function saveReviveSpreeStats(file, list) 
    local funcStart = et.trap_Milliseconds()
    local fd, len = et.trap_FS_FOpenFile(file, et.FS_WRITE)

    if len == -1 then
        et.G_Printf("uMod WARNING: failed to open %s", file)
    else
        local head = string.format("# %s, written %s\n", file, os.date())

        et.trap_FS_Write(head, string.len(head), fd)

        for first, arr in pairs(list) do
            local line = first .. ";" .. table.concat(arr, ";") .. "\n"

            et.trap_FS_Write(line, string.len(line), fd) 
            -- FIXME: check for errors (i.e. ENOSPACE or sth like that)?
        end

        et.trap_FS_FCloseFile(fd)
    end

    et.G_Printf("uMod WARNING: saveReviveSpreeStats(): %d ms\n", et.trap_Milliseconds() - funcStart)
end

-- Check & return result if it's a new revive spree map record.
--  clientNum is the client slot id.
function checkReviveSpreeRecord(clientNum)
    if reviveSpree["maxId"] == clientNum and
        client[clientNum]["reviveSpree"] == reviveSpree["maxSpree"] then 
        -- hmm... reviveSpree["maxId"] can't be nil here... it's at least 1
        local max = findMaxReviveSpree() -- max = { count, date, name }

        if (table.getn(max) == 3 and reviveSpree["maxSpree"] > max[1]) or
            table.getn(max) == 0 then
            -- insert max record on death... 
            -- then a player gets the reward, if he disconnects before EOMap

            -- no previous record for this map
            reviveSpree["stats"][mapName] = {
                reviveSpree["maxSpree"], os.time(), client[vars["victim"]]["name"]
            }

            reviveSpree["mapRecord"] = true

            return true
        end
    end
    
    return false
end

-- Check revive spree ended & display if t's a new map record.
--  medic is the slot id of medic who have his revive spree ended.
--  killer is the slot id of medic killer.
function checkReviveSpreeEnd(medic, killer)
    local record     = checkReviveSpreeRecord(medic)
    local killerName = ""
    local msg

    if killer == 1022 then
        msg        = reviveSpree["endMsgByWorld"]
        killerName = "The World"
    else
        if killer ~= medic then
            if client[killer]["team"] ~= client[medic]["team"] then
                msg = reviveSpree["endMsgByEnemy"]
            else
                msg = reviveSpree["endMsgByTeamkill"]
            end
        else
            msg = reviveSpree["endMsgBySelfkill"]
        end

        killerName = client[killer]["name"]
    end

    msg = string.gsub(msg, "#medic#", client[medic]["name"])
    msg = string.gsub(msg, "#revive#", client[medic]["reviveSpree"])
    msg = string.gsub(msg, "#killer#", client[killer]["name"])

    sayClients(
        reviveSpree["position"],
        msg,
        "reviveSpreeMsg"
    )

    if record and killer ~= 1022 then
        sayClients(
            reviveSpree["position"],
            color1 .. "This is a new map record!^7",
            "reviveSpreeMsg"
        )
    end
end

-- Callback function of et_Obituary function.
-- If victim is on revive spree, display revive spree end message.
-- Reset revive spree counter of victim.
--  vars is the local vars of et_Obituary function.
function reviveSpreeObituary(vars)
    if client[vars["victim"]]["reviveSpree"] >= 5 then
        checkReviveSpreeEnd(vars["victim"], vars["killer"])
    end

    client[vars["victim"]]["reviveSpree"] = 0
end

-- Add callback revive spree function.
addCallbackFunction({
    ["InitGame"]              = "reviveSpreeInitGame",
    ["RunFrameEndRound"]      = "checkReviveSpreeRunFrameEndRound",
    ["ClientBegin"]           = "reviveSpreeUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "reviveSpreeUpdateClientUserinfo",
    ["ClientDisconnect"]      = "reviveSpreeClientDisconnect",
    ["Obituary"]              = "reviveSpreeObituary"
})
