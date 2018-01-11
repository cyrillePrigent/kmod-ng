-- Birthday
-- From etadmin script.

-- Global var

birthday = {
    -- List of current birthday.
    --  key   => player name
    --  value => player age 
    ["nameList"] = {},
    -- Current birthday announce content.
    ["msg"] = "",
    -- Time (in ms) of last birthday announce check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 300000 -- 5mins
}

-- Set module command.
cmdList["client"]["!setbirthday"]     = "/command/both/setbirthday.lua"
cmdList["client"]["!removebirthday"]  = "/command/both/removebirthday.lua"
cmdList["console"]["!setbirthday"]    = "/command/both/setbirthday.lua"
cmdList["console"]["!removebirthday"] = "/command/both/removebirthday.lua"

-- Function

-- Callback function when ReadConfig is called in et_InitGame function
-- and in the !readconfig client command.
-- Initializes birthday data.
-- Load birthday entry of birthday.cfg file.
function loadBirthday()
    local funcStart = et.trap_Milliseconds()
    local fd, len   = et.trap_FS_FOpenFile("birthday.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: birthday.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No birthday's defined!\n")
    else
        local fileStr    = et.trap_FS_Read(fd, len)
        local month, day = os.date("%m"), os.date("%d")

        for bDay, bMonth, bYear, name
          in string.gfind(fileStr, "(%d+)%-(%d+)%-(%d+)%s%-%s([^%\r%\n]*)") do
            if bDay == day and bMonth == month then
                birthday["nameList"][name] = os.date("%Y") - tonumber(bYear)
            end
        end

        birthday["msg"] = formatBirthdayGlobalMsg()

        if birthday["msg"] ~= "" then
            addCallbackFunction({ ["RunFrame"] = "checkBirthdayRunFrame" })
        end
    end

    et.trap_FS_FCloseFile(fd)
    et.G_LogPrintf("uMod: Loading birthday in %d ms\n", et.trap_Milliseconds() - funcStart)
end

-- Set a birthday entry.
--  name is the player name of birthday entry.
--  bDay is the day of birthday date.
--  bMonth is the month of birthday date.
--  bYear is the year of birthday date.
function setBirthday(name, bDay, bMonth, bYear)
    local fdIn, lenIn = et.trap_FS_FOpenFile("birthday.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("birthday.tmp.cfg", et.FS_WRITE)
    local result

    if lenIn == -1 then
        et.G_LogPrint("WARNING: birthday.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("WARNING: birthday.tmp.cfg file no found / not readable!\n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)
        result = "add"
        local birthdayLine

        for birthdayDate, _name 
          in string.gfind(fileStr, "(%d+%-%d+%-%d+)%s%-%s([^%\r%\n]*)") do
            if _name == name then
                birthday["nameList"][name] = nil

                local year, month, day = os.date("%Y"), os.date("%m"), os.date("%d")

                if bDay == day and bMonth == month then
                    birthday["nameList"][name] = os.date("%Y") - tonumber(bYear)
                end

                result = "edit"
            else
                birthdayLine = birthdayDate .. " - " .. _name .. "\n"
                et.trap_FS_Write(birthdayLine, string.len(birthdayLine), fdOut)
            end
        end

        birthdayLine = string.format(
            "%d-%d-%d - %s",
            bDay, bMonth, bYear, name
        )

        et.trap_FS_Write(birthdayLine, string.len(birthdayLine), fdOut)

        if table.getn(birthday["nameList"]) == 0 then
            removeCallbackFunction("RunFrame", "checkBirthdayRunFrame")
            birthday["msg"] = ""
        else
            birthday["msg"] = formatBirthdayGlobalMsg()
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("birthday.tmp.cfg", "birthday.cfg")
    return result
end

-- Remove a birthday entry.
--  name is the player name of birthday entry.
function removeBirthday(name)
    local fdIn, lenIn = et.trap_FS_FOpenFile("birthday.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("birthday.tmp.cfg", et.FS_WRITE)

    if lenIn == -1 then
        et.G_LogPrint("WARNING: birthday.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("WARNING: birthday.tmp.cfg file no found / not readable!\n")
    elseif lenIn == 0 then
        et.G_Print("There is none birthday to remove\n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)

        for birthdayDate, _name 
          in string.gfind(fileStr, "(%d+%-%d+%-%d+)%s%-%s([^%\r%\n]*)") do
            if _name == name then
                birthday["nameList"][name] = nil
            else
                local birthdayLine = birthdayDate .. " - " .. name .. "\n"
                et.trap_FS_Write(birthdayLine, string.len(birthdayLine), fdOut)
            end
        end

        if table.getn(birthday["nameList"]) == 0 then
            removeCallbackFunction("RunFrame", "checkBirthdayRunFrame")
            birthday["msg"] = ""
        else
            birthday["msg"] = formatBirthdayGlobalMsg()
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("birthday.tmp.cfg", "birthday.cfg")
end

-- Return formated birthday annoucement.
function formatBirthdayGlobalMsg()
    local str = ""
    local nb  = 0

    for name, age in pairs(birthday["nameList"]) do
        if nb > 1 then
            str = "," .. str
        end

        str = str .. name .. " (" .. age .. ")"
    end

    if str ~= "" then
        str = "^3Todays birthdays:^7 " .. str .. ".\n"
    end

    return str
end

-- Callback function when qagame runs a server frame.
-- Every 5mins, display birthday message if needed.
--  vars is the local vars passed from et_RunFrame function.
function checkBirthdayRunFrame(vars)
    if birthday["time"] + birthday["frameCheck"] < vars["levelTime"] then
        et.trap_SendServerCommand(-1, "cpm \"" .. birthday["msg"] .. "\"")
        birthday["time"] = vars["levelTime"]
    end
end

-- Add callback birthday function.
addCallbackFunction({
    ["ReadConfig"] = "loadBirthday"
})
