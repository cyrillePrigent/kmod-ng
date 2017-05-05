

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knifeonly:^7 Disable or enable g_knifeonly \[0-1\]\n")
    else
        local knife = tonumber(params["arg1"])

        if knife == 0 or knife == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knifeonly " .. knife .. "\n" )

            if knife == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knifeonly:^7Knifeonly has been Enabled\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knifeonly:^7Knifeonly has been Disabled\n")
            end
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knifeonly:^7 Valid values are \[0-1\]\n")
        end
    end

    return 1
end
