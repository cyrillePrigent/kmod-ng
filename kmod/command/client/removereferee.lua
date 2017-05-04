

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Removereferee:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Removereferee', 'client', params.say)

        if clientNum ~= nil
            et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref unreferee " .. clientNum .. "\n" )
        end
    end

    return 1
end
