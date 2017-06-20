
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    local date = os.date("%x %I:%M:%S%p")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " The server date is " .. date .. "\n")

    return 1
end
