-- Global var

weaponsList = {
    nil,    --  1
    false,  --  2 WP_LUGER
    false,  --  3 WP_MP40
    true,   --  4 WP_GRENADE_LAUNCHER
    false,  --  5 WP_PANZERFAUST
    false,  --  6 WP_FLAMETHROWER
    false,  --  7 WP_COLT              // equivalent american weapon to german luger
    false,  --  8 WP_THOMPSON          // equivalent american weapon to german mp40
    true,   --  9 WP_GRENADE_PINEAPPLE
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
    false,  -- 25 WP_GARAND
    false,  -- 26 WP_LANDMINE
    false,  -- 27 WP_SATCHEL
    false,  -- 28 WP_SATCHEL_DET
    nil,    -- 29
    false,  -- 30 WP_SMOKE_BOMB
    false,  -- 31 WP_MOBILE_MG42
    false,  -- 32 WP_K43
    false,  -- 33 WP_FG42
    nil,    -- 34
    false,  -- 35 WP_MORTAR
    nil,    -- 36
    false,  -- 37 WP_AKIMBO_COLT
    false,  -- 38 WP_AKIMBO_LUGER
    nil,    -- 39
    nil,    -- 40
    false,  -- 41 WP_SILENCED_COLT
    false,  -- 42 WP_GARAND_SCOPE
    false,  -- 43 WP_K43_SCOPE
    false,  -- 44 WP_FG42SCOPE
    false,  -- 45 WP_MORTAR_SET
    false,  -- 46 WP_MEDIC_ADRENALINE
    false,  -- 47 WP_AKIMBO_SILENCEDCOLT
    false   -- 48 WP_AKIMBO_SILENCEDLUGER
}

gameMode["clientSettingsModified"] = false

-- Function

-- Callback function executed when qagame runs a server frame.
--  clientNum is the client slot id.
function gameModeRunFramePlayerCallback(clientNum)
    -- Nothing to do
end

-- Enabled / disabled grenadewar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new grenadewar value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: grenadewar \[0-1\]\n")
    else
        local grenadewar = tonumber(params["arg1"])

        if grenadewar == 1 then
            if gameMode["current"] ~= 'grenadewar' then
                if not gameModeIsActive("grenadewar", params) then
                    saveServerClassSetting()
                    printCmdMsg(params, "Grenadewar has been Enabled\n")
                    et.trap_SendConsoleCommand( et.EXEC_APPEND, "team_maxmedics -1 ; team_maxcovertops -1 ; team_maxfieldops -1 ; team_maxengineers -1 ; team_maxSoldiers -1 ; team_maxflamers -1 ; team_maxmortars -1 ; team_maxmg42s -1 ; team_maxpanzers -1\n")
                    gameMode["current"] = 'grenadewar'

                    for p = 0, clientsLimit, 1 do
                        if client[p]['team'] == 1 or client[p]['team'] == 2 then
                            if et.gentity_get(p, "health") > 0 then
                                et.G_Damage(p, p, 1022, 400, 24, 0)
                                -- in case they recently spawned and are protected by spawn shield
                                et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                            end
                        end
                    end
                end
            else
                printCmdMsg(params, "Grenadewar is already active\n")
            end
        elseif grenadewar == 0 then
            if gameMode["current"] == 'grenadewar' then
                printCmdMsg(params, "Grenadewar has been Disabled.\n")
                gameMode["current"] = false
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. "\n")

                for p = 0, clientsLimit, 1 do
                    if client[p]['team'] == 1 or client[p]['team'] == 2 then
                        if et.gentity_get(p, "health") > 0 then
                            et.G_Damage(p, p, 1022, 400, 24, 0)
                            -- in case they recently spawned and are protected by spawn shield
                            et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                        end
                    end
                end
            else
                printCmdMsg(params, "Grenadewar has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
