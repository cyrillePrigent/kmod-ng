
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: finger \[partname/id#\]\n")
    else
        params.clientNum = client2id(params["arg1"], params)

        if params.clientNum ~= nil then
            adminStatus(params)
        end
    end

    return 1
end
