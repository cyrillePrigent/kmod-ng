

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params.command, "^3Frenzy:^7 Disable or enable frenzy \[0-1\]\n" )
    else
        local frenzy = tonumber(params["arg1"])

        if frenzy == 1 then
            if gameMode ~= 'frenzy' then
                if gameMode == 'panzerwar' then
                    printCmdMsg(params.command, "^3Frenzy:^7 Panzerwar must be disabled first\n")
                elseif gameMode == 'grenadewar' then
                    printCmdMsg(params.command, "^3Frenzy:^7 Grenadewar must be disabled first\n")
                elseif gameMode == 'sniperwar' then
                    printCmdMsg(params.command, "^3Frenzy:^7 Sniperwar must be disabled first\n")
                else
                    printCmdMsg(params.command, "^3Frenzy:^7 Frenzy has been Enabled\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics -1 ; team_maxcovertops -1 ; team_maxfieldops -1 ; team_maxengineers -1 ; team_maxflamers 0 ; team_maxmortars 0 ; team_maxmg42s 0 ; team_maxpanzers 0\n")
                    gameMode = 'frenzy'

                    for p = 0, clientsLimit, 1 do
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
                printCmdMsg(params.command, "^3Frenzy:^7 Frenzy is already active\n")
            end
        elseif frenzy == 0 then
            if gameMode == 'frenzy' then
                printCmdMsg(params.command, "^3Frenzy:^7 Frenzy has been Disabled.\n")
                gameMode = false
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. "\n")

                for p = 0, clientsLimit, 1 do
                    if team[p] == 1 or team[p] == 2 then
                        if et.gentity_get(p, "health") > 0 then
                            et.G_Damage(p, p, 1022, 400, 24, 0)
                            -- in case they recently spawned and are protected by spawn shield
                            et.gentity_set(p, "health", (et.gentity_get(p, "health") - 400))
                        end
                    end
                end
            else
                printCmdMsg(params.command, "^3Frenzy:^7 Frenzy has already been disabled\n")
            end
        else
            printCmdMsg(params.command, "^3Frenzy:^7 Valid values are \[0-1\]\n")
        end
    end
end
