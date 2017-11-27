-- Advanced adrenaline

-- Global var

advancedAdrenaline = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_aa_enable_sound")),
    ["sound"]        = et.trap_Cvar_Get("u_aa_sound")
}

-- Set default client data.
clientDefaultData["adrenalineDummy"]      = 0
clientDefaultData["adrenalineMsgTrigger"] = 0
clientDefaultData["adrenalineMsgTime"]    = 0
clientDefaultData["adrenalineCounter"]    = 0

-- Function

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function advancedAdrenalineInitGame(vars)
    local cvar

    if etMod == "etpro" then
        cvar = "b_levels_medic"
    elseif etMod == "etlegacy" then
        cvar = "skill_medic"
    end

    if string.find(et.trap_Cvar_Get(cvar), "%s+%-1%s*$") == nil then
        et.G_LogPrint("Adrenaline is disabled! Please enable it with " .. cvar .. " cvar.\n")
    else
        addCallbackFunction({["RunFrame"] = "checkAdvancedAdrenalineRunFrame"})
    end
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedAdrenalineRunFrame(vars)
    for i = 0, clientsLimit, 1 do
        if pause["startTrigger"] then
            client[i]["adrenalineDummy"] = 1
        end

        local psPowerups = tonumber(et.gentity_get(i, "ps.powerups", 12))

        if client[i]["adrenalineDummy"] == 1 and psPowerups == 0 then
            client[i]["adrenalineDummy"] = 0
        end

        if client[i]["adrenalineDummy"] == 0 then
            if psPowerups > 0 then
                client[i]["useAdrenaline"] = 1

                if client[i]["adrenalineMsgTrigger"] == 0 then
                    client[i]["adrenalineMsgTrigger"] = 1
                    client[i]["adrenalineMsgTime"]    = vars["levelTime"]

                    if advancedAdrenaline["enabledSound"] == 1 then
                        et.G_Sound(i, et.G_SoundIndex(advancedAdrenaline["sound"]))
                    end

                    client[i]["adrenalineCounter"] = client[i]["adrenalineCounter"] + 1
                    et.trap_SendServerCommand(i, "cp \"^3Adrenaline ^1" .. client[i]["adrenalineCounter"] .. "\n\"")
                end

                if math.floor(((vars["levelTime"] - client[i]["adrenalineMsgTime"]) / 1000) + 0.05) >= 1 then
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
