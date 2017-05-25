-- Killing spree

-- Global var

killingSpree = {
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("k_spreesounds")),
    ["amount1"]      = tonumber(et.trap_Cvar_Get("k_spree1_amount")),
    ["amount2"]      = tonumber(et.trap_Cvar_Get("k_spree2_amount")),
    ["amount3"]      = tonumber(et.trap_Cvar_Get("k_spree3_amount")),
    ["amount4"]      = tonumber(et.trap_Cvar_Get("k_spree4_amount")),
    ["amount5"]      = tonumber(et.trap_Cvar_Get("k_spree5_amount")),
    ["amount6"]      = tonumber(et.trap_Cvar_Get("k_spree6_amount")),
    ["sound1"]       = et.trap_Cvar_Get("killingspreesound1"),
    ["sound2"]       = et.trap_Cvar_Get("killingspreesound2"),
    ["sound3"]       = et.trap_Cvar_Get("killingspreesound3"),
    ["sound4"]       = et.trap_Cvar_Get("killingspreesound4"),
    ["sound5"]       = et.trap_Cvar_Get("killingspreesound5"),
    ["sound6"]       = et.trap_Cvar_Get("killingspreesound6"),
    ["message1"]     = et.trap_Cvar_Get("k_ks_message1"),
    ["message2"]     = et.trap_Cvar_Get("k_ks_message2"),
    ["message3"]     = et.trap_Cvar_Get("k_ks_message3"),
    ["message4"]     = et.trap_Cvar_Get("k_ks_message4"),
    ["message5"]     = et.trap_Cvar_Get("k_ks_message5"),
    ["message6"]     = et.trap_Cvar_Get("k_ks_message6"),
    ["endMessage1"]  = et.trap_Cvar_Get("k_end_message1"),
    ["endMessage2"]  = et.trap_Cvar_Get("k_end_message2"),
    ["endMessage3"]  = et.trap_Cvar_Get("k_end_message3"),
    ["endMessage4"]  = et.trap_Cvar_Get("k_end_message4"),
    ["location"]     = getMessageLocation(tonumber(et.trap_Cvar_Get("k_ks_location")))
}

-- Set default client data.
clientDefaultData["killingspree"] = 0

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkKillingSpreeRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        for i = 0, clientsLimit, 1 do
            if client[i]["killingspree"] >= 5 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^7" .. client[i]["name"] .. "^1's Killing spree was ended! Due to Map's end.\n")
            end

            client[i]["killingspree"] = 0
        end
    end
end

-- Display killing spree message and play killing spree sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  sound is the death spree sound to play.
function killingSpreeProcess(vars, msg, sound)
    msg = string.gsub(msg, "#killer#", vars["killerName"])
    msg = string.gsub(msg, "#kills#", client[vars["killer"]]["killingspree"])
    et.trap_SendConsoleCommand(et.EXEC_APPEND, killingSpree["location"] .. " " .. msg .. "\n")

    if killingSpree["enabledSound"] == 1 then
        if k_noisereduction == 1 then
            et.G_ClientSound(vars["killer"], sound)
        else
            et.G_globalSound(sound)
        end
    end
end

-- Display killing spree end message.
--  vars is the local vars of et_Obituary function.
--  msg is the death spree message to display.
--  killsClientNum is the player slot id of client `killingspree` data.
--  ksResetClientNum is the player slot id of client `killingspree` data reset.
function killingSpreeEndProcess(vars, msg, killsClientNum, ksResetClientNum)
    msg = string.gsub(msg, "#victim#", vars["victimName"])
    msg = string.gsub(msg, "#kills#", client[killsClientNum]["killingspree"])
    msg = string.gsub(msg, "#killer#", vars["killerName"])
    et.trap_SendConsoleCommand(et.EXEC_APPEND, killingSpree["location"] .. " " .. msg .. "\n")
    client[ksResetClientNum]["killingspree"] = 0
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryEnemyKill(vars)
    client[vars["killer"]]["killingspree"] = client[vars["killer"]]["killingspree"] + 1

    if client[vars["killer"]]["killingspree"] == killingSpree["amount1"] then
        killingSpreeProcess(vars, killingSpree["message1"], killingSpree["sound1"])
    elseif client[vars["killer"]]["killingspree"] == killingSpree["amount2"] then
        killingSpreeProcess(vars, killingSpree["message2"], killingSpree["sound2"])
    elseif client[vars["killer"]]["killingspree"] == killingSpree["amount3"] then
        killingSpreeProcess(vars, killingSpree["message3"], killingSpree["sound3"])
    elseif client[vars["killer"]]["killingspree"] == killingSpree["amount4"] then
        killingSpreeProcess(vars, killingSpree["message4"], killingSpree["sound4"])
    elseif client[vars["killer"]]["killingspree"] == killingSpree["amount5"] then
        killingSpreeProcess(vars, killingSpree["message5"], killingSpree["sound5"])
    elseif client[vars["killer"]]["killingspree"] == killingSpree["amount6"] then
        killingSpreeProcess(vars, killingSpree["message6"], killingSpree["sound6"])
    end
end

-- Callback function when world kill a player.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryWorldKill(vars)
    if client[vars["victim"]]["killingspree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage3"], vars["victim"], vars["victim"])
    else
        client[vars["victim"]]["killingspree"] = 0
    end
end

-- Callback function when victim have team kill or self kill.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryTkAndSelfKill(vars)
    if client[vars["killer"]]["killingspree"] >= 5 then
        if vars["killer"] == vars["victim"] then
            killingSpreeEndProcess(vars, killingSpree["endMessage2"], vars["victim"], vars["killer"])
        else
            killingSpreeEndProcess(vars, killingSpree["endMessage4"], vars["killer"], vars["killer"])
        end
    else
        client[vars["killer"]]["killingspree"] = 0
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituary(vars)
    if client[vars["victim"]]["killingspree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage1"], vars["victim"], vars["victim"])
    else
        client[vars["victim"]]["killingspree"] = 0
    end
end

-- Add callback killing spree function.
addCallbackFunction({
    ["RunFrameEndRound"]      = "checkKillingSpreeRunFrameEndRound",
    ["ObituaryEnemyKill"]     = "checkKillingSpreeObituaryEnemyKill",
    ["ObituaryWorldKill"]     = "checkKillingSpreeObituaryWorldKill",
    ["ObituaryTkAndSelfKill"] = "checkKillingSpreeObituaryTkAndSelfKill",
    ["Obituary"]              = "checkKillingSpreeObituary"
})
