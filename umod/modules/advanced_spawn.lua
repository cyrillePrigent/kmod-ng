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
        addCallbackFunction({["RunFrame"] = "checkAdvancedSpawnPlayerRunFrame"})
    else
        et.G_LogPrint("uMod Advanced spawn: <g_inactivity> cvar must be > 0.\n")
    end
end

-- Callback function when qagame runs a server frame in player loop pending warmup and round.
-- Check if player is inactive and extend his spawn shield.
--  clientNum is the client slot id.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedSpawnPlayerRunFrame(clientNum, vars)
    if client[clientNum]["switchTeam"] == 1 then
        et.gentity_set(clientNum, "ps.powerups", 1, 0)
    end

    client[clientNum]["switchTeam"] = 0

    if client[clientNum]["respawn"] == 1 then
        if client[clientNum]["switchTeam"] == 0 and et.gentity_get(clientNum, "ps.powerups", 1) > 0 then
            if client[clientNum]["invincibleDummy"] == 0 then
                client[clientNum]["invincibleStart"] = tonumber(et.gentity_get(clientNum, "client.inactivityTime"))
                client[clientNum]["invincibleDummy"] = 1
            end

            if tonumber(et.gentity_get(clientNum, "client.inactivityTime")) == client[clientNum]["invincibleStart"] then
                et.gentity_set(clientNum, "ps.powerups", 1, vars["levelTime"] + 3000)
            else
                client[clientNum]["respawn"]         = 0
                client[clientNum]["invincibleDummy"] = 0
            end
        else
            client[clientNum]["respawn"]         = 0
            client[clientNum]["invincibleDummy"] = 0
        end
    end
end

-- Add callback advanced spawn function.
addCallbackFunction({
    ["InitGame"] = "advancedSpawnInitGame"
})
