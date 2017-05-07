

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params.command, "^3Sniperwar:^7 Disable or enable Sniperwar \[0-1\]\n")
    else
        local snip = tonumber(params["arg1"])

        if snip >= 0 and snip <= 1 then
            if snip == 1 then
                if snipdv == 0 then
                    if panzdv == 1 then
                        printCmdMsg(params.command, "^3Sniperwar:^7 Panzerwar must be disabled first\n")
                    elseif frenzdv == 1 then
                        printCmdMsg(params.command, "^3Sniperwar:^7 Frenzy must be disabled first\n")
                    elseif grendv == 1 then
                        printCmdMsg(params.command, "^3Sniperwar:^7 Grenadewar must be disabled first\n")
                    else
                        printCmdMsg(params.command, "^3Sniperwar:^7 Sniperwar has been Enabled\n")
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics -1 ; team_maxcovertops -1 ; team_maxfieldops -1 ; team_maxengineers -1 ; team_maxflamers 0 ; team_maxmortars 0 ; team_maxmg42s 0 ; team_maxpanzers 0\n")
                        snipdv = 1

                        for p = 0, clientsLimit, 1 do
                            originalclass[p] = tonumber(et.gentity_get(p, "sess.latchPlayerType"))
                            originalweap[p] = tonumber(et.gentity_get(p, "sess.latchPlayerWeapon"))

                            if team[p] == 1 or team[p] == 2 then
                                if et.gentity_get(p, "health") > 0 then
                                    et.G_Damage(p, p, 1022, 400, 24, 0)
                                    -- in case they recently spawned and are protected by spawn shield
                                    et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                                end
                            end
                        end
                    end
                else
                    printCmdMsg(params.command, "^3Sniperwar:^7 Sniperwar is already active\n")
                end
            else
                if snipdv == 1 then
                    printCmdMsg(params.command, "^3Sniperwar:^7 Sniperwar has been Disabled.\n")
                    snipdv = 0
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")

                    for p = 0, clientsLimit, 1 do
                        if team[p] == 1 or team[p] == 2 then
                            if et.gentity_get(p, "health") > 0 then
                                et.G_Damage(p, p, 1022, 400, 24, 0)
                                -- in case they recently spawned and are protected by spawn shield
                                et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                            end
                                et.gentity_set(p, "sess.latchPlayerType", originalclass[p])
                                et.gentity_set(p, "sess.latchPlayerWeapon", originalweap[p])
                        end
                    end
                else
                    printCmdMsg(params.command, "^3Sniperwar:^7 Sniperwar has already been disabled\n")
                end
            end
        else
            printCmdMsg(params.command, "^3Sniperwar:^7 Valid values are \[0-1\]\n")
        end
    end
end
