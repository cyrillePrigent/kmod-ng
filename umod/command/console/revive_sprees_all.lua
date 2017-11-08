-- Display all admins name and level in server console.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    et.G_Printf("^7Alltime reviving sprees:\n")

    for map, arr in pairs(reviveSpree["stats"]) do
        et.G_Printf("rspreesall: %s: %s^7 with %d revives @%s\n", map, arr[3], arr[1], os.date(date_fmt, arr[2]))
    end

    et.G_Printf("^7Alltime reviving sprees END\n")

    return 1
end