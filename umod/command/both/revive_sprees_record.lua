
-- Display all admins name and level in server console.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    local func_start  = et.trap_Milliseconds()
    local rec_arr     = {}
    local multi_rec   = { 0, nil } 
    local monster_rec = { 0, nil }
    local revive_rec  = { 0, nil }
    local oldest      = 2147483647 -- 2^31 - 1
    local rec_msg

    for guid, arr in pairs(reviveSpree["serverRecords"]) do
        if arr[2] > monster_rec[1] then
            monster_rec = { arr[2], arr[4] }
        end

        if arr[1] > multi_rec[1] then
            multi_rec = { arr[1], arr[4] }
        end

        if arr[3] > revive_rec[1] then
            revive_rec = { arr[3], arr[4] }
        end

        if arr[5] < oldest then
            oldest = arr[5]
        end
    end

    if monster_rec[2] ~= nil then
        table.insert(rec_arr, string.format("%s ^8(^7%d monster revives^8)^7", monster_rec[2], monster_rec[1])) 
    end

    if multi_rec[2] ~= nil then
        table.insert(rec_arr, string.format("%s ^8(^7%d multi revives^8)^7", multi_rec[2], multi_rec[1]))
    end

    if revive_rec[2] ~= nil then
        table.insert(rec_arr, string.format("%s^7 with a total of %d revives", revive_rec[2], revive_rec[1]))
    end

    local cmd = params.bangCmd or params.cmd
    et.G_Printf("%s: %d ms\n", cmd, et.trap_Milliseconds() - func_start)
 
    if table.getn(rec_arr) ~= 0 then
        rec_msg = "^7Top revivers since ".. os.date(date_fmt, oldest) .. " are " .. table.concat(rec_arr, ", ")
    else
        rec_msg = "^7no records found :("
    end

    printCmdMsg(params, rec_msg)

    return 1
end