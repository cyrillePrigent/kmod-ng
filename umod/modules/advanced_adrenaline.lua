-- Advanced adrenaline
-- From kmod script.

-- Global var

advancedAdrenaline = {
    -- Advanced adrenaline sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_aa_enable_sound")),
    -- Advanced adrenaline sound file.
    ["sound"] = et.trap_Cvar_Get("u_aa_sound")
}

-- Set default client data.
--
-- Trigger to display adrenaline counter.
clientDefaultData["adrenalineMsgTrigger"] = 0
-- Time (in ms) of last adrenaline counter display.
clientDefaultData["adrenalineMsgTime"] = 0
-- Current adrenaline counter.
clientDefaultData["adrenalineCounter"] = 0
-- Print adrenaline counter status.
clientDefaultData["adrenalineMsg"] = 0

-- Set advanced adrenaline module message.
table.insert(slashCommandModuleMsg, {
    -- Name of advanced adrenaline module message key in client data.
    ["clientDataKey"] = "adrenalineMsg",
    -- Name of advanced adrenaline module message key in userinfo data.
    ["userinfoKey"] = "u_advadre",
    -- Name of advanced adrenaline module message slash command.
    ["slashCommand"] = "advadre",
    -- Print advanced adrenaline messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_aa_msg_default"))
})

-- Function

-- Called when qagame initializes.
-- Check if adrenaline is enabled and add advanced adrenaline run frame if needed.
--  vars is the local vars of et_InitGame function.
function advancedAdrenalineInitGame(vars)
    if etMod == "etpro" then
        local b_levels_medic  = et.trap_Cvar_Get("b_levels_medic")
        local b_defaultskills = et.trap_Cvar_Get("b_defaultskills")

        if (b_levels_medic == "" and b_defaultskills == "") or
          (b_levels_medic ~= "" and string.find(b_levels_medic, "%s+%-1%s*$") ~= nil) or
          (b_defaultskills ~= "" and string.find(b_defaultskills, "^%s*[0-4]%s+[0-4]%s+4") == nil) then
            et.G_LogPrint(
                "uMod Advanced adrenaline: Adrenaline is disabled!" ..
                " Please enable it with <b_levels_medic> or <b_defaultskills> cvar.\n"
            )
            return
        end
    elseif etMod == "etlegacy" then
        if string.find(et.trap_Cvar_Get("skill_medic"), "%s+%-1%s*$") == nil then
            et.G_LogPrint(
                "uMod Advanced adrenaline: Adrenaline is disabled!" ..
                " Please enable it with <skill_medic> cvar.\n"
            )
            return
        end
    end

    addCallbackFunction({["RunFrame"] = "checkAdvancedAdrenalineRunFrame"})
end

-- Callback function when qagame runs a server frame.
-- Check if player use adrenaline and display counter if needed.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedAdrenalineRunFrame(vars)
    for i = 0, clientsLimit, 1 do
        -- TODO : Check if slot is used
        local psPowerups = tonumber(et.gentity_get(i, "ps.powerups", 12))

        if not pause["startTrigger"] or (pause["startTrigger"] and psPowerups == 0) then
            if psPowerups > 0 then
                client[i]["useAdrenaline"] = 1

                if client[i]["adrenalineMsgTrigger"] == 0 then
                    client[i]["adrenalineMsgTrigger"] = 1
                    client[i]["adrenalineMsgTime"]    = vars["levelTime"]
                    client[i]["adrenalineCounter"]    = client[i]["adrenalineCounter"] + 1

                    if client[i]["adrenalineMsg"] == 1 then
                        if advancedAdrenaline["enabledSound"] == 1 then
                            et.G_ClientSound(
                                i,
                                advancedAdrenaline["sound"]
                            )
                        end

                        et.trap_SendServerCommand(
                            i,
                            "cp \"^3Adrenaline ^1" .. client[i]["adrenalineCounter"] .. "\n\""
                        )
                    end
                end

                if vars["levelTime"] - client[i]["adrenalineMsgTime"] + 50 >= 1000 then
                    client[i]["adrenalineMsgTrigger"] = 0
                end
            else
                client[i]["useAdrenaline"]        = 0
                client[i]["adrenalineMsgTrigger"] = 0
                client[i]["adrenalineMsgTime"]    = 0
                client[i]["adrenalineCounter"]    = 0
            end
        end
    end
end

-- Add callback advanced adrenaline function.
addCallbackFunction({
    ["InitGame"] = "advancedAdrenalineInitGame"
})
