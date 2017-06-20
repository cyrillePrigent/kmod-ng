
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: getguid \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")
            local name = et.gentity_get(clientNum, "pers.netname")
            et.trap_SendServerCommand(params.clientNum, "b 8 \"^3Getguid: " .. name .. "^7's GUID is " .. guid)
        end
    end

    return 1
end
