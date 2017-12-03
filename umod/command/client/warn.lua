-- Warn a player.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => reason
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: warn \[partname/id#\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    string.format(
                        "ref warn \"%s\" \"%s\"\n",
                        string.lower(et.Q_CleanStr(client[clientNum]["name"])),
                        params["arg2"]
                    )
                )
            else
                printCmdMsg(params, "Cannot warn a higher admin\n")
            end
        end
    end

    return 1
end
