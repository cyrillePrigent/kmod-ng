

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Cheats:^7 Disable or enable cheats \[0-1\]\n")
    else
        local cheat = tonumber(params["arg1"])

        if cheat == 0 or cheat == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar sv_cheats " .. cheat .. "\n")

            if cheat == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Cheats:^7Cheats have been Enabled\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Cheats:^7Cheats have been Disabled\n")
            end
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Cheats:^7 Valid values are \[0-1\]\n")
        end
    end

    return 1
end
