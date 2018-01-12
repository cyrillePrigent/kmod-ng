
-- Change this to your desired prefix
cmdPrefix = "!"

-- Global vars

version       = "0.1"
releaseStatus = "alpha"

-- Load Uber Mod cvar
autoPanzerDisable     = tonumber(et.trap_Cvar_Get("u_auto_panzer_disable"))
panzersPerTeam        = tonumber(et.trap_Cvar_Get("team_maxpanzers")) -- et-legacy : team_maxPanzers
advancedPm            = tonumber(et.trap_Cvar_Get("u_advanced_pm"))
pmSound               = et.trap_Cvar_Get("u_pm_sound")
selfkillMode          = tonumber(et.trap_Cvar_Get("u_selfkill_mode"))
--dateFormat            = et.trap_Cvar_Get("u_date_format")
spectatorInactivity   = tonumber(et.trap_Cvar_Get("g_spectatorInactivity")) -- et-legacy : ???
mapName               = et.trap_Cvar_Get("mapname")
muteModule            = tonumber(et.trap_Cvar_Get("u_mute_module"))
curseMode             = tonumber(et.trap_Cvar_Get("u_cursemode"))
logChatModule         = tonumber(et.trap_Cvar_Get("u_log_chat"))
landminesLimitModule  = tonumber(et.trap_Cvar_Get("u_landmines_limit"))
killingSpreeModule    = tonumber(et.trap_Cvar_Get("u_killing_spree"))
spreeRecordModule     = tonumber(et.trap_Cvar_Get("u_ks_record"))
svMaxClients          = tonumber(et.trap_Cvar_Get("sv_maxclients"))

callbackList = {
    ["ReadConfig"]            = {},
    ["InitGame"]              = {},
    ["ShutdownGame"]          = {},
    ["RunFrame"]              = {},
    ["RunFrameEndRound"]      = {},
    ["ClientConnect"]         = {},
    ["ClientDisconnect"]      = {},
    ["ClientBegin"]           = {},
    ["ClientUserinfoChanged"] = {},
    ["ClientSpawn"]           = {},
    ["ObituaryEnemyKill"]     = {},
    ["ObituarySelfKill"]      = {},
    ["ObituaryTeamKill"]      = {},
    ["ObituaryWorldKill"]     = {},
    ["Obituary"]              = {},
    ["Print"]                 = {}
}

-- Client
clientsLimit = svMaxClients - 1
--_clientsLimit = 0

client = {}

clientDefaultData = {
    ["useAdrenaline"]  = 0,
    ["respawn"]        = 0,
    ["switchTeam"]     = 0,
    ["name"]           = "",
    ["guid"]           = "",
    ["lastName"]       = "",
    ["team"]           = 0,
    ["whoKilledYou"]   = 1022,
    ["yourLastVictim"] = 1022,
    ["killerWeapon"]   = "",
    ["victimWeapon"]   = "",
    ["tkIndex"]        = 0
}

-- Players stats
players = {
    ["allies"]    = 0,
    ["axis"]      = 0,
    ["spectator"] = 0,
    ["active"]    = 0,
    ["total"]     = 0
}

-- Command (client & console)
cmdList = {
    ["client"] = {
        ["!about"]             = "/command/client/about.lua",
        ["!admintest"]         = "/command/client/admintest.lua",
        ["!time"]              = "/command/client/time.lua",
        ["!date"]              = "/command/client/date.lua",
        ["!spec999"]           = "/command/both/spec999.lua",
        ["!specall"]           = "/command/both/specall.lua",
        ["!listcmds"]          = "/command/client/listcmds.lua",
        ["!gib"]               = "/command/both/gib.lua",
        ["!slap"]              = "/command/both/slap.lua",
        ["!burn"]              = "/command/both/burn.lua",
        ["!setlevel"]          = "/command/both/setlevel.lua",
        ["!readconfig"]        = "/command/both/readconfig.lua",
        ["!ban"]               = "/command/client/ban.lua",
        ["!unban"]             = "/command/client/unban.lua",
        ["!getip"]             = "/command/client/getip.lua",
        ["!getguid"]           = "/command/client/getguid.lua",
        ["!makereferee"]       = "/command/client/makereferee.lua",
        ["!removereferee"]     = "/command/client/removereferee.lua",
        ["!gravity"]           = "/command/client/gravity.lua",
        ["!speed"]             = "/command/client/speed.lua",
        ["!knockback"]         = "/command/client/knockback.lua",
        ["!cheats"]            = "/command/client/cheats.lua",
        ["!laser"]             = "/command/client/laser.lua",
        ["!kick"]              = "/command/client/kick.lua",
        ["!warn"]              = "/command/client/warn.lua",
        ["!putspec"]           = "/command/client/putspec.lua",
        ["!putallies"]         = "/command/client/putallies.lua",
        ["!putaxis"]           = "/command/client/putaxis.lua",
        ["!timelimit"]         = "/command/client/timelimit.lua",
        ["!finger"]            = "/command/client/finger.lua",
        ["!goto"]              = "/command/both/goto.lua",
        ["!want"]              = "/command/both/want.lua",
        ["!unmute"]            = "/command/client/unmute.lua",
        ["!mute"]              = "/command/client/mute.lua"
    },
    ["console"] = {
        ["!setlevel"]      = "/command/both/setlevel.lua",
        ["!goto"]          = "/command/both/goto.lua",
        ["!want"]          = "/command/both/want.lua",
        ["!showadmins"]    = "/command/console/showadmins.lua",
        ["!readconfig"]    = "/command/console/readconfig.lua",
        ["!spec999"]       = "/command/both/spec999.lua",
        ["!specall"]       = "/command/both/specall.lua",
        ["!gib"]           = "/command/both/gib.lua",
        ["!slap"]          = "/command/both/slap.lua",
        ["!burn"]          = "/command/both/burn.lua"
    }
}

clientCmdData = {
    ["say"] = {
        ["mode"]   = et.SAY_ALL,
        ["sayCmd"] = "qsay"
    },
    ["say_team"] = {
        ["mode"]   = et.SAY_TEAM,
        ["sayCmd"] = "qsay"
    },
    ["say_buddy"] = {
        ["mode"]   = et.SAY_BUDDY,
        ["sayCmd"] = "qsay"
    },
    ["say_teamnl"] = {
        ["mode"]   = et.SAY_TEAMNL,
        ["sayCmd"] = "qsay"
    },
    ["vsay"] = {
        ["mode"]   = "VSAY_ALL"
    },
    ["vsay_team"] = {
        ["mode"]   = "VSAY_TEAM"
    },
    ["vsay_buddy"] = {
        ["mode"]   = "VSAY_BUDDY"
    }
}

slashCommandClient = {
    ["multiple"] = {},
    ["single"] = {}
}

slashCommandConsole   = {}
slashCommandModuleMsg = {}

meansOfDeathList = {
    [0] = "UNKNOWN",                      -- 0
    "MACHINEGUN",                         -- 1
    "BROWNING",                           -- 2
    "MG42",                               -- 3
    "GRENADE",                            -- 4
    "ROCKET",                             -- 5
    "KNIFE",                              -- 6
    "LUGER",                              -- 7
    "COLT",                               -- 8
    "MP40",                               -- 9
    "THOMPSON",                           -- 10
    "STEN",                               -- 11
    "GARAND",                             -- 12
    "SNOOPERSCOPE",                       -- 13
    "SILENCER",                           -- 14
    "FG42",                               -- 15
    "FG42SCOPE",                          -- 16
    "PANZERFAUST",                        -- 17
    "GRENADE_LAUNCHER",                   -- 18
    "FLAMETHROWER",                       -- 19
    "GRENADE_PINEAPPLE",                  -- 20
    "CROSS",                              -- 21
    "MAPMORTAR",                          -- 22
    "MAPMORTAR_SPLASH",                   -- 23
    "KICKED",                             -- 24
    "GRABBER",                            -- 25
    "DYNAMITE",                           -- 26
    "AIRSTRIKE",                          -- 27
    "SYRINGE",                            -- 28
    "AMMO",                               -- 29
    "ARTY",                               -- 30
    "WATER",                              -- 31
    "SLIME",                              -- 32
    "LAVA",                               -- 33
    "CRUSH",                              -- 34
    "TELEFRAG",                           -- 35
    "FALLING",                            -- 36
    "SUICIDE",                            -- 37
    "TARGET_LASER",                       -- 38
    "TRIGGER_HURT",                       -- 39
    "EXPLOSIVE",                          -- 40
    "CARBINE",                            -- 41
    "KAR98",                              -- 42
    "GPG40",                              -- 43
    "M7",                                 -- 44
    "LANDMINE",                           -- 45
    "SATCHEL",                            -- 46
    "TRIPMINE",                           -- 47
    "SMOKEBOMB",                          -- 48
    "MOBILE_MG42",                        -- 49
    "SILENCED_COLT",                      -- 50
    "GARAND_SCOPE",                       -- 51
    "CRUSH_CONSTRUCTION",                 -- 52
    "CRUSH_CONSTRUCTIONDEATH",            -- 53
    "CRUSH_CONSTRUCTIONDEATH_NOATTACKER", -- 54
    "K43",                                -- 55
    "K43_SCOPE",                          -- 56
    "MORTAR",                             -- 57
    "AKIMBO_COLT",                        -- 58
    "AKIMBO_LUGER",                       -- 59
    "AKIMBO_SILENCEDCOLT",                -- 60
    "AKIMBO_SILENCEDLUGER",               -- 61
    "SMOKEGRENADE",                       -- 62
    "SWAP_SPACES",                        -- 63
    "SWITCH_TEAM"                         -- 64
}

game = {
    ["paused"]            = false,
    ["state"]             = 0,
    ["endRoundTrigger"]   = false,
    ["firstFrameTrigger"] = false
}

time = {
    ["trigger"] = false,
    ["init"]    = 0,
    ["frame"]   = 0,
    ["counter"] = 0,
}

timedv1 = 0
timedv2 = 0

pause = {
    ["time"]         = 0,
    ["dummyTime"]    = 0,
    ["startTrigger"] = false,
    ["endTrigger"]   = false
}

-- Colorization

-- Color of general text
color1 = "^7"

-- Color of command word
color2 = "^3"

-- Color of special text (command status, date, etc)
color3 = "^8"

-- Color of warning text
color4 = "^1"

-- Punkbuster status before disable it.
pbState = false

dateFormat = "%Y-%m-%d, %H:%M:%S" -- for map record dates, see strftime(3) ;->

--floodprotect = 0

-- **********************************************

-- Under etpro mod :
--  fs_homepath (default win xp) : 
--  fs_homepath (default gnu/linux) : /home/$USER/.etwolf  with logued user
--  fs_homepath (default gnu/linux) : /root/.etwolf        with root

--  fs_game : etpro
--  fs_basegame : 
--  gamename : etpro
--  mod_version : 3.2.6
--  mod_url = http://etpro.anime.net/
--  lua version 5.0.2

-- **********************************************

-- Under et-legacy :
--  fs_homepath (default win xp) : 
--  fs_homepath (default gnu/linux) : 

--  fs_game : legacy
--  fs_basegame : 
--  gamename : legacy
--  mod_version : 
--  mod_url = www.etlegacy.com
--  lua version 5.3

-- **********************************************

-- Store a settings function list in main callback function list.
--  settings is the function list to set.
function addCallbackFunction(settings)
    for callbackType, functionName in pairs(settings) do
        if type(_G[functionName]) == "function" then
            if callbackList[callbackType] ~= nil then
                table.insert(callbackList[callbackType], functionName)
            else
                et.G_LogPrint("ERROR addCallbackFunction : CallbackType " .. callbackType .. " don't exist!\n")
            end
        else
            et.G_LogPrint("ERROR addCallbackFunction : Function " .. functionName .. " don't exist!\n")
        end
    end
end

-- Remove a function in main callback function list.
--  callbackType is the callback type list to remove.
--  removeName is the function / file name to remove.
function removeCallbackFunction(callbackType, removeFunctionName)
    if callbackList[callbackType] ~= nil then
        for key, functionName in pairs(callbackList[callbackType]) do
            if functionName == removeFunctionName then
                callbackList[callbackType][key] = nil
                break
            end
        end
    else
        et.G_LogPrint("ERROR removeCallbackFunction : CallbackType " .. callbackType .. " don't exist!\n")
    end
end

-- Execute callback function list of callback type.
--  callbackType is the callback type list to execute.
--  vars is the local vars passed to callback function.
function executeCallbackFunction(callbackType, vars)
    local result
    
    if callbackList[callbackType] ~= nil then
        for _, functionName in pairs(callbackList[callbackType]) do
            result = _G[functionName](vars)

            if result then
                return result
            end
        end
    else
        et.G_LogPrint("ERROR executeCallbackFunction : CallbackType " .. callbackType .. " don't exist!\n")
    end
end

-- Check client and return this slot id.
--  client can be :
--   * A slot id
--   * Partial / complete player name (two character minimum)
--  params is parameters passed to the function executed in command file.
function client2id(client, params)
    local clientNum = tonumber(client)

    if clientNum then
        if clientNum >= 0 and clientNum < clientsLimit then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                if params ~= nil then
                    printCmdMsg(params, "There is no client associated with this slot number\n")
                end

                return nil
            end
        else
            if params ~= nil then
                printCmdMsg(params, "Please enter a slot number between 0 and " .. clientsLimit .. "\n")
            end

            return nil
        end
    else
        local client = et.Q_CleanStr(client)

        if client then
            if string.len(client) <= 2 then
                if params ~= nil then
                    printCmdMsg(params, "Player name requires more than 2 characters\n")
                end

                return nil
            else
                clientNum = getPlayernameToId(client, params)
            end
        end

        if not clientNum then
            if params ~= nil then
                printCmdMsg(params, "Try name again or use slot number\n")
            end

            return nil
        end
    end

    return clientNum
end

-- Split string in word table and return it.
--  inputString is the string to split.
function splitWord(inputString)
    local i = 1
    local t = {}

    for w in string.gfind(inputString, "([^%s]+)%s*") do
        t[i] = w
        i = i + 1
    end

    return t
end

-- Strip whitespace (or other characters) from the beginning and end of a string.
-- From minipb by Hadro
--  str is the string to trim.
function trim(str)
    local result, _ = string.gsub(str, "^%s*(.-)%s*$", "%1")

    return result
end

-- Check if a certain player is connected and return his slot id.
--  name is partial / complete player name (two character minimum) to search.
--  params is parameters passed to the function executed in command file.
function getPlayernameToId(name, params)
    local slot       = nil
    local matchCount = 0
    local cleanName  = string.lower(trim(et.Q_CleanStr(name)))

    for p = 0, clientsLimit, 1 do
        local searchCleanName = string.lower(trim(et.Q_CleanStr(client[p]["name"])))
        
        if cleanName == searchCleanName then
            matchCount = 0
            slot       = p
            break
        end

        s, e = string.find(searchCleanName, cleanName)

        if s and e then
            matchCount = matchCount + 1
            slot = p
        end
    end

    if matchCount >= 2 then
        if params ~= nil then
            printCmdMsg(
                params,
                "There are currently " .. color4 .. matchCount .. color1 ..
                " client\[s\] that match \"" .. name .. "\"\n"
            )
        end

        return nil
    else
        return slot
    end
end

-- Manage client / console message displaying.
--  params is parameters passed to the function executed in command file.
--  msg is the message content.
function printCmdMsg(params, msg)
    if params.cmdMode == "console" then
        et.G_Print(msg)
        
        if params.broadcast2allClients then
            local cmd = ""

            if not params.noDisplayCmd then
                cmd = params.cmd
                cmd = string.gsub(cmd, "^" .. cmdPrefix .. "%l", string.upper)
                cmd = color2 .. cmd .. ": "
            end

            et.trap_SendServerCommand(
                -1,
                params.say .. " \"" .. cmd .. color1 .. msg .. "\""
            )
        end
    elseif params.cmdMode == "client" then
        if params.displayInConsole then
            et.trap_SendServerCommand(params.clientNum, "print \"" .. msg .. "\"")
        else
            local clientNum = -1
            local cmd       = ""

            if not params.noDisplayCmd then
                cmd = params.bangCmd or params.cmd
                cmd = string.gsub(cmd, "^" .. cmdPrefix .. "%l", string.upper)
                cmd = color2 .. cmd .. ": "
            end

            if not params.broadcast2allClients then
                 clientNum = params.clientNum
            end

            et.trap_SendServerCommand(
                clientNum,
                params.say .. " \"" .. cmd .. color1 .. msg .. "\""
            )
        end
    end
end

-- Check if a command exist and execute his command file.
--  command is command name to execute.
--  params is parameters passed to the function executed in command file.
function runCommandFile(command, params)
    local result    = 0
    execute_command = nil

    if cmdList[params.cmdMode] ~= nil and cmdList[params.cmdMode][command] ~= nil then
        dofile(umod_path .. cmdList[params.cmdMode][command])

        if (type(execute_command) == "function") then
            result          = execute_command(params)
            execute_command = nil
        else
            et.G_LogPrint("ERROR runCommandFile : None `execute_command` function defined in command file\n")
        end
    end

    return result
end

-- Set function / file to execute when a slash command is executed by client.
--  cmdType is the command type (client or console).
--  cmdArg is the slash commande name or table with list of command name.
--  cmdData is the slash command data.
function addSlashCommand(cmdType, cmdArg, cmdData)
    if cmdType == "client" then
        local cmdArgType = type(cmdArg)

        if cmdArgType == "table" then
            local t = _G["slashCommandClient"]["multiple"]

            for _, arg in ipairs(cmdArg) do
                t[arg] = t[arg] or {}
                t = t[arg]
            end

            t = t or {}
            table.insert(t, cmdData)
        elseif cmdArgType == "string" then
            slashCommandClient["single"][cmdArg] = slashCommandClient["single"][cmdArg] or {}
            table.insert(slashCommandClient["single"][cmdArg], cmdData)
        end
    elseif cmdType == "console" then
        slashCommandConsole[cmdArg] = slashCommandConsole[cmdArg] or {}
        table.insert(slashCommandConsole[cmdArg], cmdData)
    end
end

-- Remove function / file of the slash command list.
--  cmdType is the command type (client or console).
--  cmdArg is the slash commande name or table with list of command name.
--  removeName is the function / file name to remove.
function removeSlashCommand(cmdType, cmdArg, removeName)
    if cmdType == "client" then
        local cmdArgType = type(cmdArg)

        if cmdArgType == "table" then
            local t = _G["slashCommandClient"]["multiple"]

            for _, arg in ipairs(cmdArg) do
                if t[arg] then
                    t = t[arg]
                else
                    et.G_LogPrint("ERROR removeSlashCommand : Cannot remove slash command '" .. table.concat(cmdArg, " ") .. "'\n")
                    return
                end
            end

            if t then
                for key, functionName in ipairs(slashCommandClient["single"]) do
                    if functionName == removeName then
                        t[key] = nil
                        break
                    end
                end
            end
        elseif cmdArgType == "string" then
            for key, functionName in ipairs(slashCommandClient["single"]) do
                if functionName == removeName then
                    slashCommandClient["single"][key] = nil
                    break
                end
            end
        end
    elseif cmdType == "console" then
        for key, functionName in ipairs(slashCommandConsole) do
            if functionName == removeName then
                slashCommandConsole[key] = nil
                break
            end
        end
    end
end

-- Execute function / file of slash command called by client.
--  data is the slash command data.
--  params is parameters passed to the function executed the slash command.
function runSlashCommand(data, params)
    local result    = 0
    execute_command = nil

    if data[1] == "function" then
        result = _G[data[2]](params)
    elseif data[1] == "file" then
        dofile(umod_path .. data[2])

        if (type(execute_command) == "function") then
            result          = execute_command(params)
            execute_command = nil
        else
            et.G_LogPrint("ERROR runSlashCommand : None `execute_command` function defined in command file\n")
        end
    else
        et.G_LogPrint("ERROR runSlashCommand : Bad slash command data : " .. tostring(data) .. "\n")
    end

    return result
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function pauseSlashCommand(params)
    if not pause["startTrigger"] then
        game["paused"]     = true
        pause["dummyTime"] = time["frame"]
    end

    return 0
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function unPauseSlashCommand(params)
    -- TODO : Why?
    if params.cmdMode == "client" then
        if pause["startTrigger"] and ((time["frame"] - pause["dummyTime"]) / 1000) >= 5 then
            game["paused"] = false
        end
    elseif params.cmdMode == "console" then
        if pause["startTrigger"] then
            game["paused"] = false
        end
    end

    return 0
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function teamSlashCommand(params)
    local teamSelect = et.trap_Argv(1)

    if client[params.clientNum]["team"] == 3 and (teamSelect == "r" or teamSelect == "b") then
        client[params.clientNum]["switchTeam"] = 1
    end

    return 0
end

function getFormatedDate(dateValue, displayTime)
    local str

    -- dateFormat

    if displayTime then
        str = dateFormat .. ", %H:%M:%S"
    else
        str = dateFormat
    end

    local returnValue, result = pcall(os.date, str, dateValue)

    if returnValue then
        return result
    else
        return os.date(str, dateValue)
    end
end

-- printf wrapper
et.G_Printf = function(...)
    et.G_Print(string.format(unpack(arg)))
end

-- log printf wrapper
et.G_LogPrintf = function(...)
    et.G_LogPrint(string.format(unpack(arg)))
end

-- Kick a player. Use punkbuster if enabled.
--  clientNum is the client slot id.
--  reason is the displayed reason of kick.
--  timeout the the time in minutes to kick the client from the server.
function kick(clientNum, reason, timeout)
    timeout = tonumber(timeout)

    if not timeout then
        timeout = 0
    end

    if reason == "" then
        reason = "Come back in, if you want"
    end

    if tonumber(et.trap_Cvar_Get("sv_punkbuster")) == 1 then
        local pbClient = clientNum + 1

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "pb_sv_kick " .. pbClient .. " " .. timeout .. " " .. reason .. "\n"
        )
    else
        et.trap_DropClient(
            clientNum,
            "Kick reason : " .. reason,
            timeout * 60
        )
    end

    if logChatModule == 1 then
        local time = os.date("%x %I:%M:%S%p")
        local ip   = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip"))
        local guid = string.upper(client[clientNum]["guid"])
        writeLog("(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") KICK for : " .. reason .. "\n")
    end
end

-- Return player ip.
--  clientNum is the client slot id.
function getClientIp(clientNum)
    local ip = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip")
    local _, _, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

    return ip
end

-- Convert time value (in seconds) to readable string with hours, minutes & seconds.
--  value is the time in seconds to convert.
function second2readeableTime(value)
    local str = ""
    local hours = math.floor(value / 3600)
    local mins  = math.floor(value / 60 - hours * 60)
    local secs  = math.floor(value - hours * 3600 - mins * 60)

    if hours > 0 then
        str = hours .. " hours "
    end

    if mins > 0 then
        str = str .. mins .. " mins "
    end

    if secs > 0 then
        return str .. secs .. " secs"
    else
        return trim(str)
    end
end

-- Load modules
local modUrl = et.trap_Cvar_Get("mod_url")

msgCmd = {
    ["chatArea"]   = "chat",
    ["popupArea"]  = "cpm",
    ["centerArea"] = "cp"
}

if modUrl == "http://etpro.anime.net/" then
    etMod = "etpro"

    dofile(umod_path .. "/mods/etpro.lua")
elseif modUrl == "www.etlegacy.com" then
    etMod = "etlegacy"
end

if tonumber(et.trap_Cvar_Get("u_crazygravity")) == 1 then
    dofile(umod_path .. "/modules/crazygravity.lua")
end

if tonumber(et.trap_Cvar_Get("u_game_mode")) == 1 then
    dofile(umod_path .. '/modules/game_mode.lua')
end

if muteModule == 1 then
    dofile(umod_path .. "/modules/mute.lua")
end

if curseMode > 0 then
    dofile(umod_path .. "/modules/curse_filter.lua")
end

if tonumber(et.trap_Cvar_Get("u_disable_votes")) == 1 then
    dofile(umod_path .. "/modules/disable_vote.lua")
end

if tonumber(et.trap_Cvar_Get("u_advanced_adrenaline")) == 1 then
    dofile(umod_path .. "/modules/advanced_adrenaline.lua")
end

if tonumber(et.trap_Cvar_Get("u_advanced_spawn")) == 1 then 
    dofile(umod_path .. "/modules/advanced_spawn.lua")
end

if tonumber(et.trap_Cvar_Get("u_auto_panzer_disable")) == 1 then
    dofile(umod_path .. "/modules/auto_panzer_disable.lua")
end

if selfkillMode == 1 then
    dofile(umod_path .. "/modules/selfkill/disabled.lua")
elseif selfkillMode == 2 then
    dofile(umod_path .. "/modules/selfkill/in_fight.lua")
elseif selfkillMode == 3 then
    dofile(umod_path .. "/modules/selfkill/limit.lua")
end

if logChatModule == 1 then
    dofile(umod_path .. "/modules/log.lua")
end

if killingSpreeModule == 1 or spreeRecordModule == 1 then
    dofile(umod_path .. "/modules/killing_spree.lua")
end

if tonumber(et.trap_Cvar_Get("u_multikill")) == 1 then
    dofile(umod_path .. "/modules/multikill.lua")
end

if tonumber(et.trap_Cvar_Get("u_flak_monkey")) == 1 then
    dofile(umod_path .. "/modules/flak_monkey.lua")
end

if tonumber(et.trap_Cvar_Get("u_death_spree")) == 1 then
    dofile(umod_path .. "/modules/death_spree.lua")
end

if tonumber(et.trap_Cvar_Get("u_teamkill_restriction")) == 1 then
    dofile(umod_path .. "/modules/teamkill_restriction.lua")
end

if tonumber(et.trap_Cvar_Get("u_first_blood")) == 1 then
    dofile(umod_path .. "/modules/first_blood.lua")
end

if tonumber(et.trap_Cvar_Get("u_last_blood")) == 1 then
    dofile(umod_path .. "/modules/last_blood.lua")
end

if tonumber(et.trap_Cvar_Get("u_display_killer_hp")) == 1 then
    dofile(umod_path .. "/modules/display_killer_hp.lua")
end

if tonumber(et.trap_Cvar_Get("u_end_round_shuffle")) == 1 then
    dofile(umod_path .. "/modules/end_round_shuffle.lua")
end

if tonumber(et.trap_Cvar_Get("u_anti_unmute")) == 1 then
    dofile(umod_path .. "/modules/anti_unmute.lua")
end

if advancedPm == 1 then
    dofile(umod_path .. "/modules/advanced_private_message.lua")
end

if tonumber(et.trap_Cvar_Get("u_playsound")) == 1 then
    addSlashCommand("console", "playsound", {"file", "/command/console/playsound.lua"})
    addSlashCommand("console", "playsound_env", {"file", "/command/console/playsound_env.lua"})
end

dofile(umod_path .. "/modules/revive/core.lua")

if tonumber(et.trap_Cvar_Get("u_uneven_team")) == 1 then
    dofile(umod_path .. "/modules/uneven_team.lua")
end

if tonumber(et.trap_Cvar_Get("u_name_stealing_protection")) == 1 then
    dofile(umod_path .. "/modules/name_stealing_protection.lua")
end

if tonumber(et.trap_Cvar_Get("u_birthday")) == 1 then
    dofile(umod_path .. "/modules/birthday.lua")
end

if landminesLimitModule == 1 then
    dofile(umod_path .. "/modules/landmines_limit.lua")
end

if tonumber(et.trap_Cvar_Get("u_dynamite_timer")) == 1 then
    dofile(umod_path .. "/modules/dynamite_timer.lua")
end

if tonumber(et.trap_Cvar_Get("u_disarm")) == 1 then
    dofile(umod_path .. "/modules/disarm.lua")
end

if tonumber(et.trap_Cvar_Get("u_know_guids")) == 1 then
    dofile(umod_path .. "/modules/know_guids.lua")
end

if tonumber(et.trap_Cvar_Get("u_own")) == 1 then
    dofile(umod_path .. "/modules/own.lua")
end

dofile(umod_path .. "/modules/commands.lua")
dofile(umod_path .. "/modules/admins.lua")

addSlashCommand("client", "ma", {"file", "/command/client/private_message_admin.lua"})
addSlashCommand("client", "pma", {"file", "/command/client/private_message_admin.lua"})
addSlashCommand("client", "msga", {"file", "/command/client/private_message_admin.lua"})

addSlashCommand("console", "ma", {"file", "/command/console/private_message_admin.lua"})
addSlashCommand("console", "pma", {"file", "/command/console/private_message_admin.lua"})
addSlashCommand("console", "msga", {"file", "/command/console/private_message_admin.lua"})

if tonumber(et.trap_Cvar_Get("u_advanced_players")) == 1 then
    addSlashCommand("client", "players", {"file", "/command/client/players.lua"})
end

addSlashCommand("client", {"ref", "pause"}, {"function", "pauseSlashCommand"})
addSlashCommand("client", {"ref", "unpause"}, {"function", "unPauseSlashCommand"})
addSlashCommand("client", "team", {"function", "teamSlashCommand"})
addSlashCommand("console", "pause", {"function", "pauseSlashCommand"})
addSlashCommand("console", "unpause", {"function", "unPauseSlashCommand"})

-- Enemy Territory callbacks

-- qagame execution

-- Called when qagame initializes.
--  levelTime is the current level time in milliseconds.
--  randomSeed is a number that can be used to seed random number generators.
--  restart indicates if et_InitGame() is being called due to a map restart (1) or not (0).
function et_InitGame(levelTime, randomSeed, restart)
    time["init"] = levelTime

    -- 1 : warmup, 0 : match
    game["state"] = tonumber(et.trap_Cvar_Get("gamestate"))

    local currentVersion = et.trap_Cvar_Get("mod_version")
    et.RegisterModname("uMod v" .. version .. releaseStatus .. " " .. et.FindSelf())
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar mod_version \"" .. currentVersion .. " - uMod " .. version .. "\"\n")

    for p = 0, clientsLimit, 1 do
        client[p] = {}

        for key, value in pairs(clientDefaultData) do
            client[p][key] = value
        end

        if et.gentity_get(p, "pers.connected") == 2 then
            client[p]["name"] = et.Info_ValueForKey(et.trap_GetUserinfo(p), "name")
        end
    end

    executeCallbackFunction("InitGame", {["levelTime"] = levelTime, ["restart"] = restart})
    executeCallbackFunction("ReadConfig")

    et.G_Print("uMod version " .. version .. " " .. releaseStatus .. " has been initialized...\n")
end

-- Called when qagame shuts down.
--  restart indicates if the shutdown is being called due to a map_restart (1) or not (0).
function et_ShutdownGame(restart)
    executeCallbackFunction("ShutdownGame", {["restart"] = restart})
end

-- Called when qagame runs a server frame.
--  levelTime is the current level time in milliseconds.
function et_RunFrame(levelTime)
    time["frame"] = levelTime

    if time["counter"] == 0 then
        time["counter"] = (time["frame"] - time["init"]) / 1000
    end

    if game["paused"] then
        if not pause["startTrigger"] then
            pause["time"]         = time["frame"]
            pause["startTrigger"] = true
        end

        -- Server is paused for 3 minutes (180 seconds)
        if ((time["frame"] - pause["time"]) / 1000) >= 180 then
            game["paused"] = false
        end
    elseif not game["paused"] and pause["startTrigger"] then
        if not pause["endTrigger"] then
            pause["time"]       = time["frame"]
            pause["endTrigger"] = true
        end

        -- when unpaused before 3 minutes is up it counts down from 10 seconds
        if ((time["frame"] - pause["time"]) / 1000) >= 10 then
            pause["startTrigger"] = false
            pause["endTrigger"]   = false
            timedv1 = 0
            timedv2 = 0
        end
    else
        if not time["trigger"] then
            timedv1 = time["frame"]
            time["trigger"] = true

            if timedv2 ~= 0 then
                time["counter"] = time["counter"] + ((timedv1 - timedv2) / 1000) -- + 0.05
                local _, _, thous = string.find(time["counter"], "%d*%.%d%d(%d*)")

                if thous == 9999999 then
                    time["counter"] = time["counter"] + 0.000000001
                end
            end
        else
            timedv2 = time["frame"]
            time["trigger"] = false
            time["counter"] = time["counter"] + ((timedv2 - timedv1) / 1000)
            local _, _, thous = string.find(time["counter"], "%d*%.%d%d(%d*)")

            if thous == 9999999 then
                time["counter"] = time["counter"] + 0.000000001
            end
        end
    end

    players["axis"]   = 0
    players["allies"] = 0
    players["active"] = 0
    players["total"]  = 0

    for p = 0, clientsLimit, 1 do
        if et.gentity_get(p, "pers.connected") == 2 then
            client[p]["name"] = et.Info_ValueForKey(et.trap_GetUserinfo(p), "name")

            if client[p]["name"] ~= client[p]["lastName"] then
                if logChatModule == 1 then
                    writeLog(
                        "*** " .. client[p]["lastName"] .. " HAS RENAMED TO " ..
                        client[p]["name"] .. " ***\n"
                    )
                end

                client[p]["lastName"] = client[p]["name"]
            end

            if client[p]["team"] == 1 then
                players["axis"] = players["axis"] + 1
            elseif client[p]["team"] == 2 then
                players["allies"] = players["allies"] + 1
            elseif client[p]["team"] == 3 then
                players["spectator"] = players["spectator"] + 1
            end

            if client[p]["team"] == 1 or client[p]["team"] == 2 then
                players["active"] = players["active"] + 1
            end

            players["total"] = players["total"] + 1
        else
            client[p]["name"]     = ""
            client[p]["lastName"] = ""
        end
    end

    if spectatorInactivity > 0 then
        for p = 0, clientsLimit, 1 do
            if client[p]["team"] == 3 and getAdminLevel(p) >= 1 then
                et.gentity_set(p, "client.inactivityTime", time["frame"])
                et.gentity_set(p, "client.inactivityWarning", 1)
            end
        end
    end

--     if floodprotect == 1 then
--         fpPtime = (time["frame"] - fpProt) / 1000
-- 
--         if fpPtime >= 2 then
--             floodprotect = 0
--         end
--     end

    if game["state"] == 3 then
        executeCallbackFunction("RunFrameEndRound", {["levelTime"] = tonumber(levelTime)})
        game["endRoundTrigger"] = true
    else
        executeCallbackFunction("RunFrame", {["levelTime"] = tonumber(levelTime)})

        --for p = 0, clientsLimit, 1 do
        --    executeCallbackFunction("RunFramePlayerLoop", {["levelTime"] = tonumber(levelTime), ["clientNum"] = p})
        --end
    end
end

-- Client management

-- Called when a client connect.
--  clientNum is the client slot id.
--  firstTime indicates if this is a new connection (1) or a reconnection (0).
--  isBot indicates if the client is a bot (1) or not (0).
function et_ClientConnect(clientNum, firstTime, isBot)
    client[clientNum]["guid"] = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")

    local result = executeCallbackFunction("ClientConnect", {
        ["clientNum"] = clientNum,
        ["firstTime"] = firstTime,
        ["isBot"]     = isBot
    })

    if result then
        return result
    end

--     client[clientNum]["slotUsed"] = 1
--
--     if clientNum > _clientsLimit then
--         _clientsLimit = clientNum
--     end
end

-- Called when a client disconnects.
--  clientNum is the client slot id.
function et_ClientDisconnect(clientNum)
    executeCallbackFunction("ClientDisconnect", {["clientNum"] = clientNum})

    client[clientNum] = {}

    for key, value in pairs(clientDefaultData) do
        client[clientNum][key] = value
    end

--     if clientNum == _clientsLimit then
--         for p = clientNum - 1, 0, -1 do
--             if client[p]["slotUsed"] == 1 then
--             --if et.gentity_get(p, "pers.connected") == 2 then
--                 _clientsLimit = p
--                 break
--             end
--         end
--     end
end

-- Called when a client begins (becomes active, and enters the gameworld).
--  clientNum is the client slot id.
function et_ClientBegin(clientNum)
    et.trap_SendServerCommand(clientNum, "cpm \"This server is running UberMod v" .. version .. " " .. releaseStatus .. "\n\"")

    local userinfo = et.trap_GetUserinfo(clientNum)
    local name     = et.Info_ValueForKey(userinfo, "name")

    client[clientNum]["name"]     = name
    client[clientNum]["lastName"] = name
    client[clientNum]["team"]     = tonumber(et.gentity_get(clientNum, "sess.sessionTeam"))

    executeCallbackFunction("ClientBegin", {["clientNum"] = clientNum})

    for _, data in ipairs(slashCommandModuleMsg) do
        local value = et.Info_ValueForKey(
            userinfo,
            data["userinfoKey"]
        )

        if value == "" then
            client[clientNum][data["clientDataKey"]] = data["msgDefault"]

            userinfo = et.Info_SetValueForKey(
                userinfo,
                data["userinfoKey"],
                data["msgDefault"]
            )
            
            et.trap_SetUserinfo(clientNum, userinfo)
        elseif tonumber(value) == 1 then
            client[clientNum][data["clientDataKey"]] = 1
        else
            client[clientNum][data["clientDataKey"]] = 0
        end
    end
end

-- Called when a client’s Userinfo string has changed.
--  clientNum is the client slot id.
-- NOTE : This only gets called when the players CS_PLAYERS config string changes,
-- rather than every time the userinfo changes. This only happens for a subset of userinfo fields.
function et_ClientUserinfoChanged(clientNum)
    executeCallbackFunction("ClientUserinfoChanged", {["clientNum"] = clientNum})

    local userinfo = et.trap_GetUserinfo(clientNum)

    for _, data in ipairs(slashCommandModuleMsg) do
        local value = et.Info_ValueForKey(
            userinfo,
            data["userinfoKey"]
        )

        if value == "" then
            client[clientNum][data["clientDataKey"]] = data["msgDefault"]

            userinfo = et.Info_SetValueForKey(
                userinfo,
                data["userinfoKey"],
                data["msgDefault"]
            )
            
            et.trap_SetUserinfo(clientNum, userinfo)
        elseif tonumber(value) == 1 then
            client[clientNum][data["clientDataKey"]] = 1
        else
            client[clientNum][data["clientDataKey"]] = 0
        end
    end
end

-- Called when a client is spawned.
--  clientNum is the client slot id.
--  revived is 1 if the client was spawned by being revived.
-- ET:Legacy => et_ClientSpawn(clientNum, revived, teamChange, restoreHealth)
function et_ClientSpawn(clientNum, revived)
    client[clientNum]["team"] = tonumber(et.gentity_get(clientNum, "sess.sessionTeam"))

    -- TODO : Check if spawn in spectator is possible (lol)
    if client[clientNum]["team"] == 1 or client[clientNum]["team"] == 2 then
        if revived == 0 then
            client[clientNum]["respawn"] = 1 
        end
    end
    
    executeCallbackFunction("ClientSpawn", {["clientNum"] = clientNum, ["revived"] = revived})
end

-- commands

-- Called when a command is received from a client.
--  clientNum is the client slot id.
--  command is the command. The mod should return 1 if the command was intercepted by the mod,
--  and 0 if the command was ignored by the mod and should be passed through
--  to the server (and other mods in the chain).
function et_ClientCommand(clientNum, command)
    local params = {
        ["cmdMode"]   = "client",
        ["clientNum"] = clientNum,
        ["cmd"]       = string.lower(et.trap_Argv(0))
    }

    if et.gentity_get(clientNum, "sess.muted") == 0 then
        if clientCmdData[params.cmd] ~= nil then
            local sayContent = et.ConcatArgs(1)
            
            if logChatModule == 1 then
                logChat(clientNum, clientCmdData[params.cmd]["mode"], sayContent)
            end

            if clientCmdData[params.cmd]["sayCmd"] ~= nil then
                params.say   = clientCmdData[params.cmd]["sayCmd"]
                params.nbArg = 0

                local _, _, first, second, third, fourth = string.find(
                    sayContent,
                    "^%s*([^%s]+)%s*([^%s]*)%s*([^%s]*)%s*([^%s]*)"
                )

                if first ~= "" then
                    params.nbArg = 1

                    if second ~= "" then
                        params.nbArg = 2

                        if third ~= "" then
                            params.nbArg = 3

                            if fourth ~= "" then
                                params.nbArg = 4
                            end
                        end
                    end
                end

                params.bangCmd = first
                params["arg1"] = second
                params["arg2"] = third
                params["arg3"] = fourth

                params.broadcast2allClients = false
                params.noDisplayCmd         = false

                if checkClientCommand(params, string.lower(params.bangCmd)) then
                    return 1
                end

                if curseMode > 0 then
                    checkBadWord(params, sayContent)
                end
            end
        end
    end

    params.nbArg = et.trap_Argc()
    params["arg1"] = et.trap_Argv(1)
    params["arg2"] = et.trap_Argv(2)

    for _, data in ipairs(slashCommandModuleMsg) do
        if data["slashCommand"] == params.cmd then
            --params.noDisplayCmd = true
            params.say = msgCmd["chatArea"]
            params.cmd = "/" .. params.cmd

            if params["arg1"] == "" then
                local status = "on"

                if client[clientNum][data["clientDataKey"]] == 0 then
                    status = "off"
                end

                printCmdMsg(
                    params,
                    "Messages are " .. color3 .. status
                )
            elseif tonumber(params["arg1"]) == 1 then
                client[clientNum][data["clientDataKey"]] = 1

                et.trap_SetUserinfo(
                    clientNum,
                    et.Info_SetValueForKey(
                        et.trap_GetUserinfo(clientNum),
                        data["userinfoKey"],
                        1
                    )
                )

                printCmdMsg(
                    params,
                    "Messages are now " .. color3 .. "on"
                )
            else
                client[clientNum][data["clientDataKey"]] = 0

                et.trap_SetUserinfo(
                    clientNum,
                    et.Info_SetValueForKey(
                        et.trap_GetUserinfo(clientNum),
                        data["userinfoKey"],
                        0
                    )
                )

                printCmdMsg(
                    params,
                    "Messages are now " .. color3 .. "off"
                )
            end

            return 1
        end
    end

    if slashCommandClient["single"][params.cmd] ~= nil then
        for _, cmdData in ipairs(slashCommandClient["single"][params.cmd]) do
            if runSlashCommand(cmdData, params) == 1 then
                return 1
            end
        end
    end

    if slashCommandClient["multiple"][params.cmd] ~= nil then
        local subCmd = string.lower(et.trap_Argv(1))

        if slashCommandClient["multiple"][params.cmd][subCmd] ~= nil then
            for _, cmdData in ipairs(slashCommandClient["multiple"][params.cmd][subCmd]) do
                if runSlashCommand(cmdData, params) == 1 then
                    return 1
                end
            end
        end
    end

    return 0
end

-- Called when a command is entered on the server console.
-- The mod should return 1 if the command was intercepted by the mod,
-- and 0 if the command was ignored by the mod and should be passed through
-- to the server (and other mods in the chain).
function et_ConsoleCommand()
    local params = {
        ["cmdMode"]   = "console",
        ["clientNum"] = 1022,
        ["nbArg"]     = et.trap_Argc(),
        ["cmd"]       = string.lower(et.trap_Argv(0)),
        ["arg1"]      = et.trap_Argv(1),
        ["arg2"]      = et.trap_Argv(2)
    }

    if runCommandFile(params.cmd, params) == 1 then
        return 1
    end

    if slashCommandConsole[params.cmd] ~= nil then
        for _, cmdData in ipairs(slashCommandConsole[params.cmd]) do
            if runSlashCommand(cmdData, params) == 1 then
                return 1
            end
        end
    end

    return 0
end

-- miscellaneous

-- Called whenever the server or qagame prints a string to the console.
-- WARNING! text may contain a player name + their chat message.
-- This makes it very easy to spoof.
-- DO NOT TRUST STRINGS OBTAINED IN THIS WAY
function et_Print(text)
    local arg = splitWord(text)
    executeCallbackFunction("Print", {["text"] = text, ["arg"] = arg})

    if arg[1] == "saneClientCommand:" and arg[3] == "callvote" then
        local caller = tonumber(arg[2])
        local vote   = arg[4]
        local target = tonumber(arg[5])

        if (vote == "kick" or vote == "mute") and getAdminLevel(caller) < getAdminLevel(target) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Admins cannot be vote kicked or vote muted!\n")
        end
    end

    -- Set end of round status when we detect it.
    if text == "Exit: Timelimit hit.\n" or text == "Exit: Wolf EndRound.\n" then
        game["state"] = 3
    end
end

-- Called whenever a player is killed.
function et_Obituary(victim, killer, meansOfDeath)
    local vars = {
        ["victim"]       = victim,
        ["victimName"]   = et.Info_ValueForKey(et.trap_GetUserinfo(victim), "name"),
        ["killer"]       = killer,
        ["killerName"]   = "The World",
        ["meansOfDeath"] = meansOfDeath
    }

    if killer == 1022 then
        executeCallbackFunction("ObituaryWorldKill", vars)
    else
        client[killer]["yourLastVictim"] = victim
        client[killer]["killerWeapon"]   = meansOfDeathList[meansOfDeath]

        vars["killerName"] = et.Info_ValueForKey(et.trap_GetUserinfo(killer), "name")

        if killer ~= victim then
            if client[victim]["team"] ~= client[killer]["team"] then
                executeCallbackFunction("ObituaryEnemyKill", vars)
            else
                executeCallbackFunction("ObituaryTeamKill", vars)
            end
        else
            executeCallbackFunction("ObituarySelfKill", vars)
        end
    end

    client[victim]["whoKilledYou"] = killer
    client[victim]["victimWeapon"] = meansOfDeathList[meansOfDeath]

    executeCallbackFunction("Obituary", vars)

    if meansOfDeath == 64 or meansOfDeath == 63 then
        client[victim]["switchTeam"] = 1
    else
        client[victim]["switchTeam"] = 0
    end
end

-- Plays a global sound soundfile for a certain client only.
--  clientNum is the client slot id.
--  soundfile is the sound file to play.
function et.G_ClientSound(clientNum, soundFile)
    -- NOTE : EV_GLOBAL_CLIENT_SOUND = 54
    local tmpEntity = et.G_TempEntity(et.gentity_get(clientNum, "r.currentOrigin"), 54)
    et.gentity_set(tmpEntity, "s.teamNum", clientNum)
    et.gentity_set(tmpEntity, "s.eventParm", et.G_SoundIndex(soundFile))
end

-- Set a sound index for a certain client only.
--  clientNum is the client slot id.
--  soundIndex is the sound index to set.
function setClientSoundIndex(clientNum, soundIndex)
    -- NOTE : EV_GLOBAL_CLIENT_SOUND = 54
    local tmpEntity = et.G_TempEntity(et.gentity_get(clientNum, "r.currentOrigin"), 54)
    et.gentity_set(tmpEntity, "s.teamNum", clientNum)
    et.gentity_set(tmpEntity, "s.eventParm", soundIndex)
end


function playSound(soundFile, playKey, clientNum)
    local soundIndex = et.G_SoundIndex(soundFile)

    if soundIndex == nil or clientDefaultData[playKey] == nil then
        return 
    end

    if clientNum == nil then
        for p = 0, clientsLimit, 1 do
            if client[p][playKey] == 1 then
                setClientSoundIndex(p, soundIndex)
            end
        end
    else
        if client[clientNum][playKey] == 1 then
            setClientSoundIndex(clientNum, soundIndex)
        end
    end
end

function sayClients(pos, msg, msgKey)
    msg = pos .. " \"" .. msg .. "\""

    if clientDefaultData[msgKey] == nil then
        et.trap_SendServerCommand(-1, msg)
    else
        for p = 0, clientsLimit, 1 do
            if client[p][msgKey] == 1 then
                et.trap_SendServerCommand(p, msg)
            end
        end
    end
end
