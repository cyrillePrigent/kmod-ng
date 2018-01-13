-- Display player ip address.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getip [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            printCmdMsg(
                params,
                color1 .. client[clientNum]["name"] .. color1 .. "'s IP is " ..
                et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip")
            )
        end
    end

    return 1
end
