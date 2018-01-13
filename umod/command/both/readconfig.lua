-- Read all configuration file and reload mod configuration.
-- From kmod script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec umod/umod.cfg\n")
    executeCallbackFunction("ReadConfig")

    params.broadcast2allClients = true
    params.noDisplayCmd         = true
    params.say                  = "cpm"

    printCmdMsg(params, "Uber Mod config reloaded\n")

    return 1
end
