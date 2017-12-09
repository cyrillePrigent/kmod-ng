-- Teamkill restriction
--  From etadmin script & kmod lua script.

-- Global var

tkIndex = {
    ["0.75"] = {
        [3]  = true, -- MG42
        [4]  = true, -- GRENADE
        [17] = true, -- PANZERFAUST
        [18] = true, -- GRENADE LAUNCHER
        [23] = true, -- MAPMORTAR SPLASH
        [43] = true, -- GPG40
        [44] = true, -- M7
        [49] = true, -- MOBILE MG42
        [57] = true, -- MORTAR
    },
    ["0.5"] = {
        [27] = true, -- AIRSTRIKE
        [30] = true, -- ARTY
    },
    ["nothing"] = {
        [26] = true, -- DYNAMITE
        [45] = true, -- LANDMINE
    }
}

tkRestriction = {
    ["limitLow"]  = tonumber(et.trap_Cvar_Get("u_tk_limit_low")),
    ["limitHigh"] = tonumber(et.trap_Cvar_Get("u_tk_limit_high")),
    ["protect"]   = tonumber(et.trap_Cvar_Get("u_tk_protect"))
}

-- Set module command.
cmdList["client"]["!tk_index"] = "/command/client/tk_index.lua"

-- Function

-- Callback function when victim is killed by mate (teamkill).
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

    if (tkRestriction["limitLow"] + 1) == client[vars["killer"]]["tkIndex"] then
        et.trap_SendServerCommand(
            vars["killer"],
            string.format(
                "%s \"^1You are making to many teamkills please be more careful or you will be kicked!\n\"",
                msgCmd["chatArea"]
            )
        )
        
        et.G_ClientSound(vars["killer"], "sound/misc/referee.wav")
    elseif client[vars["killer"]]["tkIndex"] <= tkRestriction["limitLow"] then
        kick(vars["killer"], "Too many teamkills", 10)
    end
end

-- Callback function when a player kill a enemy.
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
