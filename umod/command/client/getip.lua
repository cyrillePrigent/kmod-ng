
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getip \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            local ip   = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip")
            et.trap_SendServerCommand(params.clientNum, "b 8 \"^3Getip: " .. client[clientNum]["name"] .. "^7's IP is " .. ip)
        end
    end

    return 1
end
