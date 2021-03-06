-- Selfkill in fight

-- From nofightsk script.

-- GhosT:McSteve
-- www.ghostworks.co.uk
-- #ghostworks, #pbbans @quakenet
-- Version 1, 25/1/07

-- From skcount script.

-- Selfkill penalty script
-- many thanks to GhosT:Rabid for his help in building the class/weapon table
-- version:  v1.1
-- by GhosT:McSteve, 25/11/06

-- From ???

-- Disabled selfkill in fight for x seconds

-- Global var

selfkillInFight = {
    -- Punishment level.
    ["punishment"] = tonumber(et.trap_Cvar_Get("u_selfkill_punishment")),
    -- Time to wait before selfkill
    ["hitWait"] = {
        ["secs"]    = tonumber(et.trap_Cvar_Get("u_selfkill_hit_wait")),
        ["ms"]      = 0
    }
    -- Limit of allowed selkill.
    ["limit"] = tonumber(et.trap_Cvar_Get("u_selfkill_limit")),
    -- Percentage before warning.
    ["warnPercentage"] = et.trap_Cvar_Get("u_selfkill_warn_percentage"),
    -- Selfkill in fight message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_selfkill_msg_position"),
    -- Time (in ms) of last selfkill in fight check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 100
}

selfkillInFight["hitWait"]["ms"] = selfkillInFight["hitWait"]["secs"] * 1000

-- Set default client data.
--
-- Last damage received value.
clientDefaultData["damageReceived"] = 0
-- Time to end damage received check.
clientDefaultData["damageReceivedEnding"] = 0

if selfkillInFight["punishment"] > 0 and selfkillInFight["punishment"] < 4 then
    -- Number of selkill value.
    clientDefaultData["selfkills"] = 0
end

if selfkillInFight["punishment"] == 2 then
    -- Punishment level.
    clientDefaultData["selfkillPunishment"] = 0
end

-- Override kill slash command.
addSlashCommand("client", "kill", {"function", "selfkillInFightSlashCommand"})

periodicFrameCallback["checkSelfkillInFightPlayerRunFrame"] = "selfkillInFight"

-- Function

-- Callback function when qagame runs a server frame in player loop
-- pending warmup and round.
-- Check periodically players is hit.
--  clientNum is the client slot id.
--  vars is the local vars passed from et_RunFrame function.
function checkSelfkillInFightPlayerRunFrame(clientNum, vars)
    if client[clientNum]["team"] == 1 or client[clientNum]["team"] == 2 then
        -- Compare damage to the last value (check if ~= 0)
        local damageReceived = et.gentity_get(clientNum, "sess.damage_received")

        if damageReceived > client[clientNum]["damageReceived"] then
            -- Damage has been taken in the last <sampleRate> milliseconds -> set switch to 10
            client[clientNum]["damageReceivedEnding"] = vars["levelTime"] + selfkillInFight["hitWait"]["ms"]

            -- Save the current damage value to carry across to next iteration
            client[clientNum]["damageReceived"] = damageReceived
        else
            if client[clientNum]["damageReceivedEnding"] ~= 0 then
                if vars["levelTime"] > client[clientNum]["damageReceivedEnding"] then
                    client[clientNum]["damageReceivedEnding"] = 0
                end
            end
        end
    end
end

-- Function executed when slash command is called in et_ClientCommand function.
-- If kill slash command is used and if it'a a selfkill in fight, apply
-- punishment : warning, limit selkill, incur a penalty at next respawn,
-- move to spectator or kick.
--  params is parameters passed to the function executed in command file.
function selfkillInFightSlashCommand(params)
    if client[params.clientNum]["team"] ~= 3 and et.gentity_get(params.clientNum, "health") > 0 then
        --if damageReceivedEnding = 1, then client is taking damage and should not be able to selfkill
        if client[params.clientNum]["damageReceivedEnding"] > 0 then
            params.say          = selfkillInFight["msgPosition"]
            params.noDisplayCmd = true

            if selfkillInFight["punishment"] == 0 then
                params.broadcast2allClients = true

                printCmdMsg(
                    params,
                    color4 .. "WARNING! " .. color1 ..
                    client[params.clientNum]["name"] .. color2 ..
                    " selfkilled infight.\n"
                )
            elseif selfkillInFight["punishment"] == 4 then
                -- Wait 3 seconds before execute self kill
                -- Work only with self kills in fight restriction
                printCmdMsg(
                    params,
                    color2 .. "Server detects you have been hit - selfkill disabled for " ..
                    selfkillInFight["hitWait"]["secs"] .. " seconds"
                )

                return 1
            else
                client[params.clientNum]["selfkills"] = client[params.clientNum]["selfkills"] + 1

                if selfkillInFight["limit"] < client[params.clientNum]["selfkills"] then
                    if selfkillInFight["punishment"] == 1 then
                        params.broadcast2allClients = true

                        printCmdMsg(
                            params,
                            color4 .. "*ATTENTION*: " .. color1 ..
                            client[params.clientNum]["name"] .. color1 ..
                            " made more selfkills, then allowed -> " .. color4 ..
                            "Moving to spectator..."
                        )

                        et.trap_SendConsoleCommand(
                            et.EXEC_APPEND,
                            "forceteam " .. params.clientNum .. " s"
                        )
                    elseif selfkillInFight["punishment"] == 2 then
                        client[params.clientNum]["selfkillPunishment"] = client[params.clientNum]["selfkillPunishment"] + 1

                        if client[params.clientNum]["selfkillPunishment"] == 1 then
                            printCmdMsg(
                                params,
                                "^1Warning, your next selfkill will incur a penalty."
                            )
                        elseif client[params.clientNum]["selfkillPunishment"] > 1 then
                            printCmdMsg(
                                params,
                                color4 .. "Selfkills = " ..
                                client[params.clientNum]["selfkillPunishment"] ..
                                color4 .. " , penalty incurred"
                            )
                        end
                    elseif selfkillInFight["punishment"] == 3 then
                        params.broadcast2allClients = true

                        printCmdMsg(
                            params,
                            color4 .. "*ATTENTION*: " .. color1 ..
                            client[params.clientNum]["name"] .. color1 ..
                            " made more selfkills, then allowed -> " .. color4 .. "kick"
                        )

                        kick(params.clientNum, "you made more selfkills then allowed.")
                    end
                elseif selfkillInFight["limit"] * selfkillInFight["warnPercentage"] < client[params.clientNum]["selfkills"] then
                    local nextAction = ""

                    if client[params.clientNum]["selfkills"] == selfkillInFight["limit"] then
                        if selfkillInFight["punishment"] == 1 then
                            nextAction = color1 .. " Next " .. color2 ..
                                "/kill " .. color1 .. "= " .. color4 ..
                                "Moving to spectator" .. color1 .. "."
                        elseif selfkillInFight["punishment"] == 3 then
                            nextAction = color1 .. " Next " .. color2 ..
                                "/kill " .. color1 .. "= " .. color4 ..
                                "Kick" .. color1 .. "."
                        end
                    end

                    printCmdMsg(
                        params,
                        color4 .. "*WARNING*: " .. color1 .. client[params.clientNum]["name"] ..
                        color1 .. ", you have " .. color4 ..
                        (selfkillInFight["limit"] - client[params.clientNum]["selfkills"]) ..
                        color1 .. " suicides left!" .. nextAction
                    )
                end
            end
        end
    end

    client[params.clientNum]["damageReceivedEnding"] = 0

    return 0
end

if selfkillInFight["punishment"] == 2 then
    -- Callback function when a client is spawned.
    -- Apply player punishment. 
    --  vars is the local vars passed from et_ClientSpawn function.
    function selfkillInFightClientSpawn(vars)
        if vars["revived"] ~= 0 then
            return
        end

        -- selfkillPunishment = 1, warning only
        if client[vars["clientNum"]]["selfkillPunishment"] < 2 then
            return
        end

        -- Check the player's weapon
        local weapon = et.gentity_get(vars["clientNum"], "s.weapon")

        -- Check the player's ammo
        local ammo     = et.gentity_get(vars["clientNum"], "ps.ammo", weapon)
        local ammoClip = et.gentity_get(vars["clientNum"], "ps.ammoclip", weapon)

        -- selfkillPunishment = 2, -1/2 clip of ammo
        if client[vars["clientNum"]]["selfkillPunishment"] == 2  then
            et.gentity_set(vars["clientNum"], "ps.ammoclip", weapon, ammoClip - (ammoClip / 2))

        -- selfkillPunishment = 3, -1 clip of ammo
        elseif client[vars["clientNum"]]["selfkillPunishment"] == 3  then
            et.gentity_set(vars["clientNum"], "ps.ammoclip", weapon, 0)

        -- selfkillPunishment = 4, -1 1/2 clips of ammo
        elseif client[vars["clientNum"]]["selfkillPunishment"] == 4  then
            et.gentity_set(vars["clientNum"], "ps.ammoclip", weapon, 0)
            et.gentity_set(vars["clientNum"], "ps.ammo", weapon, ammo - (ammo / 2))

        -- selfkillPunishment = 5, -1 2/3 clips of ammo + set health to 70 HP
        elseif client[vars["clientNum"]]["selfkillPunishment"] == 5  then
            et.gentity_set(vars["clientNum"], "ps.ammoclip", weapon, 0)
            et.gentity_set(vars["clientNum"], "ps.ammo", weapon, ammo - (2 * ammo / 3))
            et.gentity_set(vars["clientNum"], "health", 70)

        -- selfkillPunishment = 6, - all ammo + set health to 10 HP
        elseif client[vars["clientNum"]]["selfkillPunishment"] >= 6  then
            et.gentity_set(vars["clientNum"], "ps.ammoclip", weapon, 0)
            et.gentity_set(vars["clientNum"], "ps.ammo", weapon, 0)
            et.gentity_set(vars["clientNum"], "health", 10)
        end
    end

    -- Add callback selfkill in fight function.
    addCallbackFunction({
        ["ClientSpawn"] = "selfkillInFightClientSpawn"
    })
end

-- Add callback selfkill in fight function.
addCallbackFunction({
    ["RunFramePlayerLoop"]         = "checkSelfkillInFightPlayerRunFrame",
    ["RunFramePlayerLoopEndRound"] = "checkSelfkillInFightPlayerRunFrame"
})
