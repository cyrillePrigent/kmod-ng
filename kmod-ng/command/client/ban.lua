

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Ban:^7 \[partname/id#\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], 'Ban', params)

        if clientNum ~= nil
            local client = clientNum + 1
            et.trap_SendConsoleCommand( et.EXEC_APPEND, "pb_sv_ban " .. client .. " " .. params["arg2"] .. "\n" )
        end
    end

    return 1
end
