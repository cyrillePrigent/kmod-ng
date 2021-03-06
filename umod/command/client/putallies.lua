-- Put player to allies team.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: putallies [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if params.clientNum == clientNum
              or getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                if client[clientNum]['team'] == 1 or client[clientNum]['team'] == 3 then
                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "ref putallies " .. clientNum .. "\n"
                    )

                    params.broadcast2allClients = true

                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. color1 .. " has been putted allies\n"
                    )
                else
                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. color1 .. " is already allies\n"
                    )
                end
            else
                printCmdMsg(params, "Cannot put allies a higher admin\n")
            end
        end
    end

    return 1
end
