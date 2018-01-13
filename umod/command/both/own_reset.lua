-- Reset all player ownage.
--  From gw_ref script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.broadcast2allClients = true
    params.say                  = "chat"

    local count = 0

    for p = 0, clientsLimit, 1 do
        if client[p]["own"] == 1 then
            client[p]["own"] = 0
            count = count + 1
        end
    end

    printCmdMsg(
        params,
        color4 ..  count .. color1 .. " players was ownage stopped\n"
    )

    return 1
end
