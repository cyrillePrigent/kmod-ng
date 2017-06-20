-- Curse filter

-- Global var

badWordList = {}

-- Function

-- Load unauthorized word stored in badwords.list file.
function loadBadWord()
    local fd, len = et.trap_FS_FOpenFile("badwords.list", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("WARNING: badwords.list file no found / not readable!\n")
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
--  params is parameters passed to the function executed in command file.
--  text is the content of client said.
function checkBadWord(params, text)
    for _, badWord in ipairs(badWordList) do
        for word in string.gfind(text, "([^%s]+)%p*") do
            if word == badWord then
                curseFilter(params)
                break
            end
        end
    end
end

-- Apply sentence of curse mode.
--  params is parameters passed to the function executed in command file.
function curseFilter(params)
    local name     = et.gentity_get(params.clientNum, "pers.netname")
    local ref      = tonumber(et.gentity_get(params.clientNum, "sess.referee"))
    local curseMod = k_cursemode

    if (curseMod - 32) >= 0 then
        -- Override kill and slap
        if (curseMod - 32) > 7 then
            curseMod = 7
        else
            curseMod = curseMod - 32
        end

        if et.gentity_get(params.clientNum, "pers.connected") == 2 then
            if client[params.clientNum]["team"] > 0 or client[params.clientNum]["team"] < 4 then
                params.bangCmd = "gib"
                params["arg1"] = params.clientNum
                params.nbArg   = 2
                dofile(kmod_ng_path .. "command/both/gib.lua")
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

        if et.gentity_get(params.clientNum, "pers.connected") == 2 then
            if client[params.clientNum]["team"] > 0 or client[params.clientNum]["team"] < 4 then
                local health = et.gentity_get(params.clientNum, "health")
                et.G_Damage(params.clientNum, params.clientNum, 1022, health - 1, 24, 0)
                et.gentity_set(params.clientNum, "health", -1)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto killed for language!\n")
            end
        end
    end

    if (curseMod - 8) >= 0 then
        curseMod = curseMod - 16

        if et.gentity_get(params.clientNum, "pers.connected") == 2 then
            if client[params.clientNum]["team"] > 0 or client[params.clientNum]["team"] < 4 then
                params.bangCmd = "slap"
                params["arg1"] = params.clientNum
                params.nbArg   = 2
                dofile(kmod_ng_path .. "command/both/slap.lua")
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
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute \"" .. params.clientNum .. "\"\n")

            if k_mute_module == 1 then
                client[params.clientNum]["muteEnd"] = -1
                setMute(params.clientNum, -1)
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
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute \"" .. params.clientNum .. "\"\n" )

            if k_mute_module == 1 then
                if client[params.clientNum]["muteMultipliers"] == 0 then
                    client[params.clientNum]["muteMultipliers"] = 1
                    client[params.clientNum]["muteEnd"]         = time["frame"] + (1 * 60 * 1000)
                else
                    client[params.clientNum]["muteMultipliers"] = client[params.clientNum]["muteMultipliers"] + client[params.clientNum]["muteMultipliers"]
                    client[params.clientNum]["muteEnd"]         = time["frame"] + (client[params.clientNum]["muteMultipliers"] * 60 * 1000)
                end

                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted for ^1" .. client[params.clientNum]["muteMultipliers"] .. "^7 minute(s)!\n")
            else
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted!\n")
            end
        end
    end

    if curseMod == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute \"" .. params.clientNum .. "\"\n" )
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted!\n")
    end
end

-- Add callback curse filter function.
addCallbackFunction({
    ["ReadConfig"] = "loadBadWord"
})
