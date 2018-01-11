-- Killing spree & spree record
-- From kmod script.

-- TODO : Rewrite u_ks_end_message cvar name

-- Global var

if killingSpreeModule == 1 then
    killingSpree = {
        -- Killing spree list.
        --  key   => killing spree amount
        --  value => list of killing spree data (message & sound)
        ["list"] = {},
        -- Killing spree sound status.
        ["enabledSound"] = tonumber(et.trap_Cvar_Get("u_ks_enable_sound")),
        -- Killing spree ended by enemy.
        ["endMessage1"] = et.trap_Cvar_Get("u_ks_end_message1"),
        -- Killing spree ended by selfkill.
        ["endMessage2"] = et.trap_Cvar_Get("u_ks_end_message2"),
        -- Killing spree ended by world.
        ["endMessage3"] = et.trap_Cvar_Get("u_ks_end_message3"),
        -- Killing spree ended by teamkill.
        ["endMessage4"] = et.trap_Cvar_Get("u_ks_end_message4"),
        -- Killing spree message position.
        ["msgPosition"] = et.trap_Cvar_Get("u_ks_msg_position"),
        -- Noise reduction of killing spree sound.
        ["noiseReduction"] = tonumber(et.trap_Cvar_Get("u_ks_noise_reduction"))
    }
    
    -- Set killing spree default client data.
    --
    -- Print killing spree status.
    clientDefaultData["killingSpreeMsg"] = 0

    -- Set killing spree module message.
    table.insert(slashCommandModuleMsg, {
        -- Name of killing spree module message key in client data.
        ["clientDataKey"] = "killingSpreeMsg",
        -- Name of killing spree module message key in userinfo data.
        ["userinfoKey"] = "u_kspree",
        -- Name of killing spree module message slash command.
        ["slashCommand"] = "kspree",
        -- Print killing spree messages by default.
        ["msgDefault"] = tonumber(et.trap_Cvar_Get("u_ks_msg_default"))
    })
    
    -- Function

    -- Called when qagame initializes.
    -- Prepare killing spree list.
    --  vars is the local vars of et_InitGame function.
    function killingSpreeInitGame(vars)
        local n = 1

        while true do
            local amount = tonumber(et.trap_Cvar_Get("u_ks_amount" .. n))
            local sound  = et.trap_Cvar_Get("u_ks_sound" .. n)
            local msg    = et.trap_Cvar_Get("u_ks_message" .. n)

            if amount ~= nil and sound ~= "" and msg ~= "" then
                killingSpree["list"][amount] = {
                    ["sound"]   = sound,
                    ["message"] = msg
                }
            else
                break
            end
            
            n = n + 1
        end
    end

    -- Display killing spree end message.
    --  vars is the local vars of et_Obituary function.
    --  msg is the death spree message to display.
    --  killsClientNum is the player slot id of client `killingSpree` data.
    function killingSpreeEndProcess(vars, msg, killsClientNum)
        msg = string.gsub(msg, "#victim#", vars["victimName"])
        msg = string.gsub(msg, "#kills#", client[killsClientNum]["killingSpree"])
        msg = string.gsub(msg, "#killer#", vars["killerName"])
        sayClients(killingSpree["msgPosition"], msg, "killingSpreeMsg")
    end

    -- Add callback killing spree function.
    addCallbackFunction({
        ["InitGame"] = "killingSpreeInitGame"
    })
end

if spreeRecordModule == 1 then
    spree = {
        -- Current spree record.
        ["killsRecord"] = 0,
        -- Current spree message.
        ["msg"] = {
            ["oldShort"] = "^3[Old: ^7N/A^3]",
            ["oldLong"]  = "^3Spree Record: ^7There is no current spree record",
            ["current"]  = "Current spree record: ^7N/A"
        }
    }

    mapSpree = {
        -- Current map spree record.
        ["killsRecord"] = 0,
        -- Current map spree message.
        ["msg"] = {
            ["oldShort"] = "^3[Old: ^7N/A^3]",
            ["oldLong"]  = "^3Map Spree Record: ^7There is no current spree record",
            ["current"]  = "Current Map spree record: ^7N/A"
        }
    }

    -- Set module command.
    cmdList["client"]["!spree_record"] = "/command/client/spree_record.lua"
    cmdList["client"]["!spree_reset"]  = "/command/both/spree_reset.lua"
    cmdList["console"]["!spree_reset"] = "/command/both/spree_reset.lua"

    -- Function

    -- Write spree record of player.
    --  clientNum is the client slot id.
    --  kills is the kill count of spree record.
    function writeSpreeRecord(clientNum, kills)
        local name = et.Q_CleanStr(client[clientNum]["name"])
        local date = os.date("%x %I:%M:%S%p")

        local fd, len = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_WRITE)

        if len == -1 then
            et.G_LogPrint("uMod ERROR: sprees/spree_record.dat file not writable!\n")
        else
            local spreeRecordLine = kills .. "@" .. date .. "@" .. name
            et.trap_FS_Write(spreeRecordLine, string.len(spreeRecordLine), fd)
        end

        et.trap_FS_FCloseFile(fd)

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "qsay ^1New spree record: ^7" .. name .. " ^7with ^3" .. kills
                .. " ^7kills ^7" .. spree["msg"]["oldShort"] .. "\n"
        )

        setSpreeRecord(name, kills, date)
    end

    -- Set spree record data.
    --  name is the player name.
    --  kills is the kill count of spree record.
    --  date is the current time and date of spree record.
    function setSpreeRecord(name, kills, date)
        spree["killsRecord"]= kills

        spree["msg"]["oldShort"] = "^3[Old: ^7" .. name
            .. " ^3" .. kills .. " ^7@ " .. date .. "^3]"

        spree["msg"]["oldLong"] = "^3Spree Record: ^7" .. name
            .. " ^7with ^3" .. kills .. " ^7kills at " .. date

        spree["msg"]["current"] = "Current spree record: ^7"
            .. name .. " ^7with ^3" .. kills .. " ^7kills at " .. date
    end

    -- Write map spree record of player.
    --  clientNum is the client slot id.
    --  kills is the kill count of map spree record.
    function writeMapSpreeRecord(clientNum, kills)
        local name = et.Q_CleanStr(client[clientNum]["name"])
        local date = os.date("%x %I:%M:%S%p")

        local fd, len = et.trap_FS_FOpenFile("sprees/" .. mapName .. ".record", et.FS_WRITE)

        if len == -1 then
            et.G_LogPrint("uMod ERROR: sprees/" .. mapName .. ".record file not writable!\n")
        else
            local mapSpreeRecordLine = kills .. "@" .. date .. "@" .. name
            et.trap_FS_Write(mapSpreeRecordLine, string.len(mapSpreeRecordLine), fd)
        end

        et.trap_FS_FCloseFile(fd)

        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "qsay ^1New Map spree record: ^7" .. name .. " ^7with^3 " .. kills ..
                " ^7kills on " .. mapName .." ^7" .. mapSpree["msg"]["oldShort"] .. "\n"
        )

        setMapSpreeRecord(name, kills, date)
    end

    -- Set map spree record data.
    --  name is the player name.
    --  kills is the kill count of map spree record.
    --  date is the current time and date of map spree record.
    function setMapSpreeRecord(name, kills, date)
        mapSpree["killsRecord"] = kills

        mapSpree["msg"]["oldShort"] = "^3[Old: ^7" .. name
            .. " ^3" .. kills .. " ^7@ " .. date .. "^3]"

        mapSpree["msg"]["oldLong"] = "^3Map Spree Record: ^7" .. name
            .. " ^7with ^3" .. kills .. " ^7kills at " .. date
            .. " on the map of " .. mapName

        mapSpree["msg"]["current"] = "Current Map spree record: ^7" .. name
            .. " ^7with ^3" .. kills .. " ^7kills at " .. date
    end

    -- Callback function when ReadConfig is called in et_InitGame function
    -- and in the !readconfig client command.
    -- Load and set spree record and map spree record.
    function loadSpreeRecord()
        local funcStart = et.trap_Milliseconds()

        -- Load spree record.
        local fd, len = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_READ)

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: sprees/spree_record.dat file no found / not readable!\n"
            )
        elseif len == 0 then
            et.G_Print("uMod : No spree record defined\n")
        else
            local fileStr = et.trap_FS_Read(fd, len)
            local _, _, kills, date, name = string.find(
                fileStr,
                "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)"
            )

            setSpreeRecord(name, tonumber(kills), date)
        end

        et.trap_FS_FCloseFile(fd)

        -- Load map spree record.
        local fd, len = et.trap_FS_FOpenFile("sprees/" .. mapName .. ".record", et.FS_READ)

        if len == -1 then
            et.G_LogPrint(
                "uMod WARNING: sprees/" .. mapName .. ".record file no found / not readable!\n"
            )
        elseif len == 0 then
            et.G_Print("uMod : No map spree record defined\n")
        else
            local fileStr = et.trap_FS_Read(fd, len)
            local _, _, kills, date, name = string.find(
                fileStr,
                "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)"
            )

            setMapSpreeRecord(name, tonumber(kills), date)
        end

        et.trap_FS_FCloseFile(fd)

        et.G_LogPrintf(
            "uMod: Loading spree & map spree records in %d ms\n",
            et.trap_Milliseconds() - funcStart
        )
    end

    -- Check if victim have new spree / map pree record.
    --  vars is the local vars of et_Obituary function.
    function checkSpreeRecord(vars)
        if client[vars["victim"]]["killingSpree"] > spree["killsRecord"] then
            writeSpreeRecord(vars["victim"], client[vars["victim"]]["killingSpree"])
        end

        if client[vars["victim"]]["killingSpree"] > mapSpree["killsRecord"] then
            writeMapSpreeRecord(vars["victim"], client[vars["victim"]]["killingSpree"])
        end
    end

    -- Add callback spree record function.
    addCallbackFunction({
        ["ReadConfig"] = "loadSpreeRecord"
    })
end

-- Set common default client data.
--
-- Killing spree value.
clientDefaultData["killingSpree"] = 0

-- Set module command.
cmdList["client"]["!spree"] = "/command/client/spree.lua"

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
-- At end of round, heck players and display killing spree end message if needed.
-- Check and display spree and map spree records if needed.
--  vars is the local vars passed from et_RunFrame function.
function checkKillingSpreeRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        local endRoundfunctionList = {}
        local endKillingSpree      = ""

        local maxSpree = {
            ["killingSpree"] = 0,
            ["clientNum"]    = nil
        }

        local maxMapSpree = {
            ["killingSpree"] = 0,
            ["clientNum"]    = nil
        }

        if killingSpreeModule == 1 then
            endRoundfunctionList[1] = function (clientNum)
                if client[clientNum]["killingSpree"] >= 5 then
                    if endKillingSpree ~= "" then
                        endKillingSpree = endKillingSpree .. "^7, "
                    else
                        endKillingSpree = endKillingSpree .. "^7"
                    end

                    endKillingSpree = endKillingSpree .. client[clientNum]["name"]
                end
            end
        end
        
        if spreeRecordModule == 1 then
            endRoundfunctionList[2] = function (clientNum)
                if client[clientNum]["killingSpree"] > spree["killsRecord"] then
                    maxSpree = {
                        ["killingSpree"] = client[clientNum]["killingSpree"],
                        ["clientNum"]    = clientNum
                    }
                end

                if client[clientNum]["killingSpree"] > mapSpree["killsRecord"] then
                    maxMapSpree = {
                        ["killingSpree"] = client[clientNum]["killingSpree"],
                        ["clientNum"]    = clientNum
                    }
                end
            end
        end
        
        for p = 0, clientsLimit, 1 do
            for _, endRoundfunction in pairs(endRoundfunctionList) do
                endRoundfunction(p)
            end

            client[p]["killingSpree"] = 0
        end

        if endKillingSpree ~= "" then
            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay ^1Killing spree ended due to map's end for : "
                    .. endKillingSpree .. "\n"
            )
        end

        if spreeRecordModule == 1 then
            if maxSpree["killingSpree"] > 0 then
                writeSpreeRecord(
                    maxSpree["clientNum"],
                    maxSpree["killingSpree"]
                )
            end

            if maxMapSpree["killingSpree"] > 0 then
                writeMapSpreeRecord(
                    maxMapSpree["clientNum"],
                    maxMapSpree["killingSpree"]
                )
            end

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay ^" .. color .. spree["msg"]["current"] .. "\n"
            )

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay ^" .. color .. mapSpree["msg"]["current"] .. "\n"
            )
        end

        removeCallbackFunction("RunFrameEndRound", "checkKillingSpreeRunFrameEndRound")
    end
end

-- Callback function when a player kill a enemy.
-- If player kill a enemy, increment his killing spree counter.
-- Check if victim have new spree / map pree record.
-- If player is on killing spree, display his killing spree message and
-- play killing spree sound. If victim is on killing spree, display his
-- killing spree end message. Reset killing spree counter of victim.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryEnemyKill(vars)
    client[vars["killer"]]["killingSpree"] = client[vars["killer"]]["killingSpree"] + 1

    if spreeRecordModule == 1 then
        checkSpreeRecord(vars)
    end

    if killingSpreeModule == 1 then
        local ks = client[vars["killer"]]["killingSpree"]

        if killingSpree["list"][ks] then
            local msg = killingSpree["list"][ks]["message"]
            msg = string.gsub(msg, "#killer#", vars["killerName"])
            msg = string.gsub(msg, "#kills#", client[vars["killer"]]["killingSpree"])
            sayClients(killingSpree["msgPosition"], msg, "killingSpreeMsg")

            if killingSpree["enabledSound"] == 1 then
                if killingSpree["noiseReduction"] == 1 then
                    playSound(
                        killingSpree["list"][ks]["sound"],
                        "killingSpreeMsg",
                        vars["killer"]
                    )
                else
                    playSound(
                        killingSpree["list"][ks]["sound"],
                        "killingSpreeMsg"
                    )
                end
            end
        end

        if client[vars["victim"]]["killingSpree"] >= 5 then
            killingSpreeEndProcess(vars, killingSpree["endMessage1"], vars["victim"])
        end
    end

    client[vars["victim"]]["killingSpree"] = 0
end

-- Callback function when world kill a player.
-- If killer is killed by the world and is on killing spree, display his killing spree end
-- message and reset killing spree counter of victim.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryWorldKill(vars)
    if killingSpreeModule == 1 and client[vars["victim"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage3"], vars["victim"]) 
    end

    client[vars["victim"]]["killingSpree"] = 0
end

-- Callback function when victim is killed by mate (team kill).
-- If killer is team killed and is on killing spree, display his killing spree end message
-- and reset killing spree counter of killer and victim.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituaryTeamKill(vars)
    if killingSpreeModule == 1 and client[vars["killer"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage4"], vars["killer"])
    end

    client[vars["killer"]]["killingSpree"] = 0
    client[vars["victim"]]["killingSpree"] = 0
end

-- Callback function when victim is killed himself (self kill).
-- If killer make selfkill and is on killing spree, display his killing spree end message
-- and reset his killing spree counter.
--  vars is the local vars of et_Obituary function.
function checkKillingSpreeObituarySelfKill(vars)
    if killingSpreeModule == 1 and client[vars["killer"]]["killingSpree"] >= 5 then
        killingSpreeEndProcess(vars, killingSpree["endMessage2"], vars["victim"])
    end

    client[vars["killer"]]["killingSpree"] = 0
end

-- Add callback killing spree & spree record function.
if tonumber(et.trap_Cvar_Get("u_ks_teamkill_allowed")) == 0 then
    addCallbackFunction({
        ["ObituaryTeamKill"] = "checkKillingSpreeObituaryTeamKill"
    })
end

if spreeRecordModule == 1 then
    addCallbackFunction({
        ["ObituaryTeamKill"]  = "checkSpreeRecord",
        ["ObituaryWorldKill"] = "checkSpreeRecord",
        ["ObituarySelfKill"]  = "checkSpreeRecord"
    })
end

addCallbackFunction({
    ["RunFrameEndRound"]  = "checkKillingSpreeRunFrameEndRound",
    ["ObituaryEnemyKill"] = "checkKillingSpreeObituaryEnemyKill",
    ["ObituaryWorldKill"] = "checkKillingSpreeObituaryWorldKill",
    ["ObituarySelfKill"]  = "checkKillingSpreeObituarySelfKill"
})
