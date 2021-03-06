-- Enable / disabled crazygravity.
-- From kmod script.
-- Require : crazygravity module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => new crazygravity value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: crazygravity [0-1]\n")
    else
        local cgValue = tonumber(params["arg1"])

        if cgValue == 1 then
            if crazyGravity["active"] == false then
                crazyGravity["active"] = true
                crazyGravity["gravityOrigin"] = tonumber(et.trap_Cvar_Get("g_gravity"))
                crazyGravity["time"] = time["frame"] + crazyGravity["intervalChange"]

                addCallbackFunction({
                    ["RunFrame"]         = "checkCrazyGravityRunFrame",
                    ["RunFrameEndRound"] = "crazyGravityReset"
                })

                params.broadcast2allClients = true
                printCmdMsg(params, "Crazygravity has been enabled\n")
            else
                printCmdMsg(params, "Crazygravity is already active\n")
            end
        elseif cgValue == 0 then
            if crazyGravity["active"] == true then
                crazyGravity["active"] = false

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "g_gravity " .. crazyGravity["gravityOrigin"] .. "\n"
                )

                removeCallbackFunction("RunFrame", "checkCrazyGravityRunFrame")
                removeCallbackFunction("RunFrameEndRound", "crazyGravityReset")

                params.broadcast2allClients = true
                printCmdMsg(params, "Crazygravity has been disabled. Resetting gravity\n")
            else
                printCmdMsg(params, "Crazygravity has already been disabled\n")
            end
        else
            printCmdMsg(params, "Valid values are \[0-1\]\n")
        end
    end

    return 1
end
