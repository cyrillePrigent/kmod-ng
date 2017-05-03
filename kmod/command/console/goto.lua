

-- part2id

-- params["arg1"] => player ID
-- params["arg2"] => target
function execute_command(params)
    if et.trap_Argc() < 2 then
        et.G_Print("Goto is used to teleport one player to another player\n") 
        et.G_Print("useage: goto \[name/PID\] \[name/PID\]\n")
        return 1
    end

    target = part2id(params["arg2"])

    if target ~= nil then
        local team = et.gentity_get(params["arg1"], "sess.sessionTeam")

        if et.gentity_get(params["arg1"], "pers.connected") == 2 and (team > 0 or team < 4) then
            local targetOrigin = et.gentity_get(target, "origin")
            targetOrigin[2] = targetOrigin[2] + 40
            et.gentity_set(params["arg1"], "origin", targetOrigin)
        end
    end
end
