

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Timelimit:^7 \[time\]\n")
    else
        local timeLimit = tonumber(params["arg1"])

        if timeLimit then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "timelimit " .. timeLimit .. "\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Timelimit:^7 Timelimit has been changed to " .. timeLimit .. "\n")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Timelimit:^7 Please enter in only numbers\n")
        end
    end

    return 1
end
