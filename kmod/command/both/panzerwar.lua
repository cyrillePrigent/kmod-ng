

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params.command, "^3Panzerwar:^7 Disable or enable panzerwar \[0-1\]\n")
    else
        local panz = tonumber(params["arg1"])
        local dspeed = (speed * 2)

        if panz >= 0 and panz <= 1 then
            if panz == 1 then
                if panzdv == 0 then
                    if frenzdv == 1 then
                        printCmdMsg(params.command, "^3Panzerwar:^7 Frenzy mode must be disabled first\n")
                    elseif grendv == 1 then
                        printCmdMsg(params.command, "^3Panzerwar:^7 Grenadewar must be disabled first\n")
                    elseif snipdv == 1 then
                        printCmdMsg(params.command, "^3Panzerwar:^7 Sniperwar must be disabled first\n")
                    else
                        printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has been Enabled\n")
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics 0 ; team_maxcovertops 0 ; team_maxfieldops 0 ; team_maxengineers 0 ; team_maxflamers 0 ; team_maxmortars 0 ; team_maxmg42s 0 ; team_maxpanzers -1 ; g_speed " .. dspeed .. " ; forcecvar g_soldierchargetime 0\n")
                        panzdv = 1

                        for p = 0, clientsLimit, 1 do
                            if team[p] == 1 or team[p] == 2 then
                                originalclass[p] = tonumber(et.gentity_get(p, "sess.latchPlayerType"))
                                originalweap[p] = tonumber(et.gentity_get(p, "sess.latchPlayerWeapon"))

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
            else
                if panzdv == 1 then
                    printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has been Disabled.\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; g_speed " .. speed .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")
                    panzdv = 0

                    for p = 0, clientsLimit, 1 do
                        if team[p] == 1 or team[p] == 2 then
                            if et.gentity_get(p, "health") >= 0 then
                                et.G_Damage(p, p, 1022, 400, 24, 0)
                                -- in case they recently spawned and are protected by spawn shield
                                et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                                et.gentity_set(p, "sess.latchPlayerType", originalclass[p])
                                et.gentity_set(p, "sess.latchPlayerWeapon", originalweap[p])
                            end
                        end
                    end
                else
                    printCmdMsg(params.command, "^3Panzerwar:^7 Panzerwar has already been disabled\n" )
                end
            end
        else
            printCmdMsg(params.command, "^3Panzerwar:^7 Valid values are \[0-1\]\n" )
        end
    end
end
