-- Display player current spree.
-- Require : killing spree module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]

    printCmdMsg(
        params,
        "Your current spree : "
            .. client[params.clientNum]["killingSpree"]
            .. " kill(s)\n"
    )

    return 1
end
