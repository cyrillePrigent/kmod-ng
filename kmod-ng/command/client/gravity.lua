
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => gravity value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: gravity \[value\]\nDefault : 800\n")
    else
        local grav = tonumber(params["arg1"])

        if grav then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity " .. grav .. "\n")
            printCmdMsg(params, "Gravity has been changed to " .. grav .. "\n")
        else
            printCmdMsg(params, "Please enter in only numbers\n")
        end
    end

    return 1
end
