-- Test a player admin level and display result.
-- Require : admins module
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: finger \[partname/id#\]\n")
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            local level = getAdminLevel(clientNum)

            if level > 0 then
                printCmdMsg(
                    params,
                    client[clientNum]["name"] .. " ^7is an admin \[lvl " .. level .. "\]\n"
                )
            else
                printCmdMsg(
                    params,
                    client[clientNum]["name"] .. " ^7is a guest \[lvl 0\]\n"
                )
            end
        end
    end

    return 1
end
