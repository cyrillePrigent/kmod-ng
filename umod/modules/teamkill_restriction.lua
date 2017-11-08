-- Teamkill restriction

-- Global var

tkRestriction = {
    ["limitLow"]  = tonumber(et.trap_Cvar_Get("u_tklimit_low")),
    ["limitHigh"] = tonumber(et.trap_Cvar_Get("u_tklimit_high")),
    ["protect"]   = tonumber(et.trap_Cvar_Get("u_tk_protect"))
}

-- Function

-- Callback function when victim is killed by mate (team kill).
--  vars is the local vars of et_Obituary function.
function checkTeamkillRestrictionObituaryTeamKill(vars)
    if game["state"] == 0 then
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

            --if (tkRestriction["limitLow"] + 1) > client[vars["killer"]]["tkIndex"] and tkRestriction["limitLow"] < client[vars["killer"]]["tkIndex"] then
            if (tkRestriction["limitLow"] + 1) == client[vars["killer"]]["tkIndex"] then
                if advancedPms == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. et.Q_CleanStr(vars["killerName"]) .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                    --et.G_ClientSound(vars["killer"], pmSound)
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. et.Q_CleanStr(vars["killerName"]) .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                end
            elseif client[vars["killer"]]["tkIndex"] <= tkRestriction["limitLow"] then
                local pbkiller = vars["killer"] + 1
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_kick " .. pbkiller .. " 10 Too many teamkills\n")
            end
        end
    end
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkTeamkillRestrictionObituaryEnemyKill(vars)
    if game["state"] == 0 then
        client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] + 1

        if client[vars["killer"]]["tkIndex"] > tkRestriction["limitHigh"] then
            client[vars["killer"]]["tkIndex"] = tkRestriction["limitHigh"]
        end
    end
end

-- Callback function whenever the server or qagame prints a string to the console.
--  vars is the local vars of et_Print function.
function checkTeamkillRestrictionPrint(vars)
    if vars["arg"][1] == "Medic_Revive:" then
        local reviver = tonumber(vars["arg"][2])
        client[reviver]["tkIndex"] = client[reviver]["tkIndex"] + 1

        if client[reviver]["tkIndex"] > tkRestriction["limitHigh"] then
            client[reviver]["tkIndex"] = tkRestriction["limitHigh"]
        end
    end
end

-- Add callback teamkill restriction function.
addCallbackFunction({
    ["ObituaryTeamKill"]  = "checkTeamkillRestrictionObituaryTeamKill",
    ["ObituaryEnemyKill"] = "checkTeamkillRestrictionObituaryEnemyKill",
    ["Print"]             = "checkTeamkillRestrictionPrint"
})
