

-- params["arg1"] => player ID
function execute_command(params)
    if getAdminLevel(params.clientNum) >= 2 then
        et.trap_SendServerCommand(params.clientNum, string.format("print \"^3 ID ^1:^3 Player                   ^1: ^3 Level ^1 : ^3 AdminName\n"))
        et.trap_SendServerCommand(params.clientNum, string.format("print \"^1----------------------------------------------------------------\n"))
        local pteam = { "^1X" , "^4L" , " " }
        local playercount = 0
        local spa = 23
        local adname = ""

        for i = 0, clientsLimit, 1 do
            guis = et.Info_ValueForKey(et.trap_GetUserinfo(i), "cl_guid")
            GUID = string.upper(guis)
            local cname = et.Info_ValueForKey(et.trap_GetUserinfo(i), "name")
            local nudge = et.Info_ValueForKey(et.trap_GetUserinfo(i), "cl_timenudge")
            local pitch = et.Info_ValueForKey(et.trap_GetUserinfo(i), "m_pitch")
            local name = string.lower(et.Q_CleanStr(cname))
            local namel = tonumber(string.len(name)) - 1
            local namespa = spa - namel
            local space = string.rep(" ", namespa)
            local fps = et.Info_ValueForKey(et.trap_GetUserinfo(i), "com_maxfps")
            local sens = et.Info_ValueForKey(et.trap_GetUserinfo(i), "sensitivity")
            local fov = et.Info_ValueForKey(et.trap_GetUserinfo(i), "cg_fov")
            local pmove = et.Info_ValueForKey(et.trap_GetUserinfo(i), "pmove_fixed")
            local level = getAdminLevel(i)
            local adname = admin['name'][GUID]

            if getAdminLevel(i) >= 1 then
                if et.gentity_get(i, "pers.connected") == 2 then
                    et.trap_SendServerCommand(params.clientNum, string.format('print "%s^7%2s ^1:^7 %s%s ^1:  %5s  ^1:^7  ^7%s\n"', pteam[client[i]['team']], i, name, space, level, adname))
                    playercount = playercount + 1
                end

            end
        end

        et.trap_SendServerCommand(params.clientNum, string.format("print \"\n^3 " .. playercount .. " ^7total admins\n"))
        return 1
    end

    return 0
end
