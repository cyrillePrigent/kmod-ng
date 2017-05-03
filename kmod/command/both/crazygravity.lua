

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params.command, "^3Crazygravity:^7 Disable or enable crazygravity \[0-1\]\n")
    else
        local crazy = tonumber(params["arg1"])

        if crazy >= 0 and crazy <= 1 then
            if crazy == 1 then
                if CGactive == 0 then
                    printCmdMsg(params.command, "^3Crazygravity:^7 Crazygravity has been Enabled\n")
                    crazygravity = true
                    crazydv = 1
                else
                    printCmdMsg(params.command, "^3Crazygravity:^7 Crazygravity is already active\n")
                end
            else
                if CGactive == 1 then
                    printCmdMsg(params.command, "^3Crazygravity:^7 Crazygravity has been Disabled.  Resetting gravity\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity 800\n")
                    crazygravity = false
                    crazydv = 0
                else
                    printCmdMsg(params.command, "^3Crazygravity:^7 Crazygravity has already been disabled\n")
                end
            end
        else
            printCmdMsg(params.command, "^3Crazygravity:^7 Valid values are \[0-1\]\n")
        end
    end
end
