
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => name
--   * params["arg2"] => birthday
--   * params["arg3"] => guid (optional)
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: addbirthday \[name\] \[birthday\] \[guid\]\nBirthday format is dd-mm-yyyy, guid is optional.\n")
    else
        addBirthday(params["arg1"], params["arg2"], params["arg3"])
    end

    return 1
end
