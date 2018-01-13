-- Enabled / disabled knifewar game mode.
-- From kmod script.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new knifewar value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: knifewar [0-1]")
    else
        local knifewar = tonumber(params["arg1"])

        if knifewar == 1 then
            if not checkGameMode("knifewar", "enabled", params) then
                return
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly 1\n")

            gameMode["weaponsList"] = {
                [11] = { 0, 0 }, -- Medic syringe
                [15] = { 0, 0 }, -- Dynamite
                [19] = { 0, 0 }, -- Medkit
                [46] = { 0, 0 }  -- Medic adrenaline    
            }

            params.gameModeSettings = {
                ["team_maxSoldiers"]      = -1,
                ["team_maxmortars"]       = 0,
                ["team_maxpanzers"]       = 0,
                ["team_maxflamers"]       = 0,
                ["team_maxmg42s"]         = 0,
                ["team_maxmedics"]        = -1,
                ["team_maxengineers"]     = -1,
                ["team_maxfieldops"]      = 0,
                ["team_maxcovertops"]     = -1,
                ["team_maxriflegrenades"] = 0
            }

            if etMod == "etpro" then
                params.gameModeSettings["b_riflegrenades"] = 0
            else
                gameMode["weaponsList"][40] = { 0, 0 }
            end

            enabledGameMode("knifewar", params)
            addCallbackFunction({ ["RunFrame"] = "checkGameModeRunFrame" })

            params.broadcast2allClients = true
            printCmdMsg(params, "Knifewar has been enabled")
        elseif knifewar == 0 then
            if not checkGameMode("knifewar", "disabled", params) then
                return
            end

            params.noGameModeBackup = true

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly 0\n")

            removeCallbackFunction("RunFrame", "checkGameModeRunFrame")
            disabledGameMode(params)

            params.broadcast2allClients = true
            printCmdMsg(params, "Knifewar has been disabled.")
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
