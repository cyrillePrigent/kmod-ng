

-- params["arg1"] => player ID
function execute_command(params)
    et.trap_SendServerCommand(params["arg1"], string.format("print \"^3 ID ^1: ^3Player                     Rate  Snaps\n"))
    et.trap_SendServerCommand(params["arg1"], string.format("print \"^1--------------------------------------------\n"))
    local pteam = { "^1X" , "^4L" , " " }
    local playercount = 0
    local spa = 24

    for i = 0, clientLimit, 1 do
        local teamnumber = tonumber(et.gentity_get(i, "sess.sessionTeam"))
        local cname = et.Info_ValueForKey( et.trap_GetUserinfo(i), "name")
        local rate = et.Info_ValueForKey(et.trap_GetUserinfo(i), "rate")
        local snaps = et.Info_ValueForKey(et.trap_GetUserinfo(i), "snaps")
        local name = string.lower(et.Q_CleanStr(cname))
        local namel = tonumber(string.len(name)) - 1
        local namespa = spa - namel
        local space = string.rep(" ", namespa)
        local ref = tonumber(et.gentity_get(params["arg1"], "sess.referee"))

        if ref == 0 then
            ref = ""
        else
            ref = "^3REF"
        end

        if et.gentity_get(i,"pers.connected") == 2 then
            et.trap_SendServerCommand(params["arg1"], string.format('print "%s^7%2s ^1:^7 %s%s %5s  %5s %s\n"', pteam[teamnumber], i, name, space, rate, snaps, ref))
            playercount = playercount + 1
        end
    end

    et.trap_SendServerCommand(params["arg1"], string.format("print \"\n^3 " .. playercount .. " ^7total players\n"))
    return 1
end
