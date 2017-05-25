-- Teamkill restriction

-- Global var

tkRestriction = {
    ["limitLow"] = tonumber(et.trap_Cvar_Get("k_tklimit_low")),
    ["protect"]  = tonumber(et.trap_Cvar_Get("k_tk_protect"))
}

-- Function

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkTeamkillRestrictionObituary(vars)
    if game["state"] == 0 then
        if client[vars["victim"]]["team"] == client[vars["killer"]]["team"] and vars["killer"] ~= vars["victim"] and vars["killer"] ~= 1022 then
            if getAdminLevel(vars["killer"]) < tkRestriction["protect"] then
                if vars["meansOfDeath"] == 17 or vars["meansOfDeath"] == 43 or vars["meansOfDeath"] == 44 or vars["meansOfDeath"] == 4 or vars["meansOfDeath"] == 18 or vars["meansOfDeath"] == 57 or vars["meansOfDeath"] == 30  or vars["meansOfDeath"] == 27 or vars["meansOfDeath"] == 49 or vars["meansOfDeath"] == 3 then
                    client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 0.75
                elseif vars["meansOfDeath"] == 30  or vars["meansOfDeath"] == 27 then
                    client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 0.65
                elseif vars["meansOfDeath"] == 45 then
                    -- Mines do nothing!
                else
                    client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 1
                end

                if tkRestriction["limitLow"] + 1 > client[vars["killer"]]["tkIndex"] and tkRestriction["limitLow"] < client[vars["killer"]]["tkIndex"] then
                    if k_advancedpms == 1 then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. vars["killerName"] .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                        et.G_ClientSound(vars["killer"], pmSound)
                    else
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. vars["killerName"] .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                    end
                elseif client[vars["killer"]]["tkIndex"] <= tkRestriction["limitLow"] then
                    local pbkiller = vars["killer"] + 1
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_kick " .. pbkiller .. " 10 Too many teamkills\n")
                end
            end
        else
            if vars["killer"] ~= vars["victim"] then
                if vars["killer"] ~= 1022 then
                    client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] + 1

                    if client[vars["killer"]]["tkIndex"] > k_tklimit_high then
                        client[vars["killer"]]["tkIndex"] = k_tklimit_high
                    end
                end
            end
        end
    end
end

-- Add callback teamkill restriction function.
addCallbackFunction({
    ["Obituary"] = "checkTeamkillRestrictionObituary"
})
