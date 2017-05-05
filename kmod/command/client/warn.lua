

function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Warn:^7 \[partname/id#\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], 'Warn', 'client', params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")
            name = string.lower(et.Q_CleanStr(name))
            params["arg2"] = tostring(params["arg2"])

            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref warn \"" .. name .. "\" \"" .. params["arg2"] .. "\"\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Warn:^7 Cannot warn a higher admin\n")
            end
        end
    end

    return 1
end
