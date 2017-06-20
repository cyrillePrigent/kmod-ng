-- Move directly another player to your player.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => player ID
--   * params["arg2"] => target
function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: iwant \[name/PID - Destination\] \[name/PID\]\n")
    else
        targetNum = client2id(params["arg1"], params)

        if client[targetNum]['team'] >= 3 or client[targetNum]['team'] < 1 then
            printCmdMsg(params, "Client is not actively playing\n")
        else
            if et.gentity_get(targetNum, "health") <= 0 then
                printCmdMsg(params, "Client is currently dead\n")
            else
                local targetOrigin = et.gentity_get(targetNum, "origin")
                targetOrigin[2] = targetOrigin[2] + 40
                et.gentity_set(params["arg2"], "origin", targetOrigin)
            end
        end
    end

    return 1
end
