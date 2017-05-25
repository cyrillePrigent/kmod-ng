

function execute_command(params)
    if params.command == 'console' then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec kmod/kmod.cfg\n")
        et.G_Print("^3ReadConfig:^7 Config reloaded\n")
    elseif params.command == 'client' then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec kmod/kmod.cfg ; qsay ^3ReadConfig:^7 Config reloaded\n")
    end

    executeCallbackFunction('ReadConfig')
    return 1
end
