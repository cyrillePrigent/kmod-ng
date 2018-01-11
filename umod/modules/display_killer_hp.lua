-- Display killer HP
-- From kmod script.

-- Global var

killerHp = {
    -- Print killer HP messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_khp_msg_default")),
    -- Killer HP message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_khp_msg_position")
}

-- Explosive inheritance weapon list.
explosiveInheritanceWeapon = {
    [4]  = true, -- GRENADE
    [18] = true, -- GRENADE_LAUNCHER
    [26] = true, -- DYNAMITE
    [27] = true, -- AIRSTRIKE
    [30] = true, -- ARTY
    [43] = true, -- GPG40
    [44] = true  -- M7
}

-- Set default client data.
--
-- Print killer HP status.
clientDefaultData["killerHpMsg"] = 0

-- Set slash command of killer HP message status.
addSlashCommand("client", "killerhp", {"function", "killerHpSlashCommand"})

-- Function

-- Set client data & client user info if killer hp message is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if killer hp message is enabled or not..
function setKillerHpMsg(clientNum, value)
    client[clientNum]["killerHpMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_killerhp", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Manage killer HP message status when killerhp slash command is used.
--  params is parameters passed to the function executed in command file.
function killerHpSlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "on"

        if client[params.clientNum]["killerHpMsg"] == 0 then
            status = "off"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setKillerHpMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setKillerHpMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage killer HP message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function killerHpUpdateClientUserinfo(vars)
    local khp = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_killerhp")

    if khp == "" then
        setKillerHpMsg(vars["clientNum"], killerHp["msgDefault"])
    elseif tonumber(khp) == 0 then
        client[vars["clientNum"]]["killerHpMsg"] = 0
    else
        client[vars["clientNum"]]["killerHpMsg"] = 1
    end
end

-- Callback function when a player kill a enemy.
-- Display killer HP when a player is killed and the killer is alive.
-- Add a notification if killer use adrenaline.
-- If killer is death, check his weapon and display notification for
-- explosive inheritance.
--  vars is the local vars of et_Obituary function.
function displayKillerHpObituaryEnemyKill(vars)
    if client[vars["victim"]]["killerHpMsg"] == 0 then
        return
    end

    local hp = et.gentity_get(vars["killer"], "health")

    if hp > 0 then
        et.trap_SendServerCommand(
            vars["victim"],
            killerHp["msgPosition"] .. " \""  .. color1 .. vars["killerName"]
            .. color1 .. "'s hp (" .. color3 .. hp .. color1 .. ")\""
        )

        if client[vars["killer"]]["useAdrenaline"] == 1 then
            et.trap_SendServerCommand(
                vars["victim"],
                killerHp["msgPosition"] .. " \"" .. color1 .. vars["killerName"]
                .. color1 .. " is an adrenaline junkie!\""
            )
        end
    else
        if explosiveInheritanceWeapon[vars["meansOfDeath"]] then
            et.trap_SendServerCommand(
                vars["victim"],
                killerHp["msgPosition"] .. " \"" .. color1 .. "You were owned by "
                .. vars["killerName"] .. color1 .. "'s explosive inheritance\""
            )
        end
    end
end

-- Add callback display killer HP function.
addCallbackFunction({
    ["ClientBegin"]           = "killerHpUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "killerHpUpdateClientUserinfo",
    ["ObituaryEnemyKill"]     = "displayKillerHpObituaryEnemyKill"
})
