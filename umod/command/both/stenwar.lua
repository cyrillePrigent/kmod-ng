-- Stenwar game mode management
-- From kmod script.
-- Require : game mode module

-- Function

-- Callback function when qagame runs a server frame in player loop
-- pending warmup and round.
--  * Add / remove ammo with weapon list.
--  * Force player to use Sten weapon.
--  clientNum is the client slot id.
--  vars is the local vars passed from et_RunFrame function.
function checkStenwarPlayerRunFrame(clientNum, vars)
    for weaponNum, weaponAmmo in pairs(gameMode["weaponsList"]) do
        if weaponAmmo[1] ~= -1 then
            et.gentity_set(clientNum, "ps.ammoclip", weaponNum, weaponAmmo[1])
        end

        if weaponAmmo[2] ~= -1 then
            et.gentity_set(clientNum, "ps.ammo", weaponNum, weaponAmmo[2])
        end
    end

    et.gentity_set(clientNum, "sess.latchPlayerType", 4)
    et.gentity_set(clientNum, "sess.latchPlayerWeapon", 10)
end

-- Enabled / disabled stenwar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new stenwar value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: stenwar [0-1]")
    else
        local stenwar = tonumber(params["arg1"])

        if stenwar == 1 then
            if not checkGameMode("stenwar", "enabled", params) then
                return
            end

            gameMode["weaponsList"] = {
                [2]  = { 0, 0 },   -- Luger
                [4]  = { 0, 0 },   -- Grenade launcher (Axis grenade)
                [7]  = { 0, 0 },   -- Colt
                [9]  = { 0, 0 },   -- Grenade pineapple (Allies grenade)
                [10] = { -1, 99 }, -- Sten
                [14] = { 0, 0 },   -- Silenced Luger
                [25] = { 0, 0 },   -- Silenced M1 Garand
                [27] = { 0, 0 },   -- Satchel
                [30] = { 0, 0 },   -- Smoke bomb
                [32] = { 0, 0 },   -- Silenced K43
                [33] = { 0, 0 },   -- FG42
                [37] = { 0, 0 },   -- Akimbo Colt
                [38] = { 0, 0 },   -- Akimbo Luger
                [41] = { 0, 0 },   -- Silenced colt
                [42] = { 0, 0 },   -- M1 Garand scope
                [43] = { 0, 0 },   -- K43 scope
                [44] = { 0, 0 },   -- FG42 scope
                [47] = { 0, 0 },   -- Akimbo silenced Colt
                [48] = { 0, 0 }    -- Akimbo silenced Luger
            }

            params.gameModeSettings = {
                ["team_maxSoldiers"]      = 0,
                ["team_maxmedics"]        = 0,
                ["team_maxengineers"]     = 0,
                ["team_maxfieldops"]      = 0,
                ["team_maxcovertops"]     = -1
            }

            params.clientSettingsCallbackFunction = function(clientNum)
                et.gentity_set(clientNum, "sess.latchPlayerType", 4)
                et.gentity_set(clientNum, "sess.latchPlayerWeapon", 10)
            end

            enabledGameMode("stenwar", params)
            periodicFrameCallback["checkStenwarPlayerRunFrame"] = "gameMode"
            addCallbackFunction({ ["RunFramePlayerLoop"] = "checkStenwarPlayerRunFrame" })

            params.broadcast2allClients = true
            printCmdMsg(params, "Stenwar has been enabled")
        elseif stenwar == 0 then
            if not checkGameMode("stenwar", "disabled", params) then
                return
            end

            periodicFrameCallback["checkStenwarPlayerRunFrame"] = nil
            removeCallbackFunction("RunFramePlayerLoop", "checkStenwarPlayerRunFrame")
            disabledGameMode(params)

            _G["checkStenwarPlayerRunFrame"] = nil

            params.broadcast2allClients = true
            printCmdMsg(params, "Stenwar has been disabled.")
            collectgarbage()
        else
            printCmdMsg(params, "Valid values are [0-1]")
        end
    end

    return 1
end
