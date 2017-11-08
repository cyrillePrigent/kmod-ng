-- Global var

weaponsList = {
    nil,    --  1
    false,  --  2 WP_LUGER
    false,  --  3 WP_MP40
    false,  --  4 WP_GRENADE_LAUNCHER
    false,  --  5 WP_PANZERFAUST
    false,  --  6 WP_FLAMETHROWER
    false,  --  7 WP_COLT              // equivalent american weapon to german luger
    false,  --  8 WP_THOMPSON          // equivalent american weapon to german mp40
    false,  --  9 WP_GRENADE_PINEAPPLE
    false,  -- 10 WP_STEN              // silenced sten sub-machinegun
    false,  -- 11 WP_MEDIC_SYRINGE     // JPW NERVE -- broken out from CLASS_SPECIAL per Id request
    false,  -- 12 WP_AMMO              // JPW NERVE likewise
    false,  -- 13 WP_ARTY
    false,  -- 14 WP_SILENCER          // used to be sp5
    false,  -- 15 WP_DYNAMITE
    nil,    -- 16
    nil,    -- 17
    nil,    -- 18
    false,  -- 19 WP_MEDKIT
    false,  -- 20 WP_BINOCULARS
    nil,    -- 21
    nil,    -- 22
    false,  -- 23 WP_KAR98             // WolfXP weapons
    false,  -- 24 WP_CARBINE
    true,   -- 25 WP_GARAND
    false,  -- 26 WP_LANDMINE
    false,  -- 27 WP_SATCHEL
    nil,    -- 28 WP_SATCHEL_DET
    nil,    -- 29
    false,  -- 30 WP_SMOKE_BOMB
    false,  -- 31 WP_MOBILE_MG42
    true,   -- 32 WP_K43
    true,   -- 33 WP_FG42
    nil,    -- 34
    false,  -- 35 WP_MORTAR
    nil,    -- 36
    false,  -- 37 WP_AKIMBO_COLT
    false,  -- 38 WP_AKIMBO_LUGER
    nil,    -- 39
    nil,    -- 40
    false,  -- 41 WP_SILENCED_COLT
    true,   -- 42 WP_GARAND_SCOPE
    true,   -- 43 WP_K43_SCOPE
    true,   -- 44 WP_FG42SCOPE
    false,  -- 45 WP_MORTAR_SET
    false,  -- 46 WP_MEDIC_ADRENALINE
    false,  -- 47 WP_AKIMBO_SILENCEDCOLT
    false   -- 48 WP_AKIMBO_SILENCEDLUGER
}

gameMode["clientSettingsModified"] = true

-- Function

-- Callback function executed when qagame runs a server frame.
--  clientNum is the client slot id.
function gameModeRunFramePlayerCallback(clientNum)
    if tonumber(et.gentity_get(clientNum, "sess.latchPlayerType")) ~= 4 then
        et.gentity_set(clientNum, "sess.latchPlayerType", 4)
    end

    local latchPlayerWeapon = tonumber(et.gentity_get(clientNum, "sess.latchPlayerWeapon"))

    if latchPlayerWeapon ~= 33 and (latchPlayerWeapon ~= 32 or latchPlayerWeapon ~= 25 or latchPlayerWeapon ~= 42 or latchPlayerWeapon ~= 43) then
        if client[clientNum]["team"] == 1 then
            et.gentity_set(clientNum, "sess.latchPlayerWeapon", 32)
        elseif client[clientNum]["team"] == 2 then
            et.gentity_set(clientNum, "sess.latchPlayerWeapon", 25)
        end
    end
end

-- Enabled / disabled sniperwar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new sniperwar value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: sniperwar \[0-1\]\n")
    else
        local sniperwar = tonumber(params["arg1"])

        if sniperwar == 1 then
            if gameMode["current"] ~= 'sniperwar' then
                if not gameModeIsActive("sniperwar", params) then
                    saveServerClassSetting()
                    printCmdMsg(params, "Sniperwar has been Enabled\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics 0 ; team_maxcovertops -1 ; team_maxfieldops 0 ; team_maxengineers 0 ; team_maxSoldiers 0 ; team_maxflamers 0 ; team_maxmortars 0 ; team_maxmg42s 0 ; team_maxpanzers 0\n")
                    gameMode["current"] = 'sniperwar'

                    for p = 0, clientsLimit, 1 do
                        if client[p]['team'] == 1 or client[p]['team'] == 2 then
                            client[p]['originalClass']  = tonumber(et.gentity_get(p, "sess.latchPlayerType"))
                            client[p]['originalWeapon'] = tonumber(et.gentity_get(p, "sess.latchPlayerWeapon"))

                            if et.gentity_get(p, "health") > 0 then
                                et.G_Damage(p, p, 1022, 400, 24, 0)
                                -- in case they recently spawned and are protected by spawn shield
                                et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                            end
                        end
                    end
                end
            else
                printCmdMsg(params, "Sniperwar is already active\n")
            end
        elseif sniperwar == 0 then
            if gameMode["current"] == 'sniperwar' then
                printCmdMsg(params, "Sniperwar has been Disabled.\n")
                gameMode["current"] = false
                gameMode["clientSettingsModified"] = false
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. "\n")

                for p = 0, clientsLimit, 1 do
                    if client[p]['team'] == 1 or client[p]['team'] == 2 then
                        if et.gentity_get(p, "health") > 0 then
                            et.G_Damage(p, p, 1022, 400, 24, 0)
                            -- in case they recently spawned and are protected by spawn shield
                            et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                        end

                        et.gentity_set(p, "sess.latchPlayerType", client[p]['originalClass'])
                        et.gentity_set(p, "sess.latchPlayerWeapon", client[p]['originalWeapon'])
                    end
                end
            else
                printCmdMsg(params, "Sniperwar has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
