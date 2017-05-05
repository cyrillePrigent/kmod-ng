

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gravity:^7 Changes the gravity \[default = 800\]\n")
    else
        local grav = tonumber(params["arg1"])

        if grav then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity " .. grav .. "\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gravity:^7 Gravity has been changed to " .. grav .. "\n")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gravity:^7 Please enter in only numbers\n")
        end
    end

    return 1
end
