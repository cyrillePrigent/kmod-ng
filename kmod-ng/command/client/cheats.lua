
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => cheats value
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: cheats \[0-1\]\n")
    else
        local cheat = tonumber(params["arg1"])

        if cheat == 0 or cheat == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar sv_cheats " .. cheat .. "\n")

            if cheat == 1 then
                printCmdMsg(params, "Cheats have been Enabled\n")
            else
                printCmdMsg(params, "Cheats have been Disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
