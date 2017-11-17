-- Death spree

-- Global var

deathSpree = {
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_ds_enable_sound")),
    ["amount1"]        = tonumber(et.trap_Cvar_Get("u_ds_amount1")),
    ["amount2"]        = tonumber(et.trap_Cvar_Get("u_ds_amount2")),
    ["amount3"]        = tonumber(et.trap_Cvar_Get("u_ds_amount3")),
    ["sound1"]         = et.trap_Cvar_Get("u_ds_sound1"),
    ["sound2"]         = et.trap_Cvar_Get("u_ds_sound2"),
    ["sound3"]         = et.trap_Cvar_Get("u_ds_sound3"),
    ["message1"]       = et.trap_Cvar_Get("u_ds_message1"),
    ["message2"]       = et.trap_Cvar_Get("u_ds_message2"),
    ["message3"]       = et.trap_Cvar_Get("u_ds_message3"),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_ds_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_ds_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_ds_noise_reduction"))
}

-- Set default client data.
clientDefaultData["deathSpree"]    = 0
clientDefaultData["deathSpreeMsg"] = false

addSlashCommand("client", "dskill", {"function", "deathSpreeSlashCommand"})

-- Function

-- Set client data & client user info if death spree message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if death spree message & sound is enabled or not..
function setDeathSpreeMsg(clientNum, value)
    client[clientNum]["deathSpreeMsg"] = value

    if value then
        value = "1"
    else
        value = "0"
    end

    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_dspree", value))
end

-- Function executed when slash command is called in et_ClientCommand function
-- `dspree` command here.
--  params is parameters passed to the function executed in command file.
function deathSpreeSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["deathSpreeMsg"] == false then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(dspree):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setDeathSpreeMsg(params.clientNum, false)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(dspree):^7 Messages are now ^8off^7\"")
    else
        setDeathSpreeMsg(params.clientNum, true)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(dspree):^7 Messages are now ^8on^7\"")
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function deathSpreeUpdateClientUserinfo(vars)
    local ds = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_dspree")

    if ds == "" then
        setDeathSpreeMsg(vars["clientNum"], deathSpree["msgDefault"])
    elseif tonumber(ds) == 0 then
        client[vars["clientNum"]]["deathSpreeMsg"] = false
    else
        client[vars["clientNum"]]["deathSpreeMsg"] = true
    end
end

-- Display death spree message and play death spree sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  sndFile is the death spree sound to play.
function deathSpreeProcess(vars, msg, sndFile)
    msg = string.gsub(msg, "#victim#", vars["victimName"])
    msg = string.gsub(msg, "#deaths#", client[vars["victim"]]["deathSpree"])

    sayClients(deathSpree["msgPosition"], msg, "deathSpreeMsg")

    if deathSpree["enabledSound"] == 1 then
        if deathSpree["noiseReduction"] == 1 then
            playSound(sndFile, "multikillMsg", vars["victim"])
        else
            playSound(sndFile, "multikillMsg")
        end
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituary(vars)
    client[vars["victim"]]["deathSpree"] = client[vars["victim"]]["deathSpree"] + 1

    if client[vars["victim"]]["deathSpree"] == deathSpree["amount1"] then
        deathSpreeProcess(vars, deathSpree["message1"], deathSpree["sound1"])
    elseif client[vars["victim"]]["deathSpree"] == deathSpree["amount2"] then
        deathSpreeProcess(vars, deathSpree["message2"], deathSpree["sound2"])
    elseif client[vars["victim"]]["deathSpree"] == deathSpree["amount3"] then
        deathSpreeProcess(vars, deathSpree["message3"], deathSpree["sound3"])
    end
end

-- Callback function when victim is killed by enemy or team.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituaryEnemyAndTeamKill(vars)
    client[vars["killer"]]["deathSpree"] = 0
end

-- Add callback death spree function.
addCallbackFunction({
    ["ClientBegin"]           = "deathSpreeUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "deathSpreeUpdateClientUserinfo",
    ["Obituary"]              = "checkDeathSpreeObituary",
    ["ObituaryEnemyKill"]     = "checkDeathSpreeObituaryEnemyAndTeamKill",
    ["ObituaryTeamKill"]      = "checkDeathSpreeObituaryEnemyAndTeamKill"
})
