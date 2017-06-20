
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: putaxis \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                local name = et.gentity_get(clientNum, "pers.netname")

                if client[clientNum]['team'] ~= 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref putaxis " .. clientNum .. "\n")
                    printCmdMsg(params, name .. " ^7has been putted axis\n")
                else
                    printCmdMsg(params, name .. " ^7is already axis\n")
                end
            else
                printCmdMsg(params, "Cannot put axis a higher admin\n")
            end
        end
    end

    return 1
end
