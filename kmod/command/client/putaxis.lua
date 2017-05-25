

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putaxis:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Putaxis', params.command, params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")

            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                if client[clientNum]['team'] ~= 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref putaxis " .. clientNum .. "\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putaxis: ^7" .. name .. " ^7has been putted axis\n")
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putspec: ^7" .. name .. " ^7is already axis\n")
                end
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Putaxis:^7 Cannot put axis a higher admin\n")
            end
        end
    end

    return 1
end
