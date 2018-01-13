-- Sets the speed of player's.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => speed value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: speed [value]\nDefault : 320\n")
    else
        local speed = tonumber(params["arg1"])

        if speed then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_speed " .. speed .. "\n")

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(params, "Game speed has been changed to " .. speed .. "\n")
        else
            printCmdMsg(params, "Please enter in only numbers\n")
        end
    end

    return 1
end
