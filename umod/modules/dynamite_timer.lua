-- Dynamite timer

-- From : 

--------------------------------------------------------------------------
-- Vetinari's dynamite.lua version 1.4 - a server side dynamite timer script
--------------------------------------------------------------------------
--
-- $Date: 2007-02-18 20:00:45 +0100 (Sun, 18 Feb 2007) $
-- $Revision: 93 $

-- Global var

dynamiteTimer = {
    -- Effectively frequency of server calculating states.
    ["svFps"] = tonumber(et.trap_Cvar_Get("sv_fps")),
    -- Dynamite plant message status.
    ["announcePlant"] = tonumber(et.trap_Cvar_Get("u_dt_announce_plant")),
    -- Dynamite timer message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_dt_msg_position"),
    -- List of current dynamite.
    ["list"] = {},
    -- First step of dynamite timer.
    ["firstStep"] = 0,
    -- List of dynamite timer steps.
    ["steps"] = {},
    -- Number Of current dynamite planted.
    ["count"] = 0,
    -- Entity list of current dynamite planted.
    ["alreadyKnown"] = {},
    -- Time (in ms) of last existing dynamite check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 250
}

-- Set default client data.
--
-- Print dynamite timer status.
clientDefaultData["dynamiteTimerMsg"] = 0

-- Set dynamite timer module message.
table.insert(slashCommandModuleMsg, {
    -- Name of dynamite timer module message key in client data.
    ["clientDataKey"] = "dynamiteTimerMsg",
    -- Name of dynamite timer module message key in userinfo data.
    ["userinfoKey"] = "u_dynatimer",
    -- Name of dynamite timer module message slash command.
    ["slashCommand"] = "dynatimer",
    -- Print dynamite timer messages by default.
    ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_dt_msg_default"))
})

-- Function

-- Called when qagame initializes.
-- Prepare dynamite timer steps and store first step.
--  vars is the local vars of et_InitGame function.
function dynamiteTimerInitGame(vars)      
    local list = {}

    for i in string.gfind(et.trap_Cvar_Get("u_dt_time_list"), "(%d+)") do
        i = tonumber(i)

        if i ~= nil then
            list[i] = {}
        end

        if i > dynamiteTimer["firstStep"] then
            dynamiteTimer["firstStep"] = i
        end
    end

    local lastTime = 0
    local nextStep, diffStep

    for t = 0, dynamiteTimer["firstStep"], 1 do
        if list[t] then
            if t == 0 then
                nextStep = 0
                diffStep = 0
            else
                nextStep = lastTime
                diffStep = (t - lastTime) * 1000
            end

            dynamiteTimer["steps"][t] = {
                ["next"] = nextStep, -- in second
                ["diff"] = diffStep  -- in millisecond
            }

            lastTime = t
        end
    end
end

-- Callback function whenever the server or qagame prints a string to the console.
-- Check if a dynamite is planted and add his dynamite timer.
-- Display notification if enabled.
-- Check if a dynamite is defused and remove his dynamite timer.
--  vars is the local vars of et_Print function.
function checkDynamiteTimerPrint(vars)
    -- etpro popup: allies planted "the Old City Wall"
    -- etpro popup: axis defused "the Old City Wall"
    if vars["arg"][1] == "etpro" and vars["arg"][2] == "popup:" then
        local team   = vars["arg"][3]
        local action = vars["arg"][4]

        local _, _, location = string.find(
            vars["text"],
            "^etpro%s+popup:%s+%w+%s+%w+%s+\"(.+)\""
        )

        if team ~= nil and action ~= nil and location ~= nil then
            if action == "planted" then
                if dynamiteTimer["announcePlant"] == 1 then
                    sayClients(
                        dynamiteTimer["msgPosition"], 
                        "Dynamite planted at " .. color3 .. location,
                        "dynamiteTimerMsg"
                    )
                end

                local dynamiteEntity

                for e = svMaxClients + 1, 1021, 1 do
                    if et.gentity_get(e, "classname") == "dynamite" then
                        if dynamiteTimer["alreadyKnown"][e] == nil then
                            dynamiteTimer["alreadyKnown"][e] = true
                            dynamiteEntity = e
                            break
                        end
                    end
                end

                addDynamiteTimer(location, dynamiteEntity)

                if dynamiteTimer["count"] == 0 then
                    addCallbackFunction({ ["RunFrame"] = "checkDynamiteTimerRunFrame" })
                end

                dynamiteTimer["count"] = dynamiteTimer["count"] + 1
            end

            if action == "defused" then
                sayClients(
                    dynamiteTimer["msgPosition"], 
                    "Dynamite defused at " .. color3 .. location,
                    "dynamiteTimerMsg"
                )

                local dynamiteEntity

                for e, _ in pairs(dynamiteTimer["alreadyKnown"]) do
                    if et.gentity_get(e, "classname") ~= "dynamite" then
                        dynamiteTimer["alreadyKnown"][e] = nil
                        dynamiteEntity = e
                        break
                    end
                end
                
                removeDynamiteTimer(location, dynamiteEntity)
                dynamiteTimer["count"] = dynamiteTimer["count"] - 1

                if dynamiteTimer["count"] == 0 then
                    removeCallbackFunction("RunFrame", "checkDynamiteTimerRunFrame")
                end
            end
        end
    end
end

-- Callback function when qagame runs a server frame (pending warmup and round).
-- Display step of dynamite timer if needed.
-- Remove dynamite timer after exploding.
--  vars is the local vars passed from et_RunFrame function.
function checkDynamiteTimerRunFrame(vars)
    if vars["levelTime"] - dynamiteTimer["time"] >= dynamiteTimer["frameCheck"] then
        for i, timer in pairs(dynamiteTimer["list"]) do
            if et.gentity_get(timer["entity"], "classname") ~= "dynamite" then
                dynamiteTimer["list"][i]                       = nil
                dynamiteTimer["alreadyKnown"][timer["entity"]] = nil
            end
        end

        dynamiteTimer["time"] = vars["levelTime"]
    end

    -- Usually this is empty, so nothing is done.
    for _, timer in pairs(dynamiteTimer["list"]) do
        if timer["time"] <= vars["levelTime"] then 
            printDynamiteTimer(timer["step"], timer["location"])

            local step = dynamiteTimer["steps"][timer["step"]]

            if step["diff"] == 0 then
                removeDynamiteTimer(timer["location"], timer["entity"])
            else
                timer["step"] = step["next"]
                timer["time"] = vars["levelTime"] + step["diff"]
            end
        end
    end
end

-- Callback function when qagame runs a server frame. (pending end round)
-- Stop countdowns on intermission.
--  vars is the local vars passed from et_RunFrame function.
function dynamiteTimerReset(vars)
    if not game["endRoundTrigger"] then
        dynamiteTimer["list"]         = {}
        dynamiteTimer["alreadyKnown"] = {}

        removeCallbackFunction("RunFrameEndRound", "dynamiteTimerReset")
    end
end

-- Print dynamite timer message.
--  seconds is the remaing time before dynamite explosion.
--  location is the dynamite location.
function printDynamiteTimer(seconds, location) 
    local when

    if seconds == 0 then
        when = color3 .. "now"
    elseif seconds == 1 then
        when = "in " .. color3 .. "1" .. color1 .. " second"
    else
        when = "in " .. color3 .. seconds .. color1 .. " seconds"
    end

    sayClients(
        dynamiteTimer["msgPosition"], 
        "Dynamite at " .. color3 .. location .. color1 .. " exploding " .. when,
        "dynamiteTimerMsg"
    )
end

-- Add a dynamite timer.
--  location is the dynamite location.
--  entity is entity number of the dynamite.
function addDynamiteTimer(location, entity) 
    -- Move one server frame earlier.
    local diff = ((30 - dynamiteTimer["firstStep"]) * 1000)
                    - math.floor(1000 / dynamiteTimer["svFps"])

    table.insert(
        dynamiteTimer["list"],
        {
            ["time"]     = time["frame"] + diff,
            ["step"]     = dynamiteTimer["firstStep"],
            ["location"] = location,
            ["entity"]   = entity
        }
    )
end

-- Remove a dynamite timer.
--  location is the dynamite location.
--  entity is entity number of the dynamite.
function removeDynamiteTimer(location, entity) 
    for i, timer in pairs(dynamiteTimer["list"]) do
        if timer["location"] == location and timer["entity"] == entity then
            dynamiteTimer["list"][i]              = nil
            dynamiteTimer["alreadyKnown"][entity] = nil
            break
        end
    end
end

-- Add callback dynamite timer function.
addCallbackFunction({
    ["InitGame"]         = "dynamiteTimerInitGame",
    ["Print"]            = "checkDynamiteTimerPrint",
    ["RunFrameEndRound"] = "dynamiteTimerReset",
})
