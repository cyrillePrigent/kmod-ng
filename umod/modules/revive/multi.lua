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
    ["multiNoiseReduction"] = tonumber(et.trap_Cvar_Get("u_mr_multi_revive_noise_reduction"))
}

-- Set default client data.
--
-- Multi revive value.
clientDefaultData["multiRevive"] = 0
-- Time of Last revive (in ms).
clientDefaultData["lastReviveTime"] = 0
-- Print multi revive status.
clientDefaultData["multiReviveMsg"] = 0

-- Set multi revive module message.
table.insert(slashCommandModuleMsg, {
    -- Name of multi revive module message key in client data.
    ["clientDataKey"] = "multiReviveMsg",
    -- Name of multi revive module message key in userinfo data.
    ["userinfoKey"] = "u_mrevive",
    -- Name of multi revive module message slash command.
    ["slashCommand"] = "mrevive",
    -- Print multi revive messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_mr_msg_default"))
})

-- Function

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
