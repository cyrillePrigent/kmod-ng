

-- part2id

function execute_command(params)
    target = part2id(params.target)

    if target ~= nil and et.gentity_get(params.playerID, "pers.connected") == 2 and (et.gentity_get(params.playerID, "sess.sessionTeam") > 0 or et.gentity_get(params.playerID, "sess.sessionTeam") < 4) then
        local target_origin = et.gentity_get(target, "origin")
        target_origin[2] = target_origin[2] + 40
        et.gentity_set(params.playerID, "origin", target_origin)
    end
end
