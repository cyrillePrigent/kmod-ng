

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Removeshoutcaster:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Removeshoutcaster', params.command, params.say)

        if clientNum ~= nil
            et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref removeshoutcaster " .. clientNum .. "\n" )
        end
    end

    return 1
end
