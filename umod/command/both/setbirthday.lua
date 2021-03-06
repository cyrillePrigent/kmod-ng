-- Add a birthday to database.
-- From etadmin script.
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
--   * params["arg1"] => name
--   * params["arg2"] => birthday
function execute_command(params)
    params.say = "chat"

    if params.nbArg < 3 then
        -- TODO : Check for date format
        printCmdMsg(
            params,
            "Useage: setbirthday [name] [birthday]\nBirthday format is dd-mm-yyyy.\n"
        )
    else
        local _, _, d, m, y = string.find(params["arg2"], "(%d+)\-(%d+)\-(%d+)")
        local epoch = os.time{year = y, month = m, day = d}

        if string.format("%02d/%02d/%04d", d, m, y) == os.date('%d/%m/%Y', epoch) then
            local result = setBirthday(params["arg1"], d, m, y)
            
            if result == "add" then
                printCmdMsg(params, "Birthday of " .. params["arg1"] .." added\n")
            elseif result == "edit" then
                printCmdMsg(params, "Birthday of " .. params["arg1"] .." edited\n")
            end
        else
            printCmdMsg(params, "Invalid birthday date.\nFormat is dd-mm-yyyy\n")
        end
    end

    return 1
end
