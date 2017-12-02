-- Display player guid.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getguid \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            printCmdMsg(
                params,
                string.format(
                    "^7%s^7's GUID is %s",
                    client[clientNum]["name"], client[clientNum]["guid"]
                )
            )
        end
    end

    return 1
end
