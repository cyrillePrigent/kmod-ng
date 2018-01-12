-- Reset all player ownage.
--  From gw_ref lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.broadcast2allClients = true
    params.say                  = msgCmd["chatArea"]

    local count = 0

    for p = 0, clientsLimit, 1 do
        if client[p]["own"] == 1 then
            client[p]["own"] = 0
            count = count + 1
        end
    end

    printCmdMsg(params, "^1" .. count .. " ^7players was ownage stopped\n")

    return 1
end
