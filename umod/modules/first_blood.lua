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
    -- Print first blood message by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_fb_msg_default")),
    -- First blood message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_fb_msg_position"),
    -- Noise reduction of first blood sound.
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_fb_noise_reduction")),
    
    ["trigger"] = false
}

-- Set default client data.
--
-- Print first blood status.
clientDefaultData["firstBloodMsg"] = 0

-- Set slash command of first blood message status.
addSlashCommand("client", "fblood", {"function", "firstBloodSlashCommand"})

-- Function

-- Set client data & client user info if first blood message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if first blood message & sound is enabled or not..
function setFirstBloodMsg(clientNum, value)
    client[clientNum]["firstBloodMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_fblood", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Manage first blood message status when fblood slash command is used.
--  params is parameters passed to the function executed in command file.
function firstBloodSlashCommand(params)
    --params.noDisplayCmd = true
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "on"

        if client[params.clientNum]["firstBloodMsg"] == 0 then
            status = "off"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setFirstBloodMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setFirstBloodMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage first blood message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function firstBloodUpdateClientUserinfo(vars)
    local fb = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_fblood")

    if fb == "" then
        setFirstBloodMsg(vars["clientNum"], firstBlood["msgDefault"])
    elseif tonumber(fb) == 0 then
        client[vars["clientNum"]]["firstBloodMsg"] = 0
    else
        client[vars["clientNum"]]["firstBloodMsg"] = 1
    end
end

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
    ["ClientBegin"]           = "firstBloodUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "firstBloodUpdateClientUserinfo",
    ["ObituaryEnemyKill"]     = "checkFirstBloodRunObituaryEnemyKill"
})
