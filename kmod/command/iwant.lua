

-- part2id

-- params["arg1"] => player ID
-- params["arg2"] => target
function execute_command(params)
    if params.nbArg < 2 then
        et.G_Print("Iwant is used to teleport one player to another player\n")
        et.G_Print("useage: iwant \[name/PID - Destination\] \[name/PID\]\n")
        return 1
    end

    playerId = part2id(params["arg1"])

    if playerId ~= nil then
        local team = et.gentity_get(params["arg1"], "sess.sessionTeam")

        if et.gentity_get(params["arg1"], "pers.connected") == 2 and (team > 0 or team < 4) then
            local playerIdOrigin = et.gentity_get(playerId, "origin")
            playerIdOrigin[2] = playerIdOrigin[2] + 40
            et.gentity_set(params["arg2"], "origin", playerIdOrigin)
        end
    end
end
