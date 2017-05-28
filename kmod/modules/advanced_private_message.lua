-- Private message admins

-- Global var

slashCommand["m"]   = { "function", "privateMessageSlashCommand" }
slashCommand["pm"]  = { "function", "privateMessageSlashCommand" }
slashCommand["msg"] = { "function", "privateMessageSlashCommand" }

slashCommandConsole["m"]   = { "function", "privateMessageSlashCommand" }
slashCommandConsole["pm"]  = { "function", "privateMessageSlashCommand" }
slashCommandConsole["msg"] = { "function", "privateMessageSlashCommand" }
slashCommandConsole["m2"]  = { "function", "privateMessageSlashCommand" }

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function privateMessageSlashCommand(params)
    if params.cmdMode == "console" and (params.cmd == "m" or params.cmd == "pm" or params.cmd == "msg") then
        if k_logchat == 1 then
            logPrivateMessage(params["arg2"], pmContent, et.trap_Argv(1))
        end

        return 0
    end

    if params.nbArg < 2 then
        if params.cmdMode == "client" then
            et.trap_SendServerCommand(params.clientNum, "print \"Useage:  /m \[pname/ID\] \[message\]\n")
        elseif params.cmdMode == "console" then
            et.G_Print("Useage:  /m \[pname/ID\] \[message\]\n")
        end
    else
        target = et.trap_Argv(1)

        if params.cmdMode == "client" then
            clientNum = params.clientNum
        elseif params.cmdMode == "console" then
            clientNum = 1022
        end

        local pmContent = et.ConcatArgs(2)
        local targetNum = tonumber(target)

        if targetNum then
            if targetNum >= 0 and targetNum < 64 then
                if et.gentity_get(targetNum, "pers.connected") ~= 2 then
                    if params.cmdMode == 'client' then
                        et.trap_SendServerCommand(clientNum, "print \"There is no client associated with this slot number\n")
                    elseif params.cmdMode == 'console' then
                        et.G_Print("There is no client associated with this slot number\n")
                    end

                    return 1
                end
            else
                if params.cmdMode == 'client' then
                    et.trap_SendServerCommand(clientNum, "print \"Please enter a slot number between 0 and 63\n")
                elseif params.cmdMode == 'console' then
                    et.G_Print("Please enter a slot number between 0 and 63\n")
                end

                return 1
            end
        else
            if target then
                s, e = string.find(target, target)

                if e <= 2 then
                    if params.cmdMode == 'client' then
                        et.trap_SendServerCommand(clientNum, "print \"Player name requires more than 2 characters\n")
                    elseif params.cmdMode == 'console' then
                        et.G_Print("Player name requires more than 2 characters\n")
                    end

                    return 1
                else
                    targetNum = getPlayernameToId(target)
                end
            end

            if not targetNum then
                if params.cmdMode == 'client' then
                    et.trap_SendServerCommand(clientNum, "print \"Try name again or use slot number\n")
                elseif params.cmdMode == 'console' then
                    et.G_Print("Try name again or use slot number\n")
                end

                return 1
            end
        end

        local name  = et.gentity_get(clientNum, "pers.netname")
        local rname = et.gentity_get(targetNum, "pers.netname")

        if k_logchat == 1 then
            logPrivateMessage(params["arg2"], pmContent, nil, rname)
        end

        if clientNum == 1022 then
            name = "^1SERVER"
        end

        if params.cmdMode == 'client' then
            if clientNum ~= 1022 then
                et.trap_SendServerCommand(clientNum, "b 8 \"^dPrivate message sent to " .. rname .. "^d --> ^3" .. pmContent .. "^7")
                et.G_ClientSound(clientNum, pmSound)
            end
        elseif params.cmdMode == 'console' then
            et.G_Print("Private message sent to " .. rname .. "^d --> ^3" .. pmContent .. "^7\n")
        end

        et.trap_SendServerCommand(targetNum, "b 8 \"^dPrivate message from " .. name .. "^d --> ^3" .. pmContent .. "^7")
        et.G_ClientSound(targetNum, pmSound)
    end

    return 1
end
