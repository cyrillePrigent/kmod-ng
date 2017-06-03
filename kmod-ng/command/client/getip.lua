

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Getip:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Getip', params)

        if clientNum ~= nil
            local IP   = et.Info_ValueForKey( et.trap_GetUserinfo(clientNum), "ip")
            local name = et.gentity_get(clientNum, "pers.netname")
            et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^3Getip: " .. name .. "^7's IP is " .. IP))
        end
    end

    return 1
end
