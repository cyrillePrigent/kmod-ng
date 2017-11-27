-- Selfkill in fight

-- nofightsk.lua
--
-- GhosT:McSteve
-- www.ghostworks.co.uk
-- #ghostworks, #pbbans @quakenet
-- Version 1, 25/1/07

-- skcount.lua
--
-- Selfkill penalty script
-- many thanks to GhosT:Rabid for his help in building the class/weapon table
-- version:  v1.1
-- by GhosT:McSteve, 25/11/06

-- ???.lua
--
-- Disabled selfkill in fight for x seconds

-- Global var

selfkillInFight = {
    ["sampleRate"]     = 100,
    ["time"]           = 0,
    ["punishment"]     = tonumber(et.trap_Cvar_Get("u_selfkill_punishment")),
    ["hitWait"]        = tonumber(et.trap_Cvar_Get("u_selfkill_hit_wait")),
    ["limit"]          = tonumber(et.trap_Cvar_Get("u_selfkill_limit")),
    ["warnPercentage"] = et.trap_Cvar_Get("u_selfkill_warn_percentage"),
    ["msgPosition"]    = et.trap_Cvar_Get("u_selfkill_msg_position")
}

-- Set default client data.
clientDefaultData["damageReceived"]        = 0
clientDefaultData["damageReceivedCounter"] = 0

if selfkillInFight["punishment"] > 0 and selfkillInFight["punishment"] < 4 then
    clientDefaultData["selfkills"] = 0
end

if selfkillInFight["punishment"] == 2 then
    clientDefaultData["selfkillPunishment"] = 0
end

addSlashCommand("client", "kill", {"function", "selfkillInFightSlashCommand"})

-- Function

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkSelfkillInFightRunFrame(vars)
    if vars["levelTime"] - selfkillInFight["time"] > selfkillInFight["sampleRate"] then
        -- for all clients, check the client's damage received
        for i = 0, clientsLimit, 1 do
            --compare damage to the last value (check if ~= 0)
            
            --current value = et.gentity_get(i, "sess.damage_received")
            if (et.gentity_get(i, "sess.damage_received")) > (client[i]["damageReceived"]) then
                --damage has been taken in the last <sampleRate> milliseconds -> set switch to 10
                client[i]["damageReceivedCounter"] = selfkillInFight["hitWait"]

                --save the current damage value to carry across to next iteration
                client[i]["damageReceived"] = et.gentity_get(i, "sess.damage_received")
            else
                if client[i]["damageReceivedCounter"] ~= 0 then
                    client[i]["damageReceivedCounter"] = client[i]["damageReceivedCounter"] - 1
                end
            end
        end
        
        selfkillInFight["time"] = vars["levelTime"]
    end
end

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function selfkillInFightSlashCommand(params)
    if et.gentity_get(params.clientNum, "health") > 0 then
        --if damageReceivedCounter = 1, then client is taking damage and should not be able to selfkill
        if client[params.clientNum]["damageReceivedCounter"] >= 1 then
            if selfkillInFight["punishment"] == 0 then
                sayClients("qsay", string.format("^1WARNING! %s ^3selfkilled infight.\n", client[params.clientNum]["name"]))
            --[[
            elseif selfkillInFight["punishment"] == 4 then
                --  Wait 3 seconds before execute self kill (Work only with self kills in fight restriction)
                et.trap_SendServerCommand(
                    params.clientNum,
                    string.format(
                        "%s ^3Server detects you have been hit - selfkill disabled for %d seconds^7",
                        selfkillInFight["msgPosition"],
                        selfkillInFight["hitWait"]
                    )
                )
                return 1
            --]]
            else
                client[params.clientNum]["selfkills"] = client[params.clientNum]["selfkills"] + 1

                if selfkillInFight["limit"] < client[params.clientNum]["selfkills"] then
                    if selfkillInFight["punishment"] == 1 then
                        sayClients(
                            selfkillInFight["msgPosition"],
                            string.format(
                                "^1*ATTENTION*:^7 %s ^7made more selfkills, then allowed -> ^1Moving to spectator...^7",
                                client[params.clientNum]["name"]
                            )
                        )

                        et.trap_SendConsoleCommand(et.EXEC_APPEND, string.format("forceteam %d s", params.clientNum))
                    elseif selfkillInFight["punishment"] == 2 then
                        client[params.clientNum]["selfkillPunishment"] = client[params.clientNum]["selfkillPunishment"] + 1

                        if client[params.clientNum]["selfkillPunishment"] == 1 then
                            et.trap_SendServerCommand(
                                params.clientNum,
                                string.format(
                                    "%s \"^1Warning, your next selfkill will incur a penalty.\n\"",
                                    selfkillInFight["msgPosition"]
                                )
                            )
                        elseif client[params.clientNum]["selfkillPunishment"] > 1 then
                            et.trap_SendServerCommand(
                                params.clientNum,
                                string.format(
                                    "%s \"^1Selfkills = %d ^1, penalty incurred\n\"",
                                    selfkillInFight["msgPosition"],
                                    client[params.clientNum]["selfkillPunishment"]
                                )
                            )
                        end
                    elseif selfkillInFight["punishment"] == 3 then
                        sayClients(
                            selfkillInFight["msgPosition"],
                            string.format(
                                "^1*ATTENTION*:^7 %s ^7made more selfkills, then allowed -> ^1kick^7",
                                client[params.clientNum]["name"]
                            )
                        )

                        kick(params.clientNum, "you made more selfkills then allowed.")
                    end
                elseif selfkillInFight["limit"] * selfkillInFight["warnPercentage"] < client[params.clientNum]["selfkills"] then
                    local nextAction = ""

                    if client[params.clientNum]["selfkills"] == selfkillInFight["limit"] then
                        nextAction = " ^7Next ^3/kill ^7= ^1kick^7."
                    end

                    sayClients(
                        selfkillInFight["msgPosition"],
                        string.format(
                            "^1*WARNING*^7: %s^7, you have ^2%d^7 suicides left!%s",
                            client[params.clientNum]["name"],
                            (selfkillInFight["limit"] - client[params.clientNum]["selfkills"]),
                            nextAction
                        )
                    )
                end
            end
            
            return 0
        end
    end

    return 0
end

-- Callback function when a client is spawned.
--  vars is the local vars passed from et_ClientSpawn function.
function selfkillInFightClientSpawn(vars)
    if vars["revived"] ~= 0 then
        return
    end

    -- selfkillPunishment = 1, warning only
    if client[vars["clientNum"]]["selfkillPunishment"] < 2 then
        return
    end

    -- check the player's weapon
    local weapon = et.gentity_get(vars["clientNum"], "s.weapon")

    --check the player's ammo
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
if selfkillInFight["punishment"] == 2 then
    addCallbackFunction({
        ["RunFrame"]    = "checkSelfkillInFightRunFrame",
        ["ClientSpawn"] = "selfkillInFightClientSpawn"
    })
else
    addCallbackFunction({
        ["RunFrame"] = "checkSelfkillInFightRunFrame"
    })
end