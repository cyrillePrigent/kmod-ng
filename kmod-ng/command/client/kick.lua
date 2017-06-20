
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => reason
function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: kick \[partname/id#\] \[time\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if getAdminLevel(params.clientNum) > getAdminLevel(clientNum) then
                local pbClient = clientNum + 1
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_kick " .. pbClient .. " " .. params["arg2"] .. "\n")
            else
                printCmdMsg(params, "Cannot kick a higher admin\n")
            end
        end
    end

    return 1
end
