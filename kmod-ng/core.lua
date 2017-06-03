
-- Change this to your desired prefix
k_commandprefix = "!"

-- Global vars

version       = "0.1"
releaseStatus = "alpha"

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
    ["ObituaryTkAndSelfKill"] = {},
    ["ObituaryWorldKill"]     = {},
    ["ObituaryNoTk"]          = {},
    ["Obituary"]              = {},
    ["Print"]                 = {}
}

-- Client
clientsLimit = tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1

client = {}

clientDefaultData = {
    ["useAdrenaline"]  = 0,
    ["respawn"]        = 0,
    ["switchTeam"]     = 0,
    ["name"]           = "",
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
    ["allies"] = 0,
    ["axis"]   = 0,
    ["active"] = 0,
    ["total"]  = 0
}

-- Command (client & console)
cmdList = {
    ["client"] = {
        ["!admintest"]         = "/command/client/admintest.lua",
        ["!time"]              = "/command/client/time.lua",
        ["!date"]              = "/command/client/date.lua",
        ["!spec999"]           = "/command/both/spec999.lua",
        ["!tk_index"]          = "/command/client/tk_index.lua",
        ["!listcmds"]          = "/command/client/listcmds.lua",
        ["!gib"]               = "/command/both/gib.lua",
        ["!slap"]              = "/command/both/slap.lua",
        ["!burn"]              = "/command/both/burn.lua",
        ["!setlevel"]          = "/command/both/setlevel.lua",
        ["!readconfig"]        = "/command/both/readconfig.lua",
        ["!ban"]               = "/command/client/ban.lua",
        ["!getip"]             = "/command/client/getip.lua",
        ["!getguid"]           = "/command/client/getguid.lua",
        ["!makeshoutcaster"]   = "/command/client/makeshoutcaster.lua",
        ["!removeshoutcaster"] = "/command/client/removeshoutcaster.lua",
        ["!makereferee"]       = "/command/client/makereferee.lua",
        ["!removereferee"]     = "/command/client/removereferee.lua",
        ["!gravity"]           = "/command/client/gravity.lua",
        ["!knifeonly"]         = "/command/client/knifeonly.lua",
        ["!speed"]             = "/command/client/speed.lua",
        ["!knockback"]         = "/command/client/knockback.lua",
        ["!cheats"]            = "/command/both/cheats.lua",
        ["!laser"]             = "/command/both/laser.lua",
        ["!kick"]              = "/command/client/kick.lua",
        ["!warn"]              = "/command/client/warn.lua",
        ["!mute"]              = "/command/client/mute.lua",
        ["!pmute"]             = "/command/client/pmute.lua",
        ["!putspec"]           = "/command/client/putspec.lua",
        ["!putallies"]         = "/command/client/putallies.lua",
        ["!putaxis"]           = "/command/client/putaxis.lua",
        ["!timelimit"]         = "/command/client/timelimit.lua",
        ["!unmute"]            = "/command/client/unmute.lua",
        ["!finger"]            = "/command/client/finger.lua",
        ["goto"]               = "/command/both/goto.lua",
        ["iwant"]              = "/command/both/iwant.lua",
    },
    ["console"] = {
        ["!setlevel"]      = "/command/both/setlevel.lua",
        ["goto"]           = "/command/both/goto.lua",
        ["iwant"]          = "/command/both/iwant.lua",
        ["!showadmins"]    = "/command/console/showadmins.lua",
        ["!readconfig"]    = "/command/console/readconfig.lua",
        ["!spec999"]       = "/command/both/spec999.lua",
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

slashCommandConsole = {}

obituary = {
    ["lastKillerName"] = "",
    ["meansOfDeath"] = {
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
}

game = {
    ["paused"] = false,
    ["state"]  = 0,
    ["endRoundTrigger"] = false
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

--floodprotect = 0

-- **********************************************

-- Under etpro mod :
--  fs_game : etpro
--  fs_basegame : 
--  gamename : etpro
--  mod_version : 3.2.6
--  mod_url = http://etpro.anime.net/

-- Under et-legacy :
--  fs_game : 
--  fs_basegame : 
--  gamename : 
--  mod_version : 
--  mod_url = 

-- Load KMOD-ng cvar
k_color               = et.trap_Cvar_Get("k_color")
k_panzersperteam      = tonumber(et.trap_Cvar_Get("team_maxpanzers"))
--k_panzersperteam    = tonumber(et.trap_Cvar_Get("k_panzersperteam"))
k_advplayers          = tonumber(et.trap_Cvar_Get("k_advplayers"))
k_tklimit_high        = tonumber(et.trap_Cvar_Get("k_tklimit_high"))
k_noisereduction      = tonumber(et.trap_Cvar_Get("k_noisereduction"))
k_advancedpms         = tonumber(et.trap_Cvar_Get("k_advancedpms"))
k_antiunmute          = tonumber(et.trap_Cvar_Get("k_antiunmute"))
k_mute_module         = tonumber(et.trap_Cvar_Get("k_mute_module"))
k_cursemode           = tonumber(et.trap_Cvar_Get("k_cursemode"))
k_disablevotes        = tonumber(et.trap_Cvar_Get("k_disablevotes"))
k_advancedadrenaline  = tonumber(et.trap_Cvar_Get("k_advancedadrenaline"))
k_advancedspawn       = tonumber(et.trap_Cvar_Get("k_advancedspawn"))
k_autopanzerdisable   = tonumber(et.trap_Cvar_Get("k_autopanzerdisable"))
k_selfkilllimit       = tonumber(et.trap_Cvar_Get("k_selfkilllimit"))
k_logchat             = tonumber(et.trap_Cvar_Get("k_logchat"))
k_multikills          = tonumber(et.trap_Cvar_Get("k_multikills"))
k_flakmonkey          = tonumber(et.trap_Cvar_Get("k_flakmonkey"))
k_deathsprees         = tonumber(et.trap_Cvar_Get("k_deathsprees"))
k_sprees              = tonumber(et.trap_Cvar_Get("k_sprees"))
k_spreerecord         = tonumber(et.trap_Cvar_Get("k_spreerecord"))
k_teamkillrestriction = tonumber(et.trap_Cvar_Get("k_teamkillrestriction"))
k_firstblood          = tonumber(et.trap_Cvar_Get("k_firstblood"))
k_lastblood           = tonumber(et.trap_Cvar_Get("k_lastblood"))
k_killerhpdisplay     = tonumber(et.trap_Cvar_Get("k_killerhpdisplay"))
k_endroundshuffle     = tonumber(et.trap_Cvar_Get("k_endroundshuffle"))
pmSound               = et.trap_Cvar_Get("pmsound")
k_playsound           = et.trap_Cvar_Get("k_playsound")


-- Store a settings function list in main callback function list.
--  settings is the function list to set.
function addCallbackFunction(settings)
    for callbackType, functionName in pairs(settings) do
        if type(_G[functionName]) == "function" then
            if callbackList[callbackType] ~= nil then
                table.insert(callbackList[callbackType], functionName)
            else
                et.G_LogPrint("ERROR : CallbackType " .. callbackType .. " don't exist!")
            end
        else
            et.G_LogPrint("ERROR : Function " .. functionName .. " don't exist!")
        end
    end
end

-- Execute callback function list of callback type.
--  callbackType is the callback type list to execute.
--  vars is the local vars passed to callback function.
function executeCallbackFunction(callbackType, vars)
    if callbackList[callbackType] ~= nil then
        for _, functionName in ipairs(callbackList[callbackType]) do
            _G[functionName](vars)
        end
    else
        et.G_LogPrint("ERROR : CallbackType " .. callbackType .. " don't exist!")
    end
end

-- Check client and return this slot id.
--  client can be :
--   * A slot id
--   * Partial / complete player name (two character minimum)
--  cmdName is the client / console command who execute client2id.
--  params is parameters passed to the function executed in command file.
function client2id(client, cmdName, params)
    local clientNum = tonumber(client)

    if clientNum then
        if clientNum >= 0 and clientNum < 64 then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                if params ~= nil then
                    printCmdMsg(params, cmdName, "There is no client associated with this slot number\n")
                end

                return nil
            end
        else
            if params ~= nil then
                printCmdMsg(params, cmdName, "Please enter a slot number between 0 and 63\n")
            end

            return nil
        end
    else
        local client = et.Q_CleanStr(client)

        if client then
            if string.len(client) <= 2 then
                if params ~= nil then
                    printCmdMsg(params, cmdName, "Player name requires more than 2 characters\n")
                end

                return nil
            else
                clientNum = getPlayernameToId(client)
            end
        end

        if not clientNum then
            if params ~= nil then
                printCmdMsg(params, cmdName, "Try name again or use slot number\n")
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

-- Check if a certain player is connected and return his slot id.
--  name is partial / complete player name (two character minimum) to search.
function getPlayernameToId(name)
    local slot       = nil
    local matchCount = 0
    local cleanName  = string.lower(et.Q_CleanStr(name))

    for i = 0, clientsLimit, 1 do
        s, e = string.find(string.lower(et.Q_CleanStr(client[i]["name"])), cleanName)

        if s and e then
            matchCount = matchCount + 1
            slot = i
        end
    end

    if matchCount >= 2 then
-- set level
--         if params.cmdMode == "client" then
--             et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gib: ^7There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--         elseif params.cmdMode == "console" then
--             et.G_Print("There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--         end

        return nil
    else
        return slot
    end
end

-- Manage client / console message displaying.
--  params is parameters passed to the function executed in command file.
--  cmdName is the client / console command who execute printCmdMsg.
--  msg is the message content.
function printCmdMsg(params, cmdName, msg)
    if params.cmdMode == "client" then
        et.G_Print("^7" .. msg)
    elseif params.cmdMode == "console" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3" .. cmdName .. ": ^7" .. msg)
    end
end

-- Get location of displayed message on client screen.
--  location value can be :
--   1 : chat area
--   2 : center screen area
--   3 : top of screen
function getMessageLocation(location)
    if location == 2 then
        return "cp"
    elseif location == 3 then
        return "bp"
    else
        return "qsay"
    end
end

-- Check if a command exist and execute his command file.
--  command is command name to execute.
--  params is parameters passed to the function executed in command file.
function runCommandFile(command, params)
    local result    = 0
    execute_command = nil

    if cmdList[params.cmdMode] ~= nil and cmdList[params.cmdMode][command] ~= nil then
        dofile(kmod_ng_path .. cmdList[params.cmdMode][command])

        if (type(execute_command) == "function") then
            result          = execute_command(params)
            execute_command = nil
        else
            et.G_LogPrint("ERROR : None `execute_command` function defined in command file")
        end
    else
        et.G_LogPrint("ERROR : Unknow command : " .. command)
    end

    return result
end

function setSlashCommandMultipleField(cmdArg, cmdData)
    local t = _G["slashCommandClient"]["multiple"]

    for _, arg in ipairs(cmdArg) do
        t[arg] = t[arg] or {}
        t = t[arg]
    end

    t = cmdData
end

function addSlashCommand(cmdType, cmdArg, cmdData)
    if cmdType == "client" then
        local cmdArgType = type(cmdArg)

        if cmdArgType == "table" then
            setSlashCommandMultipleField(cmdArg, cmdData)
        elseif cmdArgType == "string" then
            slashCommandClient["single"][cmdArg] = slashCommandClient["single"][cmdArg] or {}
            table.insert(slashCommandClient["single"][cmdArg], cmdData)
        end
    elseif cmdType == "console" then
        slashCommandConsole[cmdArg] = slashCommandConsole[cmdArg] or {}
        table.insert(slashCommandConsole[cmdArg], cmdData)
    end
end

function runSlashCommand(data, params)
    local result    = 0
    execute_command = nil

    if data[1] == "function" then
        result = _G[data[2]](params)
    elseif data[1] == "file" then
        dofile(kmod_ng_path .. data[2])

        if (type(execute_command) == "function") then
            result          = execute_command(params)
            execute_command = nil
        else
            et.G_LogPrint("ERROR : None `execute_command` function defined in command file")
        end
    else
        et.G_LogPrint("ERROR : Bad slash command data : " .. tostring(data))
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

et.G_Printf = function(...)
    et.G_Print(string.format(unpack(arg)))
end

et.G_LogPrintf = function(...)
    et.G_LogPrint(string.format(unpack(arg)))
end

-- Load modules
dofile(kmod_ng_path .. "/mods/etpro.lua")

if k_mute_module == 1 then
    dofile(kmod_ng_path .. "/modules/mute.lua")
end

if k_cursemode > 0 then
    dofile(kmod_ng_path .. "/modules/curse_filter.lua")
end

if k_disablevotes == 1 then
    dofile(kmod_ng_path .. "/modules/disable_vote.lua")
end

if k_advancedadrenaline == 1 then
    dofile(kmod_ng_path .. "/modules/advanced_adrenaline.lua")
end

-- g_inactivity is required or this will not work
if k_advancedspawn == 1 and tonumber(et.trap_Cvar_Get("g_inactivity")) > 0 then 
    dofile(kmod_ng_path .. "/modules/advanced_spawn.lua")
end

if k_autopanzerdisable == 1 then
    dofile(kmod_ng_path .. "/modules/auto_panzer_disable.lua")
end

if k_selfkilllimit == 1 then
    dofile(kmod_ng_path .. "/modules/selfkill_limit.lua")
end

if k_logchat == 1 then
    dofile(kmod_ng_path .. "/modules/log.lua")
end

if k_sprees == 1 then
    dofile(kmod_ng_path .. "/modules/killing_spree.lua")
end

if k_spreerecord == 1 then
    dofile(kmod_ng_path .. "/modules/spree_record.lua")
end

if k_multikills == 1 then
    dofile(kmod_ng_path .. "/modules/multikill.lua")
end

if k_flakmonkey == 1 then
    dofile(kmod_ng_path .. "/modules/flak_monkey.lua")
end

if k_deathsprees == 1 then
    dofile(kmod_ng_path .. "/modules/death_spree.lua")
end

if k_teamkillrestriction == 1 then
    dofile(kmod_ng_path .. "/modules/teamkill_restriction.lua")
end

if k_firstblood == 1 then
    dofile(kmod_ng_path .. "/modules/first_blood.lua")
end

if k_lastblood == 1 then
    dofile(kmod_ng_path .. "/modules/last_blood.lua")
end

if k_killerhpdisplay == 1 then
    dofile(kmod_ng_path .. "/modules/display_killer_hp.lua")
end

if k_endroundshuffle == 1 then
    dofile(kmod_ng_path .. "/modules/end_round_shuffle.lua")
end

if k_antiunmute == 1 then
    dofile(kmod_ng_path .. "/modules/anti_unmute.lua")
end

if k_advancedpms == 1 then
    dofile(kmod_ng_path .. "/modules/advanced_private_message.lua")
end

if k_playsound == 1 then
    dofile(kmod_ng_path .. "/modules/playsound.lua")
end

dofile(kmod_ng_path .. "/modules/commands.lua")
dofile(kmod_ng_path .. "/modules/admins.lua")
dofile(kmod_ng_path .. "/modules/private_message_admin.lua")

if k_advplayers == 1 then
    addSlashCommand("client", "players", {"file", "/command/client/players.lua"})
    addSlashCommand("client", "admins", {"file", "/command/client/admins.lua"})
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

    local currentVersion = et.trap_Cvar_Get("mod_version")
    et.RegisterModname("KMOD-ng v" .. version .. releaseStatus .. " " .. et.FindSelf())
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar mod_version \"" .. currentVersion .. " - KMOD-ng " .. version .. "\"\n")

    for i = 0, clientsLimit, 1 do
        client[i] = {}

        for key, value in pairs(clientDefaultData) do
            client[i][key] = value
        end

        if et.gentity_get(i, "pers.connected") == 2 then
            client[i]["name"] = et.gentity_get(i, "pers.netname")
        end
    end

    executeCallbackFunction("InitGame", {["levelTime"] = levelTime, ["restart"] = restart})
    executeCallbackFunction("ReadConfig")

    if k_advancedpms == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 0\n")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 2\n")
    end

    et.G_Print("KMOD-ng version " .. version .. " " .. releaseStatus .. " has been initialized...\n")
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

    -- 1 : warmup, 0 : match, 3 : end round
    game["state"] = tonumber(et.trap_Cvar_Get("gamestate"))

    --players["axis"] = 0
    --players["allies"] = 0
    players["active"] = 0
    --players["total"] = 0

    for i = 0, clientsLimit, 1 do
        client[i]["name"] = et.gentity_get(i, "pers.netname")
 
        if et.gentity_get(i, "pers.connected") == 2 then
            if client[i]["name"] ~= client[i]["lastName"] then
                -- TODO : Check if log module is enabled
                writeLog("*** " .. client[i]["lastName"] .. " HAS RENAMED TO " .. client[i]["name"] .. " ***\n")
                client[i]["lastName"] = client[i]["name"]
            end

            --[[
            if client[i]["team"] == 1 then
                players["axis"] = players["axis"] + 1
            elseif client[i]["team"] == 2 then
                players["allies"] = players["allies"] + 1
            end
            ]]--

            if client[i]["team"] == 1 or client[i]["team"] == 2 then
                players["active"] = players["active"] + 1
            end

            --players["total"] = players["total"] + 1
        else
            client[i]["name"]     = ""
            client[i]["lastName"] = ""
        end
    end

    if tonumber(et.trap_Cvar_Get("g_spectatorInactivity")) > 0 then
        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 1 then
                --if client[i]["team"] >= 3 or client[i]["team"] < 1 then
                if client[i]["team"] == 3 then
                    et.gentity_set(i, "client.inactivityTime", time["frame"])
                    et.gentity_set(i, "client.inactivityWarning", 1)
                end
            end
        end
    end

    if game["state"] == 3 then
        executeCallbackFunction("RunFrameEndRound", {["levelTime"] = tonumber(levelTime)})
        endRoundTrigger = true
    end

--     if floodprotect == 1 then
--         fpPtime = (time["frame"] - fpProt) / 1000
-- 
--         if fpPtime >= 2 then
--             floodprotect = 0
--         end
--     end

    executeCallbackFunction("RunFrame", {["levelTime"] = tonumber(levelTime)})
end

-- Client management

-- Called when a client connect.
--  clientNum is the client slot id.
--  firstTime indicates if this is a new connection (1) or a reconnection (0).
--  isBot indicates if the client is a bot (1) or not (0).
function et_ClientConnect(clientNum, firstTime, isBot)
    executeCallbackFunction("ClientConnect", {["clientNum"] = clientNum, ["firstTime"] = firstTime, ["isBot"] = isBot})
end

-- Called when a client disconnects.
--  clientNum is the client slot id.
function et_ClientDisconnect(clientNum)
    client[clientNum] = {}

    for key, value in pairs(clientDefaultData) do
        client[clientNum][key] = value
    end

    executeCallbackFunction("ClientDisconnect", {["clientNum"] = clientNum})
end

-- Called when a client begins (becomes active, and enters the gameworld).
--  clientNum is the client slot id.
function et_ClientBegin(clientNum)
    et.trap_SendServerCommand(clientNum, "cpm \"This server is running the new KMOD-ng version " .. version .. " " .. releaseStatus .. "\n\"")
    et.trap_SendServerCommand(clientNum, "cpm \"Created by Clutch152.\n\"")

    client[clientNum]["lastName"] = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name")

    executeCallbackFunction("ClientBegin", {["clientNum"] = clientNum})
end

-- Called when a client’s Userinfo string has changed.
--  clientNum is the client slot id.
-- NOTE : This only gets called when the players CS_PLAYERS config string changes,
-- rather than every time the userinfo changes. This only happens for a subset of userinfo fields.
function et_ClientUserinfoChanged(clientNum)
    executeCallbackFunction("ClientUserinfoChanged", {["clientNum"] = clientNum})
end


-- Called when a client is spawned.
--  clientNum is the client slot id.
--  revived is 1 if the client was spawned by being revived.
-- ET:Legacy => et_ClientSpawn(clientNum, revived, teamChange, restoreHealth)
function et_ClientSpawn(clientNum, revived)
    client[clientNum]["team"] = tonumber(et.gentity_get(clientNum, "sess.sessionTeam"))

    -- TODO : Check if spawn in spectator is possible (lol)
    if client[clientNum]["team"] == 1 or client[clientNum]["team"] == 2 then
        --gameModeClientSpawn(clientNum)

        if revived == 0 then
            client[clientNum]["respawn"] = 1
        end
    end
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
        ["cmd"]       = string.lower(command)
    }

    if et.gentity_get(clientNum, "sess.muted") == 0 then
        if clientCmdData[params.cmd] ~= nil then
            if k_logchat == 1 then
                logChat(clientNum, clientCmdData[params.cmd]["mode"], et.ConcatArgs(1))
            end

            if clientCmdData[params.cmd]["sayCmd"] ~= nil then
                params.say       = clientCmdData[params.cmd]["sayCmd"]
                params.nbArg     = et.trap_Argc() - 1
                params.bangCmd   = et.trap_Argv(1)
                params["arg1"]   = et.trap_Argv(2)
                params["arg2"]   = et.trap_Argv(3)

                if k_cursemode > 0 then
                    checkBadWord(params.clientNum, et.ConcatArgs(1))
                end

                if checkClientCommand(params, string.lower(params.bangCmd)) then
                    return 1
                end
            end
        end
    end

    if slashCommandClient["multiple"][params.cmd] ~= nil then
        local subCmd = string.lower(et.trap_Argv(1))

        if slashCommandClient["multiple"][params.cmd][subCmd] ~= nil then
            if slashCommandClient["multiple"][params.cmd][subCmd] ~= nil then
                for _, cmdData in ipairs(slashCommandClient["multiple"][params.cmd][subCmd]) do
                    if runSlashCommand(cmdData, params) == 1 then
                        return 1
                    end
                end
            end
        end
    elseif slashCommandClient["single"][params.cmd] ~= nil then
        for _, cmdData in ipairs(slashCommandClient["single"][params.cmd]) do
            if runSlashCommand(cmdData, params) == 1 then
                return 1
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
        ["cmdMode"] = "console",
        ["nbArg"]   = et.trap_Argc(),
        ["cmd"]     = string.lower(et.trap_Argv(0)),
        ["arg1"]    = et.trap_Argv(1),
        ["arg2"]    = et.trap_Argv(2)
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
    executeCallbackFunction("Print", {["text"] = text})

    local t = splitWord(text)

    if t[1] == "saneClientCommand:" and t[3] == "callvote" then
        local caller = tonumber(t[2])
        local vote   = t[4]
        local target = tonumber(t[5])

        if (vote == "kick" or vote == "mute") and getAdminLevel(caller) < getAdminLevel(target) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Admins cannot be vote kicked or vote muted!\n")
        end
    end

    if t[1] == "Medic_Revive:" then
        local reviver = tonumber(t[2])
        client[reviver]["tkIndex"] = client[reviver]["tkIndex"] + 1

        if client[reviver]["tkIndex"] > k_tklimit_high then
            client[reviver]["tkIndex"] = k_tklimit_high
        end
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

    -- No tk, to selfkill & not killed by the world
    if client[victim]["team"] ~= client[killer]["team"] and killer ~= 1022 and killer ~= victim then
        vars["killerName"]  = et.Info_ValueForKey(et.trap_GetUserinfo(killer), "name")
        obituary["lastKillerName"] = vars["killerName"]
        executeCallbackFunction("ObituaryEnemyKill", vars)
    end

    -- Kills
    client[killer]["yourLastVictim"] = victim
    client[killer]["killerWeapon"]   = obituary["meansOfDeath"][meansOfDeath]

    if killer == 1022 then
        executeCallbackFunction("ObituaryWorldKill", vars)
    else
        if killer ~= victim then
            executeCallbackFunction("ObituaryNoTk", vars)
        end

        if killer == victim or client[victim]["team"] == client[killer]["team"] then
            executeCallbackFunction("ObituaryTkAndSelfKill", vars)
        end
    end

    -- deaths
    client[victim]["whoKilledYou"] = killer
    client[victim]["victimWeapon"] = obituary["meansOfDeath"][meansOfDeath]

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
    -- EV_GLOBAL_CLIENT_SOUND = 54
    local tmpEntity = et.G_TempEntity(et.gentity_get(clientNum, "r.currentOrigin"), 54)
    et.gentity_set(tmpEntity, "s.teamNum", clientNum)
    et.gentity_set(tmpEntity, "s.eventParm", et.G_SoundIndex(soundFile))
end
