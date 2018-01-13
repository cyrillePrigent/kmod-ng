-- Private message admins
-- From kmod script.
-- Require : admins module

-- Send a private message to admins currently on server.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => private message content
function execute_command(params)
    if params.nbArg < 2 then 
        et.trap_SendServerCommand(
            params.clientNum,
            "print \"Useage: /" .. params.bangCmd .. " [message]\n"
        )
    else
        local pmContent  = et.ConcatArgs(1)
        local adminCount = 0

        for p = 0, clientsLimit, 1 do
            if getAdminLevel(p) >= 2 then
                et.trap_SendServerCommand(
                    p,
                    "chat \"^dPm to admins from "
                    .. client[params.clientNum]["name"]
                    .. "^d --> " .. color2 .. pmContent
                )

                et.G_ClientSound(p, pmSound)

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
                    "chat \"^dPm to admins has been sent"
                )

                et.G_ClientSound(params.clientNum, pmSound)
            end
        else
            et.trap_SendServerCommand(
                params.clientNum,
                "chat \"^dNo admins currently on server"
            )
        end
    end

    return 1
end
