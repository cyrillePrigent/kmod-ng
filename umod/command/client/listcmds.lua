-- Display available commands list.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    for i = 0, maxAdminLevel, 1 do
        if getAdminLevel(params.clientNum) >= i then
            local listCmds = {}
            
            for cmd, lvl in pairs(commands["level"]) do
                if lvl == i then
                    table.insert(listCmds, cmd)
                end
            end

            if table.getn(listCmds) > 0 then
                et.trap_SendServerCommand(
                    params.clientNum,
                    "print \"Level " .. i .. " Commands\n"
                )

                et.trap_SendServerCommand(
                    params.clientNum,
                    "print \"^1-------------------------------------------------------------------\n"
                )

                for q = 1, table.getn(listCmds), 3 do
                    local cmd1 = " "
                    local cmd3 = " "
                    local cmd3 = " "
                    
                    if listCmds[q] ~= nil then
                        cmd1 = listCmds[q]
                    end

                    local m = q + 1

                    if listCmds[m] ~= nil then
                        cmd2 = listCmds[m]
                    end

                    local e = q + 2

                    if listCmds[e] ~= nil then
                        cmd3 = listCmds[e]
                    end

                    et.trap_SendServerCommand(
                        params.clientNum,
                        string.format(
                            'print \"%21s^1|^7 %21s^1|^7 %21s^1|^7\n"',
                            cmd1, cmd2, cmd3
                        )
                    )
                end

                et.trap_SendServerCommand(
                    params.clientNum,
                    "print \"^1-------------------------------------------------------------------\n\n"
                )
            end
        end
    end

    return 1
end
