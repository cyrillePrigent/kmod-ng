

function execute_command(params)
    local matches = 0

    for i = 0, tonumber(et.trap_Cvar_Get("sv_maxclients"))-1, 1 do
        local team = tonumber(et.gentity_get(i, "sess.sessionTeam"))
        local ping = tonumber(et.gentity_get(i, "ps.ping"))

        if team ~= 3 and team ~= 0 and ping >= 999 then
            matches = matches + 1
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Spec999: ^7Moving ^1" .. matches .. " ^7players to spectator\n")
end
