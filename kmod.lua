
-- Change this to your desired prefix
k_commandprefix = "!"

--[[
This lua was created to replace most features of etadmin mod
and is much faster in response time and includes some features
that etadmin mod does not have and vice versa.

FEATURES:
    *** Killingsprees plus all the other killingspree type stuff (Sounds Included)
    *** Doublekills, Multikills, Ultrakills, Monsterkills, and Ludicrouskills (Sounds Included)
    *** Flakmonkey's - When you get 3 kills with either panzer or a riflenade.
        Flakmonkey is reset if you get any other type of kill/teamkill/or if you die (Sound included)
    *** Firstblood (Sound Included)
    *** Lastblood
    *** Spreerecord (not including records for individual maps)
    *** Enhanced Private Messaging - The sender can use partial name of recipiant
        or can now use the recipiants slot number.  When using ETPro 3.2.6 or higher,
        a new sound will be played letting you know that you have a private message.
        Players can now private message all 2+ level admins currently on the server using
        /ma or /pma then your message.
    *** Vote disable was taken directly from ETAdmin mod and is slightly enhanced such that
        it will detect changes to the timelimit.  (see config for details)
    *** Antiunmute - When a player is muted he may not be unmuted via vote
    *** Advanced Adrenaline - Players using adrenaline now have a timer in their cp area
        displaying the amount of adrenaline time they have left.
        A sound will also be played in their general location letting everyone else
        know that they are using adrenaline (disableable) (sound included)
    *** Killer's HP - Killer's HP is displayed to their victims.  When you kill somone
        and are killed in return within a certain amount of time no message will be displayed.
        When a killer is using adrenaline the victim will see a message displaying so.
    *** Advanced players - Time nudge and max packets are removed from players list
        and admins may see which admins (level 2+) are on the server using /admins
    *** Chat log - All chats are logged along with player renames/connects/disconnects/and map restarts
    *** Crazygravity - The exact same crazy gravity you've come to know and love
    *** Team kill restriction - Taken from Etadmin mod and uses punkbuster to kick (see config)
    *** /kill limit - After the max amount of slash kills is reached they are no longer
        able to /kill.
    *** Endround shuffle - At the end of each round teams are shuffled automatically
        I recomend using this on servers with alot of people.
    *** Noise reduction - ETPRO 3.2.6 OR HIGHER IS REQUIRED!!!  Plays all killingsprees
        multikills/deathsprees/and firstblood to the killer or victim depending on which one
    *** Color codes can be changed for lastblood and killer HP display in config
    *** Spawn kill protection - A newly spawned player will keep his spawn shield
        Until he either moves or fires his weapon.  (see config)
    *** Paths to sounds can be changed to fit server admins needs.

CREDITS:
    Special to
        Noobology
        Armymen
        Rikku
        Monkey Spawn
        Brunout
        Dominator
        James
        Pantsless Victims
    For helping with testing

SOURCES:
    Some code and ideas dirived from G073nks which can be found here
        http://wolfwiki.anime.net/index.php/User:Gotenks
    Code to get slot number from name was from the slap command I found on the ETPro forum here 
        http://bani.anime.net/banimod/forums/viewtopic.php?t=6579&highlight=slap
    Infty's NoKill lua code was used and edited for the slashkill limit which can be found here
        http://wolfwiki.anime.net/index.php/User:Infty
    Ideas dirived from ETAdmin_mod found here
        http://et.d1p.de/etadmin_mod/wiki/index.php/Main_Page

    If you see your code in here let me know and I'll add you to the credits for future releases

    The rest of the code is mine :D
--]]

kmod_ng_path = et.trap_Cvar_Get("fs_basepath") .. "/" .. et.trap_Cvar_Get("gamename") .. "/kmod/"
dofile(kmod_ng_path .. "/core.lua")

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
