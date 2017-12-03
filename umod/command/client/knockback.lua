-- Sets the knockback effect after player is shot or pushed.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => knockback value
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: knockback \[value\]\nDefault : 1000\n")
    else
        local knockback = tonumber(params["arg1"])

        if knockback then
            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "g_knockback " .. knockback .. "\n"
            )

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(params, "Knockback has been changed to " .. knockback .. "\n")
        else
            printCmdMsg(params, "Please enter in only numbers\n")
        end
    end

    return 1
end
