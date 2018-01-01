-- Uneven team
-- From kmod lua script.

-- Global var

unevenTeam = {
    ["time"]              = {
        ["check"]             = 0,
        ["notify"]            = 0,
    },
    ["notify"]            = 0,
    ["playersDifference"] = tonumber(et.trap_Cvar_Get("u_ut_teams_difference")),
    ["escalationCmd"]     = et.trap_Cvar_Get("u_ut_escalation_cmd"),
    ["message1"]          = et.trap_Cvar_Get("u_ut_message1"),
    ["message2"]          = et.trap_Cvar_Get("u_ut_message2"),
    ["message3"]          = et.trap_Cvar_Get("u_ut_message3"),
    ["message4"]          = et.trap_Cvar_Get("u_ut_message4"),
    ["msgPosition"]       = et.trap_Cvar_Get("u_ut_msg_position")
}

-- Function

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkUnevenTeamRunFrame(vars)
    if vars["levelTime"] - unevenTeam["time"]["check"] >= 3000 then
        local diff = math.abs(players["axis"] - players["allies"])

        if diff >= unevenTeam["playersDifference"] then
            -- Teams are uneven
            if unevenTeam["time"]["notify"] == 0 then
                unevenTeam["time"]["notify"] = vars["levelTime"] - 27000
            end
        else
            -- Teams are even again.
            unevenTeam["time"]["notify"] = 0
            unevenTeam["notify"]         = 0
        end

        unevenTeam["time"]["check"] = vars["levelTime"] -- Next checking in 3 seconds.
    end
    
    if unevenTeam["time"]["notify"] > 0 and vars["levelTime"] - unevenTeam["time"]["notify"] > 30000 then
        if unevenTeam["notify"] == 0 then
            et.trap_SendServerCommand(
                -1,
                unevenTeam["msgPosition"] .. " \"" .. unevenTeam["message1"] .. "\"\n"
            )

            unevenTeam["notify"] = 1
        elseif unevenTeam["notify"] == 1 then
            et.trap_SendServerCommand(
                -1,
                unevenTeam["msgPosition"] .. " \"" .. unevenTeam["message2"] .. "\"\n"
            )

            unevenTeam["notify"] = 2
        elseif unevenTeam["notify"] == 2 then
            if unevenTeam["escalationCmd"] ~= "" then
                -- Small workaround for shuffles.
                if string.find(unevenTeam["escalationCmd"], "shuffleteamsxp_norestart") == nil then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["escalationCmd"])
                else
                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "set umod \"" .. unevenTeam["escalationCmd"] .. "\""
                    )

                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "vstr umod")
                end

                -- Workarround for shuffleteamsxp_norestart
                if string.find(unevenTeam["escalationCmd"], "ref%sshuffleteamsxp_norestart") ~= nil then
                    unevenTeam["time"]["notify"] = 0
                end
            end

            et.trap_SendServerCommand(
                -1,
                unevenTeam["msgPosition"] .. " \"" .. unevenTeam["message3"] .. "\"\n"
            )

            unevenTeam["notify"] = 3
        elseif unevenTeam["notify"] == 3 then
            et.trap_SendServerCommand(
                -1,
                unevenTeam["msgPosition"] .. " \"" .. unevenTeam["message4"] .. "\"\n"
            )
        end

        unevenTeam["time"]["notify"] = vars["levelTime"] -- Next notification in 30 seconds.
    end
end

-- Add callback uneven team function.
addCallbackFunction({
    ["RunFrame"] = "checkUnevenTeamRunFrame"
})
