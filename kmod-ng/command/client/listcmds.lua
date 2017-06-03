

function execute_command(params)
    for i = 0, maxAdminLevel, 1 do
        if getAdminLevel(params.clientNum) >= i then
            et.trap_SendServerCommand(params.clientNum, string.format("print \"Level " .. i .. " Commands\n"))
            et.trap_SendServerCommand(params.clientNum, string.format("print \"^1-------------------------------------------------------------------\n"))

            for q = 1, tonumber(commands['listCount'][i]), 3 do
                if commands['list'][i][q] == nil then
                    local cmd1 = " "
                else
                    local cmd1 = commands['list'][i][q]
                end

                local m = q + 1

                if commands['list'][i][m] == nil then
                    local cmd2 = " "
                else
                    local cmd2 = commands['list'][i][m]
                end

                local e = q + 2

                if commands['list'][i][e] == nil then
                    local cmd3 = " "
                else
                    local cmd3 = commands['list'][i][e]
                end

                et.trap_SendServerCommand(params.clientNum, string.format('print \"%21s^1|^7 %21s^1|^7 %21s^1|^7\n"', cmd1, cmd2, cmd3))
            end

            et.trap_SendServerCommand(params.clientNum, string.format("print \"^1-------------------------------------------------------------------\n\n"))
        end
    end

    return 1
end
