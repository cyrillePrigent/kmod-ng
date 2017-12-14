-- Advanced adrenaline
-- From kmod lua script.

-- Global var

advancedAdrenaline = {
    ["msgDefault"]   = tonumber(et.trap_Cvar_Get("u_aa_msg_default")),
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_aa_enable_sound")),
    ["sound"]        = et.trap_Cvar_Get("u_aa_sound")
}

-- Set default client data.
--clientDefaultData["adrenalineDummy"]      = 0
clientDefaultData["adrenalineMsgTrigger"] = 0
clientDefaultData["adrenalineMsgTime"]    = 0
clientDefaultData["adrenalineCounter"]    = 0
clientDefaultData["adrenalineMsg"]        = 0

addSlashCommand("client", "advadre", {"function", "advancedAdrenalineSlashCommand"})

-- Function

-- Set client data & client user info if adrenaline message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if adrenaline message & sound is enabled or not..
function setAdrenalineMsg(clientNum, value)
    client[clientNum]["adrenalineMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_advadre", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- `advadre` command here.
--  params is parameters passed to the function executed in command file.
function advancedAdrenalineSlashCommand(params)
    --params.noDisplayCmd = true
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "on"

        if client[params.clientNum]["adrenalineMsg"] == 0 then
            status = "off"
        end

        printCmdMsg(
            params,
            "Messages are " .. color3 .. status
        )
    elseif tonumber(params["arg1"]) == 0 then
        setAdrenalineMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setAdrenalineMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function advancedAdrenalineUpdateClientUserinfo(vars)
    local aa = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_advadre")

    if aa == "" then
        setAdrenalineMsg(vars["clientNum"], advancedAdrenaline["msgDefault"])
    elseif tonumber(aa) == 0 then
        client[vars["clientNum"]]["adrenalineMsg"] = 0
    else
        client[vars["clientNum"]]["adrenalineMsg"] = 1
    end
end

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function advancedAdrenalineInitGame(vars)
    if etMod == "etpro" then
        local b_levels_medic  = et.trap_Cvar_Get("b_levels_medic")
        local b_defaultskills = et.trap_Cvar_Get("b_defaultskills")

        if (b_levels_medic == "" and b_defaultskills == "") or
          (b_levels_medic ~= "" and string.find(b_levels_medic, "%s+%-1%s*$") ~= nil) or
          (b_defaultskills ~= "" and string.find(b_defaultskills, "^%s*[0-4]%s+[0-4]%s+4") == nil) then
            et.G_LogPrint("Adrenaline is disabled! Please enable it with <b_levels_medic> or <b_defaultskills> cvar.\n")
            return
        end
    elseif etMod == "etlegacy" then
        if string.find(et.trap_Cvar_Get("skill_medic"), "%s+%-1%s*$") == nil then
            et.G_LogPrint("Adrenaline is disabled! Please enable it with <skill_medic> cvar.\n")
            return
        end
    end

    addCallbackFunction({["RunFrame"] = "checkAdvancedAdrenalineRunFrame"})
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkAdvancedAdrenalineRunFrame(vars)
    for i = 0, clientsLimit, 1 do
--             if pause["startTrigger"] then
--                 client[i]["adrenalineDummy"] = 1
--             end
-- 
--             local psPowerups = tonumber(et.gentity_get(i, "ps.powerups", 12))
-- 
--             if client[i]["adrenalineDummy"] == 1 and psPowerups == 0 then
--                 client[i]["adrenalineDummy"] = 0
--             end
-- 
--             if client[i]["adrenalineDummy"] == 0 then
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
    ["InitGame"]              = "advancedAdrenalineInitGame",
    ["ClientBegin"]           = "advancedAdrenalineUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "advancedAdrenalineUpdateClientUserinfo",
})
