-- Uneven team

-- Global var

unevenTeam = {
    ["time"]              = 0,
    ["notify"]            = 0,
    ["playersDifference"] = et.trap_Cvar_Get("k_detect_uneven_teams_difference"),
    ["escalationCmd"]     = et.trap_Cvar_Get("k_uneven_teams_escalation_cmd"),
    ["message1"]          = et.trap_Cvar_Get("k_ut_message1"),
    ["message2"]          = et.trap_Cvar_Get("k_ut_message2"),
    ["message3"]          = et.trap_Cvar_Get("k_ut_message3"),
    ["message4"]          = et.trap_Cvar_Get("k_ut_message4"),
    ["location"]          = getMessageLocation(tonumber(et.trap_Cvar_Get("k_ut_location")))
}

-- Function

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkUnevenTeamRunFrame(vars)
    -- Do i have all required information from ALL players?
    if players["axis"] + players["allies"] + players["spectator"] == players["total"] then
        local diff = players["axis"] - players["allies"]

        if diff >= unevenTeam["playersDifference"] or diff <= -1 * unevenTeam["playersDifference"] then
            -- Teams are uneven
            if unevenTeam["time"] == 0 then
                unevenTeam["time"] = vars["levelTime"] - 27
            end
        else
            -- Teams are even again.
            unevenTeam["time"]   = 0
            unevenTeam["notify"] = 0
        end
    end
    
    if unevenTeam["time"] and vars["levelTime"] - unevenTeam["time"] > 30 then
        if unevenTeam["notify"] == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["location"] .. " " .. unevenTeam["message1"] .. "\n")
            unevenTeam["notify"] = 1
        elseif unevenTeam["notify"] == 1 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["location"] .. " " .. unevenTeam["message2"] .. "\n")
            unevenTeam["notify"] = 2
        elseif unevenTeam["notify"] == 2 then
            if unevenTeam["escalationCmd"] then
                -- Small workaround for shuffles.
                if string.find(unevenTeam["escalationCmd"], "shuffleteamsxp_norestart") == nil then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["escalationCmd"])
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "set etadmin \"" .. unevenTeam["escalationCmd"] .. "\"")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "vstr etadmin")
                end

                -- Workarround for shuffleteamsxp_norestart
                if string.find(unevenTeam["escalationCmd"], "ref%sshuffleteamsxp_norestart") ~= nil then
                    unevenTeam["time"] = 0
                end
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["location"] .. " " .. unevenTeam["message3"] .. "\n")
            unevenTeam["notify"] = 3
        elseif unevenTeam["notify"] == 3 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, unevenTeam["location"] .. " " .. unevenTeam["message4"] .. "\n")
        end

        unevenTeam["time"] = vars["levelTime"] -- Next notification in 30 seconds.
    end
end

-- Add callback uneven team function.
addCallbackFunction({
    ["RunFrame"] = "checkUnevenTeamRunFrame"
})
