
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getguid \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            et.trap_SendServerCommand(params.clientNum, "b 8 \"^3Getguid: " .. client[clientNum]["name"] .. "^7's GUID is " .. client[clientNum]["guid"])
        end
    end

    return 1
end
