-- Self kill limit

-- Global var

nbSelfkillMax = tonumber(et.trap_Cvar_Get("k_selfkills"))

-- Set default client data.
clientDefaultData["selfkills"] = 0

addSlashCommand("client", "kill", {"function", "selfkillLimitSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function selfkillLimitSlashCommand(params)
    if client[params.clientNum]["team"] ~= 3 and et.gentity_get(params.clientNum, "health") > 0 then
        if client[params.clientNum]["selfkills"] < nbSelfkillMax then
            client[params.clientNum]["selfkills"] = client[params.clientNum]["selfkills"] + 1

            if client[params.clientNum]["selfkills"] == nbSelfkillMax then
                if k_advancedpms == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. params.clientNum .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                    --et.G_ClientSound(params.clientNum, pmSound)
                else
                    local name = et.gentity_get(params.clientNum, "pers.netname")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                end
            elseif client[params.clientNum]["selfkills"] == (nbSelfkillMax - 1) then
                if k_advancedpms == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. params.clientNum .. " ^7You have ^11^7 /kill left for this map.\n")
                    --et.G_ClientSound(params.clientNum, pmSound)
                else
                    local name = et.gentity_get(params.clientNum, "pers.netname")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have ^11^7 /kill left for this map.\n")
                end
            end
        else
            if k_advancedpms == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. params.clientNum .. " ^7You may no longer /kill for the rest of this map!\n")
                --et.G_ClientSound(params.clientNum, pmSound)
            else
                local name = et.gentity_get(params.clientNum, "pers.netname")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You may no longer /kill for the rest of this map!\n")
            end

            return 1
        end
    end

    return 0
end
