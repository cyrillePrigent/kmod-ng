-- Death spree
-- From kmod lua script.

-- Global var

deathSpree = {
    ["list"]           = {},
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_ds_enable_sound")),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_ds_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_ds_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_ds_noise_reduction"))
}

-- Set default client data.
clientDefaultData["deathSpree"]    = 0
clientDefaultData["deathSpreeMsg"] = 0

addSlashCommand("client", "dspree", {"function", "deathSpreeSlashCommand"})

-- Function

-- Called when qagame initializes.
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
-- `dspree` command here.
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
            playSound(sndFile, "deathSpreeMsg", vars["victim"])
        else
            playSound(sndFile, "deathSpreeMsg")
        end
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkDeathSpreeObituary(vars)
    client[vars["victim"]]["deathSpree"] = client[vars["victim"]]["deathSpree"] + 1

    local ds = client[vars["victim"]]["deathSpree"]

    if deathSpree["list"][ds] then
        deathSpreeProcess(
            vars,
            deathSpree["list"][ds]["message"],
            deathSpree["list"][ds]["sound"]
        )
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
