-- Enabled / disabled knifewar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new knifewar value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: knifewar \[0-1\]\n")
    else
        local knifewar = tonumber(params["arg1"])

        if knifewar == 1 then
            if gameMode["current"] ~= 'knifewar' then
                if not gameModeIsActive("knifewar", params) then
                    if autoPanzerDisable == 1 then
                        removeCallbackFunction("RunFrame", "autoPanzerDisableRunFrame")
                    end

                    saveServerClassSetting()
                    addCallbackFunction({ ["RunFrame"] = "checkGameModeRunFrame" })
                    printCmdMsg(params, "Knifewar has been Enabled\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly 1\n")
                    gameMode["current"] = 'knifewar'

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
                printCmdMsg(params, "Knifewar is already active\n")
            end
        elseif knifewar == 0 then
            if gameMode["current"] == 'knifewar' then
                printCmdMsg(params, "Knifewar has been Disabled.\n")
                gameMode["current"] = false
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. originalSettings['team_maxmedics'] .. " ; team_maxcovertops " .. originalSettings['team_maxcovertops'] .. " ; team_maxfieldops " .. originalSettings['team_maxfieldops'] .. " ; team_maxengineers " .. originalSettings['team_maxengineers'] .. " ; team_maxflamers " .. originalSettings['team_maxflamers'] .. " ; team_maxmortars " .. originalSettings['team_maxmortars'] .. " ; team_maxmg42s " .. originalSettings['team_maxmg42s'] .. " ; team_maxpanzers " .. originalSettings['team_maxpanzers'] .. " ; forcecvar g_soldierchargetime " .. originalSettings['g_soldierchargetime'] .. " ; g_knifeonly 0\n")

                removeCallbackFunction("RunFrame", "checkGameModeRunFrame")

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

                if autoPanzerDisable == 1 then
                    addCallbackFunction({ ["RunFrame"] = "autoPanzerDisableRunFrame" })
                end
            else
                printCmdMsg(params, "Knifewar has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
