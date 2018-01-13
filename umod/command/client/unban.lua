-- Unban a player banned with Punkbuster.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => guid
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: unban [guid]\n")
    else
        if tonumber(et.trap_Cvar_Get("sv_punkbuster")) == 1 then
            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "pb_sv_unbanguid " .. params["arg1"] .. "\n"
            )

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "pb_sv_UpdBanFile\n"
            )

            params.broadcast2allClients = true
            params.noDisplayCmd         = true

            printCmdMsg(
                params,
                client[clientNum]["name"] .. " have been unbanned\n"
            )
        else
            printCmdMsg(
                params,
                "Cannot unban with Punkbuster (Punkbuster is disable).\n"
            )
        end
    end

    return 1
end
