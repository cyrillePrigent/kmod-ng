-- Mute permanently a player.
-- Require : mute module
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: pmute \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) >= getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "ref mute " .. clientNum .. "\n"
                )

                client[clientNum]['muteEnd'] = -1
                setMute(clientNum, -1)

                params.broadcast2allClients = true
                params.noDisplayCmd         = true

                printCmdMsg(
                    params,
                    client[clientNum]["name"] .. " ^7has been muted permanently\n"
                )
            else
                printCmdMsg(params, "Cannot mute a higher admin\n")
            end
        end
    end

    return 1
end
