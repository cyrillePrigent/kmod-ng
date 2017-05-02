

-- part2id

function execute_command(params)
    target = part2id(params.target)

    if target ~= nil then
        local sessionTeam = et.gentity_get(params.playerID, "sess.sessionTeam")

        if et.gentity_get(params.playerID, "pers.connected") == 2 and (sessionTeam > 0 or sessionTeam < 4) then
            local targetOrigin = et.gentity_get(target, "origin")
            targetOrigin[2] = targetOrigin[2] + 40
            et.gentity_set(params.playerID, "origin", targetOrigin)
        end
    end
end
