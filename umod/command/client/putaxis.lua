-- Put player to axis team.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: putaxis [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if params.clientNum == clientNum
              or getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                if client[clientNum]['team'] == 2 or client[clientNum]['team'] == 3 then
                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "ref putaxis " .. clientNum .. "\n"
                    )

                    params.broadcast2allClients = true

                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. color1 .. " has been putted axis\n"
                    )
                else
                    printCmdMsg(
                        params,
                        client[clientNum]["name"] .. color1 .. " is already axis\n"
                    )
                end
            else
                printCmdMsg(params, "Cannot put axis a higher admin\n")
            end
        end
    end

    return 1
end
