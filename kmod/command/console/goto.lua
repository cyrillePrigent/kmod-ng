

-- params["arg1"] => player ID
-- params["arg2"] => target
function execute_command(params)
    if params.nbArg < 2 then
        et.G_Print("Goto is used to teleport one player to another player\n")
        et.G_Print("useage: goto \[name/PID\] \[name/PID\]\n")
    else
        targetNum = client2id(params["arg2"], 'Goto', params.command, params.say)

        if targetNum ~= nil and et.gentity_get(params["arg1"], "pers.connected") == 2 and (client[params["arg1"]]['team'] > 0 or client[params["arg1"]]['team'] < 4) then
            local targetOrigin = et.gentity_get(targetNum, "origin")
            targetOrigin[2] = targetOrigin[2] + 40
            et.gentity_set(params["arg1"], "origin", targetOrigin)
        end
    end

    return 1
end
