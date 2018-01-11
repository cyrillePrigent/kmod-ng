-- Auto panzer disable
-- From kmod script.

-- Global var

-- TODO :Clean time & time2 in autoPanzerDisable table

autoPanzerDisable = {
    -- Auto panzer disable module status.
    ["enabled"] = false,
    -- Panzer enable / disable message status.
    ["msg"] = {
        ["enabled"]  = false,
        ["disabled"] = false,
    },
    -- Panzer disable warning level.
    ["warning"] = 0,
    -- Time (in ms) of last panzer disable warning check.
    ["time2"] = 0,
    -- Minimum active players to activate panzers.
    ["playerLimit"] = tonumber(et.trap_Cvar_Get("u_panzer_player_limit")),
    -- Time (in ms) of last auto panzer disable check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 250
}

-- Function

-- Called when qagame initializes.
-- Check if soldier class & panzerfaust weapon is enabled.
--  vars is the local vars of et_InitGame function.
function autoPanzerDisableInitGame(vars)
    local team_maxSoldiers = tonumber(et.trap_Cvar_Get("team_maxSoldiers"))
    local team_maxpanzers = tonumber(et.trap_Cvar_Get("team_maxpanzers"))

    if team_maxSoldiers ~= nil and team_maxSoldiers > 0 and
      team_maxpanzers ~= nil and team_maxpanzers > 0 then
        autoPanzerDisable["enabled"] = true
        addCallbackFunction({["RunFrame"] = "autoPanzerDisableRunFrame"})
    else
        et.G_LogPrint(
            "uMod Auto panzer disable : Panzerfaust is disabled! Please enable it with <team_maxSoldiers> or <team_maxpanzers> cvar.\n"
        )
    end
end

-- Callback function when qagame runs a server frame.
-- If server have minimum active players, activate panzers.
-- If not and some players used panzers, disable panzers and
-- display first warning. After 3mins, display second warning
-- and after 30secs, move soldiers with panzers to spectator.
--  vars is the local vars passed from et_RunFrame function.
function autoPanzerDisableRunFrame(vars)
    if autoPanzerDisable["time"] + autoPanzerDisable["frameCheck"] < vars["levelTime"] then
        if players["active"] < autoPanzerDisable["playerLimit"] then
            local activePanzers = false

            for i = 0, clientsLimit, 1 do
                if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                    activePanzers = true
                    break
                end
            end

            if autoPanzerDisable["msg"]["disabled"] == false then
                autoPanzerDisable["msg"]["disabled"] = true
                autoPanzerDisable["msg"]["enabled"]  = false

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay ^3Panzerlimit: ^7Panzers have been disabled.\n"
                )
            end

            if activePanzers then
                if autoPanzerDisable["warning"] == 0 then
                    autoPanzerDisable["time2"]   = vars["levelTime"]
                    autoPanzerDisable["warning"] = 1

                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "qsay ^3Panzerlimit: ^7Please switch to a different weapon or be automatically moved to spec in ^11^3 minute!\n"
                    )

                    et.trap_SendConsoleCommand(
                        et.EXEC_APPEND,
                        "team_maxpanzers 0\n"
                    )
                end

                local remainingTime = vars["levelTime"] - autoPanzerDisable["time2"]

                -- After 30 secs...
                if remainingTime > 30000 then
                    if autoPanzerDisable["warning"] == 1 then
                        autoPanzerDisable["warning"] = 2

                        et.trap_SendConsoleCommand(
                            et.EXEC_APPEND,
                            "qsay ^3Panzerlimit: ^7Please switch to a different weapon or be automatically moved to spec in ^130^3 Seconds!\n"
                        )
                    end
                end

                -- After 60 secs...
                if remainingTime > 60000 then
                    for i = 0, clientsLimit, 1 do
                        if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
                            et.gentity_set(i, "sess.latchPlayerWeapon", 3)

                            et.trap_SendServerCommand(
                                i,
                                "chat \"^1You have been moved to spectator for having a panzerfaust after being warned twice to switch!\"\n"
                            )
                        end
                    end

                    autoPanzerDisable["msg"]["disabled"] = false
                    autoPanzerDisable["warning"]         = 0
                end
            else
                autoPanzerDisable["warning"] = 0
            end
        else
            autoPanzerDisable["msg"]["disabled"] = false
            autoPanzerDisable["warning"]         = 0
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers " .. panzersPerTeam .. "\n")

            if autoPanzerDisable["msg"]["enabled"] == false then
                autoPanzerDisable["msg"]["enabled"] = true

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay ^3Panzerlimit: ^7Panzers have been auto-enabled. Each team is allowed only ^1"
                    .. panzersPerTeam .. "^7 panzer(s) per team!\n"
                )
            end
        end

        autoPanzerDisable["time"] = vars["levelTime"]
    end
end

-- Add callback auto panzer disable function.
addCallbackFunction({
    ["InitGame"] = "autoPanzerDisableInitGame"
})

