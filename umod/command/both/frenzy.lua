-- Frenzy game mode management
-- From kmod script.
-- Require : game mode module

-- Enabled / disabled frenzy game mode.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new frenzy value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: frenzy [0-1]")
    else
        local frenzy = tonumber(params["arg1"])

        if frenzy == 1 then
            if not checkGameMode("frenzy", "enabled", params) then
                return
            end

            gameMode["weaponsList"] = {
                [2]  = { -1, 99 },  -- Luger
                [3]  = { -1, 99 },  -- MP40
                [4]  = { 99, -1 },  -- Grenade launcher (Axis grenade)
                [5]  = { 99, -1 },  -- Panzerfaust
                [6]  = { 99, -1 },  -- Flamethrower
                [7]  = { -1, 99 },  -- Colt
                [8]  = { -1, 99 },  -- Thompson
                [9]  = { 99, -1 },  -- Grenade pineapple (Allies grenade)
                [10] = { -1, 99 },  -- Sten
                [11] = { 99, -1 },  -- Medic syringe
                [14] = { -1, 99 },  -- Silenced Luger
                [23] = { -1, 99 },  -- K43
                [24] = { -1, 99 },  -- M1 Garand
                [25] = { -1, 99 },  -- Silenced M1 Garand
                [31] = { -1, 150 }, -- Mobile MG42
                [32] = { -1, 99 },  -- Silenced K43
                [33] = { -1, 99 },  -- FG42
                [35] = { -1, 98 },  -- Mortar
                [37] = { -1, 99 },  -- Akimbo Colt
                [38] = { -1, 99 },  -- Akimbo Luger
                [40] = { -1, 99 },  -- Riffle
                [41] = { -1, 99 },  -- Silenced colt
                [42] = { -1, 99 },  -- M1 Garand scope
                [43] = { -1, 99 },  -- K43 scope
                [44] = { -1, 99 },  -- FG42 scope
                [46] = { 99, -1 },  -- Medic adrenaline
                [47] = { -1, 99 },  -- Akimbo silenced Colt
                [48] = { -1, 99 },  -- Akimbo silenced Luger
            }

            params.gameModeSettings = {
                ["team_maxSoldiers"]      = -1,
                ["team_maxmortars"]       = -1,
                ["team_maxpanzers"]       = -1,
                ["team_maxflamers"]       = -1,
                ["team_maxmg42s"]         = -1,
                ["team_maxmedics"]        = -1,
                ["team_maxengineers"]     = -1,
                ["team_maxfieldops"]      = -1,
                ["team_maxcovertops"]     = -1,
                ["team_maxriflegrenades"] = -1
            }

            if etMod == "etpro" then
                params.gameModeSettings["b_riflegrenades"] = 1
            end

            enabledGameMode("frenzy", params)
            periodicFrameCallback["checkGameModePlayerRunFrame"] = "gameMode"
            addCallbackFunction({ ["RunFramePlayerLoop"] = "checkGameModePlayerRunFrame" })

            params.broadcast2allClients = true
            printCmdMsg(params, "Frenzy has been enabled")
        elseif frenzy == 0 then
            if not checkGameMode("frenzy", "disabled", params) then
                return
            end

            periodicFrameCallback["checkGameModePlayerRunFrame"] = nil
            removeCallbackFunction("RunFramePlayerLoop", "checkGameModePlayerRunFrame")
            disabledGameMode(params)

            params.broadcast2allClients = true
            printCmdMsg(params, "Frenzy has been disabled.")
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
