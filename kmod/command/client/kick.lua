

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Kick:^7 \[partname/id#\] \[time\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], 'Kick', 'client', params.say)

        if clientNum ~= nil
            local client = clientNum + 1

            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_kick " .. client .. " " .. params["arg2"] .. "\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Kick:^7 Cannot kick a higher admin\n")
            end
        end
    end

    return 1
end
