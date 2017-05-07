

function execute_command(params)
    local matches = 0

    for i = 0, clientLimit, 1 do
        local ping = tonumber(et.gentity_get(i, "ps.ping"))

        if (team[i] == 1 or team[i] == 2) and ping >= 999 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Spec999: ^7Moving ^1" .. matches .. " ^7players to spectator\n")
end
