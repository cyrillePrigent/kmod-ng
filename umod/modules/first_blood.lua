-- First blood
-- From kmod script.

-- Global var

firstBlood = {
    -- First blood sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_fb_enable_sound")),
    -- First blood sound file.
    ["sound"] = et.trap_Cvar_Get("u_fb_sound"),
    -- First blood message content.
    ["message"] = et.trap_Cvar_Get("u_fb_message"),
    -- First blood message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_fb_msg_position"),
    -- Noise reduction of first blood sound.
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_fb_noise_reduction")),
    -- First blood status.
    ["trigger"] = false
}

-- Set default client data.
--
-- Print first blood status.
clientDefaultData["firstBloodMsg"] = 0

-- Set first blood module message.
table.insert(slashCommandModuleMsg, {
    -- Name of first blood module message key in client data.
    ["clientDataKey"] = "firstBloodMsg",
    -- Name of first blood module message key in userinfo data.
    ["userinfoKey"] = "u_fblood",
    -- Name of first blood module message slash command.
    ["slashCommand"] = "fblood",
    -- Print first blood messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_fb_msg_default"))
})

-- Function

-- Callback function when a player kill a enemy.
-- At first enemy killed, display first blood message and play
-- first sound blood.
--  vars is the local vars of et_Obituary function.
function checkFirstBloodRunObituaryEnemyKill(vars)
    if not firstBlood["trigger"] then
        firstBlood["trigger"] = true

        local msg = string.gsub(firstBlood["message"], "#killer#", vars["killerName"])
        sayClients(firstBlood["msgPosition"], msg, "firstBloodMsg")

        if firstBlood["enabledSound"] == 1 then
            if firstBlood["noiseReduction"] == 1 then
                playSound(firstBlood["sound"], "firstBloodMsg", vars["killer"])
            else
                playSound(firstBlood["sound"], "firstBloodMsg")
            end
        end

        removeCallbackFunction("ObituaryEnemyKill", "checkFirstBloodRunObituaryEnemyKill")
    end
end

-- Add callback first blood function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "checkFirstBloodRunObituaryEnemyKill"
})
