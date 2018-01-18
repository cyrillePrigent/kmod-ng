-- Display revive spree, multi revive & monster revive record
-- from current map revive spree record & revive spree player stats.
-- From rspree script.
-- Require : revive spree & multi revive module
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    params.say = "chat"

    local mapMsg = ""
    local mapMax = findMaxReviveSpree()

    if table.getn(mapMax) ~= 3 then
        mapMax = { 0, 0, nil }
    end

    if mapMax[3] ~= nil then
        mapMsg = color4 .. "map: " .. color1 .. mapName .. color4 .. ": " ..
                color1 .. mapMax[3] .. color4 .. " (" .. color1 .. mapMax[1] ..
                color4 .. ") @ " .. getFormatedDate(mapMax[2], true)
    else
        mapMsg = color4 .. "map: " .. color1 .. mapName .. color4 .. ": " ..
                color1 .. "no record"
    end

    local allMsg = ""
    local allMax = { 0, 0, nil }

    for map, arr in pairs(reviveSpree["stats"]) do
        if arr[1] > allMax[1] then
            allMax = arr
        end
    end

    if allMax[3] ~= nil then
        allMsg = " " .. color4 .. "[" .. color1 .. "overall: " .. allMax[3] ..
            color4 .. " (" .. color1 .. allMax[1] .. color4 .. ") @ " ..
            getFormatedDate(allMax[2], true) .. color4 .. "]"
    end

    printCmdMsg(params, mapMsg .. allMsg)

    return 0
end
