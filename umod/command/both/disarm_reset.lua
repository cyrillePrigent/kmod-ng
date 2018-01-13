-- Rearm all disarmed players.
-- From gw_ref script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    params.say = "chat"
    local count = 0

    for p = 0, clientsLimit, 1 do
        if client[p]["disarm"] == 1 then
            client[p]["disarm"] = 0
            count = count + 1
        end
    end

    printCmdMsg(params, color4 ..  count .. color1 .. " players rearmed\n")
    disarm["count"] = 0
    removeCallbackFunction("RunFrame", "checkDisarmRunFrame")

    return 1
end
