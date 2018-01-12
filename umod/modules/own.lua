--  Own
--  From gw_ref script.

--  By GhosT:McSteve, 3.12.06, www.ghostworks.co.uk
--      Thanks to Fusion for his patience during the debugging.

-- Global var

-- Set default client data.
--
-- Own status.
clientDefaultData["own"] = 0

-- Set module command.
cmdList["client"]["!own"]        = "/command/both/own.lua"
cmdList["client"]["!own_stop"]   = "/command/both/own_stop.lua"
cmdList["client"]["!own_reset"]  = "/command/both/own_reset.lua"
cmdList["console"]["!own"]       = "/command/both/own.lua"
cmdList["console"]["!own_stop"]  = "/command/both/own_stop.lua"
cmdList["console"]["!own_reset"] = "/command/both/own_reset.lua"

-- Function

-- Callback function of et_Obituary function.
-- When a player is owned and kill a another player, kill him
-- and display own message.
--  vars is the local vars of et_Obituary function.
function checkOwnObituary(vars)
    if vars["killer"] ~= 1022 and client[vars["killer"]]["own"] == 1 then
        if et.gentity_get(vars["killer"], "ps.powerups", 1) > 0 then
            et.gentity_set(vars["killer"], "ps.powerups", 1, 0)
        end

        et.G_Damage(vars["killer"], 80, vars["victim"], 1000, 8, vars["meansOfDeath"])

        -- Bring the victim back to life here
        -- NOTE: this doesn't work very well
        --       victim seems to be "dead" hence another kill doesnt register
        --et.gentity_set(vars["victim"], "health", 100)

        et.trap_SendServerCommand(
            -1,
            msgCmd["chatArea"] .. color1 .. vars["killerName"] ..
            color1 .. "just got owned!\n"
        )
    end
end

-- Add callback own function.
addCallbackFunction({
    ["Obituary"] = "checkOwnObituary"
})
