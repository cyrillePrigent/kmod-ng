

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Unmute:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Unmute', params.command, params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref unmute " .. clientNum .. "\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Unmute: ^7" .. name .. " ^7has been unmuted\n")
        end
    end

    return 1
end
