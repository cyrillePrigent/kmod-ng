-- Game mode (frenzy, grenadewar, knifewar, lugerwar, panzerwar, sniperwar & stenwar)
-- From kmod script.

-- Global var

gameMode = {
    -- Current game mode.
    ["current"] = "",
    -- Time (in ms) of last game mode check.
    ["time"] = 0,
    -- Current game mode weapons list.
    ["weaponsList"] = {}
}

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
cmdList["console"]["!knifewar"]   = "/command/both/knifewar.lua"

-- Function

-- landmines_limit

-- Start game mode.
--  * Disable other modules if needed (auto panzer disable & landmines limit)
--  * Backup server settings
--  * Set common game mode data
--  * Backup client class & weapon
--  * Kill players to apply new server settings
--  gameModeName is the game mode name to enabled.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function enabledGameMode(gameModeName, params)
    if autoPanzerDisable == 1 then
        if autoPanzerDisable["enabled"] then
            removeCallbackFunction("RunFrame", "autoPanzerDisableRunFrame")
        end
    end

    if landminesLimit == 1 then
        if landminesLimit["enabled"] then
            removeCallbackFunction("RunFrame", "checkLandminesLimitRunFrame")
        end
    end
    
    local umod_gameMode = et.trap_Cvar_Get("umod_gameMode")

    if umod_gameMode == "" and params.gameModeSettings then
        -- Backup server settings
        local fd, len = et.trap_FS_FOpenFile(
            "game_mode/server_settings.cfg", et.FS_WRITE
        )

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: game_mode/server_settings.cfg file no found / not readable!\n"
            )
        else
            for cvar, value in pairs(params.gameModeSettings) do
                local backupLine = "forcecvar " .. cvar .. " \""
                    .. tonumber(et.trap_Cvar_Get(cvar)) .. "\"\n"

                et.trap_FS_Write(backupLine, string.len(backupLine), fd)

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "forcecvar " .. cvar .. " \"" .. value .. "\"\n"
                )
            end
        end

        et.trap_FS_FCloseFile(fd)
    end

    -- Set common game mode data
    gameMode["current"] = gameModeName
    gameMode["time"]    = time["frame"]

    et.trap_SendConsoleCommand(
        et.EXEC_APPEND,
        "seta umod_gameMode \"" .. gameModeName .. "\"\n"
    )

    if not params.noBackupClient then
        -- Backup client class & weapon
        local fd, len = et.trap_FS_FOpenFile(
            "game_mode/client_settings.cfg", et.FS_WRITE
        )

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: game_mode/client_settings.cfg file no found / not readable!\n"
            )
        else
            for p = 0, clientsLimit, 1 do
                if client[p]["team"] == 1 or client[p]["team"] == 2 then
                    local clientClass = tonumber(
                        et.gentity_get(p, "sess.latchPlayerType")
                    )

                    local clientWeapon = tonumber(
                        et.gentity_get(p, "sess.latchPlayerWeapon")
                    )

                    local backupLine = client[p]["guid"] .. " - "
                        .. clientClass .. " - " .. clientWeapon .. "\n"

                    et.trap_FS_Write(backupLine, string.len(backupLine), fd)
                end
            end
        end

        et.trap_FS_FCloseFile(fd)
    end

    -- Kill players to apply new server settings
    local clientSettingsCallbackFunction

    if type(params.clientSettingsCallbackFunction) == "function" then
        clientSettingsCallbackFunction = params.clientSettingsCallbackFunction
    end

    for p = 0, clientsLimit, 1 do
        if client[p]["team"] == 1 or client[p]["team"] == 2 then
            if clientSettingsCallbackFunction ~= nil then
                clientSettingsCallbackFunction(p)
            end

            if et.gentity_get(p, "health") > 0 then
                if et.gentity_get(p, "ps.powerups", 1) > 0 then
                    et.gentity_set(p, "ps.powerups", 1, 0)
                end

                et.G_Damage(p, p, 1022, 400, 24, 0)
            end
        end
    end
end

-- Stop game mode.
--  * Reset common game mode data
--  * Restore server settings
--  * Restore client class & weapon
--  * Clean backup file of client class & weapon
--  * Kill players to apply new server settings
--  * Enable other modules if needed (auto panzer disable & landmines limit)
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function disabledGameMode(params)
    -- Reset common game mode data
    gameMode["current"]          = ""
    gameMode["weaponsList"]      = nil
    gameMode["gameModeRunFrame"] = defaultGameModeRunFrame

    et.trap_SendConsoleCommand(
        et.EXEC_APPEND,
        "seta umod_gameMode \"\"\n"
    )

    if not params.noGameModeBackup then
        -- Restore server settings
        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "exec game_mode/server_settings.cfg\n"
        )
    end

    -- Restore client class & weapon
    local fd, len = et.trap_FS_FOpenFile(
        "game_mode/client_settings.cfg", et.FS_READ
    )

    if len == -1 then
        et.G_LogPrint(
            "uMod WARNING: game_mode/client_settings.cfg file no found / not readable!\n"
        )
    elseif len == 0 then
        -- Do nothing ...
    else
        local fileStr = et.trap_FS_Read(fd, len)
        local backup = {}

        for clientGuid, clientClass, clientWeapon
          in string.gfind(fileStr, "(%x+)%s%-%s(%d+)%s%-%s(%d+)\n") do
            backup[clientGuid] = {
                ["clientClass"]  = clientClass,
                ["clientWeapon"] = clientWeapon
            }
        end

        for p = 0, clientsLimit, 1 do
            if client[p]["team"] == 1 or client[p]["team"] == 2 then
                if backup[client[p]["guid"]] then
                    et.gentity_set(
                        p,
                        "sess.latchPlayerType",
                        backup[client[p]["guid"]]["clientClass"]
                    )

                    et.gentity_set(
                        p,
                        "sess.latchPlayerWeapon",
                        backup[client[p]["guid"]]["clientWeapon"]
                    )
                end
            end
        end
    end

    et.trap_FS_FCloseFile(fd)

    -- Clean backup file of client class & weapon
    local fd, len = et.trap_FS_FOpenFile(
        "game_mode/client_settings.cfg", et.FS_WRITE
    )

    if len == -1 then
        et.G_LogPrint(
            "uMod WARNING: game_mode/client_settings.cfg file no found / not readable!\n"
        )
    else
        et.trap_FS_Write("", string.len(""), fd)
    end

    et.trap_FS_FCloseFile(fd)

    -- Kill players to apply new server settings
    for p = 0, clientsLimit, 1 do
        if client[p]["team"] == 1 or client[p]["team"] == 2 then
            if et.gentity_get(p, "health") > 0 then
                if et.gentity_get(p, "ps.powerups", 1) > 0 then
                    et.gentity_set(p, "ps.powerups", 1, 0)
                end

                et.G_Damage(p, p, 1022, 400, 24, 0)
            end
        end
    end

    if autoPanzerDisable == 1 then
        if autoPanzerDisable["enabled"] then
            addCallbackFunction({ ["RunFrame"] = "autoPanzerDisableRunFrame" })
        end
    end

    if landminesLimit == 1 then
        if landminesLimit["enabled"] then
            addCallbackFunction({ ["RunFrame"] = "checkLandminesLimitRunFrame" })
        end
    end
end

-- Called when qagame initializes.
-- Check if a game mode is select and run it again.
--  vars is the local vars of et_InitGame function.
function gameModeInitGame(vars)
    local currentGameMode = et.trap_Cvar_Get("umod_gameMode")

    local gameModeList = {
        ["panzerwar"]  = true,
        ["grenadewar"] = true,
        ["sniperwar"]  = true,
        ["stenwar"]    = true,
        ["frenzy"]     = true,
        ["lugerwar"]   = true,
        ["knifewar"]   = true
    }

    if gameModeList[currentGameMode] then
        local params = {
            ["cmdMode"]              = "console",
            ["clientNum"]            = 1022,
            ["nbArg"]                = 2,
            ["cmd"]                  = cmdPrefix .. currentGameMode,
            ["arg1"]                 = 1,
            ["broadcast2allClients"] = true,
            ["noBackupClient"]       = true
        }

        runCommandFile(params.cmd, params)
    end
end

-- Set ammo for each weapon.
--  clientNum is the client slot id.
function setWeaponAmmo(clientNum)
    for weaponNum, weaponAmmo in pairs(gameMode["weaponsList"]) do
        if weaponAmmo[1] ~= -1 then
            et.gentity_set(clientNum, "ps.ammoclip", weaponNum, weaponAmmo[1])
        end

        if weaponAmmo[2] ~= -1 then
            et.gentity_set(clientNum, "ps.ammo", weaponNum, weaponAmmo[2])
        end
    end
end

-- Callback function when qagame runs a server frame.
-- Run game mode run frame function periodically.
-- Game mode run frame function can be defaultGameModeRunFrame function
-- Or a custom function (see game mode command file).
--  vars is the local vars passed from et_RunFrame function.
function checkGameModeRunFrame(vars)
    -- Reset ammo and stuff every 0.25 of a second rather
    -- than 0.05 of a second (which caused lag)
    if vars["levelTime"] - gameMode["time"] >= 250 then
        gameMode["gameModeRunFrame"]()
        gameMode["time"] = vars["levelTime"]
    end
end

-- Default game mode RunFrame
-- Add / remove ammo with weapon list.
function defaultGameModeRunFrame()
    for p = 0, clientsLimit, 1 do
        setWeaponAmmo(p)
    end
end

-- Set default game mode RunFrame
gameMode["gameModeRunFrame"] = defaultGameModeRunFrame

-- Check game mode for enabled / disabled it.
--  gameModeName is the game mode to check.
--  action is the action to check game mode (enabled / disabled).
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function checkGameMode(gameModeName, action, params)
    if action == "enabled" then
        if gameMode["current"] ~= "" then
            local currentGM = string.gsub(gameMode["current"], "^%l", string.upper)

            if gameMode["current"] == gameModeName then
                printCmdMsg(
                    params,
                    currentGM .. " is already active"
                )
            else
                printCmdMsg(
                    params,
                    currentGM .. " must be disabled first"
                )
            end

            return false
        end
    elseif action == "disabled" then
        if gameMode["current"] ~= gameModeName then
            gameModeName = string.gsub(gameModeName, "^%l", string.upper)

            printCmdMsg(
                params,
                gameModeName .. " has already been disabled"
            )

            return false
        end
    end

    return true
end

-- Add callback game mode function.
addCallbackFunction({
    ["InitGame"] = "gameModeInitGame"
})
