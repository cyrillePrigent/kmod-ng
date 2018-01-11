-- Death spree
-- From kmod script.

-- Global var

deathSpree = {
    -- List of death spree.
    --  key   => death spree amount
    --  value => list of death spree data (message & sound)
    ["list"] = {},
    -- Death spree sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_ds_enable_sound")),
    -- Death spree message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_ds_msg_position"),
    -- Noise reduction of death spree sound.
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_ds_noise_reduction"))
}

-- Set default client data.
--
-- Death spree value.
clientDefaultData["deathSpree"] = 0
-- Print death spree status.
clientDefaultData["deathSpreeMsg"] = 0

-- Set death spree module message.
table.insert(slashCommandModuleMsg, {
    -- Name of death spree module message key in client data.
    ["clientDataKey"] = "deathSpreeMsg",
    -- Name of death spree module message key in userinfo data.
    ["userinfoKey"] = "u_dspree",
    -- Name of death spree module message slash command.
    ["slashCommand"] = "dspree",
    -- Print death spree messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_ds_msg_default"))
})

-- Function

-- Called when qagame initializes.
-- Prepare death spree list.
--  vars is the local vars of et_InitGame function.
function deathSpreeInitGame(vars)
    local n = 1

    while true do
        local amount = tonumber(et.trap_Cvar_Get("u_ds_amount" .. n))
        local sound  = et.trap_Cvar_Get("u_ds_sound" .. n)
        local msg    = et.trap_Cvar_Get("u_ds_message" .. n)

        if amount ~= nil and sound ~= "" and msg ~= "" then
            deathSpree["list"][amount] = {
                ["sound"]   = sound,
                ["message"] = msg
            }
        else
            break
        end
        
        n = n + 1
    end
end

-- Callback function of et_Obituary function.
-- Increment death spree counter of victim and check if victim have dath spree.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituary(vars)
    client[vars["victim"]]["deathSpree"] = client[vars["victim"]]["deathSpree"] + 1

    local ds = client[vars["victim"]]["deathSpree"]

    if deathSpree["list"][ds] then
        local msg = deathSpree["list"][ds]["message"]
        msg = string.gsub(msg, "#victim#", vars["victimName"])
        msg = string.gsub(msg, "#deaths#", client[vars["victim"]]["deathSpree"])

        sayClients(deathSpree["msgPosition"], msg, "deathSpreeMsg")

        if deathSpree["enabledSound"] == 1 then
            if deathSpree["noiseReduction"] == 1 then
                playSound(
                    deathSpree["list"][ds]["sound"],
                    "deathSpreeMsg",
                    vars["victim"]
                )
            else
                playSound(
                    deathSpree["list"][ds]["sound"],
                    "deathSpreeMsg"
                )
            end
        end
    end
end

-- Reset death spree when victim is killed by enemy or team.
--  vars is the local vars of et_Obituary function.
function resetDeathSpree(vars)
    client[vars["killer"]]["deathSpree"] = 0
end

-- Add callback death spree function.
addCallbackFunction({
    ["InitGame"]              = "deathSpreeInitGame",
    ["Obituary"]              = "checkDeathSpreeObituary",
    ["ObituaryEnemyKill"]     = "resetDeathSpree",
    ["ObituaryTeamKill"]      = "resetDeathSpree"
})
