

-- part2id

function execute_command(params)
    playerId = part2id(params.playerId)

    if playerId ~= nil then
        local sessionTeam = et.gentity_get(params.playerId, "sess.sessionTeam")

        if et.gentity_get(params.playerId, "pers.connected") == 2 and (sessionTeam > 0 or sessionTeam < 4) then
            local playerIdOrigin = et.gentity_get(playerId, "origin")
            playerIdOrigin[2] = playerIdOrigin[2] + 40
            et.gentity_set(params.target, "origin", playerIdOrigin)
        end
    end
end
