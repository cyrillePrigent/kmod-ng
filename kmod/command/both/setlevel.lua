

-- params["arg1"] => client ID
-- params["arg2"] => level
function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Setlevel is used to set admin status to a player.\n")
            et.G_Print("useage: !setlevel \[name/PID\] \[level 0-3\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel:^7 \[partname/id#\] \[level\]\n")
        end

        return 1
    end

    local clientnum = tonumber(params["arg1"])
    local level     = tonumber(params["arg2"])

    if clientnum then
        if clientnum >= 0 and clientnum < 64 then
            if et.gentity_get(clientnum, "pers.connected") ~= 2 then
                if params.commandSaid then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^Setlevel: ^7There is no client associated with this slot number\n")
                else
                    et.G_Print("There is no client associated with this slot number\n")
                end

                return 1
            end
        else
            if params.commandSaid then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel: ^7Please enter a slot number between 0 and 63\n")
            else
                et.G_Print("Please enter a slot number between 0 and 63\n")
            end
            return 1
        end
    else
        if client then
            s, e = string.find(client, client)

            if e <= 2 then
                if params.commandSaid then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel: ^7Player name requires more than 2 characters\n")
                else
                    et.G_Print("Player name requires more than 2 characters\n")
                end

                return 1
            else
                clientnum = getPlayernameToId(client)
            end
        end

        if not clientnum then
            if params.commandSaid then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel: ^7Try name again or use slot number\n")
            else
                et.G_Print("Try name again or use slot number\n")
            end

            return 1
        end
    end

    if level < 0 or level > k_maxAdminLevels then
        if params.commandSaid then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel: ^7Admin level does not exist! \[0-" .. k_maxAdminLevels .. "\]\n")
        else
            et.G_Print("Admin level does not exist! \[0-" .. k_maxAdminLevels .. "\]\n")
        end

        return 1
    end

    if level == 0 then
        setRegularUser(clientnum)
    else
        setAdmin(clientnum, level)
    end

    return 1
end
