-- Multikill

-- Global var

multikill = {
    ["maxElapsedTime"] = tonumber(et.trap_Cvar_Get("u_multikill_time")),
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_mk_sounds")),
    ["message1"]       = et.trap_Cvar_Get("u_mk_message1"),
    ["message2"]       = et.trap_Cvar_Get("u_mk_message2"),
    ["message3"]       = et.trap_Cvar_Get("u_mk_message3"),
    ["message4"]       = et.trap_Cvar_Get("u_mk_message4"),
    ["message5"]       = et.trap_Cvar_Get("u_mk_message5"),
    ["message6"]       = et.trap_Cvar_Get("u_mk_message6"),
    ["message7"]       = et.trap_Cvar_Get("u_mk_message7"),
    ["sound1"]         = et.trap_Cvar_Get("u_multikill1"),
    ["sound2"]         = et.trap_Cvar_Get("u_multikill2"),
    ["sound3"]         = et.trap_Cvar_Get("u_multikill3"),
    ["sound4"]         = et.trap_Cvar_Get("u_multikill4"),
    ["sound5"]         = et.trap_Cvar_Get("u_multikill5"),
    ["sound6"]         = et.trap_Cvar_Get("u_multikill6"),
    ["sound7"]         = et.trap_Cvar_Get("u_multikill7"),
    ["location"]       = getMessageLocation(tonumber(et.trap_Cvar_Get("u_mk_location")))
}

-- Set default client data.
clientDefaultData["multikill"] = 0
clientDefaultData["lastKillTime"] = 0

-- Function

-- Display multikill message and play multikill sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the multikill message to display.
--  sound is the multikill sound to play.
--  reset is if multikill client counter must be reset.
function multikillProcess(vars, msg, sound, reset)
    if (time["frame"] - client[vars["killer"]]["lastKillTime"]) <= (multikill["maxElapsedTime"] * 1000) then
        client[vars["killer"]]["lastKillTime"] = time["frame"]
        local str = string.gsub(msg, "#killer#", vars["killerName"])
        et.trap_SendConsoleCommand(et.EXEC_APPEND, multikill["location"] .. " " .. str .. "\n")

        if multikill["enabledSound"] == 1 then
            if noiseReduction == 1 then
                et.G_ClientSound(vars["killer"], sound)
            else
                et.G_globalSound(sound)
            end
        end

        if reset then
            client[vars["killer"]]["multikill"]    = 0
            client[vars["killer"]]["lastKillTime"] = 0
        end
    else
        client[vars["killer"]]["multikill"]    = 1
        client[vars["killer"]]["lastKillTime"] = time["frame"]
    end
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkMultiKillObituaryEnemyKill(vars)
    client[vars["killer"]]["multikill"] = client[vars["killer"]]["multikill"] + 1

    if client[vars["killer"]]["multikill"] == 1 then
        client[vars["killer"]]["lastKillTime"] = time["frame"]
    elseif client[vars["killer"]]["multikill"] == 2 then
        multikillProcess(vars, multikill["message1"], multikill["sound1"])
    elseif client[vars["killer"]]["multikill"] == 3 then
        multikillProcess(vars, multikill["message2"], multikill["sound2"])
    elseif client[vars["killer"]]["multikill"] == 4 then
        multikillProcess(vars, multikill["message3"], multikill["sound3"])
    elseif client[vars["killer"]]["multikill"] == 5 then
        multikillProcess(vars, multikill["message4"], multikill["sound4"])
    elseif client[vars["killer"]]["multikill"] == 6 then
        multikillProcess(vars, multikill["message5"], multikill["sound5"])
    elseif client[vars["killer"]]["multikill"] == 7 then
        multikillProcess(vars, multikill["message6"], multikill["sound6"])
    elseif client[vars["killer"]]["multikill"] == 8 then
        multikillProcess(vars, multikill["message7"], multikill["sound7"], true)
    end
end

-- Callback function when a player is killed by the world, a team mate or himself.
--  vars is the local vars of et_Obituary function.
function multiKillReset(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
end


-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkMultiKillObituary(vars)
    if vars["killer"] ~= 1022 and client[vars["victim"]]["team"] ~= client[vars["killer"]]["team"] and vars["killer"] ~= vars["victim"] then
        client[vars["killer"]]["multikill"] = client[vars["killer"]]["multikill"] + 1

        if client[vars["killer"]]["multikill"] == 1 then
            client[vars["killer"]]["lastKillTime"] = time["frame"]
        elseif client[vars["killer"]]["multikill"] == 2 then
            multikillProcess(vars, multikill["message1"], multikill["sound1"])
        elseif client[vars["killer"]]["multikill"] == 3 then
            multikillProcess(vars, multikill["message2"], multikill["sound2"])
        elseif client[vars["killer"]]["multikill"] == 4 then
            multikillProcess(vars, multikill["message3"], multikill["sound3"])
        elseif client[vars["killer"]]["multikill"] == 5 then
            multikillProcess(vars, multikill["message4"], multikill["sound4"])
        elseif client[vars["killer"]]["multikill"] == 6 then
            multikillProcess(vars, multikill["message5"], multikill["sound5"])
        elseif client[vars["killer"]]["multikill"] == 7 then
            multikillProcess(vars, multikill["message6"], multikill["sound6"])
        elseif client[vars["killer"]]["multikill"] == 8 then
            multikillProcess(vars, multikill["message7"], multikill["sound7"], true)
        end
    else
        client[vars["killer"]]["multikill"]    = 0
        client[vars["killer"]]["lastKillTime"] = 0
    end
end

-- Add callback multikill function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "checkMultiKillObituaryEnemyKill",
    ["ObituaryTeamKill"]  = "multiKillReset",
    ["ObituarySelfKill"]  = "multiKillReset",
    --["Obituary"] = "checkMultiKillObituary"
})
