-- Remove the referee's rights from the player.
-- From kmod lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]

    if params.nbArg < 2 then
        printCmdMsg(params, "Useage: removereferee \[partname/id#\]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            if tonumber(et.gentity_get(clientNum, "sess.referee")) == 0 then
                printCmdMsg(
                    params,
                    string.format(
                        "^7%s ^7is not referee.\n",
                        client[clientNum]["name"]
                    )
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
