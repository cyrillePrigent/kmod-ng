

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Getguid:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Getguid', params)

        if clientNum ~= nil
            local GUID = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")
            local name = et.gentity_get(clientNum, "pers.netname")
            et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^3Getguid: " .. name .. "^7's GUID is " .. GUID))
        end
    end

    return 1
end
