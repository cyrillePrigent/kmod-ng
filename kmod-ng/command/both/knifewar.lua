-- Enabled / disabled knifewar game mode.
-- Require : game mode module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new knifewar value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: knifewar \[0-1\]\n")
    else
        local knife = tonumber(params["arg1"])

        if knife == 0 or knife == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly " .. knife .. "\n" )

            if knife == 1 then
                gameMode["current"] = 'knifewar'
                printCmdMsg(params, "Knifewar has been Enabled\n")
            else
                gameMode["current"] = false
                printCmdMsg(params, "Knifewar has been Disabled\n")
            end

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
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
