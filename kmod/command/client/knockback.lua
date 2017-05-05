

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knockback:^7 Changes knockback \[default = 1000\]\n")
    else
        local knockback = tonumber(params["arg1"])

        if knockback then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_knockback " .. knockback .. "\n" )
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knockback:^7 Knockback has been changed to " .. knockback .. "\n")
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Knockback:^7 Please enter in only numbers\n")
        end
    end

    return 1
end
