
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    if getAdminLevel(params.clientNum) >= 2 then
        et.trap_SendServerCommand(params.clientNum, "print \"^3 ID ^1:^3 Player                   ^1: ^3 Level ^1 : ^3 AdminName\n")
        et.trap_SendServerCommand(params.clientNum, "print \"^1----------------------------------------------------------------\n")
        local pteam = { "^1X" , "^4L" , " " }
        local playercount = 0

        for i = 0, clientsLimit, 1 do
            local level = getAdminLevel(i)

            if level >= 1 then
                if et.gentity_get(i, "pers.connected") == 2 then
                    local userinfo = et.trap_GetUserinfo(i)
                    local guid     = et.Info_ValueForKey(userinfo, "cl_guid")
                    local name     = string.lower(et.Q_CleanStr(et.Info_ValueForKey(userinfo, "name")))
                    local space    = string.rep(" ", 22 - tonumber(string.len(name)))
                    local adname   = admin['name'][string.upper(guid)]

                    et.trap_SendServerCommand(params.clientNum, string.format('print "%s^7%2s ^1:^7 %s%s ^1:  %5s  ^1:^7  ^7%s\n"', pteam[client[i]['team']], i, name, space, level, adname))
                    playercount = playercount + 1
                end

            end
        end

        et.trap_SendServerCommand(params.clientNum, "print \"\n^3 " .. playercount .. " ^7total admins\n")

        return 1
    end

    return 0
end
