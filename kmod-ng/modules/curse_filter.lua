-- Curse filter

-- Global var

badWordList = {}

-- Function

-- Load unauthorized word stored in badwords.list file.
function loadBadWord()
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "badwords.list", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("ERROR: badwords.list file not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No Bad Word Defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)
        local i       = 1

        for word in string.gfind(fileStr, "(%w*)") do
            badWordList[i] = word
            i = i + 1
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Check bad word in client chat entry.
--  clientNum is the client slot id.
--  text is the content of client said.
function checkBadWord(clientNum, text)
    for _, badWord in ipairs(badWordList) do
        for word in string.gfind(text, "([^%s]+)%p*") do
            if word == badWord then
                curseFilter(clientNum)
                break
            end
        end
    end
end

-- Apply sentence of curse mode.
--  clientNum is the client slot id.
function curseFilter(clientNum)
    local name     = et.gentity_get(clientNum, "pers.netname")
    local ref      = tonumber(et.gentity_get(clientNum, "sess.referee"))
    local curseMod = k_cursemode

    if (curseMod - 32) >= 0 then
        -- Override kill and slap
        if (curseMod - 32) > 7 then
            curseMod = 7
        else
            curseMod = curseMod - 32
        end

        if et.gentity_get(clientNum, "pers.connected") == 2 then
            if client[clientNum]["team"] > 0 or client[clientNum]["team"] < 4 then
                params["arg1"] = clientNum
                dofile(kmod_ng_path .. "/command/gib.lua")
                execute_command(params)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto gibbed for language!\n")
            end
        end
    end

    if (curseMod - 16) >= 0 then
        -- Override slap
        if (curseMod - 16) > 7 then
            curseMod = 7
        else
            curseMod = curseMod - 16
        end

        if et.gentity_get(clientNum, "pers.connected") == 2 then
            if client[clientNum]["team"] > 0 or client[clientNum]["team"] < 4 then
                et.gentity_get(clientNum, "health", -1)
                et.trap_SendConsoleCommand( et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto killed for language!\n" )
            end
        end
    end

    if (curseMod - 8) >= 0 then
        curseMod = curseMod - 16

        if et.gentity_get(clientNum, "pers.connected") == 2 then
            if client[clientNum]["team"] > 0 or client[clientNum]["team"] < 4 then
                params["arg1"] = clientNum
                dofile(kmod_ng_path .. "/command/burn.lua")
                execute_command(params)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto slapped for language!\n")
            end
        end
    end

    if (curseMod - 4) >= 0 then
        -- Override kill and slap
        if (curseMod - 4) > 0 then
            curseMod = 0
        end

        if ref == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. clientNum .. "\n")

            if k_mute_module == 1 then
                client[clientNum]["muteEnd"] = -1
                setMute(clientNum, -1)
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been permanently muted for language!\n")
        end
    end

    if (curseMod - 2) >= 0 then
        -- Override kill and slap
        if (curseMod - 2) > 0 then
            curseMod = 0
        end

        --Mute time starts at one then doubles each time thereafter
        if ref == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. clientNum .. "\n" )

            if k_mute_module == 1 then
                if client[clientNum]["muteMultipliers"] == 0 then
                    client[clientNum]["muteMultipliers"] = 1
                    client[clientNum]["muteEnd"]         = time["frame"] + (1 * 60 * 1000)
                else
                    client[clientNum]["muteMultipliers"] = client[clientNum]["muteMultipliers"] + client[clientNum]["muteMultipliers"]
                    client[clientNum]["muteEnd"]         = time["frame"] + (client[clientNum]["muteMultipliers"] * 60 * 1000)
                end

                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted for ^1" .. client[clientNum]["muteMultipliers"] .. "^7 minute(s)!\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted!\n")
            end
        end
    end

    if curseMod == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. clientNum .. "\n" )
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted!\n")
    end
end

-- Add callback curse filter function.
addCallbackFunction({
    ["ReadConfig"] = "loadBadWord"
})
