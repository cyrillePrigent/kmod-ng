

function execute_command(params)
    local matches = 0

    for i = 0, clientsLimit, 1 do
        local ping = tonumber(et.gentity_get(i, "ps.ping"))

        if (client[i]['team'] == 1 or client[i]['team'] == 2) and ping >= 999 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Spec999: ^7Moving ^1" .. matches .. " ^7players to spectator\n")
end
