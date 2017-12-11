-- Display connected admins list in player console.
-- Require : admins module
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.displayInConsole = true

    if getAdminLevel(params.clientNum) >= 2 then
        printCmdMsg(
            params,
            "^3 ID ^1:^3 Player                   ^1: ^3 Level ^1 : ^3 AdminName\n"
        )

        printCmdMsg(
            params,
            "^1----------------------------------------------------------------\n"
        )

        local pteam      = { "^1X" , "^4L" , " " }
        local adminCount = 0

        for i = 0, clientsLimit, 1 do
            local level = getAdminLevel(i)

            if level >= 1 then
                if et.gentity_get(i, "pers.connected") == 2 then
                    local name = et.Q_CleanStr(client[i]["name"])

                    printCmdMsg(
                        params,
                        string.format(
                            "%s^7%2s ^1:^7 %s%s ^1:  %5s  ^1:^7  ^7%s\n",
                            pteam[client[i]['team']],
                            i,
                            name,
                            string.rep(" ", 24 - tonumber(string.len(name))),
                            level,
                            admin['name'][string.upper(client[i]["guid"])]
                        )
                    )

                    adminCount = adminCount + 1
                end
            end
        end

        printCmdMsg(
            params,
            "\n^3 " .. adminCount .. " ^7total admins\n"
        )

        return 1
    end

    return 0
end
