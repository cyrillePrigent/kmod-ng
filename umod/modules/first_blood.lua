-- First blood

-- Global var

firstBlood = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_fb_sound")),
    ["sound"]        = et.trap_Cvar_Get("u_firstbloodsound"),
    ["message"]      = et.trap_Cvar_Get("u_fb_message"),
    ["location"]     = getMessageLocation(tonumber(et.trap_Cvar_Get("u_fb_location"))),
    ["apply"]        = false
}

-- Function

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkFirstBloodRunObituaryEnemyKill(vars)
    if not firstBlood["apply"] then
        firstBlood["apply"] = true

        local str = string.gsub(firstBlood["message"], "#killer#", vars["killerName"])
        et.trap_SendConsoleCommand(et.EXEC_APPEND, firstBlood["location"] .. " " .. str .. "\n")

        if firstBlood["enabledSound"] == 1 then
            if noiseReduction == 1 then
                et.G_ClientSound(vars["killer"], firstBlood["sound"])
            else
                et.G_globalSound(firstBlood["sound"])
            end
        end
    end
end

-- Add callback first blood function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "checkFirstBloodRunObituaryEnemyKill"
})
