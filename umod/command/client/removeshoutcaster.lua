-- Remove the shoutcaster spectator type rights from to the player.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removeshoutcaster [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            -- et.CS_PLAYERS = 689
            if tonumber(et.Info_ValueForKey(et.trap_GetConfigstring(689 + clientNum), "sc")) == 0 then
                printCmdMsg(
                    params,
                    color1 .. client[clientNum]["name"] .. color1 ..
                    " is not shoutcaster.\n"
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
