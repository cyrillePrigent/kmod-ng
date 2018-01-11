-- Display killer HP
-- From kmod script.

-- Global var

killerHp = {
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

-- Set display killer HP module message.
table.insert(slashCommandModuleMsg, {
    -- Name of display killer HP module message key in client data.
    ["clientDataKey"] = "killerHpMsg",
    -- Name of display killer HP module message key in userinfo data.
    ["userinfoKey"] = "u_killerhp",
    -- Name of display killer HP module message slash command.
    ["slashCommand"] = "killerhp",
    -- Print display killer HP messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_khp_msg_default"))
})

-- Function

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
    ["ObituaryEnemyKill"] = "displayKillerHpObituaryEnemyKill"
})
