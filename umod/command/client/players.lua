
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    et.trap_SendServerCommand(params.clientNum, "print \"^3 ID ^1: ^3Player                     Rate  Snaps\n")
    et.trap_SendServerCommand(params.clientNum, "print \"^1--------------------------------------------\n")
    local pteam = { "^1X" , "^4L" , " " }
    local playercount = 0

    for i = 0, clientsLimit, 1 do
        local userinfo = et.trap_GetUserinfo(i)
        local rate     = et.Info_ValueForKey(userinfo, "rate")
        local snaps    = et.Info_ValueForKey(userinfo, "snaps")
        local name     = string.lower(et.Q_CleanStr(et.Info_ValueForKey(userinfo, "name")))
        local space    = string.rep(" ", 23 - tonumber(string.len(name)))
        local ref      = tonumber(et.gentity_get(params.clientNum, "sess.referee"))

        if ref == 0 then
            ref = ""
        else
            ref = "^3REF"
        end

        if et.gentity_get(i,"pers.connected") == 2 then
            et.trap_SendServerCommand(params.clientNum, string.format('print "%s^7%2s ^1:^7 %s%s %5s  %5s %s\n"', pteam[client[i]['team']], i, name, space, rate, snaps, ref))
            playercount = playercount + 1
        end
    end

    et.trap_SendServerCommand(params.clientNum, "print \"\n^3 " .. playercount .. " ^7total players\n")

    return 1
end
