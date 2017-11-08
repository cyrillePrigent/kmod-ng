
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => client
function execute_command(params)
    local guid = getGuid(params.clientNum)
    local name = playerName(params.clientNum)
    local stats_msg

    if type(reviveSpree["serverRecords"][guid]) ~= "table" then
        stats_msg = "no reviving stats for " .. name .. "^7"
    else
        local done = 0
        local mo_rev = ""
        local mu_rev = ""
        local rev    = ""
        local msg    = name .. "^7 has "

        if reviveSpree["serverRecords"][guid][2] ~= 0 then
            mo_rev = string.format("%d monster revives", reviveSpree["serverRecords"][guid][2])
        end

        if reviveSpree["serverRecords"][guid][1] ~= 0 then
            mu_rev = string.format("%d multi revives", reviveSpree["serverRecords"][guid][1])
        end

        rev = string.format("revived a total of %d players", reviveSpree["serverRecords"][guid][3])
        -- ouch, this is ugly ;>

        if reviveSpree["serverRecords"][guid][2] == 0 and reviveSpree["serverRecords"][guid][1] == 0 then
            msg = msg .. rev
        elseif reviveSpree["serverRecords"][guid][2] ~= 0 and reviveSpree["serverRecords"][guid][1] ~= 0 then
            msg = msg .. "made " .. mo_rev .. ", " .. mu_rev .. " and " ..rev
        else
            if reviveSpree["serverRecords"][guid][2] ~= 0 then
                msg = msg .. "made " .. mo_rev .. " and " .. rev
            else -- reviveSpree["serverRecords"][guid][1] ~= 0
                msg = msg .. "made " .. mu_rev .. " and " .. rev
            end
        end
        
        stats_msg = msg .. " since " .. os.date(date_fmt, reviveSpree["serverRecords"][guid][5])
--        return(string.format("%s^7 has made %d monster revives, "
--                           .."%d multi revives and revived a total of %d "
--                           .."players since %s",
--                            name, reviveSpree["serverRecords"][guid][2], reviveSpree["serverRecords"][guid][1], 
--                            reviveSpree["serverRecords"][guid][3],
--                            os.date(date_fmt, reviveSpree["serverRecords"][guid][5])))
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay \"^3stats: ^7" .. stats_msg .. "^7\"\n")
end