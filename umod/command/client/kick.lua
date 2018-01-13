-- Kick temporary a player from the server.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => reason
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: kick [partname/id#] [reason] [time]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                kick(clientNum, params["arg2"], params["arg3"])
            else
                printCmdMsg(params, "Cannot kick a higher admin\n")
            end
        end
    end

    return 1
end
