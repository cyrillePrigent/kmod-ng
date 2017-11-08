-- Flak monkey

-- Global var

flakmonkey = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_fm_sound")),
    ["sound"]        = et.trap_Cvar_Get("u_flakmonkeysound"),
    ["message"]      = et.trap_Cvar_Get("u_fm_message"),
    ["location"]     = getMessageLocation(tonumber(et.trap_Cvar_Get("u_fm_location")))
}

-- Set default client data.
clientDefaultData["flakmonkey"] = 0

-- Function

-- Callback function when world kill a player.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituaryWorldKill(vars)
    client[vars["victim"]]["flakmonkey"] = 0
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituary(vars)
    -- Kills
    client[vars["victim"]]["flakmonkey"] = 0

    -- Deaths
    if killer ~= 1022 then
        if vars["meansOfDeath"] == 17 or vars["meansOfDeath"] == 43 or vars["meansOfDeath"] == 44 then
            -- Enemy kill
            if vars["killer"] ~= vars["victim"] and client[vars["victim"]]["team"] ~= client[vars["killer"]]["team"] then
                client[vars["killer"]]["flakmonkey"] = client[vars["killer"]]["flakmonkey"] + 1

                if client[vars["killer"]]["flakmonkey"] == 3 then
                    local str = string.gsub(flakmonkey["message"], "#killer#", vars["killerName"])
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, flakmonkey["location"] .. " " .. str .. "\n")

                    if flakmonkey["enabledSound"] == 1 then
                        if noiseReduction == 1 then
                            et.G_ClientSound(vars["killer"], flakmonkey["sound"])
                        else
                            et.G_globalSound(flakmonkey["sound"])
                        end
                    end

                    client[vars["killer"]]["flakmonkey"] = 0
                end
            -- Teamkill & Selfkill
            else
                client[vars["killer"]]["flakmonkey"] = 0
            end
        -- No flak monkey means of death
        else
            client[vars["killer"]]["flakmonkey"] = 0
        end
    end
end

-- Add callback flak monkey function.
addCallbackFunction({
    ["ObituaryWorldKill"] = "checkFlakMonkeyObituaryWorldKill",
    ["Obituary"]          = "checkFlakMonkeyObituary"
})
