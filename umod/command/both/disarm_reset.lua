-- Rearm all disarmed players.
-- From gw_ref lua script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = msgCmd["chatArea"]
    local count = 0

    for i = 0, clientsLimit, 1 do
        if client[i]["disarm"] == 1 then
            client[i]["disarm"] = 0
            count = count + 1
        end
    end

    printCmdMsg(params, "^1" .. count .. " ^7players rearmed\n")
    disarm["count"] = 0
    removeCallbackFunction("RunFrame", "checkDisarmRunFrame")

    return 1
end
