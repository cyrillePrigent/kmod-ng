

-- params["arg1"] => client ID
-- params["arg2"] => level
function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params, "Setlevel", "Useage: setlevel \[partname/id#\] \[level 0-" .. maxAdminLevel .. "\]\n")
    else
        local clientNum = client2id(params["arg1"], 'Setlevel', params)

        if clientNum ~= nil then
            local level = tonumber(params["arg2"])

            if level < 0 or level > maxAdminLevel then
                printCmdMsg(params, "Setlevel", "Admin level does not exist! \[0-" .. maxAdminLevel .. "\]\n")
            else
                if level == 0 then
                    setRegularUser(params, clientNum)
                else
                    setAdmin(params, clientNum, level)
                end
            end
        end
    end

    return 1
end
