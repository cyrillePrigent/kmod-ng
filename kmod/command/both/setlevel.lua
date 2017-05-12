

-- params["arg1"] => client ID
-- params["arg2"] => level
function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Setlevel is used to set admin status to a player.\n")
            et.G_Print("useage: !setlevel \[name/PID\] \[level 0-" .. k_maxAdminLevels .. "\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel:^7 \[partname/id#\] \[level 0-" .. k_maxAdminLevels .. "\]\n")
        end

        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Setlevel', params.command, params.say)

    if clientNum ~= nil
        local level  = tonumber(params["arg2"])

        if level < 0 or level > k_maxAdminLevels then
            if params.command == 'client' then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Setlevel: ^7Admin level does not exist! \[0-" .. k_maxAdminLevels .. "\]\n")
            elseif params.command == 'console' then
                et.G_Print("Admin level does not exist! \[0-" .. k_maxAdminLevels .. "\]\n")
            end

            return 1
        end

        if level == 0 then
            setRegularUser(clientNum)
        else
            setAdmin(clientNum, level)
        end
    end

    return 1
end
