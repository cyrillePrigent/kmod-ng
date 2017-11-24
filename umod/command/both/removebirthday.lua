
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => name
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removebirthday \[name\]\n")
    else
        removeBirthday(params["arg1"])
    end

    return 1
end
