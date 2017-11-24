-- Enable / disabled crazygravity.
-- Require : crazygravity module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new crazygravity value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: crazygravity \[0-1\]\n")
    else
        local cgValue = tonumber(params["arg1"])

        if cgValue == 1 then
            if crazyGravity['active'] == false then
                printCmdMsg(params, "Crazygravity has been Enabled\n")
                crazyGravity['active'] = true
                crazyGravity['change'] = true
                addCallbackFunction({ ["RunFrame"] = "checkCrazyGravityRunFrame" })
            else
                printCmdMsg(params, "Crazygravity is already active\n")
            end
        elseif cgValue == 0 then
            if crazyGravity['active'] == true then
                printCmdMsg(params, "Crazygravity has been Disabled.  Resetting gravity\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity 800\n")
                crazyGravity['active'] = false
                crazyGravity['change'] = false
                removeCallbackFunction("RunFrame", "checkCrazyGravityRunFrame")
            else
                printCmdMsg(params, "Crazygravity has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
