-- Display revive spree, multi revive & monster revive record
-- from current map revive spree record & revive spree player stats.
-- From rspree lua.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]

    local mapMsg = ""
    local mapMax = findMaxReviveSpree()

    if table.getn(mapMax) ~= 3 then
        mapMax = { 0, 0, nil }
    end

    if mapMax[3] ~= nil then
        mapMsg = string.format(
            "^1map: ^7%s^1: ^7%s^1 (^7%d^1) @ %s",
            mapName, mapMax[3], mapMax[1], os.date(dateFormat, mapMax[2])
        )
    else
        mapMsg = string.format(
            "^1map: ^7%s^1: ^7no record", mapName
        )
    end

    local allMsg = ""
    local allMax = { 0, 0, nil }

    for map, arr in pairs(reviveSpree["stats"]) do
        if arr[1] > allMax[1] then
            allMax = arr
        end
    end

    if allMax[3] ~= nil then
        allMsg = string.format(
            " ^1[^7overall: %s^1 (^7%d^1) @ %s^1]",
            allMax[3], allMax[1], os.date(dateFormat, allMax[2])
        )
    end

    printCmdMsg(params, mapMsg .. allMsg)

    return 0
end
