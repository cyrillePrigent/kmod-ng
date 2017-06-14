

function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params, "Knifewar", "Disable or enable knifewar \[0-1\]\n")
    else
        local knife = tonumber(params["arg1"])

        if knife == 0 or knife == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly " .. knife .. "\n" )

            if knife == 1 then
                printCmdMsg(params, "Knifewar", "Knifewar has been Enabled\n")
            else
                printCmdMsg(params, "Knifewar", "Knifewar has been Disabled\n")
            end
        else
            printCmdMsg(params, "Knifewar", "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
