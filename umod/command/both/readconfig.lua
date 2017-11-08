-- Read all configuration file and reload mod configuration.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec umod/umod.cfg\n")
    executeCallbackFunction("ReadConfig")
    printCmdMsg(params, "Config reloaded\n")

    return 1
end
