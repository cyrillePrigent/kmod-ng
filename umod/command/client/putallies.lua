
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: putallies \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                if client[clientNum]['team'] ~= 2 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref putallies " .. clientNum .. "\n")
                    printCmdMsg(params, client[clientNum]["name"] .. " ^7has been putted allies\n")
                else
                    printCmdMsg(params, client[clientNum]["name"] .. " ^7is already allies\n")
                end
            else
                printCmdMsg(params, "Cannot put allies a higher admin\n")
            end
        end
    end

    return 1
end
