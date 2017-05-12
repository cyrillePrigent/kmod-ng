

function execute_command(params)
    local time = os.date("%I:%M:%S%p")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " The server time is " .. time .. "\n")
end
