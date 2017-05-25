-- Self kill limit

-- Global var

nbSelfkillMax = tonumber(et.trap_Cvar_Get("k_selfkills"))

-- Set default client data.
clientDefaultData["selfkills"] = 0

-- Function

function checkSelfkills(clientNum)
    if client[clientNum]["team"] ~= 3 and et.gentity_get(clientNum, "health") > 0 then
        if client[clientNum]["selfkills"] < nbSelfkillMax then
            client[clientNum]["selfkills"] = client[clientNum]["selfkills"] + 1
            local name = et.gentity_get(clientNum, "pers.netname")

            if client[clientNum]["selfkills"] == nbSelfkillMax then
                if k_advancedpms == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                    et.G_ClientSound(clientNum, pmSound)
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                end
            elseif client[clientNum]["selfkills"] == (nbSelfkillMax - 1) then
                if k_advancedpms == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You have ^11^7 /kill left for this map.\n")
                    et.G_ClientSound(clientNum, pmSound)
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have ^11^7 /kill left for this map.\n")
                end
            end
        else
            if k_advancedpms == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You may no longer /kill for the rest of this map!\n")
                et.G_ClientSound(clientNum, pmSound)
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You may no longer /kill for the rest of this map!\n")
            end

            return 1
        end
    end

    return 0
end
