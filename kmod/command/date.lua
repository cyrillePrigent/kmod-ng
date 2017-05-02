

function execute_command(params)
    local date = os.date("%x %I:%M:%S%p")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " The server date is " .. date .. "\n")
end
