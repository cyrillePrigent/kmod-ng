
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. spree["msg"]["oldLong"] .. "\n")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " " .. mapSpree["msg"]["oldLong"] .. "\n")

    return 1
end
