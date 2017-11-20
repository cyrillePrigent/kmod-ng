-- Killing spree

-- Global var

killingSpree = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_ks_enable_sound")),
    ["amount1"]      = tonumber(et.trap_Cvar_Get("u_ks_amount1")),
    ["amount2"]      = tonumber(et.trap_Cvar_Get("u_ks_amount2")),
    ["amount3"]      = tonumber(et.trap_Cvar_Get("u_ks_amount3")),
    ["amount4"]      = tonumber(et.trap_Cvar_Get("u_ks_amount4")),
    ["amount5"]      = tonumber(et.trap_Cvar_Get("u_ks_amount5")),
    ["amount6"]      = tonumber(et.trap_Cvar_Get("u_ks_amount6")),
    ["sound1"]       = et.trap_Cvar_Get("u_ks_sound1"),
    ["sound2"]       = et.trap_Cvar_Get("u_ks_sound2"),
    ["sound3"]       = et.trap_Cvar_Get("u_ks_sound3"),
    ["sound4"]       = et.trap_Cvar_Get("u_ks_sound4"),
    ["sound5"]       = et.trap_Cvar_Get("u_ks_sound5"),
    ["sound6"]       = et.trap_Cvar_Get("u_ks_sound6"),
    ["message1"]     = et.trap_Cvar_Get("u_ks_message1"),
    ["message2"]     = et.trap_Cvar_Get("u_ks_message2"),
    ["message3"]     = et.trap_Cvar_Get("u_ks_message3"),
    ["message4"]     = et.trap_Cvar_Get("u_ks_message4"),
    ["message5"]     = et.trap_Cvar_Get("u_ks_message5"),
    ["message6"]     = et.trap_Cvar_Get("u_ks_message6"),
    ["endMessage1"]  = et.trap_Cvar_Get("u_ks_end_message1"),
    ["endMessage2"]  = et.trap_Cvar_Get("u_ks_end_message2"),
    ["endMessage3"]  = et.trap_Cvar_Get("u_ks_end_message3"),
    ["endMessage4"]  = et.trap_Cvar_Get("u_ks_end_message4"),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_ks_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_ks_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_ks_noise_reduction"))
}

-- Set default client data.
clientDefaultData["killingSpree"]    = 0
clientDefaultData["killingSpreeMsg"] = 0

addSlashCommand("client", "kspree", {"function", "killingSpreeSlashCommand"})

-- Function

-- Set client data & client user info if killing spree message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if killing spree message & sound is enabled or not..
function setKillingSpreeMsg(clientNum, value)
    client[clientNum]["killingSpreeMsg"] = value
    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_kspree", value))
end

-- Function executed when slash command is called in et_ClientCommand function
-- `kspree` command here.
--  params is parameters passed to the function executed in command file.
function killingSpreeSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["killingSpreeMsg"] == 0 then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(kspree):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setKillingSpreeMsg(params.clientNum, 0)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(kspree):^7 Messages are now ^8off^7\"")
    else
        setKillingSpreeMsg(params.clientNum, 1)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(kspree):^7 Messages are now ^8on^7\"")
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function killingSpreeUpdateClientUserinfo(vars)
    local ks = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_kspree")

    if ks == "" then
        setKillingSpreeMsg(vars["clientNum"], killingSpree["msgDefault"])
    elseif tonumber(ks) == 0 then
        client[vars["clientNum"]]["killingSpreeMsg"] = 0
    else
        client[vars["clientNum"]]["killingSpreeMsg"] = 1
    end
end

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkKillingSpreeRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        for i = 0, clientsLimit, 1 do
            if client[i]["killingSpree"] >= 5 then
                sayClients(
                    "qsay",
                    "^7" .. client[i]["name"] .. "^1's Killing spree was ended! Due to Map's end.\n",
                    "killingSpreeMsg"
                )
            end

            client[i]["killingSpree"] = 0
        end
    end
end

-- Display killing spree message and play killing spree sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  sndFile is the death spree sound to play.
function killingSpreeProcess(vars, msg, sndFile)
    msg = string.gsub(msg, "#killer#", vars["killerName"])
    msg = string.gsub(msg, "#kills#", client[vars["killer"]]["killingSpree"])
    sayClients(killingSpree["msgPosition"], msg, "killingSpreeMsg")

    if killingSpree["enabledSound"] == 1 then
        if killingSpree["noiseReduction"] == 1 then
            playSound(sndFile, "killingSpreeMsg", vars["killer"])
        else
            playSound(sndFile, "killingSpreeMsg")
        end
    end
end

-- Display killing spree end message.
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  killsClientNum is the player slot id of client `killingSpree` data.
--  ksResetClientNum is the player slot id of client `killingSpree` data reset.
function killingSpreeEndProcess(vars, msg, killsClientNum, ksResetClientNum)
    msg = string.gsub(msg, "#victim#", vars["victimName"])
    msg = string.gsub(msg, "#kills#", client[killsClientNum]["killingSpree"])
    msg = string.gsub(msg, "#killer#", vars["killerName"])
    sayClients(killingSpree["msgPosition"], msg, "killingSpreeMsg")
    client[ksResetClientNum]["killingSpree"] = 0
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryEnemyKill(vars)
    client[vars["killer"]]["killingSpree"] = client[vars["killer"]]["killingSpree"] + 1

    if client[vars["killer"]]["killingSpree"] == killingSpree["amount1"] then
        killingSpreeProcess(vars, killingSpree["message1"], killingSpree["sound1"])
    elseif client[vars["killer"]]["killingSpree"] == killingSpree["amount2"] then
        killingSpreeProcess(vars, killingSpree["message2"], killingSpree["sound2"])
    elseif client[vars["killer"]]["killingSpree"] == killingSpree["amount3"] then
        killingSpreeProcess(vars, killingSpree["message3"], killingSpree["sound3"])
    elseif client[vars["killer"]]["killingSpree"] == killingSpree["amount4"] then
        killingSpreeProcess(vars, killingSpree["message4"], killingSpree["sound4"])
    elseif client[vars["killer"]]["killingSpree"] == killingSpree["amount5"] then
        killingSpreeProcess(vars, killingSpree["message5"], killingSpree["sound5"])
    elseif client[vars["killer"]]["killingSpree"] == killingSpree["amount6"] then
        killingSpreeProcess(vars, killingSpree["message6"], killingSpree["sound6"])
    end

    if client[vars["victim"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage1"], vars["victim"], vars["victim"])
    else
        client[vars["victim"]]["killingSpree"] = 0
    end
end

-- Callback function when world kill a player.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryWorldKill(vars)
    if client[vars["victim"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage3"], vars["victim"], vars["victim"])
    else
        client[vars["victim"]]["killingSpree"] = 0
    end
end

-- Callback function when victim is killed by mate (team kill).
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryTeamKill(vars)
    if client[vars["killer"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage4"], vars["killer"], vars["killer"])
    else
        client[vars["killer"]]["killingSpree"] = 0
    end
end

-- Callback function when victim is killed himself (self kill).
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituarySelfKill(vars)
    if client[vars["killer"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage2"], vars["victim"], vars["killer"])
    else
        client[vars["killer"]]["killingSpree"] = 0
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
--function checkKillingSpreeObituary(vars)
--    if client[vars["victim"]]["killingSpree"] >= 5 then
--        killingSpreeEndProcess(vars, killingSpree["endMessage1"], vars["victim"], vars["victim"])
--    else
--        client[vars["victim"]]["killingSpree"] = 0
--    end
--end

-- Add callback killing spree function.
addCallbackFunction({
    ["ClientBegin"]           = "killingSpreeUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "killingSpreeUpdateClientUserinfo",
    ["RunFrameEndRound"]      = "checkKillingSpreeRunFrameEndRound",
    ["ObituaryEnemyKill"]     = "checkKillingSpreeObituaryEnemyKill",
    ["ObituaryWorldKill"]     = "checkKillingSpreeObituaryWorldKill",
    ["ObituaryTeamKill"]      = "checkKillingSpreeObituaryTeamKill",
    ["ObituarySelfKill"]      = "checkKillingSpreeObituarySelfKill",
    --["Obituary"]              = "checkKillingSpreeObituary"
})
