-- Flak monkey
-- From kmod script.

-- Global var

flakMonkey = {
    -- Flak monkey sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_fm_enable_sound")),
    -- Flak monkey sound file.
    ["sound"] = et.trap_Cvar_Get("u_fm_sound"),
    -- Flak monkey message content.
    ["message"] = et.trap_Cvar_Get("u_fm_message"),
    -- Flak monkey message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_fm_msg_position"),
    -- Noise reduction of flak monkey sound.
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_fm_noise_reduction")),
    -- Flak monkey means of death.
    ["meansOfDeath"] = {
        [17]  = true, -- Panzerfaust
        [43]  = true, -- GPG40
        [44]  = true  -- M7
    }
}


-- Set default client data.
--
-- Flak monkey kill counter.
clientDefaultData["flakMonkey"] = 0
-- Print flak monkey status.
clientDefaultData["flakMonkeyMsg"] = 0

-- Set flak monkey module message.
table.insert(slashCommandModuleMsg, {
    -- Name of flak monkey module message key in client data.
    ["clientDataKey"] = "flakMonkeyMsg",
    -- Name of flak monkey module message key in userinfo data.
    ["userinfoKey"] = "u_fmonkey",
    -- Name of flak monkey module message slash command.
    ["slashCommand"] = "fmonkey",
    -- Print flak monkey messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_fm_msg_default"))
})

-- Function

-- Callback function of et_Obituary function.
-- Reset victim flak monkey counter for all death type.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituary(vars)
    client[vars["victim"]]["flakMonkey"] = 0
end

-- Callback function when a player kill a enemy.
-- Increase flak monkey counter if weapon used for a enemy kill is in
-- flak monkey means of death. When player have 3 flak monkey kill,
-- display flak monkey message and play flak monkey sound. Flak monkey
-- counter is reset killer after 3 flak monkey kill or if weapon isn't
-- in flak monkey means of death.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituaryEnemyKill(vars)
    if flakMonkey["meansOfDeath"][vars["meansOfDeath"]] then
        client[vars["killer"]]["flakMonkey"] = client[vars["killer"]]["flakMonkey"] + 1

        if client[vars["killer"]]["flakMonkey"] == 3 then
            local str = string.gsub(flakMonkey["message"], "#killer#", vars["killerName"])
            sayClients(flakMonkey["msgPosition"], str, "flakMonkeyMsg")

            if flakMonkey["enabledSound"] == 1 then
                if flakMonkey["noiseReduction"] == 1 then
                    playSound(flakMonkey["sound"], "flakMonkeyMsg", vars["killer"])
                else
                    playSound(flakMonkey["sound"], "flakMonkeyMsg")
                end
            end

            client[vars["killer"]]["flakMonkey"] = 0
        end
    else
        client[vars["killer"]]["flakMonkey"] = 0
    end
end

-- Callback function when victim is killed himself (self kill).
-- Reset killer flak monkey counter when is team killed.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituaryTeamKill(vars)
    client[vars["killer"]]["flakMonkey"] = 0
end

-- Add callback flak monkey function.
addCallbackFunction({
    ["Obituary"]          = "checkFlakMonkeyObituary",
    ["ObituaryEnemyKill"] = "checkFlakMonkeyObituaryEnemyKill",
    ["ObituaryTeamKill"]  = "checkFlakMonkeyObituaryTeamKill",
})
