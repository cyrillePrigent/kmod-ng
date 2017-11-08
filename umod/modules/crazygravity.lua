-- Crazy gravity

-- Global var

crazyGravity = {
    ["active"]          = false,
    ["gravity"]         = 800,
    ["change"]          = false,
    ["intervalChange"]  = tonumber(et.trap_Cvar_Get("u_crazygravityinterval")),
    ["time"]            = 0
}

-- Set module command.
cmdList["client"]["!crazygravity"]  = "/command/both/crazygravity.lua"
cmdList["console"]["!crazygravity"] = "/command/both/crazygravity.lua"

-- Function

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkCrazyGravityRunFrame(vars)
    if crazyGravity["active"] then
        if crazyGravity["change"] then
            crazyGravity["time"]   = vars["levelTime"] + (crazyGravity["intervalChange"] * 1000)
            crazyGravity["change"] = false
        end

        local remainingTime = (crazyGravity["time"] - vars["levelTime"]) / 1000

        if remainingTime == 0 then
            crazyGravity["gravity"] = math.random(10, 1200)
            crazyGravity["change"]  = true
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Crazygravity: ^7The gravity has been changed to ^1" .. crazyGravity["gravity"] .. "^7!\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity " .. crazyGravity["gravity"] .. "\n")
        elseif remainingTime == 5 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Crazygravity: ^7The gravity will be changed in ^15^7 seconds!\n")
        end
    end
end

-- Add callback crazy gravity function.
addCallbackFunction({
    ["RunFrame"] = "checkCrazyGravityRunFrame"
})
