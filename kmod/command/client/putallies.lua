

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putallies:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Putallies', params.command, params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")

            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                if client[clientNum]['team'] ~= 2 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref putallies " .. clientNum .. "\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putallies: ^7" .. name .. " ^7has been putted allies\n")
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putspec: ^7" .. name .. " ^7is already allies\n")
                end
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putallies:^7 Cannot put allies a higher admin\n")
            end
        end
    end

    return 1
end
