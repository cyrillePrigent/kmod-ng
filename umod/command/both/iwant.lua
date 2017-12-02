-- Move directly another player to your player.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => player ID
--   * params["arg2"] => target
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: iwant \[name/PID - Destination\] \[name/PID\]\n")
    else
        targetNum = client2id(params["arg1"], params)

        if client[targetNum]['team'] ~= 1 and client[targetNum]['team'] ~= 2 then
            printCmdMsg(params, "Client (Destination) is not actively playing\n")
        else
            if et.gentity_get(targetNum, "health") <= 0 then
                printCmdMsg(params, "Client (Destination) is currently dead\n")
            else
                clientNum = client2id(params["arg2"], params)

                if client[clientNum]['team'] ~= 1 and client[clientNum]['team'] ~= 2 then
                    printCmdMsg(params, "Client (to move) is not actively playing\n")
                else
                    if et.gentity_get(clientNum, "health") <= 0 then
                        printCmdMsg(params, "Client (to move) is currently dead\n")
                    else
                        local targetOrigin = et.gentity_get(targetNum, "origin")
                        targetOrigin[2] = targetOrigin[2] + 40
                        et.gentity_set(clientNum, "origin", targetOrigin)
                    end
                end
            end
        end
    end

    return 1
end
