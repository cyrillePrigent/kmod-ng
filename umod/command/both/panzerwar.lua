-- Panzerwar game mode management
-- Require : game mode module
-- From kmod lua script.

-- Function

-- Callback function when a client is spawned.
--  vars is the local vars passed from et_ClientSpawn function.
function panzerwarClientSpawn(vars)
    et.gentity_set(
        vars["clientNum"],
        "health",
        tonumber(et.gentity_get(vars["clientNum"], "health")) * 2
    )
end

-- Enabled / disabled panzerwar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new panzerwar value
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: panzerwar [0-1]")
    else
        local panzerwar = tonumber(params["arg1"])

        if panzerwar == 1 then
            if not checkGameMode("panzerwar", "enabled", params) then
                return
            end         

            -- Custom game mode RunFrame
            --  * Add / remove ammo with weapon list.
            --  * Force player to use Panzerfaust weapon.
            gameMode["gameModeRunFrame"] = function()
                for p = 0, clientsLimit, 1 do
                    setWeaponAmmo(p)
                    et.gentity_set(p, "sess.latchPlayerWeapon", 5)
                end
            end

            gameMode["weaponsList"] = {
                [2]  = { 0, 0 },   -- Luger
                [3]  = { 0, 0 },   -- MP40
                [4]  = { 0, 0 },   -- Grenade launcher (Axis grenade)
                [5]  = { 99, -1 }, -- Panzerfaust
                [7]  = { 0, 0 },   -- Colt
                [8]  = { 0, 0 },   -- Thompson
                [9]  = { 0, 0 },   -- Grenade pineapple (Allies grenade)
                [37] = { 0, 0 },   -- Akimbo Colt
                [38] = { 0, 0 }    -- Akimbo Luger
            }

            params.gameModeSettings = {
                ["team_maxSoldiers"]      = -1,
                ["team_maxmortars"]       = 0,
                ["team_maxpanzers"]       = -1,
                ["team_maxflamers"]       = 0,
                ["team_maxmg42s"]         = 0,
                ["team_maxmedics"]        = 0,
                ["team_maxengineers"]     = 0,
                ["team_maxfieldops"]      = 0,
                ["team_maxcovertops"]     = 0,
                ["team_maxriflegrenades"] = 0,
                ["g_soldierchargetime"]   = 0,
                ["g_speed"]               = 640
            }

            params.clientSettingsCallbackFunction = function(clientNum)
                et.gentity_set(clientNum, "sess.latchPlayerType", 0)
                et.gentity_set(clientNum, "sess.latchPlayerWeapon", 5)
            end

            enabledGameMode("panzerwar", params)

            addCallbackFunction({
                ["RunFrame"]    = "checkGameModeRunFrame",
                ["ClientSpawn"] = "panzerwarClientSpawn"
            })

            params.broadcast2allClients = true
            printCmdMsg(params, "Panzerwar has been enabled")
        elseif panzerwar == 0 then
            if not checkGameMode("panzerwar", "disabled", params) then
                return
            end

            removeCallbackFunction("RunFrame", "checkGameModeRunFrame")
            removeCallbackFunction("ClientSpawn", "panzerwarClientSpawn")
            disabledGameMode(params)

            _G["panzerwarClientSpawn"] = nil

            params.broadcast2allClients = true
            printCmdMsg(params, "Panzerwar has been disabled.")
            collectgarbage()
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
