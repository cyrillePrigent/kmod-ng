

-- params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        if params.command == 'console' then
            et.G_Print("Gib is used to instantly kill a player\n")
            et.G_Print("useage: gib \[name/PID\]\n")
        elseif params.command == 'client' then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Gib:^7 \[partname/id#\]\n")
        end

        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Gib', params.command, params.say)

    if clientNum ~= nil
        if team[clientNum] ~= 1 and team[clientNum] ~= 2 then
            if params.command == 'client' then
                et.trap_SendConsoleCommand( et.EXEC_APPEND, params.say .. " ^3Gib: ^7Client is not actively playing\n")
            elseif params.command == 'console' then
                et.G_Print("Client is not actively playing\n")
            end

            return 1
        end

        if et.gentity_get(clientNum, "health") <= 0 then
            if params.command == 'client' then
                et.trap_SendConsoleCommand( et.EXEC_APPEND, params.say .. " ^3Gib: ^7Client is currently dead\n")
            elseif params.command == 'console' then
                et.G_Print("Client is currently dead\n")
            end

            return 1
        end

        et.G_Damage(clientNum, clientNum, 1022, 400, 24, 0)
        et.trap_SendServerCommand(-1, ("b 16 \"^7" .. et.gentity_get(clientNum, "pers.netname") .. " ^7was Gibbed^7"))
    end

    return 1
end
