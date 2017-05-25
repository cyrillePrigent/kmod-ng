

-- params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Slap is used to slap a player\n")
            et.G_Print("useage: slap \[name/PID\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Slap:^7 \[partname/id#\]\n")
        end

        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Slap', params)

    if clientNum ~= nil
        if client[clientNum]['team'] ~= 1 and client[clientNum]['team'] ~= 2 then
            printCmdMsg(params, "Slap", "Client is not actively playing\n")

            return 1
        end

        if et.gentity_get(clientNum, "health") <= 0 then
            printCmdMsg(params, "Slap", "Client is currently dead\n")

            return 1
        end

        et.G_Damage(clientNum, clientNum, 1022, 400, 24, 0)
        et.trap_SendServerCommand(-1, ("b 16 \"^7" .. et.gentity_get(clientNum, "pers.netname") .. " ^7was Slapped^7"))
    end

    return 1
end
