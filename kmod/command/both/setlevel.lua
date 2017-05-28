

-- params["arg1"] => client ID
-- params["arg2"] => level
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Setlevel", "Useage: setlevel \[partname/id#\] \[level 0-" .. maxAdminLevel .. "\]\n")
        return 1
    end

    local clientNum = client2id(tonumber(params["arg1"]), 'Setlevel', params)

    if clientNum ~= nil
        local level  = tonumber(params["arg2"])

        if level < 0 or level > maxAdminLevel then
            printCmdMsg(params, "Setlevel", "Admin level does not exist! \[0-" .. maxAdminLevel .. "\]\n")

            return 1
        end

        if level == 0 then
            setRegularUser(clientNum)
        else
            setAdmin(clientNum, level)
        end
    end

    return 1
end
