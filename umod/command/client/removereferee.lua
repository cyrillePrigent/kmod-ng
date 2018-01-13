-- Remove the referee's rights from the player.
-- From kmod script.
--  params is parameters passed from et_ClientCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removereferee [partname/id#]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if tonumber(et.gentity_get(clientNum, "sess.referee")) == 0 then
                printCmdMsg(
                    params,
                    color1 .. client[clientNum]["name"] .. color1 ..
                    " is not referee.\n"
                )
            else
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "ref unreferee " .. clientNum .. "\n"
                )
            end
        end
    end

    return 1
end
