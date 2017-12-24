-- Auto panzer disable

-- Global var

autoPanzerDisable = {
    ["enabled"]     = true,
    ["disabledMsg"] = false,
    ["enabledMsg"]  = false,
    ["warning"]     = 0,
    ["time"]        = 0,
    ["playerLimit"] = tonumber(et.trap_Cvar_Get("u_panzer_player_limit"))
}

-- Function

-- TODO : Check if panzer is enabled (team_maxSoldiers ~= 0 & team_maxpanzers ~= 0)

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function autoPanzerDisableRunFrame(vars)
    local activePanzers = false

    if players["active"] < autoPanzerDisable["playerLimit"] then
        for i = 0, clientsLimit, 1 do
            if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                activePanzers = true
                break
            end
        end

        if autoPanzerDisable["disabledMsg"] == false then
            autoPanzerDisable["disabledMsg"] = true
            autoPanzerDisable["enabledMsg"]  = false
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit: ^7Panzers have been disabled.\n")
        end

        if activePanzers then
            if autoPanzerDisable["warning"] == 0 then
                autoPanzerDisable["time"]    = vars["levelTime"]
                autoPanzerDisable["warning"] = 1
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit: ^7Please switch to a different weapon or be automatically moved to spec in ^11^3 minute!\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers 0\n")
            end

            local remainingTime = ((vars["levelTime"] - autoPanzerDisable["time"]) / 1000)

            if remainingTime > 30 then
                if autoPanzerDisable["warning"] == 1 then
                    autoPanzerDisable["warning"] = 2
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit: ^7Please switch to a different weapon or be automatically moved to spec in ^130^3 Seconds!\n")
                end
            end

            if remainingTime > 60 then
                for i = 0, clientsLimit, 1 do
                    if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
                        et.gentity_set(i, "sess.latchPlayerWeapon", 3)

                        et.trap_SendServerCommand(
                            i,
                            "b 8 ^1You have been moved to spectator for having a panzerfaust after being warned twice to switch!\n"
                        )
                    end
                end

                autoPanzerDisable["disabledMsg"] = false
                autoPanzerDisable["warning"]     = 0
            end
        else
            autoPanzerDisable["warning"] = 0
        end
    else
        autoPanzerDisable["disabledMsg"] = false
        autoPanzerDisable["warning"]     = 0
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers " .. panzersPerTeam .. "\n")

        if autoPanzerDisable["enabledMsg"] == false then
            autoPanzerDisable["enabledMsg"] = true
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit: ^7Panzers have been auto-enabled. Each team is allowed only ^1" .. panzersPerTeam .. "^7 panzer(s) per team!\n")
        end
    end
end

-- Add callback auto panzer disable function.
addCallbackFunction({
    ["RunFrame"] = "autoPanzerDisableRunFrame"
})

