-- Give admin level to a player.
-- Require : admins module
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client ID
--   * params["arg2"] => level
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 3 then
        printCmdMsg(
            params,
            "Useage: setlevel \[partname/id#\] \[level 0-" .. maxAdminLevel .. "\]\n"
        )
    else
        local clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            local level = tonumber(params["arg2"])

            if level < 0 or level > maxAdminLevel then
                printCmdMsg(
                    params,
                    "Admin level does not exist! \[0-" .. maxAdminLevel .. "\]\n"
                )
            else
                local name = et.Q_CleanStr(client[clientNum]["name"])

                if level == 0 then
                    if removeAdminIfExist(client[clientNum]["guid"]) then
                        printCmdMsg(params, name .. " is now a regular user!\n")
                    else
                        printCmdMsg(params, name .. " is already a regular user!\n")
                    end
                else
                    setAdmin(name, client[clientNum]["guid"], level)

                    if params.cmdMode == "client" then
                        level = "^1" .. level .. "^7"
                    end

                    printCmdMsg(params, name .. " is now a level " .. level .. " user!\n")
                end
            end
        end
    end

    return 1
end
