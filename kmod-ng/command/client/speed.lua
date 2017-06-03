

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Speed:^7 Changes game speed \[default = 320\]\n")
    else
        local speed = tonumber(params["arg1"])

        if speed then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_speed " .. speed .. "\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Speed:^7 Game speed has been changed to " .. speed .. "\n")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Speed:^7 Please enter in only numbers\n")
        end
    end

    return 1
end
