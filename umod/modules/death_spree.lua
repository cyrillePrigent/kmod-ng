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
    -- Print death spree messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_ds_msg_default")),
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

-- Set slash command of death spree message status.
addSlashCommand("client", "dspree", {"function", "deathSpreeSlashCommand"})

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

-- Set client data & client user info if death spree message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if death spree message & sound is enabled or not..
function setDeathSpreeMsg(clientNum, value)
    client[clientNum]["deathSpreeMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_dspree", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function
-- Manage death spree message status when dspree slash command is used.
--  params is parameters passed to the function executed in command file.
function deathSpreeSlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["deathSpreeMsg"] == 0 then
            status = "^8off^7"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setDeathSpreeMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setDeathSpreeMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage death spree message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function deathSpreeUpdateClientUserinfo(vars)
    local ds = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_dspree")

    if ds == "" then
        setDeathSpreeMsg(vars["clientNum"], deathSpree["msgDefault"])
    elseif tonumber(ds) == 0 then
        client[vars["clientNum"]]["deathSpreeMsg"] = 0
    else
        client[vars["clientNum"]]["deathSpreeMsg"] = 1
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
    ["ClientBegin"]           = "deathSpreeUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "deathSpreeUpdateClientUserinfo",
    ["Obituary"]              = "checkDeathSpreeObituary",
    ["ObituaryEnemyKill"]     = "resetDeathSpree",
    ["ObituaryTeamKill"]      = "resetDeathSpree"
})
