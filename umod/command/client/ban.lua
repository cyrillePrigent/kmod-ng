-- Ban permanently a player from the server with Punkbuster.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => reason
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 3 then
        printCmdMsg(params, "Useage: ban [partname/id#] [reason]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if tonumber(et.trap_Cvar_Get("sv_punkbuster")) == 1 then
                params["arg2"] = params["arg2"] or ""

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    string.format(
                        "pb_sv_ban %d %s\n",
                        clientNum + 1, params["arg2"]
                    )
                )
                
                params.broadcast2allClients = true
                params.noDisplayCmd         = true

                printCmdMsg(
                    params,
                    client[clientNum]["name"] .. " have been banned\n"
                )
            else
                printCmdMsg(
                    params,
                    "Cannot ban with Punkbuster (Punkbuster is disable).\n"
                )
            end
        end
    end

    return 1
end
