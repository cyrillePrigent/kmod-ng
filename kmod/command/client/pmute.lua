

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Pmute:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Pmute', params.command, params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")

            if getAdminLevel(params.clientNum) >= getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref mute " .. clientNum .. "\n")
                mute['end'][clientNum] = -1
                setMute(clientNum, -1)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Pmute: ^7" .. name .. " ^7has been muted\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Pmute:^7 Cannot mute a higher admin\n")
            end
        end
    end

    return 1
end
