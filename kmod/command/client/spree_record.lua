

function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. tostring(oldspree2) .. "\n")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. tostring(oldmapspree2) .. "\n")

    return 1
end
