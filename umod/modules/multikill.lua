-- Multikill

-- Global var

multikill = {
    ["list"]           = {},
    ["maxElapsedTime"] = tonumber(et.trap_Cvar_Get("u_mk_time")) * 1000,
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_mk_enable_sound")),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_mk_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_mk_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_mk_noise_reduction"))
}

-- Set default client data.
clientDefaultData["multikill"]    = 0
clientDefaultData["lastKillTime"] = 0
clientDefaultData["multikillMsg"] = 0

addSlashCommand("client", "mkill", {"function", "multikillSlashCommand"})

-- Function

-- Set client data & client user info if multikill message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if multikill message & sound is enabled or not..
function setMultikillMsg(clientNum, value)
    client[clientNum]["multikillMsg"] = value

    et.trap_SetUserinfo(
        clientNum,
        et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_mkill", value)
    )
end

-- Function executed when slash command is called in et_ClientCommand function
-- `mkill` command here.
--  params is parameters passed to the function executed in command file.
function multikillSlashCommand(params)
    params.say = msgCmd["chatArea"]
    params.cmd = "/" .. params.cmd

    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["multikillMsg"] == 0 then
            status = "^8off^7"
        end

            printCmdMsg(
                params,
                "Messages are " .. color3 .. status
            )
    elseif tonumber(params["arg1"]) == 0 then
        setMultikillMsg(params.clientNum, 0)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "off"
        )
    else
        setMultikillMsg(params.clientNum, 1)

        printCmdMsg(
            params,
            "Messages are now " .. color3 .. "on"
        )
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
        client[vars["clientNum"]]["multikillMsg"] = 0
    else
        client[vars["clientNum"]]["multikillMsg"] = 1
    end
end

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function multikillInitGame(vars)
    local n = 1

    while true do
        local sound = et.trap_Cvar_Get("u_mk_sound" .. n)
        local msg   = et.trap_Cvar_Get("u_mk_message" .. n)

        if sound ~= "" and msg ~= "" then
            multikill["list"][n + 1] = {
                ["sound"]   = sound,
                ["message"] = msg
            }
        else
            break
        end
        
        n = n + 1
    end
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryEnemyKill(vars)
    client[vars["killer"]]["multikill"] = client[vars["killer"]]["multikill"] + 1

    local mk = client[vars["killer"]]["multikill"]
    
    if mk == 1 then
        client[vars["killer"]]["lastKillTime"] = time["frame"]
    elseif multikill["list"][mk] then
        if (time["frame"] - client[vars["killer"]]["lastKillTime"]) <= multikill["maxElapsedTime"] then
            client[vars["killer"]]["lastKillTime"] = time["frame"]

            sayClients(
                multikill["msgPosition"],
                string.gsub(
                    multikill["list"][mk]["message"],
                    "#killer#",
                    vars["killerName"]
                ),
                "multikillMsg"
            )

            if multikill["enabledSound"] == 1 then
                if multikill["noiseReduction"] == 1 then
                    playSound(
                        multikill["list"][mk]["sound"],
                        "multikillMsg",
                        vars["killer"]
                    )
                else
                    playSound(
                        multikill["list"][mk]["sound"],
                        "multikillMsg"
                    )
                end
            end
        else
            client[vars["killer"]]["multikill"]    = 1
            client[vars["killer"]]["lastKillTime"] = time["frame"]
        end
    end
end

-- Callback function when world kill a player.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryWorldKill(vars)
    client[vars["victim"]]["multikill"]    = 0
    client[vars["victim"]]["lastKillTime"] = 0
end

-- Callback function when victim is killed by mate (team kill).
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryTeamKill(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
    client[vars["victim"]]["multikill"]    = 0
    client[vars["victim"]]["lastKillTime"] = 0
end

-- Callback function when victim is killed himself (self kill).
--  vars is the local vars of et_Obituary function.
function checkMultikillObituarySelfKill(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
end

-- Add callback multikill function.
addCallbackFunction({
    ["InitGame"]              = "multikillInitGame",
    ["ClientBegin"]           = "multikillUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "multikillUpdateClientUserinfo",
    ["ObituaryEnemyKill"]     = "checkMultikillObituaryEnemyKill",
    ["ObituaryWorldKill"]     = "checkMultikillObituaryWorldKill",
    ["ObituaryTeamKill"]      = "checkMultikillObituaryTeamKill",
    ["ObituarySelfKill"]      = "checkMultikillObituarySelfKill"
    
})
