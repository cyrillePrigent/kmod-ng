-- Private message admins

-- Global var

addSlashCommand("client", "ma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("client", "pma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("client", "msga", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("console", "ma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("console", "pma", {"function", "privateMessageAdminsSlashCommand"})
addSlashCommand("console", "msga", {"function", "privateMessageAdminsSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function privateMessageAdminsSlashCommand(params)
    local pmContent = et.ConcatArgs(1)
    local clientNum

    if params.cmdMode == "client" then
        clientNum  = params.clientNum
        clientName = client[params.clientNum]["name"]
    elseif params.cmdMode == "console" then
        clientNum  = 1022
        clientName = "^1SERVER"
    end
    
    if logChatModule == 1 then
        logAdminsPrivateMessage(clientNum, pmContent)
    end

    for i = 0, clientsLimit, 1 do
        if getAdminLevel(i) >= 2 then
            et.trap_SendServerCommand(i, "b 8 \"^dPm to admins from " .. clientName .. "^d --> ^3" .. pmContent .. "^7")
            et.G_ClientSound(i, pmSound)
        end
    end

    if params.cmdMode == "client" then
        -- TODO : What ???
        if getAdminLevel(params.clientNum) < 2 then
            et.trap_SendServerCommand(params.clientNum, "b 8 \"^dPm to admins has been sent^d --> ^3" .. pmContent .. "^7")

            if advancedPm == 1 then
                et.G_ClientSound(params.clientNum, pmSound)
            end
        end
    elseif params.cmdMode == "console" then
        et.G_Print("Private message sent to admins\n")
    end

    return 1
end
