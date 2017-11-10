
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    local map_msg = ""
    local map_max = findMaxSpree()

    if table.getn(map_max) ~= 3 then
        map_max = { 0, 0, nil }
    end

    if map_max[3] ~= nil then
        map_msg = string.format("^1map: ^7%s^1: ^7%s^1 (^7%d^1) @ %s", mapName, map_max[3], map_max[1], os.date(date_fmt, map_max[2]))
    else
        map_msg = string.format("^1map: ^7%s^1: ^7no record", mapName)
    end

    local all_msg = ""
    local all_max = { 0, 0, nil }

    for map, arr in pairs(reviveSpree["stats"]) do
        if arr[1] > all_max[1] then
            all_max = arr
        end
    end

    if all_max[3] ~= nil then
        all_msg = string.format(" ^1[^7overall: %s^1 (^7%d^1) @ %s^1]", all_max[3], all_max[1], os.date(date_fmt, all_max[2]))
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay \"^1rspree_record: " .. map_msg .. all_msg .. "^7\"\n")
    -- sayClients(reviveSpree["reviveSpreePosition"], msg) 
    -- no! with sayClients() it would be printed b4 the !spree_record :)

    return 0
end
