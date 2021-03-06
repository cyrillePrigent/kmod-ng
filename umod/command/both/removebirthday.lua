-- Remove a birthday from database.
-- From etadmin script.
-- Require : birthday module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => name
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removebirthday [name]\n")
    else
        removeBirthday(params["arg1"])
        printCmdMsg(params, "Birthday of " .. params["arg1"] .." removed\n")
    end

    return 1
end
