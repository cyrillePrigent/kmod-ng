-- Advanced private message

-- Global var

addSlashCommand("client", "ma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("client", "pma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("console", "ma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("console", "pma", {"function", "privateMessageAdminsSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function privateMessageAdminsSlashCommand(params)
    if params.cmdMode == "client" then
        local pmContent = et.ConcatArgs(1)

        if k_logchat == 1 then
            logAdminsPrivateMessage(params.clientNum, pmContent)
        end

        local name = et.gentity_get(params.clientNum, "pers.netname")

        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 2 then
                et.trap_SendServerCommand(i, "b 8 \"^dPm to admins from " .. name .. "^d --> ^3" .. pmContent .. "^7")

                if k_advancedpms == 1 then
                    et.G_ClientSound(i, pmsound)
                end
            end
        end

        if getAdminLevel(params.clientNum) < 2 then
            et.trap_SendServerCommand(params.clientNum, "b 8 \"^dPm to admins has been sent^d --> ^3" .. pmContent .. "^7")

            if k_advancedpms == 1 then
                et.G_ClientSound(params.clientNum, pmsound)
            end
        end
    elseif params.cmdMode == "console" then
        local pmContent = et.ConcatArgs(1)

        if k_logchat == 1 then
            logAdminsPrivateMessage(1022, pmContent)
        end

        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 2 then
                et.trap_SendServerCommand(i, "b 8 \"^dPm to admins from ^1SERVER^d --> ^3" .. pmContent .. "^7")
                et.G_ClientSound(i, pmsound)
            end
        end

        et.G_Print("Private message sent to admins\n")
    end

    return 1
end
