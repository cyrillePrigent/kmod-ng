-- Display revive spree, multi revive & monster revive record
-- from revive spree server record.
-- From rspree script.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    params.say = "chat"

    local funcStart     = et.trap_Milliseconds()
    local records       = {}
    local revive        = { 0, nil }
    local multiRevive   = { 0, nil } 
    local monsterRevive = { 0, nil }
    local oldest        = 2147483647 -- 2^31 - 1 FIXME : WHAT !
    local recordMsg

    for guid, arr in pairs(reviveSpree["serverRecords"]) do
        if arr[2] > monsterRevive[1] then
            monsterRevive = { arr[2], arr[4] }
        end

        if arr[1] > multiRevive[1] then
            multiRevive = { arr[1], arr[4] }
        end

        if arr[3] > revive[1] then
            revive = { arr[3], arr[4] }
        end

        if arr[5] < oldest then
            oldest = arr[5]
        end
    end

    if monsterRevive[2] ~= nil then
        table.insert(
            records,
            monsterRevive[2] .. color3 .. " (" .. color1 .. monsterRevive[1] ..
            " monster revives" .. color3 .. ")" .. color1
        )
    end

    if multiRevive[2] ~= nil then
        table.insert(
            records,
            multiRevive[2] .. color3 .. " (" .. color1 .. multiRevive[1] ..
            " multi revives" .. color3 .. ")" .. color1
        )
    end

    if revive[2] ~= nil then
        table.insert(
            records,
            revive[2] .. color1 .. " with a total of " .. revive[1] .. " revives"
        )
    end

    local cmd = params.bangCmd or params.cmd

    et.G_Printf("%s: %d ms\n", cmd, et.trap_Milliseconds() - funcStart)
 
    if table.getn(records) ~= 0 then
        recordMsg = color1 .. "Top revivers since " .. os.date(dateFormat, oldest) ..
                " are " .. table.concat(records, ", ")
    else
        recordMsg = color1 .. "no records found :("
    end

    printCmdMsg(params, recordMsg)

    return 1
end
