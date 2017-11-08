-- Death spree

-- Global var

deathSpree = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("k_deathspreesounds")),
    ["amount1"]      = tonumber(et.trap_Cvar_Get("k_deathspree1_amount")),
    ["amount2"]      = tonumber(et.trap_Cvar_Get("k_deathspree2_amount")),
    ["amount3"]      = tonumber(et.trap_Cvar_Get("k_deathspree3_amount")),
    ["sound1"]       = et.trap_Cvar_Get("deathspreesound1"),
    ["sound2"]       = et.trap_Cvar_Get("deathspreesound2"),
    ["sound3"]       = et.trap_Cvar_Get("deathspreesound3"),
    ["message1"]     = et.trap_Cvar_Get("k_ds_message1"),
    ["message2"]     = et.trap_Cvar_Get("k_ds_message2"),
    ["message3"]     = et.trap_Cvar_Get("k_ds_message3"),
    ["location"]     = getMessageLocation(tonumber(et.trap_Cvar_Get("k_ds_location")))
}

-- Set default client data.
clientDefaultData["deathspree"] = 0

-- Function

-- Display death spree message and play death spree sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  sound is the death spree sound to play.
function deathSpreeProcess(vars, msg, sound)
    msg = string.gsub(msg, "#victim#", vars["victimName"])
    msg = string.gsub(msg, "#deaths#", client[vars["victim"]]["deathspree"])
    et.trap_SendConsoleCommand(et.EXEC_APPEND, deathSpree["location"] .. " " .. msg .. "\n" )

    if deathSpree["enabledSound"] == 1 then
        if k_noisereduction == 1 then
            et.G_ClientSound(vars["victim"], sound)
        else
            et.G_globalSound(sound)
        end
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituary(vars)
    client[vars["victim"]]["deathspree"] = client[vars["victim"]]["deathspree"] + 1

    if client[vars["victim"]]["deathspree"] == deathSpree["amount1"] then
        deathSpreeProcess(vars, deathSpree["message1"], deathSpree["sound1"])
    elseif client[vars["victim"]]["deathspree"] == deathSpree["amount2"] then
        deathSpreeProcess(vars, deathSpree["message2"], deathSpree["sound2"])
    elseif client[vars["victim"]]["deathspree"] == deathSpree["amount3"] then
        deathSpreeProcess(vars, deathSpree["message3"], deathSpree["sound3"])
    end
end

-- Callback function when victim is killed by enemy or team.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituaryEnemyAndTeamKill(vars)
    --if k_sprees == 1 then -- TODO : Why?
        client[vars["killer"]]["deathspree"] = 0
    --end
end

-- Add callback death spree function.
addCallbackFunction({
    ["Obituary"]          = "checkDeathSpreeObituary",
    ["ObituaryEnemyKill"] = "checkDeathSpreeObituaryEnemyAndTeamKill",
    ["ObituaryTeamKill"]  = "checkDeathSpreeObituaryEnemyAndTeamKill"
})
