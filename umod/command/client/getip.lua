-- Display player ip address.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getip \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            printCmdMsg(
                params,
                string.format(
                    "^7%s^7's IP is %s",
                    client[clientNum]["name"],
                    et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip")
                )
            )
        end
    end

    return 1
end
