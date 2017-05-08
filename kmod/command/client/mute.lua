

-- TODO : Add mute duration
function execute_command(params)
    if params.nbArg < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Mute:^7 \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], 'Mute', 'client', params.say)

        if clientNum ~= nil
            local name = et.gentity_get(clientNum, "pers.netname")

            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. clientNum .. "\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Mute: ^7" .. name .. " ^7has been muted\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Mute:^7 Cannot mute a higher admin\n")
            end
        end
    end

    return 1
end
