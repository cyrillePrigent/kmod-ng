-- Rearm all player disarmed.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: disarm_reset \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    local count = 0

                    for i = 0, clientsLimit, 1 do
                        if client[i]["disarm"] == 1 then
                            client[i]["disarm"] = 0
                            count = count + 1
                        end
                    end

                    printCmdMsg(params, "^1" .. count .. " ^7players rearmed\n")
                end
            end
        end
    end

    return 1
end
