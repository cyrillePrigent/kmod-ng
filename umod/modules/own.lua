--  Own from gw_ref lua script
--  By GhosT:McSteve, 3.12.06, www.ghostworks.co.uk
--  	Thanks to Fusion for his patience during the debugging.


-- Global var

-- Set default client data.
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
--  vars is the local vars of et_Obituary function.
function checkOwnObituary(vars)
    -- if the killer is flagged for ownage, then own the bastard
    if own_client[vars["killer"]] == 1 then
        -- explanation -  et.G_Damage( target, inflictor, attacker, damage, dflags, mod ), mod 0 = unknown
        et.G_Damage(vars["killer"], 80, vars["victim"], 1000, 8, vars["meansOfDeath"])

        -- bring the victim back to life here
        -- note: this doesn't work very well; victim seems to be "dead" hence another kill doesnt register
        -- et.gentity_set(vars["victim"], "health", 100)

        -- sends message via qsay, method taken from hadro's anti-sk bot
        local msg = string.format("%s ^7just got owned!", vars["killerName"])
        et.trap_SendConsoleCommand(et.EXEC_APPEND, string.format("qsay %s\n", msg))
    end
end

-- Add callback own function.
addCallbackFunction({
    ["Obituary"] = "checkOwnObituary"
})
