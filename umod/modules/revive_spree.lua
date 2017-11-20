----------------
-- Vetinari's rspree.lua 
--
-- $Date: 2007-03-02 13:35:49 +0100 (Fri, 02 Mar 2007) $ 
-- $Id: rspree.lua 181 2007-03-02 12:35:49Z vetinari $
-- $Revision: 181 $
--
--version = "1.2.3"
--
-- read carefully and adjust the lines to fit your needs 
-- between the "-- Config" and "-- END of Config" lines
--
--  Thanks to the Hirntot.org admin [!!!]Harlekin and the [!!!] community
--  for testing on their servers :)
--    

-----------------------------------------------------------
-- Config                                                --
-----------------------------------------------------------
local date_fmt     = "%Y-%m-%d, %H:%M:%S" -- for map record dates, see strftime(3) ;->

local rspree_cmd_enabled = true -- set to false to ignore next line's command

-----------------------------------------------------------
-- END of Config
-----------------------------------------------------------

--
-- don't change anything below, unless you know what you're doing 
--

local teams = { [0]="Spectator", [1]="Axis", [2]="Allies", [3]="Unknown", }



-- Revive spree

-- Global var

--addSlashCommand("client", "ma", {"function", "privateMessageAdminsSlashCommand"})

reviveSpree = {
    ["announceRevives"]         = tonumber(et.trap_Cvar_Get("u_announce_revives")),
    ["reviveColor"]             = et.trap_Cvar_Get("u_revive_color"),
    ["revivePosition"]          = et.trap_Cvar_Get("u_revive_pos"),
    ["reviveSpreePosition"]     = et.trap_Cvar_Get("u_revive_spree_pos"),
    ["reviveSpreeColor"]        = et.trap_Cvar_Get("u_revive_spree_color"),
    ["multiRevive"]             = tonumber(et.trap_Cvar_Get("u_multi_revive")),
    ["multiReviveAnnounce"]     = tonumber(et.trap_Cvar_Get("u_multi_revive_announce")),
    ["multiReviveSound"]        = tonumber(et.trap_Cvar_Get("u_multi_revive_sound")),
    ["multiRevivePosition"]     = et.trap_Cvar_Get("u_multi_revive_pos"),
    ["monsterRevivePosition"]   = et.trap_Cvar_Get("u_monster_revive_pos"),
    ["multiReviveMsg"]          = et.trap_Cvar_Get("u_multi_revive_msg"),
    ["monsterReviveMsg"]        = et.trap_Cvar_Get("u_monster_revive_msg"),
    ["multiReviveWithoutDeath"] = tonumber(et.trap_Cvar_Get("u_multi_revive_without_death")),
    ["allowTkRevive"]           = tonumber(et.trap_Cvar_Get("u_allow_tk_revive")),
    ["recordLastNick"]          = tonumber(et.trap_Cvar_Get("u_record_last_nick")),
    ["recordsExpire"]           = 60 * 60 * 24 * tonumber(et.trap_Cvar_Get("u_records_expire")),
    ["saveAwards"]              = tonumber(et.trap_Cvar_Get("u_save_awards")),
    ["srvRecord"]               = tonumber(et.trap_Cvar_Get("u_srv_record")),
    ["amount1"]                 = tonumber(et.trap_Cvar_Get("u_revivespree1_amount")),
    ["amount2"]                 = tonumber(et.trap_Cvar_Get("u_revivespree2_amount")),
    ["amount3"]                 = tonumber(et.trap_Cvar_Get("u_revivespree3_amount")),
    ["amount4"]                 = tonumber(et.trap_Cvar_Get("u_revivespree4_amount")),
    ["amount5"]                 = tonumber(et.trap_Cvar_Get("u_revivespree5_amount")),
    ["amount6"]                 = tonumber(et.trap_Cvar_Get("u_revivespree6_amount")),
    ["amount7"]                 = tonumber(et.trap_Cvar_Get("u_revivespree7_amount")),
    ["message1"]                = et.trap_Cvar_Get("u_rs_message1"),
    ["message2"]                = et.trap_Cvar_Get("u_rs_message2"),
    ["message3"]                = et.trap_Cvar_Get("u_rs_message3"),
    ["message4"]                = et.trap_Cvar_Get("u_rs_message4"),
    ["message5"]                = et.trap_Cvar_Get("u_rs_message5"),
    ["message6"]                = et.trap_Cvar_Get("u_rs_message6"),
    ["message7"]                = et.trap_Cvar_Get("u_rs_message7"),
    ["msgDefault"]              = tonumber(et.trap_Cvar_Get("u_msg_default")),
    ["maxSpree"]                = 0,
    ["maxId"]                   = nil,
    ["stats"]                   = {},
    ["mapRecord"]               = false,
    ["endOfMap"]                = false,
    ["endOfMapDone"]            = false,
    ["serverRecords"]           = {}
}

-- Set default client data.
clientDefaultData["reviveSpree"]    = 0
clientDefaultData["lastReviveTime"] = 0
clientDefaultData["multiRevive"]    = 0
clientDefaultData["reviveSpreeMsg"] = 0

-- Set module command.
if rspree_cmd_enabled then
    cmdList["client"]["!spree_record"] = "/command/client/revive_sprees_record.lua"
end

if reviveSpree["srvRecord"] == 1 then
    cmdList["client"]["!rsprees"] = "/command/both/revive_sprees_record.lua"
end

if reviveSpree["srvRecord"] == 1 then
    cmdList["client"]["!stats"] = "/command/client/revive_sprees_stats.lua"
end

cmdList["console"]["!rsprees"]       = "/command/console/revive_sprees.lua"
cmdList["console"]["!rspreesall"]    = "/command/console/revive_sprees_all.lua"
cmdList["console"]["!rspreerecords"] = "/command/both/revive_sprees_record.lua"

addSlashCommand("client", "rsprees", {"function", "reviveSpreeSlashCommand"})


-- Function

function teamName(t) 
    if t < 0 or t > 3 then
        t = 3
    end

    return teams[t]
end

function findMaxSpree() 
    local max = reviveSpree["stats"][mapName]

    if max == nil then
        max = {}
    end

    return max
end

function readStats() 
    local func_start = et.trap_Milliseconds()
    local count      = 0

    local fd, len = et.trap_FS_FOpenFile("revivingspree.txt", et.FS_READ)

    if len == -1 then
        et.G_Print("Failed to open revivingspree.txt ...")
        et.G_Printf("rspree.lua: readStats(): %d ms\n", et.trap_Milliseconds() - func_start)
        return 0
    end

    local str = et.trap_FS_Read(fd, len)
    et.trap_FS_FCloseFile(fd)
    local map, spree, time, nick

    for map, spree, time, nick in string.gfind(str, "([^;#\n]+)%;(%d+)%;(%d+)%;([^%\n]+)") do
        -- et.G_Printf("'%s;%s;%s;%s'\n", map, spree, time, nick);
        reviveSpree["stats"][map] = {
                            tonumber(spree),
                            tonumber(time),
                            nick
                         }
        count = count + 1
    end

    et.G_Printf("rspree.lua: readStats(): %d ms\n", et.trap_Milliseconds() - func_start)
    return count
end

function saveStats(file, list) 
    local func_start = et.trap_Milliseconds()
    local fd, len = et.trap_FS_FOpenFile(file, et.FS_WRITE)

    if len == -1 then
        et.G_Printf("rspree.lua: failed to open %s", file)
        et.G_Printf("rspree.lua: saveStats(): %d ms\n", et.trap_Milliseconds() - func_start)
        return 0
    end

    local head = string.format("# %s, written %s\n", file, os.date())
    et.trap_FS_Write(head, string.len(head), fd)

    for first, arr in pairs(list) do
        local line = first .. ";".. table.concat(arr, ";").."\n"
        et.trap_FS_Write(line, string.len(line), fd) 
        -- FIXME: check for errors (i.e. ENOSPACE or sth like that)?
    end

    et.trap_FS_FCloseFile(fd)
    et.G_Printf("rspree.lua: saveStats(): %d ms\n", et.trap_Milliseconds() - func_start)
end

function readRecords() 
    local func_start = et.trap_Milliseconds()
    local count      = 0

    local fd, len = et.trap_FS_FOpenFile("rspree-records.txt", et.FS_READ)

    if len == -1 then
        et.G_Print("Failed to open rspree-records.txt ...")
        et.G_Printf("rspree.lua: readRecords(): %d ms\n", et.trap_Milliseconds() - func_start)
        return 0
    end

    local str = et.trap_FS_Read(fd, len)
    et.trap_FS_FCloseFile(fd)

    local guid, multi, monster, revive, nick, firstseen, lastseen
    local now      = tonumber(os.date("%s"))
    local exp_diff = now - reviveSpree["recordsExpire"]

    for guid, multi, monster, revive, nick, firstseen, lastseen in string.gfind(str, "[^%#](%x+)%;(%d*)%;(%d*)%;(%d*)%;([^;]*)%;(%d*)%;([^%\n]*)") do
        lastseen = tonumber(lastseen)

        if (reviveSpree["recordsExpire"] == 0) or (exp_diff < lastseen) then
            reviveSpree["serverRecords"][guid] = {
                                    tonumber(multi), 
                                    tonumber(monster),
                                    tonumber(revive),
                                    nick,
                                    tonumber(firstseen),
                                    lastseen
                                }
            count = count + 1
        end
    end

    et.G_Printf("rspree.lua: readRecords(): %d ms\n", et.trap_Milliseconds() - func_start)
    return count
end

function checkMultiRevive(id, guid)
    -- the multi/monster revive logic below was "stolen" from etadmin_mod.pl
    -- multi revive   = 3 revives in a row with max 3 seconds 
    --                    between each revive
    -- monster revive = 5 revives in a row with max 3 seconds 
    --                    between each revive
    local lvltime = et.trap_Milliseconds()

    if (lvltime - client[id]["lastReviveTime"]) < 3000 then
        client[id]["multiRevive"] = client[id]["multiRevive"] + 1 

        if client[id]["multiRevive"] == 3 then
            et.G_Printf("Multirevive: %d (%s)\n", id, client[id]["name"])

            if reviveSpree["multiReviveAnnounce"] == 1 then
                sayClients(
                    reviveSpree["multiRevivePosition"],
                    string.format(reviveSpree["multiReviveMsg"], client[id]["name"]),
                    "reviveSpreeMsg"
                )
            end

            if reviveSpree["multiReviveSound"] == 1 then
                local soundFile = "sound/misc/multirevive.wav"

                if noiseReduction == 1 then
                    playSound(soundFile, "reviveSpreeMsg", id)
                else
                    playSound(soundFile, "reviveSpreeMsg")
                end
            end
       
            if reviveSpree["srvRecord"] == 1 then
                reviveSpree["serverRecords"][guid][1] = reviveSpree["serverRecords"][guid][1] + 1
            end

        elseif client[id]["multiRevive"] == 5 then
            et.G_Printf("Monsterrevive: %d (%s)\n", id, client[id]["name"])

            if reviveSpree["multiReviveAnnounce"] == 1 then
                sayClients(
                    reviveSpree["monsterRevivePosition"],
                    string.format(reviveSpree["monsterReviveMsg"], client[id]["name"]),
                    "reviveSpreeMsg"
                )
            end

            if reviveSpree["multiReviveSound"] == 1 then
                local soundFile = "sound/misc/monsterrevive.wav"

                if noiseReduction == 1 then
                    playSound(soundFile, "reviveSpreeMsg", id)
                else
                    playSound(soundFile, "reviveSpreeMsg")
                end
            end

            if reviveSpree["srvRecord"] == 1 then
                reviveSpree["serverRecords"][guid][2] = reviveSpree["serverRecords"][guid][2] + 1
            end

            if reviveSpree["saveAwards"] == 1 then
                local fd,len = et.trap_FS_FOpenFile("awards.txt", et.FS_APPEND)

                if len == -1 then
                    et.G_Printf("failed to save monsterrevive award for %s\n", client[id]["name"])
                else
                    local msg = client[id]["name"] .. " - Monsterrevive- " .. os.date() .. "\n"
                    et.trap_FS_Write(msg, string.len(msg), fd)
                    et.trap_FS_FCloseFile(fd)
                end
            end
        end
    else
        client[id]["multiRevive"] = 1
    end

    client[id]["lastReviveTime"] = lvltime
end

function resetMulti(id) 
    client[id]["multiRevive"]    = 0
    client[id]["lastReviveTime"] = 0
end

function resetSpree(id)
    client[id]["reviveSpree"] = 0
end

function checkSprees(id) 
    -- et.G_Printf("checkSprees %d\n", id)
    if client[id]["reviveSpree"] ~= 0 then
        local msg

        if reviveSpree["amount1"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message1"]
        elseif reviveSpree["amount2"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message2"]
        elseif reviveSpree["amount3"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message3"]
        elseif reviveSpree["amount4"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message4"]
        elseif reviveSpree["amount5"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message5"]
        elseif reviveSpree["amount6"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message6"]
        elseif reviveSpree["amount7"] == client[id]["reviveSpree"] then
            msg = reviveSpree["message7"]
        end

        if msg ~= nil then
            sayClients(
                reviveSpree["reviveSpreePosition"],
                string.format(
                    "%s^%s %s (^7%d^%s revives in a row)",
                    client[id]["name"], reviveSpree["reviveSpreeColor"],
                    msg,
                    client[id]["reviveSpree"],
                    reviveSpree["reviveSpreeColor"]
                ),
                "reviveSpreeMsg"
            )
        end
    end
end 

function checkSpreeEnd(id, killer, normal_kill)
    if client[id]["reviveSpree"] > 0 then
        local medicName = client[id]["name"]

        if medicName == "" then
            -- this only happens if a player leaves / disconnects
            -- while on a spree. Fill with something, an empty player
            -- name just looks weird ;-)
            medicName = "(disconnected)" 
        end

        local record = false
        local msg    = ""

        if reviveSpree["maxId"] == id and client[id]["reviveSpree"] == reviveSpree["maxSpree"] then 
            -- hmm... reviveSpree["maxId"] can't be nil here... it's at least 1
            local max = findMaxSpree() -- max = { count, date, name }

            if table.getn(max) == 3 and reviveSpree["maxSpree"] > max[1] then
                -- insert max record on death... 
                -- then a player gets the reward, if he disconnects before EOMap
                reviveSpree["stats"][mapName] = { reviveSpree["maxSpree"], os.date("%s"), medicName } 
                reviveSpree["mapRecord"]      = true
                record                        = true
            elseif table.getn(max) == 0 then -- no previous record for this map
                reviveSpree["stats"][mapName] = { reviveSpree["maxSpree"], os.date("%s"), medicName }
                reviveSpree["mapRecord"]      = true
                record                        = true
            end
        end

        if client[id]["reviveSpree"] >= 5 then
            if normal_kill then -- i.e. no TK or suicide
                local killerName = ""

                if killer == 1022 then
                    killerName = "End of round"
                elseif killer == 1023 then
                    killerName = "unknown reasons"
                else
                    killerName = client[killer]["name"]
                end

                sayClients(
                    reviveSpree["reviveSpreePosition"],
                    string.format(
                        "%s^%s's reviving spree ended (^7%d^%s revives), killed by ^7%s^%s!",
                        medicName,
                        reviveSpree["reviveSpreeColor"],
                        client[id]["reviveSpree"],
                        reviveSpree["reviveSpreeColor"],
                        killerName,
                        reviveSpree["reviveSpreeColor"]
                    ),
                    "reviveSpreeMsg"
                )

                if record then
                    sayClients(
                        reviveSpree["reviveSpreePosition"],
                        "^" .. reviveSpree["reviveSpreeColor"] .. "This is a new map record!^7",
                        "reviveSpreeMsg"
                    )
                end
            else
                if record and killer <= clientsLimit + 1 then
                    sayClients(
                        reviveSpree["reviveSpreePosition"],
                        string.format(
                            "%s^%s's reviving spree ended (^7%d^%s revives).",
                            medicName,
                            reviveSpree["reviveSpreeColor"],
                            client[id]["reviveSpree"],
                            reviveSpree["reviveSpreeColor"]
                        ),
                        "reviveSpreeMsg"
                    )

                    sayClients(
                        reviveSpree["reviveSpreePosition"],
                        "^" .. reviveSpree["reviveSpreeColor"] .. "This is a new map record!^7",
                        "reviveSpreeMsg"
                    )
                end
            end
        end
    end
end

function setRSpreeMsg(id, value)
    client[id]["reviveSpreeMsg"] = value
    et.trap_SetUserinfo(id, et.Info_SetValueForKey(et.trap_GetUserinfo(id), "v_rsprees", value))
end



-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function reviveSpreeInitGame(vars)
    local func_start = et.trap_Milliseconds()

    --et.RegisterModname("rspree.lua"..version.." "..et.FindSelf())

    local i = 0

    --et.G_Printf("rspree.lua: running on map '%s'\n", mapName)

    i = readStats()
    et.G_Printf("rspree.lua: loaded %d alltime stats from revivingspree.txt\n", i)

    if reviveSpree["srvRecord"] == 1 then
        i = readRecords()
        et.G_Printf("rspree.lua: loaded %d alltime records from rspree-records.txt\n", i)
    end

    --et.trap_SendConsoleCommand(et.EXEC_NOW, "sets RSpree_mod_version "..version)
    et.G_Printf("rspree.lua: startup: %d ms\n", et.trap_Milliseconds() - func_start)
    --et.G_Printf("Vetinari's rspree.lua version "..version.." activated...\n")
end

-- Callback function whenever the server or qagame prints a string to the console.
--  vars is the local vars of et_Print function.
function checkReviveSpreePrint(vars)
    if vars["arg"][1] == "Medic_Revive:" then
    --if medic ~= nil and zombie ~= nil then
        medic  = tonumber(vars["arg"][2])
        zombie = tonumber(vars["arg"][3])

        if reviveSpree["announceRevives"] == 1 then
            sayClients(
                reviveSpree["revivePosition"],
                string.format(
                    "%s ^%s was revived by ^7%s",
                    client[zombie]["name"],
                    reviveSpree["reviveColor"],
                    client[medic]["name"]
                ),
                "reviveSpreeMsg"
            )
        end

        if et.gentity_get(zombie, "enemy") == medic then -- tk&revive
            if reviveSpree["allowTkRevive"] == 1 and client[medic]["multiRevive"] > 0 then
                client[medic]["lastReviveTime"] = et.trap_Milliseconds()
            end
        else -- not a tk&revive
            client[medic]["reviveSpree"] = client[medic]["reviveSpree"] + 1
            local guid = string.lower(client[medic]["guid"])

            if reviveSpree["srvRecord"] == 1 then
                if type(reviveSpree["serverRecords"][guid]) ~= "table" then
                    --  guid;    multi;monster;revive;nick;firstseen;lastseen
                    reviveSpree["serverRecords"][guid] = { 0, 0, 0, client[medic]["name"], tonumber(os.date("%s")), 0 }
                elseif table.getn(reviveSpree["serverRecords"][guid]) ~= 6 then
                    --  guid;    multi;monster;revive;nick;firstseen;lastseen 
                    reviveSpree["serverRecords"][guid] = { 0, 0, 0, client[medic]["name"], tonumber(os.date("%s")), 0 }
                end

                reviveSpree["serverRecords"][guid][3] = reviveSpree["serverRecords"][guid][3] + 1
                reviveSpree["serverRecords"][guid][6] = tonumber(os.date("%s"))
                -- if guid is seen the first time, insert the nick ... or just 
                -- set k_record_last_nick to 1 in config section to update
                -- every time
                if reviveSpree["recordLastNick"] == 1 or (reviveSpree["serverRecords"][guid][4] == nil) then 
                    reviveSpree["serverRecords"][guid][4] = client[medic]["name"]
                end
            end

            if client[medic]["reviveSpree"] > reviveSpree["maxSpree"] then
                reviveSpree["maxSpree"] = client[medic]["reviveSpree"]
                reviveSpree["maxId"]    = medic
            end

            if reviveSpree["multiRevive"] == 1 then
                checkMultiRevive(medic, guid)
            end

            checkSprees(medic)
        end
        return nil
    end -- END if medic ~= nil and zombie ~= nil then

    if reviveSpree["endOfMap"] and vars["arg"][1] == "WeaponStats:" then
        if not reviveSpree["endOfMapDone"] then
            if reviveSpree["maxId"] ~= nil then -- unlikely, but you never know ... :)
                local longest = ""
                local max     = findMaxSpree() -- max = { count, date, name }

                if table.getn(max) == 3 then 
                    if reviveSpree["mapRecord"] then
                        longest = " ^"..reviveSpree["reviveSpreeColor"].."This is a New map record!"
                        saveStats("revivingspree.txt", reviveSpree["stats"])
                    else 
                        longest = string.format(" ^7[record: %d by %s^7 @%s]", max[1], max[3], os.date(date_fmt, max[2]))
                    end
                end

                local msg = string.format("^7Longest reviving spree: %s^7 with %d revives!%s", client[reviveSpree["maxId"]]["name"], reviveSpree["maxSpree"], longest)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay \""..msg.."^7\"\n")
            end

            if reviveSpree["srvRecord"] == 1 then
                saveStats("rspree-records.txt", reviveSpree["serverRecords"])
            end

            reviveSpree["endOfMapDone"] = true
        end

        return nil
    end -- END if reviveSpree["endOfMap"] and string.find(vars["text"], "^WeaponStats: ") == 1 then

    if vars["text"] == "Exit: Timelimit hit.\n" or vars["text"] == "Exit: Wolf EndRound.\n" then
        reviveSpree["endOfMap"] = true

        for i = 0, clientsLimit do
            if client[i]["reviveSpree"] ~= nil and client[i]["reviveSpree"] > 0 then
                checkSpreeEnd(i, 1022, true)
            end
        end

        return nil
    end
end

function reviveSpreeObituary(vars)
    -- yes, very unlikely, but you can revive, die, get revived and do 
    -- another revive within 3 secs....
    -- hmm... probably it's worth a possible multi/monster revive if
    -- you manage to do that, so let the admin decide if it's honoured
    if reviveSpree["multiReviveWithoutDeath"] == 1 then
        resetMulti(vars["victim"])
    end

    if vars["victim"] ~= vars["killer"] and client[vars["victim"]]["team"] ~= client[vars["killer"]]["team"] then
        if vars["killer"] <= clientsLimit + 1 then
            checkSpreeEnd(vars["victim"], vars["killer"], true)
        else
            checkSpreeEnd(vars["victim"], vars["killer"], false)
        end

        resetSpree(vars["victim"])
    end
end

function reviveSpreeObituarySelfKill(vars)
    checkSpreeEnd(vars["victim"], vars["killer"], false)
    resetSpree(vars["victim"])
end

function reviveSpreeObituaryTeamKill(vars)
    checkSpreeEnd(vars["victim"], vars["killer"], false)
    resetSpree(vars["victim"])
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function reviveSpreeSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["reviveSpreeMsg"] == 0 then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(rsprees):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setRSpreeMsg(params.clientNum, 0)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(rsprees):^7 Messages are now ^8off^7\"")
    else
        setRSpreeMsg(params.clientNum, 1)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(rsprees):^7 Messages are now ^8on^7\"")
    end

    return 1
end

function reviveSpreeUpdateClientUserinfo(vars)
    local rs = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "v_rsprees")

    if rs == "" then
        setRSpreeMsg(vars["clientNum"], reviveSpree["msgDefault"])
    elseif tonumber(rs) == 0 then
        client[vars["clientNum"]]["reviveSpreeMsg"] = 0
    else
        client[vars["clientNum"]]["reviveSpreeMsg"] = 1
    end
end

-- Add callback revive spree function.
addCallbackFunction({
    ["InitGame"]              = "reviveSpreeInitGame",
    ["ClientBegin"]           = "reviveSpreeUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "reviveSpreeUpdateClientUserinfo",
    ["ObituaryTeamKill"]      = "reviveSpreeObituaryTeamKill",
    ["ObituarySelfKill"]      = "reviveSpreeObituarySelfKill",
    ["Obituary"]              = "reviveSpreeObituary",
    ["Print"]                 = "checkReviveSpreePrint"
})
