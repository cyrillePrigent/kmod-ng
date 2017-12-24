-- Lugerwar game mode management
-- Require : game mode module
-- From kmod lua script.

-- Function

-- Enabled / disabled lugerwar game mode.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new lugerwar value
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: lugerwar [0-1]")
    else
        local lugerwar = tonumber(params["arg1"])

        if lugerwar == 1 then
            if not checkGameMode("lugerwar", "enabled", params) then
                return
            end

            gameMode["weaponsList"] = {
                [2]  = { -1, 99 }, -- Luger
                [3]  = { 0, 0 },   -- MP40
                [4]  = { 0, 0 },   -- Grenade launcher (Axis grenade)
                [7]  = { -1, 99 }, -- Colt
                [8]  = { 0, 0 },   -- Thompson
                [9]  = { 0, 0 },   -- Grenade pineapple (Allies grenade)
                [10] = { 0, 0 },   -- Sten
                [11] = { 0, 0 },   -- Medic syringe
                [14] = { 0, 0 },   -- Silenced Luger
                [15] = { 0, 0 },   -- Dynamite
                [19] = { 0, 0 },   -- Medkit
                [23] = { 0, 0 },   -- K43
                [24] = { 0, 0 },   -- M1 Garand
                [25] = { 0, 0 },   -- Silenced M1 Garand
                [26] = { 0, 0 },   -- Landmine
                [27] = { 0, 0 },   -- Satchel
                [30] = { 0, 0 },   -- Smoke bomb
                [32] = { 0, 0 },   -- Silenced K43
                [33] = { 0, 0 },   -- FG42
                [37] = { -1, 99 }, -- Akimbo Colt
                [38] = { -1, 99 }, -- Akimbo Luger
                [41] = { 0, 0 },   -- Silenced colt
                [42] = { 0, 0 },   -- M1 Garand scope
                [43] = { 0, 0 },   -- K43 scope
                [44] = { 0, 0 },   -- FG42 scope
                [46] = { 0, 0 },   -- Medic adrenaline
                [47] = { -1, 99 }, -- Akimbo silenced Colt
                [48] = { -1, 99 }  -- Akimbo silenced Luger
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

            enabledGameMode("lugerwar", params)
            addCallbackFunction({ ["RunFrame"] = "checkGameModeRunFrame" })

            params.broadcast2allClients = true
            printCmdMsg(params, "Lugerwar has been enabled")
        elseif lugerwar == 0 then
            if not checkGameMode("lugerwar", "disabled", params) then
                return
            end

            removeCallbackFunction("RunFrame", "checkGameModeRunFrame")
            disabledGameMode(params)

            params.broadcast2allClients = true
            printCmdMsg(params, "Lugerwar has been disabled.")
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
