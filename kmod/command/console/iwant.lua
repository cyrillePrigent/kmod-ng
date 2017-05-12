

-- params["arg1"] => player ID
-- params["arg2"] => target
function execute_command(params)
    if params.nbArg < 2 then
        et.G_Print("Iwant is used to teleport one player to another player\n")
        et.G_Print("useage: iwant \[name/PID - Destination\] \[name/PID\]\n")
    else
        playerId = client2id(params["arg1"], 'Iwant', params.command, params.say)

        if playerId ~= nil and et.gentity_get(params["arg1"], "pers.connected") == 2 and (team[params["arg1"]] > 0 or team[params["arg1"]] < 4) then
            local playerIdOrigin = et.gentity_get(playerId, "origin")
            playerIdOrigin[2] = playerIdOrigin[2] + 40
            et.gentity_set(params["arg2"], "origin", playerIdOrigin)
        end
    end

    return 1
end
