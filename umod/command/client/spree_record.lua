-- Display current spree record.
-- Require : killing spree module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]

    printCmdMsg(params, spree["msg"]["oldLong"])
    printCmdMsg(params, mapSpree["msg"]["oldLong"])

    return 0
end
