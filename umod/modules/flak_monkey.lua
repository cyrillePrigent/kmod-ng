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
    -- Print flak monkey messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_fm_msg_default")),
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

-- Set slash command of flak monkey message status.
addSlashCommand("client", "fmonkey", {"function", "flakMonkeySlashCommand"})

-- Function

-- Set client data & client user info if flak monkey message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if flak monkey message & sound is enabled or not.
function setFlakMonkeyMsg(clientNum, value)
    client[clientNum]["flakMonkeyMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_fmonkey", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Manage flak monkey message status when fmonkey slash command is used.
--  params is parameters passed to the function executed in command file.
function flakMonkeySlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["flakMonkeyMsg"] == 0 then
            status = "^8off^7"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setFlakMonkeyMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setFlakMonkeyMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage flak monkey message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function flakMonkeyUpdateClientUserinfo(vars)
    local fm = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_fmonkey")

    if fm == "" then
        setFlakMonkeyMsg(vars["clientNum"], flakMonkey["msgDefault"])
    elseif tonumber(fm) == 0 then
        client[vars["clientNum"]]["flakMonkeyMsg"] = 0
    else
        client[vars["clientNum"]]["flakMonkeyMsg"] = 1
    end
end

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
    ["ClientBegin"]           = "flakMonkeyUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "flakMonkeyUpdateClientUserinfo",
    ["Obituary"]              = "checkFlakMonkeyObituary",
    ["ObituaryEnemyKill"]     = "checkFlakMonkeyObituaryEnemyKill",
    ["ObituaryTeamKill"]      = "checkFlakMonkeyObituaryTeamKill",
})
