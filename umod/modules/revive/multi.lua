-- Multi revive

-- From Vetinari's rspree script.
--
-- $Date: 2007-03-02 13:35:49 +0100 (Fri, 02 Mar 2007) $ 
-- $Id: rspree.lua 181 2007-03-02 12:35:49Z vetinari $
-- $Revision: 181 $
--
-- version 1.2.3
--

-- Global var

multiRevive = {
    ["list"] = {
        [3] = {
            -- Multi revive message message.
            ["msg"] = et.trap_Cvar_Get("u_mr_multi_revive_msg"),
            -- Multi revive message position.
            ["msgPosition"] = et.trap_Cvar_Get("u_mr_multi_revive_pos"),
            -- Multi revive message sound.
            ["sound"] = et.trap_Cvar_Get("u_mr_multi_revive_sound"),
        },
        [5] = {
            -- Monster revive message message.
            ["msg"] = et.trap_Cvar_Get("u_mr_monster_revive_msg"),
            -- Monster revive message position.
            ["msgPosition"] = et.trap_Cvar_Get("u_mr_monster_revive_pos"),
            -- Monster revive message sound.
            ["sound"] = et.trap_Cvar_Get("u_mr_monster_revive_sound"),
        }
    },
    -- Teamkill revive status.
    ["allowTkRevive"] = tonumber(et.trap_Cvar_Get("u_mr_allow_tk_revive")),
    -- Time in seconds between multi revive (in milliseconds).
    ["maxElapsedTime"] = tonumber(et.trap_Cvar_Get("u_mr_multi_revive_time")) * 1000,
    -- Multi & monster revive announce status.
    ["multiReviveAnnounce"] = tonumber(et.trap_Cvar_Get("u_mr_multi_revive_announce")),
    -- Multi & monster revive sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_mr_multi_revive_enable_sound")),
    -- Noise reduction of multi & monster revive sound.
    ["multiNoiseReduction"] = tonumber(et.trap_Cvar_Get("u_mr_multi_revive_noise_reduction")),
    -- Print revive spree messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_mr_msg_default")),
}

-- Set default client data.
--
-- Multi revive value.
clientDefaultData["multiRevive"] = 0
-- Time of Last revive (in ms).
clientDefaultData["lastReviveTime"] = 0
-- Print death spree status.
clientDefaultData["multiReviveMsg"] = 0

-- Set slash command of multi revive message status.
addSlashCommand("client", "mrevive", {"function", "multiReviveSlashCommand"})

-- Function

-- Set client data & client user info if multi revive message is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if multi revive message is enabled or not.
function setMultiReviveMsg(clientNum, value)
    client[clientNum]["multiReviveMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_mrevive", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Manage multi revive message status when mrevive slash command is used.
--  params is parameters passed to the function executed in command file.
function multiReviveSlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd
    
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["multiReviveMsg"] == 0 then
            status = "^8off^7"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setMultiReviveMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setMultiReviveMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
-- Manage multi revive message status when client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function multiReviveUpdateClientUserinfo(vars)
    local mr = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_mrevive")

    if mr == "" then
        setMultiReviveMsg(vars["clientNum"], reviveSpree["msgDefault"])
    elseif tonumber(mr) == 0 then
        client[vars["clientNum"]]["multiReviveMsg"] = 0
    else
        client[vars["clientNum"]]["multiReviveMsg"] = 1
    end
end

-- Check multi revive.
--  medic is the medic client slot id.
--  zombie is the revived client slot id.
--  tk is kill type of the revived client.
function checkMultiRevive(medic, zombie, tk)
    -- tk & revive
    if tk then
        if multiRevive["allowTkRevive"] == 1 and client[medic]["multiRevive"] > 0 then
            client[medic]["lastReviveTime"] = et.trap_Milliseconds()
        end
    -- not a tk & revive
    else
        local lvlTime = et.trap_Milliseconds()

        if lvlTime - client[medic]["lastReviveTime"] < multiRevive["maxElapsedTime"] then
            client[medic]["multiRevive"] = client[medic]["multiRevive"] + 1 

            local amount = client[medic]["multiRevive"]

            if multiRevive["list"][amount] then
                if multiRevive["multiReviveAnnounce"] == 1 then
                    sayClients(
                        multiRevive["list"][amount]["msgPosition"],
                        string.format(
                            multiRevive["list"][amount]["msg"],
                            client[medic]["name"]
                        ),
                        "multiReviveMsg"
                    )
                end

                if multiRevive["enabledSound"] == 1 then
                    if multiRevive["multiNoiseReduction"] == 1 then
                        playSound(
                            multiRevive["list"][amount]["sound"],
                            "multiReviveMsg",
                            medic
                        )
                    else
                        playSound(
                            multiRevive["list"][amount]["sound"],
                            "multiReviveMsg"
                        )
                    end
                end

                --local guid = string.lower(client[medic]["guid"])

                -- multi
                --if reviveSpree["srvRecord"] == 1 then
                --    reviveSpree["serverRecords"][guid][1] = reviveSpree["serverRecords"][guid][1] + 1
                --end

                -- monster
                --if reviveSpree["srvRecord"] == 1 then
                --    reviveSpree["serverRecords"][guid][2] = reviveSpree["serverRecords"][guid][2] + 1
                --end
            end
        else
            client[medic]["multiRevive"] = 1
        end

        client[medic]["lastReviveTime"] = lvlTime
    end
end

-- Callback function of et_Obituary function.
-- Rest multi revive data of victim.
--  vars is the local vars of et_Obituary function.
function resetMultiRevive(vars) 
    client[vars["victim"]]["multiRevive"]    = 0
    client[vars["victim"]]["lastReviveTime"] = 0
end

-- Add callback multi revive function.

-- yes, very unlikely, but you can revive, die, get revived and do 
-- another revive within 3 secs....
-- hmm... probably it's worth a possible multi/monster revive if
-- you manage to do that, so let the admin decide if it's honoured
if tonumber(et.trap_Cvar_Get("u_mr_multi_revive_without_death")) == 1 then
    addCallbackFunction({
        ["Obituary"] = "resetMultiRevive"
    })
end

addCallbackFunction({
    ["ClientBegin"]           = "multiReviveUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "multiReviveUpdateClientUserinfo"
})
