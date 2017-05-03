

-- getPlayernameToId


-- params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Slap is used to slap a player\n")
            et.G_Print("useage: slap \[name/PID\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Slap:^7 \[partname/id#\]\n")
        end

        return 1
    end

    local clientNum = tonumber(params["arg1"])

    if clientNum then
        if clientNum >= 0 and clientNum < 64 then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                if params.commandSaid then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Slap: ^7There is no client associated with this slot number\n")
                else
                    et.G_Print("There is no client associated with this slot number\n")
                end
                return
            end
        else
            if params.commandSaid then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Slap: ^7Please enter a slot number between 0 and 63\n")
            else
                et.G_Print("Please enter a slot number between 0 and 63\n")
            end
            return
        end
    else
        if params["arg1"] then
            s, e = string.find(params["arg1"], params["arg1"])

            if e <= 2 then
                if params.commandSaid then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Slap: ^7Player name requires more than 2 characters\n")
                else
                    et.G_Print("Player name requires more than 2 characters\n")
                end
                return
            else
                clientNum = getPlayernameToId(params["arg1"])
            end
        end

        if not clientNum then
            if params.commandSaid then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Slap: ^7Try name again or use slot number\n")
            else
                et.G_Print("Try name again or use slot number\n")
            end
            return
        end
    end

    local team = et.gentity_get(clientNum, "sess.sessionTeam")

    if team >= 3 or team < 1 then
        if params.commandSaid then
            et.trap_SendConsoleCommand( et.EXEC_APPEND, params.say .. " ^3Slap: ^7Client is not actively playing\n")
        else
            et.G_Print("Client is not actively playing\n")
        end
        return
    end

    if et.gentity_get(clientNum, "health") <= 0 then
        if params.commandSaid then
            et.trap_SendConsoleCommand( et.EXEC_APPEND, params.say .. " ^3Slap: ^7Client is currently dead\n")
        else
            et.G_Print("Client is currently dead\n")
        end
        return
    end

    et.G_Damage(clientNum, clientNum, 1022, 400, 24, 0)
    et.trap_SendServerCommand(-1, ("b 16 \"^7" .. et.gentity_get(clientNum, "pers.netname") .. " ^7was Slapped^7"))
end
