-- Display current spree record.
-- From kmod script.
-- Require : spree module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = "chat"

    printCmdMsg(params, spree["msg"]["oldLong"])
    printCmdMsg(params, mapSpree["msg"]["oldLong"])

    return 0
end
