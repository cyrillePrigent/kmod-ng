-- Display all time reviving spree in server console.
-- From rspree script.
-- Require : revive spree module
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    et.G_Print("---------------------------\n")
    et.G_Print("- All time reviving spree -\n")
    et.G_Print("---------------------------\n")

    for map, reviveStats in pairs(reviveSpree["stats"]) do
        et.G_Printf(
            "%s: %s with %d revive @ %s\n",
            map,
            et.Q_CleanStr(reviveStats[3]),
            reviveStats[1],
            os.date(dateFormat, reviveStats[2])
        )
    end

    return 1
end
