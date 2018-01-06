-- Display revive spree, multi revive & monster revive record
-- from revive spree server record.
-- From rspree lua.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
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
        table.insert(records,
            string.format("%s ^8(^7%d monster revives^8)^7", monsterRevive[2], monsterRevive[1])
        ) 
    end

    if multiRevive[2] ~= nil then
        table.insert(records,
            string.format("%s ^8(^7%d multi revives^8)^7", multiRevive[2], multiRevive[1])
        )
    end

    if revive[2] ~= nil then
        table.insert(records,
            string.format("%s^7 with a total of %d revives", revive[2], revive[1])
        )
    end

    local cmd = params.bangCmd or params.cmd

    et.G_Printf("%s: %d ms\n", cmd, et.trap_Milliseconds() - funcStart)
 
    if table.getn(records) ~= 0 then
        recordMsg = "^7Top revivers since ".. os.date(dateFormat, oldest) ..
                " are " .. table.concat(records, ", ")
    else
        recordMsg = "^7no records found :("
    end

    printCmdMsg(params, recordMsg)

    return 1
end
