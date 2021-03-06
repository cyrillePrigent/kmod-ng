-- Add the shoutcaster spectator type rights from to the player.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: makeshoutcaster [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if client[clientNum]['team'] ~= 3 then
                printCmdMsg(params, "Only spectators can be shoutcasters.\n")
            else
                -- NOTE : et.CS_PLAYERS = 689
                if tonumber(et.Info_ValueForKey(et.trap_GetConfigstring(689 + clientNum), "sc")) == 1 then
                    printCmdMsg(
                        params,
                        color1 .. client[clientNum]["name"] .. color1 ..
                        " is already shoutcaster.\n"
                    )
                else
                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "ref makeshoutcaster " .. clientNum .. "\n"
                    )
                end
            end
        end
    end

    return 1
end
