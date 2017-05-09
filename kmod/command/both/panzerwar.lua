

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params.command, "^3Panzerwar:^7 Disable or enable panzerwar \[0-1\]\n")
    else
        local panzerwar = tonumber(params["arg1"])

        if panzerwar == 1 then
            if gameMode ~= 'panzerwar' then
                if gameMode == 'frenzy' then
                    printCmdMsg(params.command, "^3Panzerwar:^7 Frenzy mode must be disabled first\n")
                elseif grendv == 1 then
                    printCmdMsg(params.command, "^3Panzerwar:^7 Grenadewar must be disabled first\n")
                elseif gameMode == 'sniperwar' then
                    printCmdMsg(params.command, "^3Panzerwar:^7 Sniperwar must be disabled first\n")
                else
                    local speed = originalSettings['g_speed'] * 2
                    printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has been Enabled\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics 0 ; team_maxcovertops 0 ; team_maxfieldops 0 ; team_maxengineers 0 ; team_maxflamers 0 ; team_maxmortars 0 ; team_maxmg42s 0 ; team_maxpanzers -1 ; g_speed " .. speed .. " ; forcecvar g_soldierchargetime 0\n")
                    gameMode = 'panzerwar'

                    for p = 0, clientsLimit, 1 do
                        if team[p] == 1 or team[p] == 2 then
                            originalClass[p] = tonumber(et.gentity_get(p, "sess.latchPlayerType"))
                            originalWeapon[p] = tonumber(et.gentity_get(p, "sess.latchPlayerWeapon"))

                            if et.gentity_get(p, "health") > 0 then
                                et.G_Damage(p, p, 1022, 400, 24, 0)
                                -- in case they recently spawned and are protected by spawn shield
                                et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                            end
                        end

                        et.gentity_set(p, "sess.latchPlayerType", 0)
                        et.gentity_set(p, "sess.latchPlayerWeapon", 5)
                    end
                end
            else
                printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar is already active\n")
            end
        elseif panzerwar == 0 then
            if gameMode == 'panzerwar' then
                printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has been Disabled.\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; g_speed " .. originalSettings['g_speed'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. "\n")
                gameMode = false

                for p = 0, clientsLimit, 1 do
                    if team[p] == 1 or team[p] == 2 then
                        if et.gentity_get(p, "health") >= 0 then
                            et.G_Damage(p, p, 1022, 400, 24, 0)
                            -- in case they recently spawned and are protected by spawn shield
                            et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                            et.gentity_set(p, "sess.latchPlayerType", originalClass[p])
                            et.gentity_set(p, "sess.latchPlayerWeapon", originalWeapon[p])
                        end
                    end
                end
            else
                printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has already been disabled\n" )
            end
        else
            printCmdMsg(params.command, "^3Panzerwar:^7 Valid values are \[0-1\]\n" )
        end
    end
end
