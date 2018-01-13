-- Sets the time limitation for the map.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => timelimit value
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: timelimit [time]\n")
    else
        local timeLimit = tonumber(params["arg1"])

        if timeLimit then
            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "timelimit " .. timeLimit .. "\n"
            )

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(params, "Timelimit has been changed to " .. timeLimit .. "\n")
        else
            printCmdMsg(params, "Please enter in only numbers\n")
        end
    end

    return 1
end
