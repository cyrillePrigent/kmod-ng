-- Advanced spawn
-- From kmod lua script.

-- Global var

-- Set default client data.
clientDefaultData["invincibleDummy"] = 0
clientDefaultData["invincibleStart"] = 0

-- Function

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function advancedSpawnInitGame(vars)
    local g_inactivity = tonumber(et.trap_Cvar_Get("g_inactivity"))

    if g_inactivity ~= nil and g_inactivity > 0 then
        addCallbackFunction({["RunFrame"] = "checkAdvancedSpawnRunFrame"})
    else
        et.G_LogPrint("uMod: Advanced spawn is disabled! <g_inactivity> cvar must be > 0.\n")
    end
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedSpawnRunFrame(vars)
    for i = 0, clientsLimit, 1 do
        if client[i]["switchTeam"] == 1 then
            et.gentity_set(i, "ps.powerups", 1, 0)
        end

        client[i]["switchTeam"] = 0

        if client[i]["respawn"] == 1 then
            if client[i]["switchTeam"] == 0 and et.gentity_get(i, "ps.powerups", 1) > 0 then
                if client[i]["invincibleDummy"] == 0 then
                    client[i]["invincibleStart"] = tonumber(et.gentity_get(i, "client.inactivityTime"))
                    client[i]["invincibleDummy"] = 1
                end

                if tonumber(et.gentity_get(i, "client.inactivityTime")) == client[i]["invincibleStart"] then
                    et.gentity_set(i, "ps.powerups", 1, vars["levelTime"] + 3000)
                else
                    client[i]["respawn"]         = 0
                    client[i]["invincibleDummy"] = 0
                end
            else
                client[i]["respawn"]         = 0
                client[i]["invincibleDummy"] = 0
            end
        end
    end
end

-- Add callback advanced spawn function.
addCallbackFunction({
    ["InitGame"] = "advancedSpawnInitGame"
})
