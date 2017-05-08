

function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. oldSpree['long'] .. "\n")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. oldMapSpree['long'] .. "\n")

    return 1
end
