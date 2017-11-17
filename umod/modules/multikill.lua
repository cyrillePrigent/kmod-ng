-- Multikill

-- Global var

multikill = {
    ["maxElapsedTime"] = tonumber(et.trap_Cvar_Get("u_mk_time")),
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_mk_enable_sound")),
    ["message1"]       = et.trap_Cvar_Get("u_mk_message1"),
    ["message2"]       = et.trap_Cvar_Get("u_mk_message2"),
    ["message3"]       = et.trap_Cvar_Get("u_mk_message3"),
    ["message4"]       = et.trap_Cvar_Get("u_mk_message4"),
    ["message5"]       = et.trap_Cvar_Get("u_mk_message5"),
    ["message6"]       = et.trap_Cvar_Get("u_mk_message6"),
    ["message7"]       = et.trap_Cvar_Get("u_mk_message7"),
    ["sound1"]         = et.trap_Cvar_Get("u_mk_sound1"),
    ["sound2"]         = et.trap_Cvar_Get("u_mk_sound2"),
    ["sound3"]         = et.trap_Cvar_Get("u_mk_sound3"),
    ["sound4"]         = et.trap_Cvar_Get("u_mk_sound4"),
    ["sound5"]         = et.trap_Cvar_Get("u_mk_sound5"),
    ["sound6"]         = et.trap_Cvar_Get("u_mk_sound6"),
    ["sound7"]         = et.trap_Cvar_Get("u_mk_sound7"),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_mk_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_mk_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_mk_noise_reduction"))
}

-- Set default client data.
clientDefaultData["multikill"]    = 0
clientDefaultData["lastKillTime"] = 0
clientDefaultData["multikillMsg"] = false

addSlashCommand("client", "mkill", {"function", "multikillSlashCommand"})

-- Function

-- Set client data & client user info if multikill message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if multikill message & sound is enabled or not..
function setMultikillMsg(clientNum, value)
    client[clientNum]["multikillMsg"] = value

    if value then
        value = "1"
    else
        value = "0"
    end

    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_mkill", value))
end

-- Function executed when slash command is called in et_ClientCommand function
-- `mkill` command here.
--  params is parameters passed to the function executed in command file.
function multikillSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["multikillMsg"] == false then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(mkill):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setMultikillMsg(params.clientNum, false)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(mkill):^7 Messages are now ^8off^7\"")
    else
        setMultikillMsg(params.clientNum, true)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(mkill):^7 Messages are now ^8on^7\"")
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function multikillUpdateClientUserinfo(vars)
    local mk = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_mkill")

    if mk == "" then
        setMultikillMsg(vars["clientNum"], multikill["msgDefault"])
    elseif tonumber(mk) == 0 then
        client[vars["clientNum"]]["multikillMsg"] = false
    else
        client[vars["clientNum"]]["multikillMsg"] = true
    end
end

-- Display multikill message and play multikill sound (if enabled).
--  vars is the local vars of et_Obituary function.
--  msg is the multikill message to display.
--  sndFile is the multikill sound to play.
--  reset is if multikill client counter must be reset.
function multikillProcess(vars, msg, sndFile, reset)
    if (time["frame"] - client[vars["killer"]]["lastKillTime"]) <= (multikill["maxElapsedTime"] * 1000) then
        client[vars["killer"]]["lastKillTime"] = time["frame"]
        sayClients(multikill["msgPosition"], string.gsub(msg, "#killer#", vars["killerName"]), "multikillMsg")

        if multikill["enabledSound"] == 1 then
            if multikill["noiseReduction"] == 1 then
                playSound(sndFile, "multikillMsg", vars["killer"])
            else
                playSound(sndFile, "multikillMsg")
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
function checkMultikillObituaryEnemyKill(vars)
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
function multikillReset(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
end

-- Add callback multikill function.
addCallbackFunction({
    ["ClientBegin"]           = "multikillUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "multikillUpdateClientUserinfo",
    ["ObituaryEnemyKill"]     = "checkMultikillObituaryEnemyKill",
    ["ObituaryTeamKill"]      = "multikillReset",
    ["ObituarySelfKill"]      = "multikillReset",
    ["ObituaryWorldKill"]     = "multikillReset"
})
