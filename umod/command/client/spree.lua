-- Display player current spree.
-- From kmod script.
-- Require : spree module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = "chat"

    printCmdMsg(
        params,
        "Your current spree : "
            .. client[params.clientNum]["killingSpree"]
            .. " kill(s)\n"
    )

    return 1
end
