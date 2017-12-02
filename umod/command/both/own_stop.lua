-- Stop ownage player.
--  From gw_ref lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: own_stop \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    if client[clientNum]["own"] == 0 then
                        printCmdMsg(
                            params,
                            client[clientNum]["name"] .. " ^7is not Owned^7"
                        )
                    else
                        client[clientNum]["own"] = 0

                        params.broadcast2allClients = true
                        params.noDisplayCmd         = true
                        params.say                  = "cpm"

                        printCmdMsg(
                            params,
                            client[clientNum]["name"] .. " ^7was Ownage stopped^7"
                        )
                    end
                end
            end
        end
    end

    return 1
end
