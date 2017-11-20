-- Dynamite timer

--------------------------------------------------------------------------
-- dynamite.lua version 1.4 - a server side dynamite timer script
--------------------------------------------------------------------------
--
-- $Date: 2007-02-18 20:00:45 +0100 (Sun, 18 Feb 2007) $
-- $Revision: 93 $




--[[ for 20, 10, 5, 3, 2, 1, NOW use:
local steps = { -- [step] = { next step, diff to next step }
                   [20]   =  { 10,        10 }, 
                   [10]   =  {  5,         5 }, 
                    [5]   =  {  3,         2 }, 
                    [3]   =  {  2,         1 }, 
                    [2]   =  {  1,         1 }, 
                    [1]   =  {  0,         1 },
                    [0]   =  {  0,         0 } -- delete if diff to next == 0
              }
--]]


-- Global var

dynamiteTimer = {
    ["list"]           = {},
    ["svFps"]          = tonumber(et.trap_Cvar_Get("sv_fps"))
    ["firstStep"]      = 0,
    ["steps"]          = {}
    ["announcePlant"]  = tonumber(et.trap_Cvar_Get("u_dt_announce_plant")),
    ["msgDefault"]     = tonumber(et.trap_Cvar_Get("u_dt_msg_default")), -- local cl_default = false
    ["msgPosition"]    = et.trap_Cvar_Get("u_dt_msg_position") -- local announce_pos   = "b 8"
}

local ST_NEXT = 1
local ST_DIFF = 2

local T_TIME     = 1
local T_STEP     = 2
local T_LOCATION = 3

-- Set default client data.
clientDefaultData["dynamiteTimerMsg"] = 0

addSlashCommand("client", "dynatimer", {"function", "dynamiteTimerSlashCommand"})

-- Function

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function dynamiteTimerInitGame(vars)      
    local list = {}

    for i in string.gmatch(et.trap_Cvar_Get("u_dt_time_list"), ",") do
        i = tonumber(i)

        if i ~= nil then
            list[i] = {}
        end
    end

    local lastTime

    for t, _ in ipairs(list) do
        if t == 0 then
            dynamiteTimer["steps"] = { 0, 0 }
        else
            dynamiteTimer["steps"] = { lastTime, t - lastTime }
        end

        lastTime = t
    end
    
    for i, _ in ipairs(dynamiteTimer["steps"]) do
        if i > dynamiteTimer["firstStep"] then
            dynamiteTimer["firstStep"] = i
        end
    end
end

-- Callback function whenever the server or qagame prints a string to the console.
--  vars is the local vars of et_Print function.
function checkDynamiteTimerPrint(vars)
    -- etpro popup: allies planted "the Old City Wall"
    -- etpro popup: axis defused "the Old City Wall"
    if vars["arg"][1] == "etpro" and vars["arg"][1] == "popup:" then
        local team     = vars["arg"][3]
        local action   = vars["arg"][4]
        local location = string.gsub(vars["arg"][5], "^\"(.-)\"$", "%1")

        --local pattern = "^etpro%s+popup:%s+(%w+)%s+(%w+)%s+\"(.+)\""
        --local junk1, junk2, team, action, location = string.find(vars["text"], pattern)

        if team ~= nil and action ~= nil and location ~= nil then
            if action == "planted" then
                if dynamiteTimer["announcePlant"] == 1 then
                    sayClients(
                        dynamiteTimer["msgPosition"], 
                        string.format("Dynamite planted at ^8%s^7", location),
                        "dynamiteTimerMsg"
                    )
                end

                addDynamiteTimer(location)
            end

            if action == "defused" then
                sayClients(
                    dynamiteTimer["msgPosition"], 
                    string.format("Dynamite defused at ^8%s^7", location),
                    "dynamiteTimerMsg"
                )

                removeDynamiteTimer(location)
            end
        end
    end

    if vars["text"] == "Exit: Timelimit hit.\n" or vars["text"] == "Exit: Wolf EndRound.\n" then
        -- stop countdowns on intermission
        dynamiteTimer["list"] = {}
    end
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkDynamiteTimerRunFrame(vars)
    for _, timer in ipairs(dynamiteTimer["list"]) do -- usually this is empty, so nothing is done
        if timer[T_TIME] <= vars["levelTime"] then 
            printDynamiteTimer(timer[T_STEP], timer[T_LOCATION])
            local step = dynamiteTimer["steps"][timer[T_STEP]]

            if step[ST_DIFF] == 0 then
                removeDynamiteTimer(timer[T_LOCATION])
            else
                timer[T_STEP] = step[ST_NEXT]
                timer[T_TIME] = vars["levelTime"] + (step[ST_DIFF] * 1000)
            end
        end
    end
end

-- Function executed when slash command is called in et_ClientCommand function
-- `dynatimer` command here.
--  params is parameters passed to the function executed in command file.
function dynamiteTimerSlashCommand(params)
    if params["arg1"] == "" then
        local status = "^8on^7"

        if client[params.clientNum]["dynamiteTimerMsg"] == 0 then
            status = "^8off^7"
        end

        et.trap_SendServerCommand(params.clientNum, string.format("b 8 \"^#(dynatimer):^7 Messages are %s\"", status))
    elseif tonumber(params["arg1"]) == 0 then
        setDynamiteTimerMsg(params.clientNum, 0)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(dynatimer):^7 Messages are now ^8off^7\"")
    else
        setDynamiteTimerMsg(params.clientNum, 1)
        et.trap_SendServerCommand(params.clientNum, "b 8 \"^#(dynatimer):^7 Messages are now ^8on^7\"")
    end

    return 1
end

function printDynamiteTimer(seconds, location) 
    local when

    if seconds == 0 then
        when = "^8now^7"
    elseif seconds == 1 then
        when = "in ^81^7 second"
    else
        when = string.format("in ^8%d^7 seconds", seconds)
    end

    sayClients(
        dynamiteTimer["msgPosition"], 
        string.format("Dynamite at ^8%s^7 exploding %s", location, when),
        "dynamiteTimerMsg"
    )
end

function addDynamiteTimer(location) 
    -- local diff = (30 - dynamiteTimer["firstStep"]) * 1000
    -- move one server frame earlier
    local diff = ((30 - dynamiteTimer["firstStep"]) * 1000) - math.floor(1000 / dynamiteTimer["svFps"])
    table.insert(dynamiteTimer["list"], { time["frame"] + diff, dynamiteTimer["firstStep"], location })
end

function removeDynamiteTimer(location) 
    for i, timer in ipairs(dynamiteTimer["list"]) do
        -- problem with 2 or more planted dynas at one location
        -- ... remove the one which was planted first
        if timer[T_LOCATION] == location then
            table.remove(dynamiteTimer["list"], i)
            break
        end
    end
end

-- Set client data & client user info if dynamite timer message is enabled or not.
--  clientNum is the client slot id.
--  value is the boolen value if dynamite timer message is enabled or not..
function setDynamiteTimerMsg(clientNum, value) 
    client[clientNum]["dynamiteTimerMsg"] = value
    et.trap_SetUserinfo(clientNum, et.Info_SetValueForKey(et.trap_GetUserinfo(clientNum), "u_dynatimer", value))
end

-- Callback function when a client’s Userinfo string has changed.
--  vars is the local vars of et_ClientUserinfoChanged function.
function dynamiteTimerUpdateClientUserinfo(vars) 
    local timer = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "u_dynatimer")

    if timer == "" then
        setDynamiteTimerMsg(vars["clientNum"], dynamiteTimer["msgDefault"])
    elseif tonumber(timer) == 0 then
        client[vars["clientNum"]]["dynamiteTimerMsg"] = 0
    else
        client[vars["clientNum"]]["dynamiteTimerMsg"] = 1 
    end
end

-- Add callback dynamite timer function.
addCallbackFunction({
    ["InitGame"]              = "dynamiteTimerInitGame",
    ["RunFrame"]              = "checkDynamiteTimerRunFrame",
    ["Print"]                 = "checkDynamiteTimerPrint",
    ["ClientBegin"]           = "dynamiteTimerUpdateClientUserinfo",
    ["ClientUserinfoChanged"] = "dynamiteTimerUpdateClientUserinfo",

})
