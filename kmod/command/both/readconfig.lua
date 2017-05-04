

function execute_command(params)
    if params.command == 'console' then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec kmod.cfg\n")
        et.G_Print("^3ReadConfig:^7 Config reloaded\n")
    elseif params.command == 'client' then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "exec kmod.cfg ; qsay ^3ReadConfig:^7 Config reloaded\n")
    end

    readConfig()
    return 1
end
