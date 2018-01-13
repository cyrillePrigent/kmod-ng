-- Unmute a player.
-- From kmod script.
-- Optional : mute module
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: unmute [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if muteModule == 1 then
                removeMute(clientNum)
            end

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "ref unmute " .. clientNum .. "\n"
            )

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(
                params,
                client[clientNum]["name"] .. color1 .. " has been unmuted\n"
            )
        end
    end

    return 1
end
