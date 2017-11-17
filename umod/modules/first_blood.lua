-- First blood

-- Global var

firstBlood = {
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_fb_enable_sound")),
    ["sound"]          = et.trap_Cvar_Get("u_fb_sound"),
    ["message"]        = et.trap_Cvar_Get("u_fb_message"),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_fb_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_fb_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_fb_noise_reduction")),
    ["apply"]          = false
}

-- Set default client data.
clientDefaultData["firstBloodMsg"] = false

addSlashCommand("client", "fblood", {"function", "firstBloodSlashCommand"})

-- Function

-- Set client data & client user info if first blood message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if first blood message & sound is enabled or not..
function setFirstBloodMsg(clientNum, value)
    client[clientNum]["firstBloodMsg"] = value

    if value then
        value = "1"
    else
        value = "0"
    end

    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_fblood", value))
end

-- Function executed when slash command is called in et_ClientCommand function
-- `fblood` command here.
--  params is parameters passed to the function executed in command file.
function firstBloodSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["firstBloodMsg"] == false then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(fblood):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setFirstBloodMsg(params.clientNum, false)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(fblood):^7 Messages are now ^8off^7\"")
    else
        setFirstBloodMsg(params.clientNum, true)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(fblood):^7 Messages are now ^8on^7\"")
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function firstBloodUpdateClientUserinfo(vars)
    local ds = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_fblood")

    if ds == "" then
        setFirstBloodMsg(vars["clientNum"], firstBlood["msgDefault"])
    elseif tonumber(ds) == 0 then
        client[vars["clientNum"]]["firstBloodMsg"] = false
    else
        client[vars["clientNum"]]["firstBloodMsg"] = true
    end
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkFirstBloodRunObituaryEnemyKill(vars)
    if not firstBlood["apply"] then
        firstBlood["apply"] = true

        local msg = string.gsub(firstBlood["message"], "#killer#", vars["killerName"])
        sayClients(firstBlood["msgPosition"], msg, "firstBloodMsg")

        if firstBlood["enabledSound"] == 1 then
            if firstBlood["noiseReduction"] == 1 then
                playSound(firstBlood["sound"], "firstBloodMsg", vars["killer"])
            else
                playSound(firstBlood["sound"], "firstBloodMsg")
            end
        end
    end
end

-- Add callback first blood function.
addCallbackFunction({
    ["ClientBegin"]           = "firstBloodUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "firstBloodUpdateClientUserinfo",
    ["ObituaryEnemyKill"]     = "checkFirstBloodRunObituaryEnemyKill"
})
