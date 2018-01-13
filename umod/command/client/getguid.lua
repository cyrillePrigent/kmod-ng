-- Display player guid.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getguid [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            printCmdMsg(
                params,
                color1 .. client[clientNum]["name"] .. color1 ..
                "'s GUID is " .. client[clientNum]["guid"]
            )
        end
    end

    return 1
end
