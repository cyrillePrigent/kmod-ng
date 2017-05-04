

function execute_command(params)
    for i = 0, k_maxAdminLevels, 1 do
        if getAdminLevel(params.clientNum) >= i then
            et.trap_SendServerCommand(params.clientNum, string.format("print \"Level " .. i .. " Commands\n"))
            et.trap_SendServerCommand(params.clientNum, string.format("print \"^1-------------------------------------------------------------------\n"))

            for q = 1, tonumber(lvlsc[i]), 3 do
                local b = q
                local m = q + 1
                local e = q + 2

                if lvls[i][b] == nil then
                    lvls[i][b] = " "
                end

                if lvls[i][m] == nil then
                    lvls[i][m] = " "
                end

                if lvls[i][e] == nil then
                    lvls[i][e] = " "
                end

                et.trap_SendServerCommand(params.clientNum, string.format('print \"%21s^1|^7 %21s^1|^7 %21s^1|^7\n"', lvls[i][b], lvls[i][m], lvls[i][e]))
            end

            et.trap_SendServerCommand(params.clientNum, string.format("print \"^1-------------------------------------------------------------------\n\n"))
        end
    end

    return 1
end
