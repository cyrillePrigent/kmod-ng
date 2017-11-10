-- Disarm a player.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: disarm \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] >= 3 or client[clientNum]['team'] < 1 then
                printCmdMsg(params, "Client is not actively playing\n")
            else
                if et.gentity_get(clientNum, "health") <= 0 then
                    printCmdMsg(params, "Client is currently dead\n")
                else
                    if client[clientNum]["disarm"] == 1 then
                        et.trap_SendServerCommand(-1, "b 16 \"^7" .. client[clientNum]["name"] .. " ^7is already Disarmed^7")
                    else
                        client[clientNum]["disarm"] = 1
                        et.trap_SendServerCommand(-1, "b 16 \"^7" .. client[clientNum]["name"] .. " ^7was Disarmed^7")
                    end
                end
            end
        end
    end

    return 1
end
