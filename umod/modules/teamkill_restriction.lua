-- Teamkill restriction
--  From etadmin script & kmod script.

-- Global var

tkIndex = {
    ["0.75"] = {
        [3]  = true, -- MG42
        [4]  = true, -- Grenade (Allies grenade)
        [17] = true, -- Panzerfaust
        [18] = true, -- Grenade launcher (Axis grenade)
        [23] = true, -- MAPMORTAR SPLASH
        [43] = true, -- GPG40
        [44] = true, -- M7
        [49] = true, -- Mobile MG42
        [57] = true, -- Mortar
    },
    ["0.5"] = {
        [27] = true, -- Airstrike
        [30] = true, -- Arty
    },
    ["nothing"] = {
        [26] = true, -- Dynamite
        [45] = true, -- Landmine
    }
}

tkRestriction = {
    -- Lower most limit for teamkill restriction.
    ["limitLow"] = tonumber(et.trap_Cvar_Get("u_tk_limit_low")),
    -- Upper most limit for teamkill restriction.
    ["limitHigh"] = tonumber(et.trap_Cvar_Get("u_tk_limit_high")),
    -- Level value will be immune to the teamkill restriction.
    ["protect"] = tonumber(et.trap_Cvar_Get("u_tk_protect"))
}

-- Set module command.
cmdList["client"]["!tk_index"] = "/command/client/tk_index.lua"

-- Function

-- Callback function when victim is killed by mate (teamkill).
-- When a player make a team kill, decrement tk index following the weapon used.
-- If his tk index is too low, warn it. If player make a another team kill, kick it.
--  vars is the local vars of et_Obituary function.
function checkTeamkillRestrictionObituaryTeamKill(vars)
    if game["state"] ~= 0 then
        return
    end

    if getAdminLevel(vars["killer"]) >= tkRestriction["protect"] then
        return
    end

    if tkIndex["0.75"][vars["meansOfDeath"]] then
        client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 0.75
    elseif tkIndex["0.5"][vars["meansOfDeath"]] then
        client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 0.5
    elseif not tkIndex["nothing"][vars["meansOfDeath"]] then -- Mines & Dynamite does nothing!
        client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] - 1
    end

    if tkRestriction["limitLow"] + 1 == client[vars["killer"]]["tkIndex"] then
        et.trap_SendServerCommand(
            vars["killer"],
            msgCmd["chatArea"] .. " \"" .. color4 .. "You are making to many teamkills" ..
            " please be more careful or you will be kicked!\n\""
        )
        
        et.G_ClientSound(vars["killer"], "sound/misc/referee.wav")
    elseif client[vars["killer"]]["tkIndex"] <= tkRestriction["limitLow"] then
        kick(vars["killer"], "Too many teamkills", 10)
    end
end

-- Callback function when a player kill a enemy.
-- When a player kill a enemy, increment tk index and limit maximum tk index.
--  vars is the local vars of et_Obituary function.
function checkTeamkillRestrictionObituaryEnemyKill(vars)
    if game["state"] == 0 then
        client[vars["killer"]]["tkIndex"] = client[vars["killer"]]["tkIndex"] + 1

        if client[vars["killer"]]["tkIndex"] > tkRestriction["limitHigh"] then
            client[vars["killer"]]["tkIndex"] = tkRestriction["limitHigh"]
        end
    end
end

-- Callback function whenever the server or qagame prints a string to the console.
-- When a player revive his mate, increment tk index and limit maximum tk index.
--  vars is the local vars of et_Print function.
function checkTeamkillRestrictionPrint(vars)
    if vars["arg"][1] == "Medic_Revive:" then
        local reviver = tonumber(vars["arg"][2])
        client[reviver]["tkIndex"] = client[reviver]["tkIndex"] + 1

        if client[reviver]["tkIndex"] > tkRestriction["limitHigh"] then
            client[reviver]["tkIndex"] = tkRestriction["limitHigh"]
        end
    end
end

-- Add callback teamkill restriction function.
addCallbackFunction({
    ["ObituaryTeamKill"]  = "checkTeamkillRestrictionObituaryTeamKill",
    ["ObituaryEnemyKill"] = "checkTeamkillRestrictionObituaryEnemyKill",
    ["Print"]             = "checkTeamkillRestrictionPrint"
})
