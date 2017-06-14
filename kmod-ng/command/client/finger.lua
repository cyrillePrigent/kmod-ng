

function execute_command(params)
    if params.nbArg < 2 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Finger:^7 \[partname/id#\]\n")
    else
        params.clientNum = client2id(params["arg1"], 'Finger', params)

        if params.clientNum ~= nil then
            adminStatus(params, 'finger')
        end
    end

    return 1
end
