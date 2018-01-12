-- Private message admins
-- From kmod lua script.

-- Send a private message to admins currently on server.
--  params is parameters passed from et_ConsoleCommand function.
--   * params["arg1"] => private message content
function execute_command(params)
    if params.nbArg < 2 then 
        et.G_Print("Useage: /" .. params.cmd .. " \[message\]\n")
    else
        local pmContent  = et.ConcatArgs(1)
        local adminCount = 0

        for p = 0, clientsLimit, 1 do
            if getAdminLevel(p) >= 2 then
                et.trap_SendServerCommand(
                    p,
                    msgCmd["chatArea"] .. "\"^dPm to admins from ^1SERVER ^d--> ^3"
                    .. pmContent .. "^7"
                )

                et.G_ClientSound(p, pmSound)

                adminCount = adminCount + 1
            end
        end

        if adminCount > 0 then
            if logChatModule == 1 then
                logAdminsPrivateMessage(1022, pmContent)
            end

            et.G_Print("Private message sent to admins\n")
        else
            et.G_Print("No admins currently on server\n")
        end
    end

    return 1
end
