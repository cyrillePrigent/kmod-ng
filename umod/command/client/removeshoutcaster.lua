-- Remove the shoutcaster spectator type rights from to the player.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removeshoutcaster \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            -- et.CS_PLAYERS = 689
            if tonumber(et.Info_ValueForKey(et.trap_GetConfigstring(689 + clientNum), "sc")) == 0 then
                printCmdMsg(
                    params,
                    string.format(
                        "^7%s ^7is not shoutcaster.\n",
                        client[clientNum]["name"]
                    )
                )
            else
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "ref removeshoutcaster " .. clientNum .. "\n"
                )
            end
        end
    end

    return 1
end
