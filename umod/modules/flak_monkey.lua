-- Flak monkey

-- Global var

flakMonkey = {
    ["enabledSound"]   = tonumber(et.trap_Cvar_Get("u_fm_enable_sound")),
    ["sound"]          = et.trap_Cvar_Get("u_fm_sound"),
    ["message"]        = et.trap_Cvar_Get("u_fm_message"),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_fm_msg_default")),
    ["msgPosition"]    = et.trap_Cvar_Get("u_fm_msg_position"),
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_fm_noise_reduction"))
}

-- Set default client data.
clientDefaultData["flakMonkey"]    = 0
clientDefaultData["flakMonkeyMsg"] = false

addSlashCommand("client", "fmonkey", {"function", "flakMonkeySlashCommand"})

-- Function

-- Set client data & client user info if flak monkey message & sound is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if flak monkey message & sound is enabled or not..
function setFlakMonkeyMsg(clientNum, value)
    client[clientNum]["flakMonkeyMsg"] = value

    if value then
        value = "1"
    else
        value = "0"
    end

    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_fmonkey", value))
end

-- Function executed when slash command is called in et_ClientCommand function
-- `fmonkey` command here.
--  params is parameters passed to the function executed in command file.
function flakMonkeySlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["flakMonkeyMsg"] == false then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(fmonkey):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setFlakMonkeyMsg(params.clientNum, false)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(fmonkey):^7 Messages are now ^8off^7\"")
    else
        setFlakMonkeyMsg(params.clientNum, true)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(fmonkey):^7 Messages are now ^8on^7\"")
    end

    return 1
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function flakMonkeyUpdateClientUserinfo(vars)
    local fm = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_fmonkey")

    if fm == "" then
        setFlakMonkeyMsg(vars["clientNum"], flakMonkey["msgDefault"])
    elseif tonumber(fm) == 0 then
        client[vars["clientNum"]]["flakMonkeyMsg"] = false
    else
        client[vars["clientNum"]]["flakMonkeyMsg"] = true
    end
end

-- Callback function of et_Obituary function.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituary(vars)
    client[vars["victim"]]["flakMonkey"] = 0
end

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituaryEnemyKill(vars)
    if vars["meansOfDeath"] == 17 or vars["meansOfDeath"] == 43 or vars["meansOfDeath"] == 44 then
        client[vars["killer"]]["flakMonkey"] = client[vars["killer"]]["flakMonkey"] + 1

        if client[vars["killer"]]["flakMonkey"] == 3 then
            local str = string.gsub(flakMonkey["message"], "#killer#", vars["killerName"])
            sayClients("flakMonkeyMsg", flakMonkey["msgPosition"], str)

            if flakMonkey["enabledSound"] == 1 then
                if flakMonkey["noiseReduction"] == 1 then
                    playSound(flakMonkey["sound"], "flakMonkeyMsg", vars["killer"])
                else
                    playSound(flakMonkey["sound"], "flakMonkeyMsg")
                end
            end

            client[vars["killer"]]["flakMonkey"] = 0
        end
    else
        client[vars["killer"]]["flakMonkey"] = 0
    end
end

-- Callback function when victim is killed himself (self kill).
--  vars is the local vars of et_Obituary function.
function checkFlakMonkeyObituaryTeamKill(vars)
    client[vars["killer"]]["flakMonkey"] = 0
end

-- Add callback flak monkey function.
addCallbackFunction({
    ["ClientBegin"]           = "flakMonkeyUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "flakMonkeyUpdateClientUserinfo",
    ["Obituary"]              = "checkFlakMonkeyObituary",
    ["ObituaryEnemyKill"]     = "checkFlakMonkeyObituaryEnemyKill",
    ["ObituaryTeamKill"]      = "checkFlakMonkeyObituaryTeamKill",
})
