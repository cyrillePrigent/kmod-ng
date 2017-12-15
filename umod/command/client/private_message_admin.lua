-- Private message admins
-- From kmod lua script.

-- Send a private message to admins currently on server.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => private message content
function execute_command(params)
    if params.nbArg < 2 then 
        et.trap_SendServerCommand(
            params.clientNum,
            "print \"Useage: /" .. params.bangCmd .. " \[message\]\n"
        )
    else
        local pmContent  = et.ConcatArgs(1)
        local adminCount = 0

        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 2 then
                et.trap_SendServerCommand(
                    i,
                    msgCmd["chatArea"] .. "\"^dPm to admins from "
                    .. client[params.clientNum]["name"]
                    .. "^d --> ^3" .. pmContent .. "^7"
                )

                et.G_ClientSound(i, pmSound)

                adminCount = adminCount + 1
            end
        end

        if adminCount > 0 then
            if logChatModule == 1 then
                logAdminsPrivateMessage(params.clientNum, pmContent)
            end

            if getAdminLevel(params.clientNum) < 2 then
                et.trap_SendServerCommand(
                    params.clientNum,
                    msgCmd["chatArea"] .. "\"^dPm to admins has been sent"
                )

                et.G_ClientSound(params.clientNum, pmSound)
            end
        else
            et.trap_SendServerCommand(
                params.clientNum,
                msgCmd["chatArea"] .. "\"^dNo admins currently on server"
            )
        end
    end

    return 1
end
