-- Panzerwar game mode management
-- From kmod script.
-- Require : game mode module

-- Function

-- Callback function when qagame runs a server frame in player loop
-- pending warmup and round.
--  * Add / remove ammo with weapon list.
--  * Force player to use Panzerfaust weapon.
--  clientNum is the client slot id.
--  vars is the local vars passed from et_RunFrame function.
function checkPanzerwarPlayerRunFrame(clientNum, vars)
    for weaponNum, weaponAmmo in pairs(gameMode["weaponsList"]) do
        if weaponAmmo[1] ~= -1 then
            et.gentity_set(clientNum, "ps.ammoclip", weaponNum, weaponAmmo[1])
        end

        if weaponAmmo[2] ~= -1 then
            et.gentity_set(clientNum, "ps.ammo", weaponNum, weaponAmmo[2])
        end
    end
    
    et.gentity_set(clientNum, "sess.latchPlayerWeapon", 5)
end

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
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: panzerwar [0-1]")
    else
        local panzerwar = tonumber(params["arg1"])

        if panzerwar == 1 then
            if not checkGameMode("panzerwar", "enabled", params) then
                return
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
            periodicFrameCallback["checkPanzerwarPlayerRunFrame"] = "gameMode"

            addCallbackFunction({
                ["RunFramePlayerLoop"] = "checkPanzerwarPlayerRunFrame",
                ["ClientSpawn"]        = "panzerwarClientSpawn"
            })

            params.broadcast2allClients = true
            printCmdMsg(params, "Panzerwar has been enabled")
        elseif panzerwar == 0 then
            if not checkGameMode("panzerwar", "disabled", params) then
                return
            end

            periodicFrameCallback["checkPanzerwarPlayerRunFrame"] = nil
            removeCallbackFunction("RunFramePlayerLoop", "checkPanzerwarPlayerRunFrame")
            removeCallbackFunction("ClientSpawn", "panzerwarClientSpawn")
            disabledGameMode(params)

            _G["panzerwarClientSpawn"]         = nil
            _G["checkPanzerwarPlayerRunFrame"] = nil

            params.broadcast2allClients = true
            printCmdMsg(params, "Panzerwar has been disabled.")
            collectgarbage()
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
