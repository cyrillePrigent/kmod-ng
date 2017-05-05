

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Laser:^7 Disable or enable g_debugbullets \[0-1\]\n")
    else
        local laser = tonumber(params["arg1"])

        if laser == 0 or laser == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar g_debugbullets " .. laser .. "\n")

            if laser == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Laser:^7Laser has been Enabled\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Laser:^7Laser has been Disabled\n")
            end
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Laser:^7 Valid values are \[0-1\]\n")
        end
    end

    return 1
end
