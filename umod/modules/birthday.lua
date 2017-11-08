-- Birthday

-- Global var

birthday = {
    ["time"]     = 0,
    ["nameList"] = {},
    ["guidList"] = {},
    ["msg"]      = "",
    ["sound"]    = et.trap_Cvar_Get("k_birthdaysoundfile") -- sound/misc/rank_up.wav
}

-- Set module command.
cmdList["client"]["!addbirthday"]     = "/command/both/addbirthday.lua"
cmdList["client"]["!removebirthday"]  = "/command/both/removebirthday.lua"
cmdList["console"]["!addbirthday"]    = "/command/both/addbirthday.lua"
cmdList["console"]["!removebirthday"] = "/command/both/removebirthday.lua"



-- Function

-- Initializes birthday data.
-- Load birthday entry of birthday.cfg file.
function loadBirthday()
    local fd, len = et.trap_FS_FOpenFile("birthday.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("WARNING: birthday.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No Birthday's Defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)
        local month, day = os.date("%m"), os.date("%d")

        for bDay, bMonth, bYear, name, guid in string.gfind(fileStr, "(%d+)%-(%d+)%-(%d+)%s%-%s(%w+)%s%-%s*([^%\r%\n]*)") do
            if bDay == day and bMonth == month then
                birthday["nameList"][name] = os.date("%Y") - tonumber(bYear)
                birthday["guidList"][guid] = name
            end
        end
    end

    et.trap_FS_FCloseFile(fd)
    formatBirthdayGlobalMsg()

    if birthday["msg"] ~= "" then
        addCallbackFunction({ ["RunFrame"] = "checkBirthdayRunFrame" })
    end
end

-- check if birthday exist
function addBirthday(name, birthdayDate, guid)
    local s, e, bDay, bMonth, bYear = string.find(birthdayDate, "(%d+)%-(%d+)%-(%d+)")

    if s and e then
        local birthdayLine = birthdayDate .. " - " .. name .. " - " .. guid .. "\n"
        local fd, len = et.trap_FS_FOpenFile("birthday.cfg", et.FS_APPEND)

        if len == -1 then
            et.G_LogPrint("WARNING: birthday.cfg file no found / not readable!\n")
        else
            et.trap_FS_Write(birthdayLine, string.len(birthdayLine), fd)
            local year, month, day = os.date("%Y"), os.date("%m"), os.date("%d")

            if bDay == day and bMonth == month then
                birthday["nameList"][name] = os.date("%Y") - tonumber(bYear)
                birthday["guidList"][guid] = name
            end
        end

        et.trap_FS_FCloseFile(fd)
    else
        et.G_Print("Wrong birthday format. Use dd-mm-yyyy !\n")
    end
end

function removeBirthday(name)
    local fdIn, lenIn = et.trap_FS_FOpenFile("birthday.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("birthday.tmp.cfg", et.FS_WRITE)
    local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")

    if lenIn == -1 then
        et.G_LogPrint("WARNING: birthday.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("WARNING: birthday.tmp.cfg file no found / not readable!\n")
    elseif lenIn == 0 then
        et.G_Print("There is birthday to remove\n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)

        for birthdayDate, _name, guid in string.gfind(fileStr, "(%d+%-%d+%-%d+)%s%-%s(%w+)%s%-%s*([^%\r%\n]*)") do
            if _name == name then
                birthday["nameList"][name] = nil
                birthday["guidList"][guid] = nil
            else
                local birthdayLine = birthdayDate .. " - " .. name .. " - " .. guid .. "\n"
                et.trap_FS_Write(birthdayLine, string.len(birthdayLine), fdOut)
            end
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("birthday.tmp.cfg", "birthday.cfg")
end

function formatBirthdayGlobalMsg()
    local str = ""
    local nb  = 0

    for name, age in pairs(birthday["list"]) do
        if nb > 1 then
            str = "," .. str
        end

        str = str .. name .. " (" .. age .. ")"
    end

    birthday["msg"] = "^3Todays birthdays:^7 " .. str .. ".\n"
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkBirthdayRunFrame(vars)
    if birthday["time"] + 300000 < vars["levelTime"] then
        et.trap_SendServerCommand(-1, "cpm \"" .. birthday["msg"] .. "\"")
        birthday["time"] = vars["levelTime"]
    end
end

-- Add callback birthday function.
addCallbackFunction({
    ["RunFrame"] = "checkBirthdayRunFrame"
})
