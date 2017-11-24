-- Global var

weaponsList = {
    nil,    --  1
    true,   --  2 WP_LUGER
    true,   --  3 WP_MP40
    true,   --  4 WP_GRENADE_LAUNCHER
    true,   --  5 WP_PANZERFAUST
    true,   --  6 WP_FLAMETHROWER
    true,   --  7 WP_COLT              // equivalent american weapon to german luger
    true,   --  8 WP_THOMPSON          // equivalent american weapon to german mp40
    true,   --  9 WP_GRENADE_PINEAPPLE
    true,   -- 10 WP_STEN              // silenced sten sub-machinegun
    true,   -- 11 WP_MEDIC_SYRINGE     // JPW NERVE -- broken out from CLASS_SPECIAL per Id request
    true,   -- 12 WP_AMMO              // JPW NERVE likewise
    true,   -- 13 WP_ARTY
    true,   -- 14 WP_SILENCER          // used to be sp5
    true,   -- 15 WP_DYNAMITE
    nil,    -- 16
    nil,    -- 17
    nil,    -- 18
    true,   -- 19 WP_MEDKIT
    true,   -- 20 WP_BINOCULARS
    nil,    -- 21
    nil,    -- 22
    true,   -- 23 WP_KAR98             // WolfXP weapons
    true,   -- 24 WP_CARBINE
    true,   -- 25 WP_GARAND
    true,   -- 26 WP_LANDMINE
    true,   -- 27 WP_SATCHEL
    true,   -- 28 WP_SATCHEL_DET
    nil,    -- 29
    true,   -- 30 WP_SMOKE_BOMB
    true,   -- 31 WP_MOBILE_MG42
    true,   -- 32 WP_K43
    true,   -- 33 WP_FG42
    nil,    -- 34
    true,   -- 35 WP_MORTAR
    nil,    -- 36
    true,   -- 37 WP_AKIMBO_COLT
    true,   -- 38 WP_AKIMBO_LUGER
    nil,    -- 39
    nil,    -- 40
    true,   -- 41 WP_SILENCED_COLT
    true,   -- 42 WP_GARAND_SCOPE
    true,   -- 43 WP_K43_SCOPE
    true,   -- 44 WP_FG42SCOPE
    true,   -- 45 WP_MORTAR_SET
    false,  -- 46 WP_MEDIC_ADRENALINE
    true,   -- 47 WP_AKIMBO_SILENCEDCOLT
    true    -- 48 WP_AKIMBO_SILENCEDLUGER
}

gameMode["clientSettingsModified"] = false

-- Function

-- Callback function executed when qagame runs a server frame.
--  clientNum is the client slot id.
function gameModeRunFramePlayerCallback(clientNum)
    -- Nothing to do
end

-- Enabled / disabled frenzy game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new frenzy value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: frenzy \[0-1\]\n")
    else
        local frenzy = tonumber(params["arg1"])

        if frenzy == 1 then
            if gameMode["current"] ~= 'frenzy' then
                if not gameModeIsActive("frenzy", params) then
                    if autoPanzerDisable == 1 then
                        removeCallbackFunction("RunFrame", "autoPanzerDisableRunFrame")
                    end

                    saveServerClassSetting()
                    addCallbackFunction({ ["RunFrame"] = "checkGameModeRunFrame" })
                    printCmdMsg(params, "Frenzy has been Enabled\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics -1 ; team_maxcovertops -1 ; team_maxfieldops -1 ; team_maxengineers -1 ; team_maxSoldiers -1 ; team_maxflamers -1 ; team_maxmortars -1 ; team_maxmg42s -1 ; team_maxpanzers -1\n")
                    gameMode["current"] = 'frenzy'

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
                printCmdMsg(params, "Frenzy is already active\n")
            end
        elseif frenzy == 0 then
            if gameMode["current"] == 'frenzy' then
                printCmdMsg(params, "Frenzy has been Disabled.\n")
                gameMode["current"] = false
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. "\n")

                removeCallbackFunction("RunFrame", "checkGameModeRunFrame")

                for p = 0, clientsLimit, 1 do
                    if client[p]['team'] == 1 or client[p]['team'] == 2 then
                        if et.gentity_get(p, "health") > 0 then
                            et.G_Damage(p, p, 1022, 400, 24, 0)
                            -- in case they recently spawned and are protected by spawn shield
                            et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                        end
                    end
                end

                if autoPanzerDisable == 1 then
                    addCallbackFunction({ ["RunFrame"] = "autoPanzerDisableRunFrame" })
                end
            else
                printCmdMsg(params, "Frenzy has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
