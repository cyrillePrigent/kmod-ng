-- Private message admins
-- From kmod script.
-- Require : admins module

-- Send a private message to admins currently on server.
--  params is parameters passed from et_ConsoleCommand function.
--   * params["arg1"] => private message content
function execute_command(params)
    if params.nbArg < 2 then 
        et.G_Print("Useage: /" .. params.cmd .. " [message]\n")
    else
        local pmContent  = et.ConcatArgs(1)
        local adminCount = 0

        for p = 0, clientsLimit, 1 do
            if getAdminLevel(p) >= 2 then
                et.trap_SendServerCommand(
                    p,
                    "chat \"^dPm to admins from " ..
                    color1 .. "SERVER ^d--> " .. color2 .. pmContent
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
