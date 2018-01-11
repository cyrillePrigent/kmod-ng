-- Multikill
-- From kmod script.

-- Global var

multikill = {
    -- Multikill list.
    --  key   => multikill amount
    --  value => list of multikill data (message & sound)
    ["list"] = {},
    -- Interval time between 2 kills to make a multikill.
    ["maxElapsedTime"] = tonumber(et.trap_Cvar_Get("u_mk_time")) * 1000,
    -- Multikill sound status.
    ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_mk_enable_sound")),
    -- Multikill message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_mk_msg_position"),
    -- Noise reduction of multikill sound.
    ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_mk_noise_reduction"))
}

-- Set default client data.
--
-- Multikill value.
clientDefaultData["multikill"] = 0
-- Time of last kill.
clientDefaultData["lastKillTime"] = 0
-- Print multikill status.
clientDefaultData["multikillMsg"] = 0

-- Set killing spree module message.
table.insert(slashCommandModuleMsg, {
    -- Name of killing spree module message key in client data.
    ["clientDataKey"] = "multikillMsg",
    -- Name of killing spree module message key in userinfo data.
    ["userinfoKey"] = "u_mkill",
    -- Name of killing spree module message slash command.
    ["slashCommand"] = "mkill",
    -- Print killing spree messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_mk_msg_default"))
})

-- Function

-- Called when qagame initializes.
-- Prepare multikill list.
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
-- If player kill a enemy, increment his multikill counter.
-- Check elapsed time with last kill of killer and display his multikill message and
-- play multikill sound. If not, reset his multikill data.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryEnemyKill(vars)
    client[vars["killer"]]["multikill"] = client[vars["killer"]]["multikill"] + 1

    local mk = client[vars["killer"]]["multikill"]
    
    if mk == 1 then
        client[vars["killer"]]["lastKillTime"] = time["frame"]
    elseif multikill["list"][mk] then
        if time["frame"] - client[vars["killer"]]["lastKillTime"] <= multikill["maxElapsedTime"] then
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
-- If killer is killed by the world, reset his multikill data.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryWorldKill(vars)
    client[vars["victim"]]["multikill"]    = 0
    client[vars["victim"]]["lastKillTime"] = 0
end

-- Callback function when victim is killed by mate (team kill).
-- If killer is team killed, reset multikill data of killer and victim.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituaryTeamKill(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
    client[vars["victim"]]["multikill"]    = 0
    client[vars["victim"]]["lastKillTime"] = 0
end

-- Callback function when victim is killed himself (self kill).
-- If killer make selfkill, reset his multikill data.
--  vars is the local vars of et_Obituary function.
function checkMultikillObituarySelfKill(vars)
    client[vars["killer"]]["multikill"]    = 0
    client[vars["killer"]]["lastKillTime"] = 0
end

-- Add callback multikill function.
addCallbackFunction({
    ["InitGame"]          = "multikillInitGame",
    ["ObituaryEnemyKill"] = "checkMultikillObituaryEnemyKill",
    ["ObituaryWorldKill"] = "checkMultikillObituaryWorldKill",
    ["ObituaryTeamKill"]  = "checkMultikillObituaryTeamKill",
    ["ObituarySelfKill"]  = "checkMultikillObituarySelfKill"
    
})
