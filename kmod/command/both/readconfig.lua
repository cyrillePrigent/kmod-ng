

function execute_command(params)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec kmod/kmod.cfg\n")
    printCmdMsg(params, "ReadConfig", "Config reloaded\n")

    executeCallbackFunction('ReadConfig')
    return 1
end
