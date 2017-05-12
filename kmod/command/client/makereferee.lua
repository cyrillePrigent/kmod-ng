

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Makereferee:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Makereferee', params.command, params.say)

        if clientNum ~= nil
            et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref referee " .. clientNum .. "\n" )
        end
    end

    return 1
end
