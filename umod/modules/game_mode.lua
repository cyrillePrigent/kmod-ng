-- Game mode (frenzy, grenadewar, panzerwar, sniperwar, stenwar, lugerwar & knifewar)

-- Global var

gameMode = {
    ["current"] = false,
    ["refresh"] = {
        ["time"]    = 0,
        ["trigger"] = false
    },
    ["clientSettingsModified"] = false
}

originalSettings = {
    ["team_maxSoldiers"]    = "",
    ["team_maxmortars"]     = "",
    ["team_maxpanzers"]     = "",
    ["team_maxflamers"]     = "",
    ["team_maxmg42s"]       = "",
    ["team_maxmedics"]      = "",
    ["team_maxengineers"]   = "",
    ["team_maxfieldops"]    = "",
    ["team_maxcovertops"]   = "",
    ["g_soldierchargetime"] = "",
    ["g_speed"]             = ""
}

-- Set default client data.
clientDefaultData["originalClass"]  = ""
clientDefaultData["originalWeapon"] = ""

-- Set module command.
cmdList["client"]["!panzerwar"]   = "/command/both/panzerwar.lua"
cmdList["client"]["!frenzy"]      = "/command/both/frenzy.lua"
cmdList["client"]["!grenadewar"]  = "/command/both/grenadewar.lua"
cmdList["client"]["!sniperwar"]   = "/command/both/sniperwar.lua"
cmdList["client"]["!stenwar"]     = "/command/both/stenwar.lua"
cmdList["client"]["!lugerwar"]    = "/command/both/lugerwar.lua"
cmdList["client"]["!knifewar"]    = "/command/both/knifewar.lua"
cmdList["console"]["!panzerwar"]  = "/command/both/panzerwar.lua"
cmdList["console"]["!frenzy"]     = "/command/both/frenzy.lua"
cmdList["console"]["!grenadewar"] = "/command/both/grenadewar.lua"
cmdList["console"]["!sniperwar"]  = "/command/both/sniperwar.lua"
cmdList["console"]["!stenwar"]    = "/command/both/stenwar.lua"
cmdList["console"]["!lugerwar"]   = "/command/both/lugerwar.lua"
cmdList["console"]["!knifewar"]    = "/command/both/knifewar.lua"

-- Function

-- Callback function when qagame shuts down.
function checkGameModeShutdownGame()
    if gameMode["current"] ~= false then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings["team_maxmedics"] .. " ; team_maxcovertops " .. originalSettings["team_maxcovertops"] .. " ; team_maxfieldops " .. originalSettings["team_maxfieldops"] .. " ; team_maxengineers " .. originalSettings["team_maxengineers"] .. " ; team_maxflamers " .. originalSettings["team_maxflamers"] .. " ; team_maxmortars " .. originalSettings["team_maxmortars"] .. " ; team_maxmg42s " .. originalSettings["team_maxmg42s"] .. " ; team_maxpanzers " .. originalSettings["team_maxpanzers"] .. " ; forcecvar g_soldierchargetime " .. originalSettings["g_soldierchargetime"] .. "\n")

        if gameMode["current"] == "panzerwar" then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_speed " .. originalSettings["g_speed"] .. "\n")
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers " .. panzersPerTeam .. "\n")

    -- checkGameModeRunFrameEndRound do this
    --[[
    if gameMode["current"] == "panzerwar" then
        for i = 0, clientsLimit, 1 do
            if client[i]["team"] == 1 or client[i]["team"] == 2 then
                et.gentity_set(i, "sess.latchPlayerType", client[i]["originalClass"])
                et.gentity_set(i, "sess.latchPlayerWeapon", client[i]["originalWeapon"])
            end
        end
    end
    --]]
end

-- Set ammo for each weapon.
--  weaponList is the configuration for set ammo or not for each weapon.
--  clientNum is the client slot id.
function setWeaponAmmo(weaponList, clientNum)
    -- et.MAX_WEAPONS = 50
    for i = 1, 49, 1 do
        if not weaponList[i] then
            et.gentity_set(clientNum, "ps.ammoclip", i, 0)
            et.gentity_set(clientNum, "ps.ammo", i, 0)
        else
            et.gentity_set(clientNum, "ps.ammo", i, 999)
        end
    end
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkGameModeRunFrame(vars)
    if gameMode["current"] ~= false then
        if not gameMode["refresh"]["trigger"] then
            gameMode["refresh"]["time"]    = vars["levelTime"]
            gameMode["refresh"]["trigger"] = true
        end

        -- reset ammo and stuff every 0.25 of a second rather than 0.05 of a second (which caused lag)
        if vars["levelTime"] - gameMode["refresh"]["time"] >= 250 then
            gameMode["refresh"]["trigger"] = false

            for i = 0, clientsLimit, 1 do
                setWeaponAmmo(weaponsList, i)
                gameModeRunFramePlayerCallback(i)
            end
        end
    end
end

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkGameModeRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        if gameMode["clientSettingsModified"] then
            for i = 0, clientsLimit, 1 do
                if client[i]["team"] == 1 or client[i]["team"] == 2 then
                    et.gentity_set(i, "sess.latchPlayerType", client[i]["originalClass"])
                    et.gentity_set(i, "sess.latchPlayerWeapon", client[i]["originalWeapon"])
                end
            end
        end
    end
end

-- Callback function when a client is spawned.
--  vars is the local vars passed from et_ClientSpawn function.
function checkGameModeClientSpawn(vars)
    if gameMode["current"] == "panzerwar" then
        local doubleHealth = tonumber(et.gentity_get(vars["clientNum"], "health")) * 2
        et.gentity_set(vars["clientNum"], "health", doubleHealth)
    end
end

function gameModeIsActive(newGameMode, params)
    if newGameMode ~= "panzerwar" and gameMode["current"] == "panzerwar" then
        printCmdMsg(params, "Panzerwar must be disabled first\n")
    elseif newGameMode ~= "grenadewar" and gameMode["current"] == "grenadewar" then
        printCmdMsg(params, "Grenadewar must be disabled first\n")
    elseif newGameMode ~= "sniperwar" and gameMode["current"] == "sniperwar" then
        printCmdMsg(params, "Sniperwar must be disabled first\n")
    elseif newGameMode ~= "stenwar" and gameMode["current"] == "stenwar" then
        printCmdMsg(params, "Stenwar must be disabled first\n")
    elseif newGameMode ~= "frenzy" and gameMode["current"] == "frenzy" then
        printCmdMsg(params, "Frenzy must be disabled first\n")
    elseif newGameMode ~= "lugerwar" and gameMode["current"] == "lugerwar" then
        printCmdMsg(params, "Lugerwar must be disabled first\n")
    elseif newGameMode ~= "knifewar" and gameMode["current"] == "knifewar" then
        printCmdMsg(params, "Knifewar must be disabled first\n")
    else
        return false
    end
    
    return true
end

function saveServerClassSetting()
    originalSettings["team_maxSoldiers"]    = tonumber(et.trap_Cvar_Get("team_maxSoldiers"))
    originalSettings["team_maxmortars"]     = tonumber(et.trap_Cvar_Get("team_maxmortars"))
    originalSettings["team_maxpanzers"]     = tonumber(et.trap_Cvar_Get("team_maxpanzers"))
    originalSettings["team_maxflamers"]     = tonumber(et.trap_Cvar_Get("team_maxflamers"))
    originalSettings["team_maxmg42s"]       = tonumber(et.trap_Cvar_Get("team_maxmg42s"))
    originalSettings["team_maxmedics"]      = tonumber(et.trap_Cvar_Get("team_maxmedics"))
    originalSettings["team_maxengineers"]   = tonumber(et.trap_Cvar_Get("team_maxengineers"))
    originalSettings["team_maxfieldops"]    = tonumber(et.trap_Cvar_Get("team_maxfieldops"))
    originalSettings["team_maxcovertops"]   = tonumber(et.trap_Cvar_Get("team_maxcovertops"))
    originalSettings["g_soldierchargetime"] = tonumber(et.trap_Cvar_Get("g_soldierchargetime"))
    originalSettings["g_speed"]             = tonumber(et.trap_Cvar_Get("g_speed"))
end

-- Add callback game mode function.
addCallbackFunction({
    ["ShutdownGame"]     = "checkGameModeShutdownGame",
    ["RunFrame"]         = "checkGameModeRunFrame",
    ["RunFrameEndRound"] = "checkGameModeRunFrameEndRound",
    --["ClientSpawn"]    = "checkGameModeClientSpawn"
})
