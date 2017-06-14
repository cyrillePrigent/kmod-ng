

function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Crazygravity", "Disable or enable crazygravity \[0-1\]\n")
    else
        local cgValue = tonumber(params["arg1"])

        if crazyGravity == nil then
            dofile(kmod_ng_path .. '/modules/crazygravity.lua')
        end

        if cgValue == 1 then
            if crazyGravity['active'] == false then
                printCmdMsg(params, "Crazygravity", "Crazygravity has been Enabled\n")
                crazyGravity['active'] = true
                crazyGravity['change'] = true
            else
                printCmdMsg(params, "Crazygravity", "Crazygravity is already active\n")
            end
        elseif cgValue == 0 then
            if crazyGravity['active'] == true then
                printCmdMsg(params, "Crazygravity", "Crazygravity has been Disabled.  Resetting gravity\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity 800\n")
                crazyGravity['active'] = false
                crazyGravity['change'] = false
            else
                printCmdMsg(params, "Crazygravity", "Crazygravity has already been disabled\n")
            end
        else
            printCmdMsg(params, "Crazygravity", "Valid values are \[0-1\]\n")
        end
    end
end
