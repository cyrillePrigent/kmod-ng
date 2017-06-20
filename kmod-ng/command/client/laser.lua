
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => laser value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: laser \[0-1\]\n")
    else
        local laser = tonumber(params["arg1"])

        if laser == 0 or laser == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar g_debugbullets " .. laser .. "\n")

            if laser == 1 then
                printCmdMsg(params, "Laser has been Enabled\n")
            else
                printCmdMsg(params, "Laser has been Disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
