
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => reason
function execute_command(params)
    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: ban \[partname/id#\] \[reason\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            local pbClient = clientNum + 1
            et.trap_SendConsoleCommand( et.EXEC_APPEND, "pb_sv_ban " .. pbClient .. " " .. params["arg2"] .. "\n" )
        end
    end

    return 1
end
