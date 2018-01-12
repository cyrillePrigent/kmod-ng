-- Advanced spawn
-- From kmod script.

-- Global var

-- Set default client data.
--
-- Player spawn shield status.
clientDefaultData["invincibleDummy"] = 0
-- Player spawn shield time start.
clientDefaultData["invincibleStart"] = 0

-- Function

-- Called when qagame initializes.
-- Check if player inactivity is enabled.
--  vars is the local vars of et_InitGame function.
function advancedSpawnInitGame(vars)
    local g_inactivity = tonumber(et.trap_Cvar_Get("g_inactivity"))

    if g_inactivity ~= nil and g_inactivity > 0 then
        addCallbackFunction({["RunFrame"] = "checkAdvancedSpawnRunFrame"})
    else
        et.G_LogPrint("uMod Advanced spawn: <g_inactivity> cvar must be > 0.\n")
    end
end

-- Callback function when qagame runs a server frame.
-- Check if player is inactive and extend his spawn shield.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedSpawnRunFrame(vars)
    for p = 0, clientsLimit, 1 do
        if client[p]["team"] ~= 0 then
            if client[p]["switchTeam"] == 1 then
                et.gentity_set(p, "ps.powerups", 1, 0)
            end

            client[p]["switchTeam"] = 0

            if client[p]["respawn"] == 1 then
                if client[p]["switchTeam"] == 0 and et.gentity_get(p, "ps.powerups", 1) > 0 then
                    if client[p]["invincibleDummy"] == 0 then
                        client[p]["invincibleStart"] = tonumber(et.gentity_get(p, "client.inactivityTime"))
                        client[p]["invincibleDummy"] = 1
                    end

                    if tonumber(et.gentity_get(p, "client.inactivityTime")) == client[p]["invincibleStart"] then
                        et.gentity_set(p, "ps.powerups", 1, vars["levelTime"] + 3000)
                    else
                        client[p]["respawn"]         = 0
                        client[p]["invincibleDummy"] = 0
                    end
                else
                    client[p]["respawn"]         = 0
                    client[p]["invincibleDummy"] = 0
                end
            end
        end
    end
end

-- Add callback advanced spawn function.
addCallbackFunction({
    ["InitGame"] = "advancedSpawnInitGame"
})
