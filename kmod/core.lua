-- Global vars

version       = "0.1"
releaseStatus = "alpha"

callbackList = {
    ["ReadConfig"] = {},
    ["InitGame"] = {},
    ["ShutdownGame"] = {},
    ["RunFrame"] = {},
    ["RunFrameEndRound"] = {},
    ["ClientDisconnect"] = {},
    ["ClientBegin"] = {},
    ["ClientSpawn"] = {},
    ["ObituaryEnemyKill"] = {},
    ["ObituaryTkAndSelfKill"] = {},
    ["ObituaryWorldKill"] = {},
    ["ObituaryNoTk"] = {},
    ["Obituary"] = {}
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
        ["!finger"]            = "/command/client/finger.lua"
    },
    ["console"] = {
        ["!setlevel"]      = "/command/both/setlevel.lua",
        ["goto"]           = "/command/console/goto.lua",
        ["iwant"]          = "/command/console/iwant.lua",
        ["!showadmins"]    = "/command/console/showadmins.lua",
        ["!readconfig"]    = "/command/console/readconfig.lua",
        ["!spec999"]       = "/command/both/spec999.lua",
        ["!gib"]           = "/command/both/gib.lua",
        ["!slap"]          = "/command/both/slap.lua",
        ["!burn"]          = "/command/both/burn.lua"
    }
}

obituary = {
    ["lastKillerName"] = "",
    ["meansOfDeath"] = {
        [0] = "UNKNOWN"                       -- 0
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

kmod_ng_path = et.trap_Cvar_Get("fs_basepath") .. "/" .. et.trap_Cvar_Get("gamename") .. "/kmod/"

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
pmSound               = tostring(et.trap_Cvar_Get("pmsound"))

-- Load modules
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

dofile(kmod_ng_path .. "/modules/commands.lua")
dofile(kmod_ng_path .. "/modules/admins.lua")

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
--  cmd is the command who execute client2id.
--  verbose is if error are displayed or not.
--  cmdSaid is the chat command to display error.
function client2id(client, cmd, verbose, cmdSaid)
    local clientNum = tonumber(client)

    if clientNum then
        if clientNum >= 0 and clientNum < 64 then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                if verbose == "client" then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7There is no client associated with this slot number\n")
                elseif verbose == "console" then
                    et.G_Print("There is no client associated with this slot number\n")
                end

                return nil
            end
        else
            if verbose == "client" then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7Please enter a slot number between 0 and 63\n")
            elseif verbose == "console" then
                et.G_Print("Please enter a slot number between 0 and 63\n")
            end

            return nil
        end
    else
        local client = et.Q_CleanStr(client)

        if client then
            if string.len(client) <= 2 then
                if verbose == "client" then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7Player name requires more than 2 characters\n")
                elseif verbose == "console" then
                    et.G_Print("Player name requires more than 2 characters\n")
                end

                return nil
            else
                clientNum = getPlayernameToId(client)
            end
        end

        if not clientNum then
            if verbose == "client" then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3" .. cmd .. ": ^7Try name again or use slot number\n")
            elseif verbose == "console" then
                et.G_Print("Try name again or use slot number\n")
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
--         if params.command == "client" then
--             et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gib: ^7There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--         elseif params.command == "console" then
--             et.G_Print("There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--         end

        return nil
    else
        return slot
    end
end

-- Manage client / console message displaying.
--  cmdType is the command type (client or console).
--  msg is the message content.
-- TODO : Replace in core, module and command file
--function printCmdMsg(cmdType, cmdSaid, caller, msg)
function printCmdMsg(cmdType, msg)
    if cmdType == "client" then
        et.G_Print(msg)
    elseif cmdType == "console" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. msg)
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

    if cmdList[params.command] ~= nil and cmdList[params.command][command] ~= nil then
        dofile(kmod_ng_path .. cmdList[params.command][command])

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

-- Check a client text send by a vocal/chat command.
--  params is parameters of client / console command.
--  text is the content of client command.
function checkClientSay(params, text)
    params.nbArg     = et.trap_Argc() - 1
    params.bangCmd   = et.trap_Argv(1)
    params["arg1"]   = et.trap_Argv(2)
    params["arg2"]   = et.trap_Argv(3)

    local lowBangCmd = string.lower(params.bangCmd)

    if k_cursemode > 0 then
        checkBadWord(params.clientNum, text)
    end

    if checkClientCommand(params, lowBangCmd) then
        return 1
    end

    --[[
    if getAdminLevel(params.clientNum) >= getCommandLevel(params.bangCmd) then
        if runCommandFile(lowBangCmd, params) == 1 then
            return 1
        end
    end
    --]]

    return 0
end
