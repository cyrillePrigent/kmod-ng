-- Crazy gravity
-- From kmod script.

-- Global var

crazyGravity = {
    -- Crazy gravity status.
    ["active"] = false,
    -- Original gravity value.
    ["gravityOrigin"] = 800,
    -- Current crazy gravity value.
    ["gravity"] = 800,
    -- Time interval (in ms) before gravity change.
    ["intervalChange"] = tonumber(et.trap_Cvar_Get("u_crazygravity_interval")) * 1000,
    -- Time (in ms) of last crazy gravity check.
    ["time"] = 0
}

-- Set module command.
cmdList["client"]["!crazygravity"]  = "/command/both/crazygravity.lua"
cmdList["console"]["!crazygravity"] = "/command/both/crazygravity.lua"

-- Function

-- Callback function when qagame runs a server frame.
-- Every <u_crazygravity_interval> seconds, change gravity value (random) and
-- display notification. Warn players 5 seconds before gravity will change.
--  vars is the local vars passed from et_RunFrame function.
function checkCrazyGravityRunFrame(vars)
    local remainingTime = crazyGravity["time"] - vars["levelTime"]

    if remainingTime == 0 then
        crazyGravity["gravity"] = math.random(10, 1200)
        crazyGravity["time"]    = vars["levelTime"] + crazyGravity["intervalChange"]

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "qsay " .. color2 .. "Crazygravity: " .. color1 ..
            "The gravity has been changed to " .. color3 ..
            crazyGravity["gravity"] .. color1 .. "!\n"
        )

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "g_gravity " .. crazyGravity["gravity"] .. "\n"
        )
    elseif remainingTime == 5000 then
        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "qsay " .. color2 .. "Crazygravity: " .. color1 ..
            "The gravity will be changed in " .. color3 ..
            "5 " .. color1 .. "seconds!\n"
        )
    end
end

-- Callback function when qagame runs a server frame. (pending end round)
-- Reset crazy gravity when round ended (restore gravity).
--  vars is the local vars passed from et_RunFrame function.
function crazyGravityReset(vars)
    if not game["endRoundTrigger"] then
        crazyGravity["active"] = false

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "g_gravity " .. crazyGravity["gravityOrigin"] .. "\n"
        )

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "qsay " .. color1 .. "Crazygravity has been disabled. Resetting gravity\n"
        )

        removeCallbackFunction("RunFrameEndRound", "checkCrazyGravityReset")
    end
end
