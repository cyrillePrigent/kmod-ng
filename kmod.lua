kmod_ng_path = et.trap_Cvar_Get("fs_basepath") .. '/etpro'

KMODversion = "Beta 1.5"
KMODversion2 = "1.5"
k_commandprefix = "!" -- change this to your desired prefix

--[[
This lua was created to replace most features of etadmin mod
and is much faster in response time and includes some features
that etadmin mod does not have and vice versa.

FEATURES:
	*** Killingsprees plus all the other killingspree type stuff (Sounds Included)
	*** Doublekills, Multikills, Ultrakills, Monsterkills, and Ludicrouskills (Sounds Included)
	*** Flakmonkey's - When you get 3 kills with either panzer or a riflenade.
		Flakmonkey is reset if you get any other type of kill/teamkill/or if you die (Sound included)
	*** Firstblood (Sound Included)
	*** Lastblood
	*** Spreerecord (not including records for individual maps)
	*** Enhanced Private Messaging - The sender can use partial name of recipiant
		or can now use the recipiants slot number.  When using ETPro 3.2.6 or higher,
		a new sound will be played letting you know that you have a private message.
		Players can now private message all 2+ level admins currently on the server using
		/ma or /pma then your message.
	*** Vote disable was taken directly from ETAdmin mod and is slightly enhanced such that
		it will detect changes to the timelimit.  (see config for details)
	*** Antiunmute - When a player is muted he may not be unmuted via vote
	*** Advanced Adrenaline - Players using adrenaline now have a timer in their cp area
		displaying the amount of adrenaline time they have left.
		A sound will also be played in their general location letting everyone else
		know that they are using adrenaline (disableable) (sound included)
	*** Killer's HP - Killer's HP is displayed to their victims.  When you kill somone
		and are killed in return within a certain amount of time no message will be displayed.
		When a killer is using adrenaline the victim will see a message displaying so.
	*** Advanced players - Time nudge and max packets are removed from players list
		and admins may see which admins (level 2+) are on the server using /admins
	*** Chat log - All chats are logged along with player renames/connects/disconnects/and map restarts
	*** Crazygravity - The exact same crazy gravity you've come to know and love
	*** Team kill restriction - Taken from Etadmin mod and uses punkbuster to kick (see config)
	*** /kill limit - After the max amount of slash kills is reached they are no longer
		able to /kill.
	*** Endround shuffle - At the end of each round teams are shuffled automatically
		I recomend using this on servers with alot of people.
	*** Noise reduction - ETPRO 3.2.6 OR HIGHER IS REQUIRED!!!  Plays all killingsprees
		multikills/deathsprees/and firstblood to the killer or victim depending on which one
	*** Color codes can be changed for lastblood and killer HP display in config
	*** Spawn kill protection - A newly spawned player will keep his spawn shield
		Until he either moves or fires his weapon.  (see config)
	*** Paths to sounds can be changed to fit server admins needs.

CREDITS:
	Special to
		Noobology
		Armymen
		Rikku
		Monkey Spawn
		Brunout
		Dominator
		James
		Pantsless Victims
	For helping with testing

SOURCES:
	Some code and ideas dirived from G073nks which can be found here
		http://wolfwiki.anime.net/index.php/User:Gotenks
	Code to get slot number from name was from the slap command I found on the ETPro forum here 
		http://bani.anime.net/banimod/forums/viewtopic.php?t=6579&highlight=slap
	Infty's NoKill lua code was used and edited for the slashkill limit which can be found here
		http://wolfwiki.anime.net/index.php/User:Infty
	Ideas dirived from ETAdmin_mod found here
		http://et.d1p.de/etadmin_mod/wiki/index.php/Main_Page

	If you see your code in here let me know and I'll add you to the credits for future releases

	The rest of the code is mine :D
--]]

killingspree = {}
flakmonkey = {}
deathspree = {}
multikill = {}
playerwhokilled = {}
killedwithweapk = {}
killedwithweapv = {}
playerlastkilled = {}
muted = {}
muteDuration = {}
nummutes = {}
chkIP = {}
antiloopadr1 = {}
antiloopadr2 = {}
adrenaline = {}
adrnum = {}
adrnum2 = {}
adrtime = {}
adrtime2 = {}
adrendummy = {}
clientrespawn = {}
invincStart = {}
invincDummy = {}
switchteam = {}
gibbed = {}
randomClient = {}

timecounter = 1

kill1 = {}
kill2 = {}
kill3 = {}
kill4 = {}
kill5 = {}
kill6 = {}
kill7 = {}
kill8 = {}
killr = {}
selfkills = {}
teamkillr = {}
khp = {}
PlayerName = {}
Bname = {}

EV_GLOBAL_CLIENT_SOUND = 54
et.CS_PLAYERS = 689
EV_GENERAL_SOUND = 49

team = { "AXIS" , "ALLIES" , "SPECTATOR" }
class = { [0]="SOLDIER" , "MEDIC" , "ENGINEER" , "FIELD OPS" , "COVERT OPS" }

AdminLV = {}

for z = 0, 9999, 1 do
    AdminLV[z] = {}
end

chkGUID = {}
AdminName = {}
originalclass = {}
originalweap = {}

et.MAX_WEAPONS = 50
GAMEPAUSED = 0

pweapons = {
	nil,	--// 1
	false,	--WP_LUGER,				// 2
	false,	--WP_MP40,				// 3
	false,	--WP_GRENADE_LAUNCHER,	// 4
	true,	--WP_PANZERFAUST,		// 5
	false,	--WP_FLAMETHROWER,		// 6
	false,	--WP_COLT,				// 7	// equivalent american weapon to german luger
	false,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
	false,	--WP_GRENADE_PINEAPPLE,	// 9
	false,	--WP_STEN,				// 10	// silenced sten sub-machinegun
	false,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
	false,	--WP_AMMO,				// 12	// JPW NERVE likewise
	false,	--WP_ARTY,				// 13
	false,	--WP_SILENCER,			// 14	// used to be sp5
	false,	--WP_DYNAMITE,			// 15
	nil,	--// 16
	nil,	--// 17
	nil,		--// 18
	false,	--WP_MEDKIT,			// 19
	false,	--WP_BINOCULARS,		// 20
	nil,	--// 21
	nil,	--// 22
	false,	--WP_KAR98,				// 23	// WolfXP weapons
	false,	--WP_CARBINE,			// 24
	false,	--WP_GARAND,			// 25
	false,	--WP_LANDMINE,			// 26
	false,	--WP_SATCHEL,			// 27
	false,	--WP_SATCHEL_DET,		// 28
	nil,	--// 29
	false,	--WP_SMOKE_BOMB,		// 30
	false,	--WP_MOBILE_MG42,		// 31
	false,	--WP_K43,				// 32
	false,	--WP_FG42,				// 33
	nil,	--// 34
	false,	--WP_MORTAR,			// 35
	nil,	--// 36
	false,	--WP_AKIMBO_COLT,		// 37
	false,	--WP_AKIMBO_LUGER,		// 38
	nil,	--// 39
	nil,	--// 40
	false,	--WP_SILENCED_COLT,		// 41
	false,	--WP_GARAND_SCOPE,		// 42
	false,	--WP_K43_SCOPE,			// 43
	false,	--WP_FG42SCOPE,			// 44
	false,	--WP_MORTAR_SET,		// 45
	false,	--WP_MEDIC_ADRENALINE,	// 46
	false,	--WP_AKIMBO_SILENCEDCOLT,// 47
	false	--WP_AKIMBO_SILENCEDLUGER,// 48
}

fweapons = {
	nil,	--// 1
	true,	--WP_LUGER,				// 2
	true,	--WP_MP40,				// 3
	true,	--WP_GRENADE_LAUNCHER,	// 4
	true,	--WP_PANZERFAUST,		// 5
	true,	--WP_FLAMETHROWER,		// 6
	true,	--WP_COLT,				// 7	// equivalent american weapon to german luger
	true,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
	true,	--WP_GRENADE_PINEAPPLE,	// 9
	true,	--WP_STEN,				// 10	// silenced sten sub-machinegun
	true,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
	true,	--WP_AMMO,				// 12	// JPW NERVE likewise
	true,	--WP_ARTY,				// 13
	true,	--WP_SILENCER,			// 14	// used to be sp5
	true,	--WP_DYNAMITE,			// 15
	nil,	--// 16
	nil,	--// 17
	nil,		--// 18
	true,	--WP_MEDKIT,			// 19
	true,	--WP_BINOCULARS,		// 20
	nil,	--// 21
	nil,	--// 22
	true,	--WP_KAR98,				// 23	// WolfXP weapons
	true,	--WP_CARBINE,			// 24
	true,	--WP_GARAND,			// 25
	true,	--WP_LANDMINE,			// 26
	true,	--WP_SATCHEL,			// 27
	true,	--WP_SATCHEL_DET,		// 28
	nil,	--// 29
	true,	--WP_SMOKE_BOMB,		// 30
	true,	--WP_MOBILE_MG42,		// 31
	true,	--WP_K43,				// 32
	true,	--WP_FG42,				// 33
	nil,	--// 34
	true,	--WP_MORTAR,			// 35
	nil,	--// 36
	true,	--WP_AKIMBO_COLT,		// 37
	true,	--WP_AKIMBO_LUGER,		// 38
	nil,	--// 39
	nil,	--// 40
	true,	--WP_SILENCED_COLT,		// 41
	true,	--WP_GARAND_SCOPE,		// 42
	true,	--WP_K43_SCOPE,			// 43
	true,	--WP_FG42SCOPE,			// 44
	true,	--WP_MORTAR_SET,		// 45
	false,	--WP_MEDIC_ADRENALINE,	// 46
	true,	--WP_AKIMBO_SILENCEDCOLT,// 47
	true	--WP_AKIMBO_SILENCEDLUGER,// 48
}

aweapons = {
	nil,	--// 1
	true,	--WP_LUGER,				// 2
	true,	--WP_MP40,				// 3
	true,	--WP_GRENADE_LAUNCHER,	// 4
	true,	--WP_PANZERFAUST,		// 5
	true,	--WP_FLAMETHROWER,		// 6
	true,	--WP_COLT,				// 7	// equivalent american weapon to german luger
	true,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
	true,	--WP_GRENADE_PINEAPPLE,	// 9
	true,	--WP_STEN,				// 10	// silenced sten sub-machinegun
	true,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
	true,	--WP_AMMO,				// 12	// JPW NERVE likewise
	true,	--WP_ARTY,				// 13
	true,	--WP_SILENCER,			// 14	// used to be sp5
	true,	--WP_DYNAMITE,			// 15
	nil,	--// 16
	nil,	--// 17
	nil,		--// 18
	true,	--WP_MEDKIT,			// 19
	true,	--WP_BINOCULARS,		// 20
	nil,	--// 21
	nil,	--// 22
	true,	--WP_KAR98,				// 23	// WolfXP weapons
	true,	--WP_CARBINE,			// 24
	true,	--WP_GARAND,			// 25
	true,	--WP_LANDMINE,			// 26
	true,	--WP_SATCHEL,			// 27
	true,	--WP_SATCHEL_DET,		// 28
	nil,	--// 29
	true,	--WP_SMOKE_BOMB,		// 30
	true,	--WP_MOBILE_MG42,		// 31
	true,	--WP_K43,				// 32
	true,	--WP_FG42,				// 33
	nil,	--// 34
	true,	--WP_MORTAR,			// 35
	nil,	--// 36
	true,	--WP_AKIMBO_COLT,		// 37
	true,	--WP_AKIMBO_LUGER,		// 38
	nil,	--// 39
	nil,	--// 40
	true,	--WP_SILENCED_COLT,		// 41
	true,	--WP_GARAND_SCOPE,		// 42
	true,	--WP_K43_SCOPE,			// 43
	true,	--WP_FG42SCOPE,			// 44
	true,	--WP_MORTAR_SET,		// 45
	false,	--WP_MEDIC_ADRENALINE,	// 46
	true,	--WP_AKIMBO_SILENCEDCOLT,// 47
	true	--WP_AKIMBO_SILENCEDLUGER,// 48
}

gweapons = {
	nil,	--// 1
	false,	--WP_LUGER,				// 2
	false,	--WP_MP40,				// 3
	true,	--WP_GRENADE_LAUNCHER,	// 4
	false,	--WP_PANZERFAUST,		// 5
	false,	--WP_FLAMETHROWER,		// 6
	false,	--WP_COLT,				// 7	// equivalent american weapon to german luger
	false,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
	true,	--WP_GRENADE_PINEAPPLE,	// 9
	false,	--WP_STEN,				// 10	// silenced sten sub-machinegun
	false,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
	false,	--WP_AMMO,				// 12	// JPW NERVE likewise
	false,	--WP_ARTY,				// 13
	false,	--WP_SILENCER,			// 14	// used to be sp5
	false,	--WP_DYNAMITE,			// 15
	nil,	--// 16
	nil,	--// 17
	nil,		--// 18
	false,	--WP_MEDKIT,			// 19
	false,	--WP_BINOCULARS,		// 20
	nil,	--// 21
	nil,	--// 22
	false,	--WP_KAR98,				// 23	// WolfXP weapons
	false,	--WP_CARBINE,			// 24
	false,	--WP_GARAND,			// 25
	false,	--WP_LANDMINE,			// 26
	false,	--WP_SATCHEL,			// 27
	false,	--WP_SATCHEL_DET,		// 28
	nil,	--// 29
	false,	--WP_SMOKE_BOMB,		// 30
	false,	--WP_MOBILE_MG42,		// 31
	false,	--WP_K43,				// 32
	false,	--WP_FG42,				// 33
	nil,	--// 34
	false,	--WP_MORTAR,			// 35
	nil,	--// 36
	false,	--WP_AKIMBO_COLT,		// 37
	false,	--WP_AKIMBO_LUGER,		// 38
	nil,	--// 39
	nil,	--// 40
	false,	--WP_SILENCED_COLT,		// 41
	false,	--WP_GARAND_SCOPE,		// 42
	false,	--WP_K43_SCOPE,			// 43
	false,	--WP_FG42SCOPE,			// 44
	false,	--WP_MORTAR_SET,		// 45
	false,	--WP_MEDIC_ADRENALINE,	// 46
	false,	--WP_AKIMBO_SILENCEDCOLT,// 47
	false	--WP_AKIMBO_SILENCEDLUGER,// 48
}

sweapons = {
	nil,	--// 1
	false,	--WP_LUGER,				// 2
	false,	--WP_MP40,				// 3
	false,	--WP_GRENADE_LAUNCHER,	// 4
	false,	--WP_PANZERFAUST,		// 5
	false,	--WP_FLAMETHROWER,		// 6
	false,	--WP_COLT,				// 7	// equivalent american weapon to german luger
	false,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
	false,	--WP_GRENADE_PINEAPPLE,	// 9
	false,	--WP_STEN,				// 10	// silenced sten sub-machinegun
	false,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
	false,	--WP_AMMO,				// 12	// JPW NERVE likewise
	false,	--WP_ARTY,				// 13
	false,	--WP_SILENCER,			// 14	// used to be sp5
	false,	--WP_DYNAMITE,			// 15
	nil,	--// 16
	nil,	--// 17
	nil,		--// 18
	false,	--WP_MEDKIT,			// 19
	false,	--WP_BINOCULARS,		// 20
	nil,	--// 21
	nil,	--// 22
	false,	--WP_KAR98,				// 23	// WolfXP weapons
	false,	--WP_CARBINE,			// 24
	true,	--WP_GARAND,			// 25
	false,	--WP_LANDMINE,			// 26
	false,	--WP_SATCHEL,			// 27
	nil,	--WP_SATCHEL_DET,		// 28
	nil,	--// 29
	false,	--WP_SMOKE_BOMB,		// 30
	false,	--WP_MOBILE_MG42,		// 31
	true,	--WP_K43,				// 32
	true,	--WP_FG42,				// 33
	nil,	--// 34
	false,	--WP_MORTAR,			// 35
	nil,	--// 36
	false,	--WP_AKIMBO_COLT,		// 37
	false,	--WP_AKIMBO_LUGER,		// 38
	nil,	--// 39
	nil,	--// 40
	false,	--WP_SILENCED_COLT,		// 41
	true,	--WP_GARAND_SCOPE,		// 42
	true,	--WP_K43_SCOPE,			// 43
	true,	--WP_FG42SCOPE,			// 44
	false,	--WP_MORTAR_SET,		// 45
	false,	--WP_MEDIC_ADRENALINE,	// 46
	false,	--WP_AKIMBO_SILENCEDCOLT,// 47
	false	--WP_AKIMBO_SILENCEDLUGER,// 48
}

lvls = {}
lvlsc = {}

numAxisPlayers = 0
numAlliedPlayers = 0
active_players = 0
total_players = 0

firstblood = 0
lastblood = ""
oldspree = ""
oldspree2 = ""
intmrecord = ""
oldmapspree = ""
oldmapspree2 = ""
intmMaprecord = ""

panzer_antiloop = 0
panzer_antiloop1 = 0
panzer_antiloop2 = 0
panzers_enabled = 0

panzers = ""
medics = ""
cvops = ""
fops = ""
engie = ""
flamers = ""
mortars = ""
mg42s = ""
soldcharge = ""
speed = ""
redlimbo = ""
bluelimbo = ""

floodprotect = 0
commandSaid = false
kick = false
fullcom = ""
finger = false
removereferee = false
makereferee = false
removeshoutcaster = false
makeshoutcaster = false
putspec = false
putallies = false
putaxis = false
unmute = false
mute = false
warn = false
ban = false
crazygravity = false
crazytime = 0

--[[
--Defaults

killingspreesound="sound/misc/killingspree.wav"
rampagesound="sound/misc/rampage.wav"
dominatingsound="sound/misc/dominating.wav"
unstopablesound="sound/misc/unstoppable.wav"
godlikesound="sound/misc/godlike.wav"
wickedsicksound="sound/misc/wickedsick.wav"
flakmonkeysound="sound/misc/flakmonkey.wav"
firstbloodsound="sound/misc/firstblood.wav"

deathspreesound1="sound/misc/humiliation.wav"
deathspreesound2="sound/misc/you_suck.wav"
deathspreesound3="sound/misc/ae821.wav"

doublekillsound="sound/misc/doublekill.wav"
multikillsound="sound/misc/multikill.wav"
ultrakillsound="sound/misc/ultrakill.wav"
monsterkillsound="sound/misc/monsterkill.wav"
ludicrouskillsound="sound/misc/ludicrouskill.wav"

k_spreesounds = 1
k_sprees = 1 -- includes sounds
k_multikillsounds = 1
k_multikills = 1 --includes sounds
k_flakmonkeysound = 1
k_flakmonkey = 1 --includes sounds
k_firstbloodsound = 1
k_firstblood = 1 --includes sound
k_lastblood = 1
k_killerhpdisplay = 1

k_spreerecord = 1
k_advplayers = 1
k_crazygravityinterval = 30
k_slashkilllimit = 1
k_slashkills = 3
k_teamkillrestriction = 1
k_tklimit_high = 3
k_tklimit_low = -3
k_color = "^2"
k_advancedpms = 1
k_playdead = 0
k_logchat = 1
k_disablevotes = 1
k_dvmode = 2
k_dvpercent = 90
k_adrensound = 1
k_advancedadrenaline = 1
k_noisereduction = 0
k_endroundshuffle = 0
k_deathsprees = 1
k_deathspreesounds = 1
k_antiunmute = 1
k_advancedspawn = 0
--]]

pmsound = "sound/misc/NewBeep.wav"

antiloop = 0
antiloop2 = 0
antiloop3 = 0
antiloop4 = 0
antiloopes = 0
antilooppw = 0
confirm = 0
spreerecordkills = 0
mapspreerecordkills = 0
crazydv = 1
CGactive = 0
panzdv = 0
sldv = 0
frenzdv = 0
grendv = 0
snipdv = 0
antiloopm = 0
pausedv = 0
pausedv2 = 0
pausetime = 0
timedv = 0
timedvs = 0
refreshrate = 0
timedelay_antiloop = 0
egamemodes = 0
run_once = 0

for i=0, tonumber(et.trap_Cvar_Get("sv_maxclients"))-1, 1 do
	antiloopadr1[i] = 0
	antiloopadr2[i] = 0
	adrenaline[i] = 0
	adrnum[i] = 0
	adrnum2[i] = 0
	adrtime[i] = 0
	adrtime2[i] = 0
end

k_Admin = {}

qwerty = 0

-- Mute function

function loadMutes()
    local i = 0
    local i2 = 0
    local dv = 1
    local dv2 = 1
    chkIP = {}
    local fd,len = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)

    for i = 0, clientsLimit, 1 do
        chkIP[i] = 0
    end

    if len <= 0 then
        et.G_Print("WARNING: No Mutes Defined! \n")
    else
        local filestr = et.trap_FS_Read(fd, len)
        local i = 0

        for time, ip in string.gfind(filestr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*") do
            muteDuration[ip] = time
            chkIP[i] = ip

            if dv == 1 then
                i = i + 1
            end
        end
    end

    et.trap_FS_FCloseFile(fd)
end

function setMute(PlayerID, muteTime)
    local time = math.ceil(muteTime)
    local fdadm,len = et.trap_FS_FOpenFile("mutes.cfg", et.FS_APPEND)
    local Name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "name"))
    local IP = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "ip"))
    s, e, IP = string.find(IP, "(%d+%.%d+%.%d+%.%d+)")
    local dv = 0

    if len == -1 then
        confirm2 = 1
        et.trap_FS_FCloseFile(fdadm)
    else
        local fdread, length = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)
        local n = 0

        if length ~= 0 then
            local filestr = et.trap_FS_Read(fdread, length)

            for ip in string.gfind(filestr, "%-*%d+%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*") do
                n = n + 1
            end
        end

        et.trap_FS_FCloseFile(fdread)
        -- Close the mutes file so that removeMute() can open the mutes.cfg
        et.trap_FS_FCloseFile(fdadm)

        for i = 0, n, 1 do
            if chkIP[i] == IP then
                dv = 1

                if dv == 1 then
                    removeMute(PlayerID)
                end

                break
            end
        end


        if muted[PlayerID] > 0 or muted[PlayerID] == -1 then
            confirm2 = 1
        else
            confirm2 = 0
        end
    end

    if confirm2 == 1 then
        fdadm, len = et.trap_FS_FOpenFile("mutes.cfg", et.FS_APPEND)

        if muted[PlayerID] ~= 0 then
            ADMIN = time .. " - " .. IP .. " - " .. Name .. "\n"
            confirm2 = 0
            et.trap_FS_Write(ADMIN, string.len(ADMIN) ,fdadm)
        else
            loadMutes()
        end

        et.trap_FS_FCloseFile(fdadm)
        loadMutes()
    end
end

function removeMute(PlayerID)
    local fdin, lenin = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)
    local fdout, lenout = et.trap_FS_FOpenFile("mutestmp.cfg", et.FS_WRITE)
    local IP2 = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "ip"))
    s, e, IP2 = string.find(IP2, "(%d+%.%d+%.%d+%.%d+)")
    local i = 0

    if lenin <= 0 then
        et.G_Print("There is no Mutes to remove \n")
    else
        local filestr = et.trap_FS_Read(fdin, lenin)

        for time, ip, name in string.gfind(filestr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*([^%\n]*)") do
            if ip ~= IP2 then
                mute = time .. " - " .. ip .. " - " .. name .. "\n"
                et.trap_FS_Write(mute, string.len(mute), fdout)
            end

            i = i + 1

        end
    end

    confirm2 = 1
    et.trap_FS_FCloseFile(fdin)
    et.trap_FS_FCloseFile(fdout)
    et.trap_FS_Rename("mutestmp.cfg", "mutes.cfg")
    loadMutes()
end

function checkMute(PlayerID)
    local ip = ""
    local name = et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "name")
    local ref = tonumber(et.gentity_get(PlayerID, "sess.referee"))

    if PlayerID ~= -1 then
        ip = et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "ip")
        s, e, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")
    else
        ip = -1
    end

    local fd, len = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)

    if len > 0 then
        local filestr = et.trap_FS_Read(fd, len)
        local i = 0

        for time in string.gfind(filestr, "(%-*%d+)%s%-%s%d+%.%d+%.%d+%.%d+%s%-%s*") do
            if chkIP[i] == ip and ref == 0 then
                if tonumber(muteDuration[ip]) > 0 then
                    muted[PlayerID] = mtime + tonumber((muteDuration[ip]) * 1000)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Curse Filter:  ^7" .. name .. "^7 has not yet finished his mute sentance.  (^1" .. muteDuration[ip] .. "^7) seconds.\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. PlayerID .. "\n" )
                elseif tonumber(muteDuration[ip]) == -1 then
                    muted[PlayerID] = -1
                    et.trap_SendConsoleCommand( et.EXEC_APPEND, "qsay ^3Curse Filter:  ^7" .. name .. "^7 has been permanently muted\n")
                    et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref mute " .. PlayerID .. "\n")
                end
            end

            i = i + 1
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Admin function

function loadAdmins()
    local i = 0
    local i2 = 0
    local dv = 1
    local dv2 = 1
    local fd, len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_READ)

    if len <= 0 then
        et.G_Print("WARNING: No Admins's Defined! \n")
    else
        local filestr = et.trap_FS_Read(fd, len)
        local i = 0

        for guid in string.gfind(filestr, "%d%s%-%s(%x+)%s%-%s*") do
            -- upcase for exact matches
            chkGUID[i] = string.upper(guid)

            if dv == 1 then
                i = i + 1
            end
        end

        for guid2 in string.gfind(filestr, "(%d%s%-%s%x+)%s%-%s*") do
            -- upcase for exact matches
            guid2 = string.upper(guid2)
            addAdmin(guid2)
        end

        for guid3, Name in string.gfind(filestr, "%d%s%-%s(%x+)%s%-%s*([^%\n]*)") do
            AdminName[guid3] = Name
        end
    end

    et.trap_FS_FCloseFile(fd)
end

function setAdmin(PlayerID, levelv)
    -- gets file length
    local fdadm,len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_APPEND)
    et.trap_FS_FCloseFile(fdadm)
    local level = tonumber(levelv)
    local Name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "name"))
    local GUID = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "cl_guid"))
    local dv = 0
    local dvi = 0

    if len == -1 then
        confirm = 1
    else
        for i = 0, tonumber(table.getn(chkGUID)), 1 do
            if chkGUID[i] == GUID then
                dv = 1

                if dv == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay changing admin!\n")
                    removeAdmin(PlayerID)
                end

                break
            end

            dvi = i
        end

        if dvi == tonumber(table.getn(chkGUID)) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay setting admin!\n")
            confirm = 1
        end
    end

    local fdadm, len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_APPEND)

    if confirm == 1 then
        for i = 0, k_maxAdminLevels, 1 do
            if level == 0 then
                if sldv == 0 then
                    if commandSaid then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Setlevel: ^7" .. Name .. "^7 is now a regular ^7user!\n")
                        commandSaid = false
                    else
                        et.G_Print(Name .. "^7 is now a regular ^7user!\n")
                        confirm = 0
                    end
                end

                loadAdmins()
                return
            elseif level == i and level > 0 then
                for q = 0, i, 1 do
                    AdminLV[q][GUID] = true
                    ADMIN = level .. " - " .. GUID .. " - " .. Name .. "\n"
                    confirm = 0
                end

                break
            end
        end

        et.trap_FS_Write(ADMIN, string.len(ADMIN), fdadm)
        et.trap_FS_FCloseFile(fdadm)

        if commandSaid then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Setlevel: ^7" .. Name .. "^7 is now a level ^1" .. level .. " ^7user!\n")
            commandSaid = false
        else
            et.G_Print(Name .. "^7 is now a level ^1" .. level .. " ^7user!\n")
        end

        loadAdmins()
        return 1
    else
        et.trap_FS_FCloseFile(fdadm)
        return 1
    end
end

function addAdmin(GUID)
    s, e, level,GUID = string.find(GUID, "(%d)%s%-%s(%x+)")
    level = tonumber(level)

    for i = 0, k_maxAdminLevels, 1 do
        if level == i then
            for q = 1, i, 1 do
                AdminLV[q][GUID] = true
            end

            break
        end
    end
end

function removeAdmin(PlayerID)
    local fdin, lenin = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_READ)
    local fdout, lenout = et.trap_FS_FOpenFile("shrubbottmp.cfg", et.FS_WRITE)
    local GUID2 = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "cl_guid"))
    local i = 0
    local IPRemove = ""
    local fname = ""
    local dv = 1

    if lenin == -1 then
        et.G_Print("There is no Power User IP to remove \n")
    else
        local filestr = et.trap_FS_Read(fdin, lenin)

        for lvl, guid, name in string.gfind(filestr, "(%d)%s%-%s(%x+)%s%-%s*([^%\n]*)") do
            if guid == GUID2 then
                guid = string.upper(guid)
                fname = name

                for q = 0, k_maxAdminLevels, 1 do
                    AdminLV[q][GUID2] = false
                end
            else
                guid = lvl .. " - " .. guid .. " - " .. name .. "\n"
                et.trap_FS_Write(guid, string.len(guid), fdout)
            end

            i = i + 1
        end
    end

    confirm = 1
    et.trap_FS_FCloseFile(fdin)
    et.trap_FS_FCloseFile(fdout)
    et.trap_FS_Rename("shrubbottmp.cfg", "shrubbot.cfg")

    if dv == 1 then
        loadAdmins()
    end
end

function adminStatus(PlayerID)
    local IP   = et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "ip")
    local GUID = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "cl_guid"))

    for i = k_maxAdminLevels, 0, -1 do
        if finger then
            local name = et.gentity_get(PlayerID, "pers.netname")

            if AdminLV[i][GUID] and i ~= 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Finger: ^7" .. name .. " ^7is an admin \[lvl " .. i .. "\]\n")
                finger = false
                commandSaid = false
                break
            elseif i == 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Finger: ^7" .. name .. " ^7is a guest \[lvl 0\]\n")
                finger = false
                commandSaid = false
                break
            end
        else
            if AdminLV[i][GUID] and i ~= 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Admintest: ^7You are an admin \[lvl " .. i .. "\]\n")
                break
            elseif i == 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Admintest: ^7You are a guest \[lvl 0\]\n")
                break
            end
        end
    end
end

function getAdminLevel(PlayerID)
    local guid = ""

    if PlayerID ~= -1 then
        guid = et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "cl_guid")
    else
        guid = -1
    end

    for i = k_maxAdminLevels, 1, -1 do
        if AdminLV[i][guid] then
            return i
        end
    end

    return 0
end

-- Spree function

function setSpreeRecord(PlayerID, kills2)
    -- TODO base path of sprees directory
    local fdadm, len = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_WRITE)
    local Name = et.Q_CleanStr(et.Info_ValueForKey( et.trap_GetUserinfo(PlayerID), "name"))
    local date = os.date("%x %I:%M:%S%p")
    local kills = tonumber(kills2)

    SPREE = kills .. "@" .. date .. "@" .. Name

    et.trap_FS_Write(SPREE, string.len(SPREE) ,fdadm)
    et.trap_FS_FCloseFile(fdadm)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^1New spree record: ^7" .. Name .. " ^7with^3 " .. kills .. "^7 kills  ^7" .. tostring(oldspree) .. "\n")
    loadSpreeRecord()
end

function loadSpreeRecord()
    -- TODO base path of sprees directory
    local fd, len = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_READ)
    local kills = 0
    local date = ""
    local name = ""

    if len <= 0 then
        et.G_Print("WARNING: No spree record found! \n")
        oldspree = "^3[Old: ^7N/A^3]"
        oldspree2 = "^3Spree Record: ^7There is no current spree record"
        spreerecordkills = 0
    else
        local filestr = et.trap_FS_Read(fd, len)

        s, e, kills, date, name = string.find(filestr, "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)")
        spreerecordkills = tonumber(kills)
        oldspree = "^3[Old: ^7" .. name .. "^3 " .. kills .. "^7 @ " .. date .. "^3]"
        oldspree2 = "^3Spree Record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date
        intmrecord = "Current spree record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date

    end

    et.trap_FS_FCloseFile(fd)
end

function setMapSpreeRecord(PlayerID, kills2)
    local mapname = tostring(et.trap_Cvar_Get("mapname"))
    -- TODO base path of sprees directory
    local fdadm,len = et.trap_FS_FOpenFile("sprees/" .. mapname .. ".record", et.FS_WRITE)
    local Name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "name"))
    local date = os.date("%x %I:%M:%S%p")
    local kills = tonumber(kills2)

    SPREE = kills .. "@" .. date .. "@" .. Name

    et.trap_FS_Write(SPREE, string.len(SPREE) ,fdadm)
    et.trap_FS_FCloseFile(fdadm)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^1New Map spree record: ^7" .. Name .. " ^7with^3 " .. kills .. "^7 kills on " .. mapname .."  ^7" .. tostring(oldmapspree) .. "\n")
    loadMapSpreeRecord()
end

function loadMapSpreeRecord()
    local mapname = tostring(et.trap_Cvar_Get("mapname"))
    -- TODO base path of sprees directory
    local fd,len = et.trap_FS_FOpenFile("sprees/" .. mapname .. ".record", et.FS_READ)
    local kills = 0
    local date = ""
    local name = ""

    if len <= 0 then
        et.G_Print("WARNING: No spree record found! \n")
        oldmapspree = "^3[Old: ^7N/A^3]"
        oldmapspree2 = "^3Map Spree Record: ^7There is no current spree record"
        mapspreerecordkills = 0
    else
        local filestr = et.trap_FS_Read(fd, len)

        s, e, kills, date, name = string.find(filestr, "(%d+)%@(%d+%/%d+%/%d+%s%d+%:%d+%:%d+%a+)%@([^%\n]*)")
        mapspreerecordkills = tonumber(kills)
        oldmapspree = "^3[Old: ^7" .. name .. "^3 " .. kills .. "^7 @ " .. date .. "^3]"
        oldmapspree2 = "^3Map Spree Record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date .. " on the map of " .. mapname
        intmMaprecord = "Current Map spree record: ^7" .. name .. "^7 with ^3" .. kills .. "^7 kills at " .. date

    end

    et.trap_FS_FCloseFile(fd)
end

-- Log function

function logMessage(clientNum, msg, msgType)
    local clientInfo = et.trap_GetUserinfo(clientNum)
    local ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
    local name = et.Q_CleanStr(et.gentity_get(clientNum, "pers.netname"))
    local LOG = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. name

    if msgType then
        return LOG .. " (" .. msgType .. "): " .. msg .. "\n"
    else
        return LOG .. ": " .. msg .. "\n"
    end
end

function logChat(PlayerID, mode, text, PMID)
    local text = et.Q_CleanStr(text)
    local fdadm, len = et.trap_FS_FOpenFile("chat_log.log", et.FS_APPEND)
    local time = os.date("%x %I:%M:%S%p")
    local ip
    local guid
    local LOG

    if mode == et.SAY_ALL then
        LOG = logMessage(PlayerID, text)
    elseif mode == et.SAY_TEAM then
        LOG = logMessage(PlayerID, text, 'TEAM')
    elseif mode == et.SAY_BUDDY then
        LOG = logMessage(PlayerID, text, 'BUDDY')
    elseif mode == et.SAY_TEAMNL then
        LOG = logMessage(PlayerID, text, 'TEAM')
    elseif mode == "VSAY_TEAM" then
        LOG = logMessage(PlayerID, text, 'VSAY_TEAM')
    elseif mode == "VSAY_BUDDY" then
        LOG = logMessage(PlayerID, text, 'VSAY_BUDDY')
    elseif mode == "VSAY_ALL" then
        LOG = logMessage(PlayerID, text, 'VSAY')
    elseif mode == "PMESSAGE" then
        local clientInfo = et.trap_GetUserinfo(PlayerID)
        ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
        guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
        local from = "SERVER"

        if PlayerID ~= 1022 then
            from = et.gentity_get(PlayerID, "pers.netname")
        end

        local rec1 = part2id(PMID)

        if rec1 then
            local recipiant = et.gentity_get(rec1,"pers.netname")
            LOG = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. text .. "\n"
        end
    elseif mode == "PMADMINS" then
        local from = "SERVER"

        if PlayerID ~= 1022 then
            local clientInfo = et.trap_GetUserinfo(PlayerID)
            ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
            guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
            from = et.gentity_get(PlayerID, "pers.netname")
        else
            ip = "127.0.0.1"
            guid = "NONE!"
        end

        local recipiant = "ADMINS"
        LOG = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. text .. "\n"
    elseif mode == "CONN" then
        local clientInfo = et.trap_GetUserinfo(PlayerID)
        ip = string.upper(et.Info_ValueForKey(clientInfo, "ip" ))
        guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid" ))
        local name = et.Q_CleanStr(et.gentity_get(PlayerID, "pers.netname"))

        LOG = "*** " .. name .. " HAS ENTERED THE GAME  (IP: " .. ip .. " GUID: " .. guid .. ") ***\n"
    elseif mode == "NAME_CHANGE" then
        LOG = "*** " .. PlayerID .. " HAS RENAMED TO " .. text .. " ***\n"
    elseif mode == "DISCONNECT" then
        local name = et.Q_CleanStr(et.gentity_get(PlayerID, "pers.netname"))

        LOG = "*** " .. name .. " HAS DISCONNECTED ***\n"
    elseif mode == "START" then
        LOG = "\n	***SERVER RESTART OR MAP CHANGE***\n\n"
    end

    et.trap_FS_Write(LOG, string.len(LOG) ,fdadm)
    et.trap_FS_FCloseFile(fdadm)
end

-- Miscellaneous

function printModInfo(clientNum)
    et.trap_SendServerCommand(clientNum, "cpm \"This server is running the new KMOD version " .. KMODversion .. "\n\"")
    et.trap_SendServerCommand(clientNum, "cpm \"Created by Clutch152.\n\"")
end

function loadCommands()
    local fd, len = et.trap_FS_FOpenFile("commands.cfg", et.FS_READ)

    if len > 0 then
        local filestr = et.trap_FS_Read(fd, len)
        local counter = {}
        local d = {}

        for i = 0, k_maxAdminLevels, 1 do
            counter[i] = 0
            d[i] = lvlsc[i]
        end

        for level, comm in string.gfind(filestr, "[^%#](%d)%s*%-%s*(%w+)%s*%=%s*[^%\n]*") do
            local comm2 = k_commandprefix .. comm

            for i = 0, k_maxAdminLevels, 1 do
                if tonumber(level) == i then
                    lvlsc[i] = lvlsc[i] + 1
                    lvls[i][lvlsc[i]] = comm2
                end
            end
        end
    end

    et.trap_FS_FCloseFile(fd)
end

function readConfig()
    loadAdmins()
    loadSpreeRecord()
    loadMapSpreeRecord()

    k_maxAdminLevels = tonumber(et.trap_Cvar_Get("k_maxAdminLevels"))

    for i = 0, k_maxAdminLevels, 1 do
        t = tostring(et.trap_Cvar_Get("k_Admin" .. i))
        local c = 1
        lvls[i] = {}

        for w in string.gfind(t, "([^%s]+)%s*") do
            lvls[i][c] = k_commandprefix .. w
            c=c + 1
        end

        lvlsc[i] = c - 1
    end

    loadCommands()
end

function client2id(client, cmd, verbose, cmdSaid)
    local clientNum = tonumber(client)

    if clientNum then
        if clientNum >= 0 and clientNum < 64 then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                if verbose == 'client' then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7There is no client associated with this slot number\n")
                elseif verbose == 'console' then
                    et.G_Print("There is no client associated with this slot number\n")
                end

                return nil
            end
        else
            if verbose == 'client' then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7Please enter a slot number between 0 and 63\n")
            elseif verbose == 'console' then
                et.G_Print("Please enter a slot number between 0 and 63\n")
            end

            return nil
        end
    else
        if client then
            s, e = string.find(client, client)

            if e <= 2 then
                if verbose == 'client' then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, cmdSaid .. " ^3" .. cmd .. ": ^7Player name requires more than 2 characters\n")
                elseif verbose == 'console' then
                    et.G_Print("Player name requires more than 2 characters\n")
                end

                return nil
            else
                clientNum = getPlayernameToId(client)
            end
        end

        if not clientNum then
            if verbose == 'client' then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3" .. cmd .. ": ^7Try name again or use slot number\n")
            elseif verbose == 'console' then
                et.G_Print("Try name again or use slot number\n")
            end

            return nil
        end
    end

    return clientNum
end

function splitWord(inputString)
    local i = 1
    local t = {}

    for w in string.gfind(inputString, "([^%s]+)%s*") do
        t[i] = w
        i = i + 1
    end

    return t
end

--

function getPlayernameToId(name)
    local i = 0
    local slot = nil
    local matchcount = 0
    local cleanname = string.lower(et.Q_CleanStr(name))
    local playerp = ""

    for i = 0, clientsLimit, 1 do
        if PlayerName[i] then
            playerp = string.lower(et.Q_CleanStr(PlayerName[i]))
            s, e = string.find(playerp, cleanname)

            if s and e then
                matchcount = matchcount + 1
                slot = i
            end
        end
    end

    if matchcount >= 2 then
-- set level
--         if commandSaid then
--             et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3Gib: ^7There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--             commandSaid = false
--         else
--             et.G_Print("There are currently ^1" .. matchcount .. "^7 client\[s\] that match \"" .. name .. "\"\n")
--         end

        return nil
    else
        return slot
    end
end

-- goto.lua
-- iwant.lua
-- logChat
-- ClientUserCommand
-- et_ClientCommand
function part2id(client)
    local clientNum = tonumber(client)

    if clientNum then
        if clientNum >= 0 and clientNum < 64 then
            if et.gentity_get(clientNum, "pers.connected") ~= 2 then
                return nil
            end

            return clientNum
        end
    else
        local client = string.lower(et.Q_CleanStr(client))

        if client then
            s, e = string.find(client, client)
                if e <= 2 then
                    return nil
                else
                    clientNum = getPlayernameToId(client)
                end
        end

        if not clientNum then
            return nil
        end
    end

    return clientNum
end

function randomClientFinder()
	randomClient = {}
	local m = 0
	
	for i=0,tonumber(et.trap_Cvar_Get("sv_maxclients"))-1,1 do
		if et.gentity_get(i,"pers.connected") == 2 then
			randomClient[m] = i
			m = m + 1
		end
	end

	local dv1 = m - 1 

	local dv = math.random(0, dv1)
	local dv2 = randomClient[dv]

	return dv2
end




function printCmdMsg(cmdType, msg)
    if cmdType == 'client' then
        et.G_Print(msg)
    elseif cmdType == 'console' then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " " .. msg)
    end
end

-- et_RunFrame

function killingSpreeReset()
    for i = 0, clientsLimit, 1 do
        local name = et.gentity_get(i, "pers.netname")

        if killingspree[i] >= 5 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^1Killingspree's disabled.  All sprees reset.\n")
        end

        killingspree[i] = 0
    end
end

function deathSpreeReset()
    for i = 0, clientsLimit, 1 do
        deathspree[i] = 0
    end
end

function flakMonkeyReset()
    for i = 0, clientsLimit, 1 do
        flakmonkey[i] = 0
    end
end

-- Get location of displayed message on client screen.
-- 1 : chat area
-- 2 : center screen area
-- 3 : top of screen
function getMessageLocation(location)
    if location == 2 then
        return "cp"
    elseif location == 3 then
        return "bp"
    else
        return "qsay"
    end
end

function setWeaponAmmo(weaponList, clientId)
    for i = 1, (et.MAX_WEAPONS - 1), 1 do
        if not weaponList[i] then
            et.gentity_set(clientId, "ps.ammoclip", i, 0)
            et.gentity_set(clientId, "ps.ammo", i, 0)
        else
            et.gentity_set(clientId, "ps.ammoclip", i, 999)
            et.gentity_set(clientId, "ps.ammo", i, 999)
        end
    end
end

-- et_Obituary

function getMeansOfDeathName(meansOfDeath)
    if (meansOfDeath==0) then
        weapon="UNKNOWN"
    elseif (meansOfDeath==1) then
        weapon="MACHINEGUN"
    elseif (meansOfDeath==2) then
        weapon="BROWNING"
    elseif (meansOfDeath==3) then
        weapon="MG42"
    elseif (meansOfDeath==4) then
        weapon="GRENADE"
    elseif (meansOfDeath==5) then
        weapon="ROCKET"
    elseif (meansOfDeath==6) then
        weapon="KNIFE"
    elseif (meansOfDeath==7) then
        weapon="LUGER"
    elseif (meansOfDeath==8) then
        weapon="COLT"
    elseif (meansOfDeath==9) then
        weapon="MP40"
    elseif (meansOfDeath==10) then
        weapon="THOMPSON"
    elseif (meansOfDeath==11) then
        weapon="STEN"
    elseif (meansOfDeath==12) then
        weapon="GARAND"
    elseif (meansOfDeath==13) then
        weapon="SNOOPERSCOPE"
    elseif (meansOfDeath==14) then
        weapon="SILENCER"
    elseif (meansOfDeath==15) then
        weapon="FG42"
    elseif (meansOfDeath==16) then
        weapon="FG42SCOPE"
    elseif (meansOfDeath==17) then
        weapon="PANZERFAUST"
    elseif (meansOfDeath==18) then
        weapon="GRENADE_LAUNCHER"
    elseif (meansOfDeath==19) then
        weapon="FLAMETHROWER"
    elseif (meansOfDeath==20) then
        weapon="GRENADE_PINEAPPLE"
    elseif (meansOfDeath==21) then
        weapon="CROSS"
    elseif (meansOfDeath==22) then
        weapon="MAPMORTAR"
    elseif (meansOfDeath==23) then
        weapon="MAPMORTAR_SPLASH"
    elseif (meansOfDeath==24) then
        weapon="KICKED"
    elseif (meansOfDeath==25) then
        weapon="GRABBER"
    elseif (meansOfDeath==26) then
        weapon="DYNAMITE"
    elseif (meansOfDeath==27) then
        weapon="AIRSTRIKE"
    elseif (meansOfDeath==28) then
        weapon="SYRINGE"
    elseif (meansOfDeath==29) then
        weapon="AMMO"
    elseif (meansOfDeath==30) then
        weapon="ARTY"
    elseif (meansOfDeath==31) then
        weapon="WATER"
    elseif (meansOfDeath==32) then
        weapon="SLIME"
    elseif (meansOfDeath==33) then
        weapon="LAVA"
    elseif (meansOfDeath==34) then
        weapon="CRUSH"
    elseif (meansOfDeath==35) then
        weapon="TELEFRAG"
    elseif (meansOfDeath==36) then
        weapon="FALLING"
    elseif (meansOfDeath==37) then
        weapon = "SUICIDE"
    elseif (meansOfDeath==38) then
        weapon="TARGET_LASER"
    elseif (meansOfDeath==39) then
        weapon="TRIGGER_HURT"
    elseif (meansOfDeath==40) then
        weapon="EXPLOSIVE"
    elseif (meansOfDeath==41) then
        weapon="CARBINE"
    elseif (meansOfDeath==42) then
        weapon="KAR98"
    elseif (meansOfDeath==43) then
        weapon="GPG40"
    elseif (meansOfDeath==44) then
        weapon="M7"
    elseif (meansOfDeath==45) then
        weapon="LANDMINE"
    elseif (meansOfDeath==46) then
        weapon="SATCHEL"
    elseif (meansOfDeath==47) then
        weapon="TRIPMINE"
    elseif (meansOfDeath==48) then
        weapon="SMOKEBOMB"
    elseif (meansOfDeath==49) then
        weapon="MOBILE_MG42"
    elseif (meansOfDeath==50) then
        weapon="SILENCED_COLT"
    elseif (meansOfDeath==51) then
        weapon="GARAND_SCOPE"
    elseif (meansOfDeath==52) then
        weapon="CRUSH_CONSTRUCTION"
    elseif (meansOfDeath==53) then
        weapon="CRUSH_CONSTRUCTIONDEATH"
    elseif (meansOfDeath==54) then
        weapon="CRUSH_CONSTRUCTIONDEATH_NOATTACKER"
    elseif (meansOfDeath==55) then
        weapon="K43"
    elseif (meansOfDeath==56) then
        weapon="K43_SCOPE"
    elseif (meansOfDeath==57) then
        weapon="MORTAR"
    elseif (meansOfDeath==58) then
        weapon="AKIMBO_COLT"
    elseif (meansOfDeath==59) then
        weapon="AKIMBO_LUGER"
    elseif (meansOfDeath==60) then
        weapon="AKIMBO_SILENCEDCOLT"
    elseif (meansOfDeath==61) then
        weapon="AKIMBO_SILENCEDLUGER"
    elseif (meansOfDeath==62) then
        weapon="SMOKEGRENADE"
    elseif (meansOfDeath==63) then
        weapon="SWAP_SPACES"
    elseif (meansOfDeath==64) then
        weapon="SWITCH_TEAM"
    end
end

function multikillProcess(dvtime, currentKillTable, lastKillTable, msg, sound, reset)
    currentKillTable[killer] = mtime

    if (currentKillTable[killer] - lastKillTable[killer]) <= dvtime then
        local str = string.gsub(msg, "#killer#", killername)
        et.trap_SendConsoleCommand(et.EXEC_APPEND, mk_location .. " " .. str .. "\n")

        if k_multikillsounds == 1 then
            if k_noisereduction == 1 then
                et.G_ClientSound(killer, sound)
            else
                et.G_globalSound(sound)
            end
        end

        if reset then
            multikill[killer] = 0
        end
    else
        multikill[killer] = 0
        multikill[killer] = multikill[killer] + 1
        lastKillTable[killer] = mtime
    end

    return currentKillTable, lastKillTable
end

function killingSpreeProcess(msg, sound)
    local str = string.gsub(msg, "#killer#", killername)
    local str = string.gsub(str, "#kills#", killingspree[killer])
    et.trap_SendConsoleCommand(et.EXEC_APPEND, ks_location .. " " .. str .. "\n")

    if k_spreesounds == 1 then
        if k_noisereduction == 1 then
            et.G_ClientSound(killer, sound)
        else
            et.G_globalSound(sound)
        end
    end
end

function kills(victim, killer, meansOfDeath, weapon)
    weapon = getMeansOfDeathName(meansOfDeath)

    local kil = tonumber(killer)
    local killername = ""

    victimname = et.Info_ValueForKey(et.trap_GetUserinfo(victim), "name")
    playerlastkilled[killer] = victim
    killedwithweapk[killer] = tostring(weapon)
    local victimteam = tonumber(et.gentity_get(victim, "sess.sessionTeam"))
    local killerteam = tonumber(et.gentity_get(killer, "sess.sessionTeam"))

    if killer == 1022 then
        killername = "The World"

        if k_sprees == 1 then
            if gibbed[victim] == 0 then
                if killingspree[victim] >= 5 then
                    local str = string.gsub(k_end_message3, "#victim#", victimname)
                    local str = string.gsub(str, "#kills#", killingspree[victim])
                    local str = string.gsub(str, "#killer#", killername)

                    et.trap_SendConsoleCommand(et.EXEC_APPEND, ks_location .. " " .. str .. "\n")
                    killingspree[victim]=0
                else
                    killingspree[victim]=0
                end
            else
                gibbed[victim] = 0
            end
        end

        if k_spreerecord == 1 then
            if killr[victim] > spreerecordkills then
                setSpreeRecord(victim, killr[victim])
            end

            if killr[victim] > mapspreerecordkills then
                setMapSpreeRecord(victim, killr[victim])
                killr[victim] = 0
            else
                killr[victim] = 0
            end
        end

        flakmonkey[victim]=0
    else
        killername=et.Info_ValueForKey(et.trap_GetUserinfo(killer), "name")
    end

    if killer ~= victim and k_sprees == 1 then
        deathspree[killer]=0
    end

    if Gamestate == 0 then
        if k_teamkillrestriction == 1 then
            if victimteam == killerteam and killer ~= victim and killer ~= 1022 then
                if getAdminLevel(killer) < k_tk_protect then
                    local warning = (k_tklimit_low + 1)
                    local pbkiller = killer + 1

                    if meansOfDeath == 17 or meansOfDeath == 43 or meansOfDeath == 44 or meansOfDeath == 4 or meansOfDeath == 18 or meansOfDeath == 57 or meansOfDeath == 30  or meansOfDeath == 27 or meansOfDeath == 49 or meansOfDeath == 3 then
                        teamkillr[killer] = teamkillr[killer] - 0.75
                    elseif meansOfDeath == 30  or meansOfDeath == 27 then
                        teamkillr[killer] = teamkillr[killer] - 0.65
                    elseif meansOfDeath == 45 then
                        -- Mines do nothing!
                    else
                        teamkillr[killer] = teamkillr[killer] - 1
                    end

                    if warning > teamkillr[killer] and k_tklimit_low < teamkillr[killer] then
                        if k_advancedpms == 1 then
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. killername .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                            et.G_ClientSound(killer, pmsound)
                        else
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. killername .. " ^1You are making to many teamkills please be more careful or you will be kicked!\n")
                        end
                    elseif teamkillr[killer] <= k_tklimit_low then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "pb_sv_kick " .. pbkiller .. " 10 Too many teamkills\n")
                    end
                end
            else
                if killer ~= victim then
                    if killer ~= 1022 then
                        teamkillr[killer] = teamkillr[killer] + 1

                        if teamkillr[killer] > k_tklimit_high then
                            teamkillr[killer] = k_tklimit_high
                        end
                    end
                end
            end
        end
    end

    if k_multikills == 1 then
        if killer ~= victim and victimteam ~= killerteam and killer ~= 1022 then
            local dvtime = (k_multikill_time * 1000)

            multikill[killer] = multikill[killer] + 1

            if multikill[killer] == 1 then
                kill1[killer] = mtime
            elseif multikill[killer] == 2 then
                kill2, kill1 = multikillProcess(dvtime, kill2, kill1, k_mk_message1, doublekillsound)
            elseif multikill[killer] == 3 then
                kill3, kill2 = multikillProcess(dvtime, kill3, kill2, k_mk_message2, multikillsound)
            elseif multikill[killer] == 4 then
                kill4, kill3 = multikillProcess(dvtime, kill4, kill3, k_mk_message3, megakillsound)
            elseif multikill[killer] == 5 then
                kill5, kill4 = multikillProcess(dvtime, kill5, kill4, k_mk_message4, ultrakillsound)
            elseif multikill[killer] == 6 then
                kill6, kill5 = multikillProcess(dvtime, kill6, kill5, k_mk_message5, monsterkillsound)
            elseif multikill[killer] == 7 then
                kill7, kill6 = multikillProcess(dvtime, kill7, kill6, k_mk_message6, ludicrouskillsound)
            elseif multikill[killer] == 8 then
                kill8, kill7 = multikillProcess(dvtime, kill8, kill7, k_mk_message7, holyshitsound, true)
            end
        else
            multikill[killer] = 0
        end
    end

    if killer ~= 1022 then
        if killer ~= victim and victimteam ~= killerteam then
            if k_spreerecord == 1 then
                killr[killer] = killr[killer] + 1
            end

            if k_sprees == 1 then
                killingspree[killer] = killingspree[killer] + 1

                if killingspree[killer] == k_spree1_amount then
                    killingSpreeProcess(k_ks_message1, killingspreesound)
                elseif killingspree[killer] == k_spree2_amount then
                    killingSpreeProcess(k_ks_message2, rampagesound)
                elseif killingspree[killer] == k_spree3_amount then
                    killingSpreeProcess(k_ks_message3, dominatingsound)
                elseif killingspree[killer] == k_spree4_amount then
                    killingSpreeProcess(k_ks_message4, unstopablesound)
                elseif killingspree[killer] == k_spree5_amount then
                    killingSpreeProcess(k_ks_message5, godlikesound)
                elseif killingspree[killer] == k_spree6_amount then
                    killingSpreeProcess(k_ks_message6, wickedsicksound)
                end

            end
        else
            if killingspree[killer] >= 5 then
                if killer == victim then
                    local str = string.gsub(k_end_message2, "#victim#", victimname)
                    local str = string.gsub(str, "#kills#", killingspree[victim])
                    local str = string.gsub(str, "#killer#", killername)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, ks_location .. " " .. str .. "\n")
                    killingspree[killer] = 0
                else
                    local str = string.gsub(k_end_message4, "#victim#", victimname)
                    local str = string.gsub(str, "#kills#", killingspree[killer])
                    local str = string.gsub(str, "#killer#", killername)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, ks_location .. " " .. str .. "\n")
                    killingspree[killer] = 0
                end
            else
                killingspree[killer] = 0
            end

            if k_spreerecord == 1 then
                if killr[victim] > spreerecordkills then
                    setSpreeRecord(victim, killr[victim])
                end

                if killr[victim] > mapspreerecordkills then
                    setMapSpreeRecord(victim, killr[victim])
                    killr[victim] = 0
                else
                    killr[victim] = 0
                end
            end
        end
    end

    if k_flakmonkey == 1 then
        if meansOfDeath == 17 or meansOfDeath == 43 or meansOfDeath == 44 then
            if killer ~= victim and victimteam ~= killerteam then
                flakmonkey[killer] = flakmonkey[killer] + 1

                if flakmonkey[killer] == 3 then
                    local str = string.gsub(k_fm_message, "#killer#", killername)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, fm_location .. " " .. str .. "\n")

                    if k_flakmonkeysound == 1 then
                        if k_noisereduction == 1 then
                            et.G_ClientSound(killer, flakmonkeysound)
                        else
                            et.G_globalSound(flakmonkeysound)
                        end
                    end

                    flakmonkey[killer] = 0
                end

            else
                flakmonkey[killer] = 0
            end
        else
            flakmonkey[killer] = 0
        end
    end
end

function deathSpreeProcess(msg, sound)
    local str = string.gsub(msg, "#victim#", killedname)
    local str = string.gsub(str, "#deaths#", deathspree[victim])
    et.trap_SendConsoleCommand(et.EXEC_APPEND, ds_location .. " " .. str .. "\n" )

    if k_deathspreesounds == 1 then
        if k_noisereduction == 1 then
            et.G_ClientSound(victim, sound)
        else
            et.G_globalSound(sound)
        end
    end
end

function deaths(victim, killer, meansOfDeath, weapon)
    weapon = getMeansOfDeathName(meansOfDeath)

    local kil = tonumber(killer)
    local killername = ""

    if killer == 1022 then
        killername = "The World"
    else
        killername = et.Info_ValueForKey(et.trap_GetUserinfo(killer), "name")
    end

    playerwhokilled[victim] = killer
    killedwithweapv[victim] = tostring(weapon)

    local victimteam = tonumber(et.gentity_get(victim, "sess.sessionTeam"))
    local killerteam = tonumber(et.gentity_get(killer, "sess.sessionTeam"))
    local killedname = et.Info_ValueForKey(et.trap_GetUserinfo( victim ), "name")

    if k_spreerecord == 1 then
        if killr[victim] > spreerecordkills then
            setSpreeRecord(victim, killr[victim])
        end

        if killr[victim] > mapspreerecordkills then
            setMapSpreeRecord(victim, killr[victim])
            killr[victim] = 0
        else
            killr[victim] = 0
        end
    end

    if k_deathsprees == 1 then
        deathspree[victim] = deathspree[victim] + 1
    end

    if k_sprees == 1 then
        if killingspree[victim] >= 5 then
            local str = string.gsub(k_end_message1, "#victim#", killedname)
            local str = string.gsub(str, "#kills#", killingspree[victim])
            local str = string.gsub(str, "#killer#", killername)

            et.trap_SendConsoleCommand(et.EXEC_APPEND, ks_location .. " " .. str .. "\n")
            killingspree[victim] = 0
        else
            killingspree[victim] = 0
        end
    end

    flakmonkey[victim] = 0

    if k_deathsprees == 1 then
        if deathspree[victim] == k_deathspree1_amount then
            deathSpreeProcess(k_ds_message1, deathspreesound1)
        elseif deathspree[victim] == k_deathspree2_amount then
            deathSpreeProcess(k_ds_message2, deathspreesound2)
        elseif deathspree[victim] == k_deathspree3_amount then
            deathSpreeProcess(k_ds_message3, deathspreesound3)
        end
    end
end

-- et_ClientSay

function curseFilter(PlayerID)
    local k_cursemode = tonumber(et.trap_Cvar_Get("k_cursemode"))
    local name = et.gentity_get(PlayerID, "pers.netname")
    local ref = tonumber(et.gentity_get(PlayerID, "sess.referee"))

    if (k_cursemode - 32) >= 0 then
        -- Override kill and slap
        if (k_cursemode - 32) > 7 then
            k_cursemode = 7
        else
            k_cursemode = k_cursemode - 32
        end

        if et.gentity_get(PlayerID, "pers.connected") == 2 then
            local team = et.gentity_get(clientNum, "sess.sessionTeam")

            if team > 0 or team < 4 then
                params.client = PlayerID
                params.commandSaid = commandSaid
                params.say = say_parms
                dofile(kmod_ng_path .. '/kmod/command/gib.lua')
                execute_command(params)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto gibbed for language!\n")
            end
        end
    end

    if (k_cursemode - 16) >= 0 then
        -- Override slap
        if (k_cursemode - 16) > 7 then
            k_cursemode = 7
        else
            k_cursemode = k_cursemode - 16
        end

        if et.gentity_get(PlayerID, "pers.connected") == 2 then
            local team = et.gentity_get(clientNum, "sess.sessionTeam")

            if team > 0 or team < 4 then
                et.gentity_get(PlayerID, "health", -1)
                et.trap_SendConsoleCommand( et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto killed for language!\n" )
            end
        end
    end

    if (k_cursemode - 8) >= 0 then
        k_cursemode = k_cursemode - 16

        if et.gentity_get(PlayerID, "pers.connected") == 2 then
            local team = tonumber(et.gentity_get(PlayerID, "sess.sessionTeam"))

            if sessionTeam > 0 or sessionTeam < 4 then
                params.client = et.PlayerID
                params.commandSaid = commandSaid
                params.say = say_parms
                dofile(kmod_ng_path .. '/kmod/command/burn.lua')
                execute_command(params)
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto slapped for language!\n")
            end
        end
    end

    if (k_cursemode - 4) >= 0 then
        -- Override kill and slap
        if (k_cursemode - 4) > 0 then
            k_cursemode = 0
        end

        if ref == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. PlayerID .. "\n")
            local mute = "-1"
            muted[PlayerID] = -1
            setMute(PlayerID, mute)
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been permanently muted for language!\n")
        end
    end

    if (k_cursemode - 2) >= 0 then
        -- Override kill and slap
        if (k_cursemode - 2) > 0 then
            k_cursemode = 0
        end

        --Mute time starts at one then doubles each time thereafter
        if ref == 0 then
            if nummutes[PlayerID] == 0 then
                nummutes[PlayerID] = 1
                muted[PlayerID] = mtime + (1 * 60 * 1000)
            else
                nummutes[PlayerID] = nummutes[PlayerID] + nummutes[PlayerID]
                muted[PlayerID] = mtime + (nummutes[PlayerID] * 60 * 1000)
            end

            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. PlayerID .. "\n" )
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted for ^1" .. nummutes[PlayerID] .. "^7 minute(s)!\n")
        end
    end

    if k_cursemode == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. PlayerID .. "\n" )
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .. " ^7has been auto muted!\n")
    end
end

function ClientUserCommand(PlayerID, Command, BangCommand, Cvar1, Cvar2, Cvarct)
    params = {}
    params.command   = 'client'
    params.nbArg     = Cvarct
    params.clientNum = PlayerID
    params["arg1"]   = Cvar1
    params["arg2"]   = Cvar2

    params.commandSaid = true
    params.say = say_parms

    local admin_req = k_maxAdminLevels + 1
    local fd,len = et.trap_FS_FOpenFile("commands.cfg", et.FS_READ)
    local lowBangCmd = string.lower(BangCommand)

    if len > 0 then
        local filestr = et.trap_FS_Read(fd, len)

        for level,comm,str in string.gfind(filestr, "[^%#](%d)%s*%-%s*([%w%_]*)%s*%=%s*([^%\n]*)") do
            local strnumber = splitWord(str)

            local comm2 = k_commandprefix .. comm
            local t = tonumber(et.gentity_get(PlayerID, "sess.sessionTeam"))
            local c = tonumber(et.gentity_get(PlayerID, "sess.latchPlayerType"))
            local player_last_victim_name = ""
            local player_last_killer_name = ""
            local player_last_victim_cname = ""
            local player_last_killer_cname = ""

            if playerlastkilled[PlayerID] == 1022 then
                player_last_victim_name = "NO ONE"
                player_last_victim_cname = "NO ONE"
            else
                player_last_victim_name = et.Q_CleanStr(et.gentity_get(playerlastkilled[PlayerID], "pers.netname"))
                player_last_victim_cname = et.gentity_get(playerlastkilled[PlayerID], "pers.netname")
            end

            if playerwhokilled[PlayerID] == 1022 then
                player_last_killer_name = "NO ONE"
                player_last_killer_cname = "NO ONE"
            else
                player_last_killer_name = et.Q_CleanStr(et.gentity_get(playerwhokilled[PlayerID], "pers.netname"))
                player_last_killer_cname = et.gentity_get(playerwhokilled[PlayerID], "pers.netname")
            end

            local pnameID = part2id(Cvar1)

            if not pnameID then
                pnameID = 1021
            end

            local PBpnameID = pnameID + 1
            local PBID = PlayerID + 1

            local randomC = randomClientFinder()
            local randomTeam = team[tonumber(et.gentity_get(randomC, "sess.sessionTeam"))]
            local randomCName = et.gentity_get(randomC, "pers.netname")
            local randomName = et.Q_CleanStr(et.gentity_get(randomC, "pers.netname"))
            local randomClass = class[tonumber(et.gentity_get(randomC, "sess.latchPlayerType"))]

            local str = string.gsub(str, "<CLIENT_ID>", PlayerID)
            local str = string.gsub(str, "<GUID>", et.Info_ValueForKey(et.trap_GetUserinfo(PlayerID), "cl_guid"))
            local str = string.gsub(str, "<COLOR_PLAYER>", et.gentity_get(PlayerID, "pers.netname"))
            local str = string.gsub(str, "<ADMINLEVEL>", getAdminLevel(PlayerID))
            local str = string.gsub(str, "<PLAYER>", et.Q_CleanStr(et.gentity_get(PlayerID, "pers.netname")))
            local str = string.gsub(str, "<PLAYER_CLASS>", class[c])
            local str = string.gsub(str, "<PLAYER_TEAM>", team[t])
            local str = string.gsub(str, "<PARAMETER>", Cvar1 .. Cvar2)
            local str = string.gsub(str, "<PLAYER_LAST_KILLER_ID>", playerwhokilled[PlayerID])
            local str = string.gsub(str, "<PLAYER_LAST_KILLER_NAME>", player_last_killer_name)
            local str = string.gsub(str, "<PLAYER_LAST_KILLER_CNAME>", player_last_killer_cname)
            local str = string.gsub(str, "<PLAYER_LAST_KILLER_WEAPON>", killedwithweapv[PlayerID])
            local str = string.gsub(str, "<PLAYER_LAST_VICTIM_ID>", playerlastkilled[PlayerID])
            local str = string.gsub(str, "<PLAYER_LAST_VICTIM_NAME>", player_last_victim_name)
            local str = string.gsub(str, "<PLAYER_LAST_VICTIM_CNAME>", player_last_victim_cname)
            local str = string.gsub(str, "<PLAYER_LAST_VICTIM_WEAPON>", killedwithweapk[PlayerID])
            local str = string.gsub(str, "<PNAME2ID>", pnameID)
            local str = string.gsub(str, "<PBPNAME2ID>", PBpnameID)
            local str = string.gsub(str, "<PB_ID>", PBID)
            local str = string.gsub(str, "<RANDOM_ID>", randomC)
            local str = string.gsub(str, "<RANDOM_CNAME>", randomCName)
            local str = string.gsub(str, "<RANDOM_NAME>", randomName)
            local str = string.gsub(str, "<RANDOM_CLASS>", randomClass)
            local str = string.gsub(str, "<RANDOM_TEAM>", randomTeam)
            local teamnumber = tonumber(et.gentity_get(PlayerID, "sess.sessionTeam"))
            local classnumber = tonumber(et.gentity_get(PlayerID, "sess.latchPlayerType"))


            if lowBangCmd == comm2 then
                if tonumber(level) <= getAdminLevel(PlayerID) then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, str .. "\n")

                    if strnumber[1] == "forcecvar" then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^3etpro svcmd: ^7forcing client cvar [" .. strnumber[2] .. "] to [" .. Cvar1 .. "]\n")
                    end
                else
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, say_parms .. " ^7Insufficient Admin status\n")
                end
            end
        end
    end

    et.trap_FS_FCloseFile(fd)


    for i = 0, k_maxAdminLevels, 1 do
        for q = 1, lvlsc[i], 1 do
            if lvls[i][q] == BangCommand then
                admin_req = i
                break
            end
        end
    end

    if getAdminLevel(PlayerID) >= admin_req then
        if lowBangCmd == k_commandprefix .. "time" then
            dofile(kmod_ng_path .. '/kmod/command/time.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "date" then
            dofile(kmod_ng_path .. '/kmod/command/date.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix.."spree_record" then
            dofile(kmod_ng_path .. '/kmod/command/client/spree_record.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "spec999" then
            dofile(kmod_ng_path .. '/kmod/command/both/spec999.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "tk_index" then
            dofile(kmod_ng_path .. '/kmod/command/client/tk_index.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "listcmds" then
            dofile(kmod_ng_path .. '/kmod/command/client/listcmds.lua')
            execute_command(params)
        end

        if lowBangCmd == k_commandprefix .. "gib" then
            dofile(kmod_ng_path .. '/kmod/command/both/gib.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "slap" then
            dofile(kmod_ng_path .. '/kmod/command/both/slap.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "setlevel" then
            dofile(kmod_ng_path .. '/kmod/command/both/setlevel.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "readconfig" then
            dofile(kmod_ng_path .. '/kmod/command/both/readconfig.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "spree_restart" then
            dofile(kmod_ng_path .. '/kmod/command/both/spree_restart.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "ban" then
            dofile(kmod_ng_path .. '/kmod/command/client/ban.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "getip" then
            dofile(kmod_ng_path .. '/kmod/command/client/getip.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "getguid" then
            dofile(kmod_ng_path .. '/kmod/command/client/getguid.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "makeshoutcaster" then
            dofile(kmod_ng_path .. '/kmod/command/client/makeshoutcaster.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "removeshoutcaster" then
            dofile(kmod_ng_path .. '/kmod/command/client/removeshoutcaster.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "makereferee" then
            dofile(kmod_ng_path .. '/kmod/command/client/makereferee.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "removereferee" then
            dofile(kmod_ng_path .. '/kmod/command/client/removereferee.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "gravity" then
            dofile(kmod_ng_path .. '/kmod/command/client/gravity.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "knifeonly" then
            dofile(kmod_ng_path .. '/kmod/command/client/knifeonly.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "speed" then
            dofile(kmod_ng_path .. '/kmod/command/client/speed.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "knockback" then
            dofile(kmod_ng_path .. '/kmod/command/client/knockback.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "cheats" then
            dofile(kmod_ng_path .. '/kmod/command/both/cheats.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "laser" then
            dofile(kmod_ng_path .. '/kmod/command/both/laser.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "crazygravity" then
            dofile(kmod_ng_path .. '/kmod/command/both/crazygravity.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "panzerwar" then
            dofile(kmod_ng_path .. '/kmod/command/both/panzerwar.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "frenzy" then
            dofile(kmod_ng_path .. '/kmod/command/both/frenzy.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "grenadewar" then
            dofile(kmod_ng_path .. '/kmod/command/both/grenadewar.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "sniperwar" then
            dofile(kmod_ng_path .. '/kmod/command/both/sniperwar.lua')
            execute_command(params)
        end

        if lowBangCmd == k_commandprefix .. "kick" then
            dofile(kmod_ng_path .. '/kmod/command/client/kick.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "warn" then
            dofile(kmod_ng_path .. '/kmod/command/client/warn.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "mute" then
            dofile(kmod_ng_path .. '/kmod/command/client/mute.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "pmute" then
            dofile(kmod_ng_path .. '/kmod/command/client/pmute.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "putspec" then
            dofile(kmod_ng_path .. '/kmod/command/client/putspec.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "putallies" then
            dofile(kmod_ng_path .. '/kmod/command/client/putallies.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "putaxis" then
            dofile(kmod_ng_path .. '/kmod/command/client/putaxis.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "timelimit" then
            dofile(kmod_ng_path .. '/kmod/command/client/timelimit.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "unmute" then
            dofile(kmod_ng_path .. '/kmod/command/client/unmute.lua')
            execute_command(params)
        elseif lowBangCmd == k_commandprefix .. "finger" then
            dofile(kmod_ng_path .. '/kmod/command/client/finger.lua')
            execute_command(params)
        end
    end
end

-- Enemy Territory callbacks

-- qagame execution

-- Called when qagame initializes.
--  levelTime is the current level time in milliseconds.
--  randomSeed is a number that can be used to seed random number generators.
--  restart indicates if et_InitGame() is being called due to a map restart (1) or not (0).
function et_InitGame(levelTime, randomSeed, restart)
    k_maxAdminLevels = tonumber(et.trap_Cvar_Get("k_maxAdminLevels"))
    initTime = levelTime

    loadAdmins()
    loadSpreeRecord()
    loadMapSpreeRecord()
    loadMutes()

    local currentver = et.trap_Cvar_Get("mod_version")
    et.RegisterModname("KMOD version " .. KMODversion .. " " .. et.FindSelf())
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forcecvar mod_version \"" .. currentver .. " - KMOD" .. KMODversion2 .. "\"\n")

    k_panzersperteam = tonumber(et.trap_Cvar_Get("team_maxpanzers"))

    for i = 0, tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1, 1 do
        killingspree[i] = 0
        flakmonkey[i] = 0
        deathspree[i] = 0
        multikill[i] = 0
        muted[i] = 0
        nummutes[i] = 0
        antiloopadr1[i] = 0
        antiloopadr2[i] = 0
        adrenaline[i] = 0
        adrnum[i] = 0
        adrnum2[i] = 0
        adrtime[i] = 0
        adrtime2[i] = 0
        adrendummy[i] = 0
        clientrespawn[i] = 0
        invincDummy[i] = 0
        switchteam[i] = 0
        gibbed[i] = 0

        playerwhokilled[i] = 1022
        killedwithweapk[i] = ""
        killedwithweapv[i] = ""
        playerlastkilled[i] = 1022
        selfkills[i] = 0
        teamkillr[i] = 0
        khp[i] = 0
        AdminName[i] = ""
        originalclass[i] = ""
        originalweap[i] = ""

        killr[i] = 0
    end

    readConfig()

    et.G_Print("KMOD version " .. KMODversion .. " has been initialized...\n")
end

-- Called when qagame shuts down.
--  restart indicates if the shutdown is being called due to a map_restart (1) or not (0).
function et_ShutdownGame(restart)
    if panzdv == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; g_speed " .. speed .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")
    elseif frenzdv == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")
    elseif grendv == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")
    elseif snipdv == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxmedics " .. medics .. " ; team_maxcovertops " .. cvops .. " ; team_maxfieldops " .. fops .. " ; team_maxengineers " .. engie .. " ; team_maxflamers " .. flamers .. " ; team_maxmortars " .. mortars .. " ; team_maxmg42s " .. mg42s .. " ; team_maxpanzers " .. panzers .. " ; forcecvar g_soldierchargetime " .. soldcharge .. "\n")
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers " .. k_panzersperteam .. "\n")

    if panzdv == 1 then
        for p = 0, tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1, 1 do
            local team = et.gentity_get(p, "sess.sessionTeam")

            if team == 1 or team == 2 then
                et.gentity_set(p, "sess.latchPlayerType", originalclass[p])
                et.gentity_set(p, "sess.latchPlayerWeapon", originalweap[p])
            end
        end
    end

    if k_logchat == 1 then
        logChat("DV", "START", "DV")
    end

    for i = 0, tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1, 1 do
        if et.gentity_get(i, "pers.connected") == 2 then
            if muted[i] > 0 then
                local muteDur = (muted[i] - mtime) / 1000
                setMute(i, muteDur)
            elseif muted[i] == 0 then
                IP = et.Info_ValueForKey(et.trap_GetUserinfo(i), "ip")
                s, e, IP = string.find(IP, "(%d+%.%d+%.%d+%.%d+)")

                if muteDuration[IP] ~= 0 then
                    local muteDur = 0
                    setMute(i, muteDur)
                end
            end
        end
    end
end

-- Called when qagame runs a server frame.
--  levelTime is the current level time in milliseconds.
function et_RunFrame(levelTime)
    mtime = tonumber(levelTime) -- still cannot remember why i made this but its used in alot of stuff so i'll leave it

    local clientsLimit = tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1

    if run_once == 0 then
        k_panzersperteam2 = tonumber(et.trap_Cvar_Get("team_maxpanzers"))
        run_once = 1
    end

    if timedvs == 0 then
        local ktime = (((mtime - initTime) / 1000))
        timecounter = ktime
        timedvs = 1
    end

    timelimit = tonumber(et.trap_Cvar_Get("timelimit"))
    Gamestate = tonumber(et.trap_Cvar_Get("gamestate"))

    if GAMEPAUSED == 1 then
        if pausedv == 0 then
            pausetime = mtime
            pausedv = 1
        end

        -- Server is paused for 3 minutes (180 seconds)
        if ((mtime - pausetime) / 1000) >= 180 then
            GAMEPAUSED = 0
        end
    elseif GAMEPAUSED == 0 and pausedv == 1 then
        if pausedv2 == 0 then
            pausetime = mtime
            pausedv2 = 1
        end

        -- when unpaused before 3 minutes is up it counts down from 10 seconds
        if ((mtime - pausetime) / 1000) >= 10 then
            pausedv = 0
            pausedv2 = 0
            timedv1 = nil
            timed=v2 = nil
        end
    else
        if timedv == 0 then
            timedv1 = mtime
            timedv = 1
            if type(timedv2) ~= "nil" then
                timecounter = timecounter + ((timedv1 - timedv2) / 1000)
                s, e, thous = string.find(timecounter, "%d*%.%d%d(%d*)")
                if thous == 9999999 then
                    timecounter = timecounter + 0.000000001
                end
            end
        else
            timedv2 = mtime
            timedv = 0
            timecounter = timecounter + ((timedv2 - timedv1) / 1000)
            s, e, thous = string.find(timecounter, "%d*%.%d%d(%d*)")

            if thous == 9999999 then
                timecounter=timecounter + 0.000000001
            end
        end
    end

    killingspreesound = tostring(et.trap_Cvar_Get("killingspreesound"))
    k_color = tostring(et.trap_Cvar_Get("k_color"))
    rampagesound = tostring(et.trap_Cvar_Get("rampagesound"))
    dominatingsound = tostring(et.trap_Cvar_Get("dominatingsound"))
    unstopablesound = tostring(et.trap_Cvar_Get("unstopablesound"))
    godlikesound = tostring(et.trap_Cvar_Get("godlikesound"))
    wickedsicksound = tostring(et.trap_Cvar_Get("wickedsicksound"))
    flakmonkeysound = tostring(et.trap_Cvar_Get("flakmonkeysound"))
    firstbloodsound = tostring(et.trap_Cvar_Get("firstbloodsound"))
    deathspreesound1 = tostring(et.trap_Cvar_Get("deathspreesound1"))
    deathspreesound2 = tostring(et.trap_Cvar_Get("deathspreesound2"))
    deathspreesound3 = tostring(et.trap_Cvar_Get("deathspreesound3"))
    doublekillsound = tostring(et.trap_Cvar_Get("doublekillsound"))
    multikillsound = tostring(et.trap_Cvar_Get("multikillsound"))
    megakillsound = tostring(et.trap_Cvar_Get("megakillsound"))
    ultrakillsound = tostring(et.trap_Cvar_Get("ultrakillsound"))
    monsterkillsound = tostring(et.trap_Cvar_Get("monsterkillsound"))
    ludicrouskillsound = tostring(et.trap_Cvar_Get("ludicrouskillsound"))
    holyshitsound = tostring(et.trap_Cvar_Get("holyshitsound"))
    k_ds_message1 = tostring(et.trap_Cvar_Get("k_ds_message1"))
    k_ds_message2 = tostring(et.trap_Cvar_Get("k_ds_message2"))
    k_ds_message3 = tostring(et.trap_Cvar_Get("k_ds_message3"))
    k_ks_message1 = tostring(et.trap_Cvar_Get("k_ks_message1"))
    k_ks_message2 = tostring(et.trap_Cvar_Get("k_ks_message2"))
    k_ks_message3 = tostring(et.trap_Cvar_Get("k_ks_message3"))
    k_ks_message4 = tostring(et.trap_Cvar_Get("k_ks_message4"))
    k_ks_message5 = tostring(et.trap_Cvar_Get("k_ks_message5"))
    k_ks_message6 = tostring(et.trap_Cvar_Get("k_ks_message6"))
    k_mk_message1 = tostring(et.trap_Cvar_Get("k_mk_message1"))
    k_mk_message2 = tostring(et.trap_Cvar_Get("k_mk_message2"))
    k_mk_message3 = tostring(et.trap_Cvar_Get("k_mk_message3"))
    k_mk_message4 = tostring(et.trap_Cvar_Get("k_mk_message4"))
    k_mk_message5 = tostring(et.trap_Cvar_Get("k_mk_message5"))
    k_mk_message6 = tostring(et.trap_Cvar_Get("k_mk_message6"))
    k_mk_message7 = tostring(et.trap_Cvar_Get("k_mk_message7"))
    k_fm_message = tostring(et.trap_Cvar_Get("k_fm_message"))
    k_end_message1 = tostring(et.trap_Cvar_Get("k_end_message1"))
    k_end_message2 = tostring(et.trap_Cvar_Get("k_end_message2"))
    k_end_message3 = tostring(et.trap_Cvar_Get("k_end_message3"))
    k_end_message4 = tostring(et.trap_Cvar_Get("k_end_message4"))
    k_fb_message = tostring(et.trap_Cvar_Get("k_fb_message"))
    k_lb_message = tostring(et.trap_Cvar_Get("k_lb_message"))
    k_autopanzerdisable = tonumber(et.trap_Cvar_Get("k_autopanzerdisable"))
    k_panzerplayerlimit = tonumber(et.trap_Cvar_Get("k_panzerplayerlimit"))
    k_panzersperteam = tonumber(et.trap_Cvar_Get("k_panzersperteam"))
    k_spreesounds = tonumber(et.trap_Cvar_Get("k_spreesounds"))
    k_sprees = tonumber(et.trap_Cvar_Get("k_sprees"))
    k_multikillsounds = tonumber(et.trap_Cvar_Get("k_multikillsounds"))
    k_multikills = tonumber(et.trap_Cvar_Get("k_multikills"))
    k_flakmonkeysound = tonumber(et.trap_Cvar_Get("k_flakmonkeysound"))
    k_flakmonkey = tonumber(et.trap_Cvar_Get("k_flakmonkey"))
    k_firstbloodsound = tonumber(et.trap_Cvar_Get("k_firstbloodsound"))
    k_firstblood = tonumber(et.trap_Cvar_Get("k_firstblood"))
    k_lastblood = tonumber(et.trap_Cvar_Get("k_lastblood"))
    k_killerhpdisplay = tonumber(et.trap_Cvar_Get("k_killerhpdisplay"))
    k_deathsprees = tonumber(et.trap_Cvar_Get("k_deathsprees"))
    k_deathspreesounds = tonumber(et.trap_Cvar_Get("k_deathspreesounds"))
    k_spreerecord = tonumber(et.trap_Cvar_Get("k_spreerecord"))
    k_advplayers = tonumber(et.trap_Cvar_Get("k_advplayers"))
    k_crazygravityinterval = tonumber(et.trap_Cvar_Get("k_crazygravityinterval"))
    k_teamkillrestriction = tonumber(et.trap_Cvar_Get("k_teamkillrestriction"))
    k_tklimit_high = tonumber(et.trap_Cvar_Get("k_tklimit_high"))
    k_tklimit_low = tonumber(et.trap_Cvar_Get("k_tklimit_low"))
    k_tk_protect = tonumber(et.trap_Cvar_Get("k_tk_protect"))
    k_slashkilllimit = tonumber(et.trap_Cvar_Get("k_slashkilllimit"))
    k_slashkills = tonumber(et.trap_Cvar_Get("k_slashkills"))
    k_endroundshuffle = tonumber(et.trap_Cvar_Get("k_endroundshuffle"))
    k_noisereduction = tonumber(et.trap_Cvar_Get("k_noisereduction"))
    k_advancedpms = tonumber(et.trap_Cvar_Get("k_advancedpms"))
    k_logchat = tonumber(et.trap_Cvar_Get("k_logchat"))
    k_disablevotes = tonumber(et.trap_Cvar_Get("k_disablevotes"))
    k_dvmode = tonumber(et.trap_Cvar_Get("k_dvmode"))
    k_dvtime = tonumber(et.trap_Cvar_Get("k_dvtime"))
    k_adrensound = tonumber(et.trap_Cvar_Get("k_adrensound"))
    k_advancedadrenaline = tonumber(et.trap_Cvar_Get("k_advancedadrenaline"))
    k_antiunmute = tonumber(et.trap_Cvar_Get("k_antiunmute"))
    k_advancedspawn = tonumber(et.trap_Cvar_Get("k_advancedspawn"))
    k_deathspree1_amount = tonumber(et.trap_Cvar_Get("k_deathspree1_amount"))
    k_deathspree2_amount = tonumber(et.trap_Cvar_Get("k_deathspree2_amount"))
    k_deathspree3_amount = tonumber(et.trap_Cvar_Get("k_deathspree3_amount"))
    k_spree1_amount = tonumber(et.trap_Cvar_Get("k_spree1_amount"))
    k_spree2_amount = tonumber(et.trap_Cvar_Get("k_spree2_amount"))
    k_spree3_amount = tonumber(et.trap_Cvar_Get("k_spree3_amount"))
    k_spree4_amount = tonumber(et.trap_Cvar_Get("k_spree4_amount"))
    k_spree5_amount = tonumber(et.trap_Cvar_Get("k_spree5_amount"))
    k_spree6_amount = tonumber(et.trap_Cvar_Get("k_spree6_amount"))
    k_multikill_time = tonumber(et.trap_Cvar_Get("k_multikill_time"))
    k_ds_location = tonumber(et.trap_Cvar_Get("k_ds_location"))
    k_ks_location = tonumber(et.trap_Cvar_Get("k_ks_location"))
    k_mk_location = tonumber(et.trap_Cvar_Get("k_mk_location"))
    k_fm_location = tonumber(et.trap_Cvar_Get("k_fm_location"))
    k_fb_location = tonumber(et.trap_Cvar_Get("k_fb_location"))
    k_lb_location = tonumber(et.trap_Cvar_Get("k_lb_location"))

    ds_location = getMessageLocation(k_ds_location)
    ks_location = getMessageLocation(k_ks_location)
    mk_location = getMessageLocation(k_mk_location)
    fm_location = getMessageLocation(k_fm_location)
    fb_location = getMessageLocation(k_fb_location)
    lb_location = getMessageLocation(k_lb_location)

    -- g_inactivity is required or this will not work
    if k_advancedspawn == 1 and tonumber(et.trap_Cvar_Get("g_inactivity")) > 0 then
        for i = 0, clientsLimit, 1 do
            if switchteam[i] == 1 then
                et.gentity_set(i, "ps.powerups", 1, 0)
            end

            switchteam[i] = 0
        end

        for i = 0, clientsLimit, 1 do
            if clientrespawn[i] == 1 then
                if (switchteam[i] == 0 and et.gentity_get(i, "ps.powerups", 1) > 0) then
                    if invincDummy[i] == 0 then
                        invincStart[i] = tonumber(et.gentity_get(i, "client.inactivityTime"))
                        invincDummy[i] = 1
                    end

                    local inactivity = tonumber(et.gentity_get(i, "client.inactivityTime"))

                    if inactivity == invincStart[i] then
                        local timer = mtime + 3000
                        et.gentity_set(i, "ps.powerups", 1, timer)
                    else
                        clientrespawn[i] = 0
                        invincDummy[i] = 0
                    end
                else
                    clientrespawn[i] = 0
                    invincDummy[i] = 0
                end
            end
        end
    end

    if panzdv == 1 or frenzdv == 1 or grendv == 1 or snipdv == 1 then
        if timedelay_antiloop == 0 then
            refreshrate = mtime
            timedelay_antiloop = 1
        end

        -- reset ammo and stuff every 0.25 of a second rather than 0.05 of a second (which caused lag)
        if ((mtime-refreshrate) / 1000) >= 0.25 then
            egamemodes = 1
            timedelay_antiloop = 0
        else
            egamemodes = 0
        end
    else
        egamemodes = 0
    end

    if tonumber(et.trap_Cvar_Get("g_spectatorInactivity")) > 0 then
        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 1 then
                local team = et.gentity_get(i, "sess.sessionTeam")

                if team >= 3 or team < 1 then
                    et.gentity_set(i, "client.inactivityTime", mtime)
                    et.gentity_set(i, "client.inactivityWarning", 1)
                end
            end
        end
    end

    if panzdv == 1 then
        if egamemodes == 1 then
            for q = 0, clientsLimit, 1 do
                et.gentity_set(q, "sess.latchPlayerWeapon", 5)
                setWeaponAmmo(pweapons, q)
            end
        end
    elseif frenzdv == 1 then
        if egamemodes == 1 then
            for w = 0, clientsLimit, 1 do
                setWeaponAmmo(fweapons, w)
            end
        end
    elseif grendv == 1 then
        if egamemodes == 1 then
            for e = 0, clientsLimit, 1 do
                setWeaponAmmo(gweapons, e)
            end
        end
    elseif snipdv == 1 then
        if egamemodes == 1 then
            for r = 0, clientsLimit, 1 do
                if tonumber(et.gentity_get(r, "sess.latchPlayerType")) ~= 4 then
                    et.gentity_set(r, "sess.latchPlayerType", 4)
                end

                local latchPlayerWeapon = tonumber(et.gentity_get(r, "sess.latchPlayerWeapon"))

                if latchPlayerWeapon ~= 32 or latchPlayerWeapon ~= 25 or latchPlayerWeapon ~= 42 or latchPlayerWeapon ~= 43 then
                    if latchPlayerWeapon ~= 33 then
                        local team = tonumber(et.gentity_get(r, "sess.sessionTeam"))

                        if team == 1 then
                            et.gentity_set(r, "sess.latchPlayerWeapon", 32)
                        elseif team == 2 then
                            et.gentity_set(r, "sess.latchPlayerWeapon", 25)
                        end
                    end
                end

                setWeaponAmmo(sweapons, r)
            end
        end
    else
        panzers = tonumber(et.trap_Cvar_Get("team_maxpanzers"))
        medics = tonumber(et.trap_Cvar_Get("team_maxmedics"))
        cvops = tonumber(et.trap_Cvar_Get("team_maxcovertops"))
        fops = tonumber(et.trap_Cvar_Get("team_maxfieldops"))
        engie = tonumber(et.trap_Cvar_Get("team_maxengineers"))
        flamers = tonumber(et.trap_Cvar_Get("team_maxflamers"))
        mortars = tonumber(et.trap_Cvar_Get("team_maxmortars"))
        mg42s = tonumber(et.trap_Cvar_Get("team_maxmg42s"))
        soldcharge = tonumber(et.trap_Cvar_Get("g_soldierchargetime"))
        speed = tonumber(et.trap_Cvar_Get("g_speed"))
    end

    if crazygravity then
        CGactive = 1
        crazygravity_gravity = math.random(10, 1200)

        if crazydv == 1 then
            crazytime = mtime + (k_crazygravityinterval * 1000)
            crazydv = 0
        end

        if (crazytime - mtime) / 1000 == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Crazygravity: ^7The gravity has been changed to ^1" .. crazygravity_gravity .. "^7!\n")
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "g_gravity " .. crazygravity_gravity .. "\n")
            crazydv = 1
        elseif (crazytime-mtime) / 1000 == 5 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Crazygravity: ^7The gravity will be changed in ^15^7 seconds!\n")
        end
    end

    local ftime = ((mtime - initTime) / 1000)

    for i = 0, clientsLimit, 1 do
        PlayerName[i] = et.gentity_get(i, "pers.netname")

        if not PlayerName[i] then
            PlayerName[i] = ""
        end

        if not Bname[i] then
            Bname[i] = ""
        end

        if et.gentity_get(i, "pers.connected") ~= 2 then
            PlayerName[i] = ""
            Bname[i] = ""
        end
    end

    if Gamestate == 3 then
        if k_lastblood == 1 and antiloop == 0 then
            if lastblood then
                local str = string.gsub(k_lb_message, "#killer#", lastblood)

                et.trap_SendConsoleCommand( et.EXEC_APPEND, lb_location .. " " .. str .. "\n")
            end

            for i = 0, clientsLimit, 1 do
                local name = et.gentity_get(i, "pers.netname")

                if killingspree[i] >= 5 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^7" .. name .. "^1's Killing spree was ended! Due to Map's end.\n")
                end

                killingspree[i] = 0
            end

            if k_spreerecord == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^" .. k_color .. tostring(intmrecord) .. "\n")
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^" .. k_color .. tostring(intmMaprecord) .. "\n")
            end

            antiloop = 1
        end

        if k_endroundshuffle == 1 and antiloopes == 0 then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref shuffleteamsxp_norestart\n")
            antiloopes = 1
        end

        if (panzdv == 1 or snipdv == 1) and antilooppw == 0 then
            for p = 0, clientsLimit, 1 do
                local team = et.gentity_get(p, "sess.sessionTeam")

                if team == 1 or team == 2 then
                    et.gentity_set(p, "sess.latchPlayerType", originalclass[p])
                    et.gentity_set(p, "sess.latchPlayerWeapon", originalweap[p])
                end
            end
            antilooppw = 1
        end
    end

    if k_advancedpms == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 0\n")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 2\n")
    end

    if k_sprees == 0 then
        if antiloop2 == 0 then
            killingSpreeReset()
        end

        antiloop2 = 1
    elseif k_sprees == 1 then
        antiloop2 = 0
    end

    if k_deathsprees == 0 then
        if antiloop3 == 0 then
            deathSpreeReset()
        end

        antiloop3 = 1
    elseif k_deathsprees == 1 then
        antiloop3 = 0
    end

    if k_flakmonkey == 0 then
        if antiloop4 == 0 then
            flakMonkeyReset()
        end

        antiloop4 = 1
    elseif k_flakmonkey == 1 then
        antiloop4 = 0
    end

    if floodprotect == 1 then
        fpPtime = (mtime - fpProt) / 1000

        if fpPtime >= 2 then
            floodprotect = 0
        end
    end

    for i = 0, clientsLimit, 1 do
        if et.gentity_get(i, "pers.connected") == 2 and PlayerName[i] ~= Bname[i] then
            logChat(Bname[i], "NAME_CHANGE", PlayerName[i])
            Bname[i] = PlayerName[i]
        end
    end

    if k_advancedadrenaline == 1 then
        for i = 0, clientsLimit, 1 do
            local adrentlimit = 10
            local adrensound = "sound/misc/regen.wav"

            if pausedv == 1 then
                adrendummy[i] = 1
            end

            if adrendummy[i] == 1 and tonumber(et.gentity_get(i, "ps.powerups", 12)) == 0 then
                adrendummy[i] = 0
            end

            if adrendummy[i] == 0 then
                if tonumber(et.gentity_get(i, "ps.powerups", 12)) > 0 then
                    adrnum[i]  = tonumber(et.gentity_get(i, "ps.powerups", 12))
                    soundindex = et.G_SoundIndex(adrensound)
                    local name = et.gentity_get(i, "pers.netname")

                    if antiloopadr1[i] == 0 then
                        adrtime[i] = mtime

                        if k_adrensound == 1 then
                            et.G_Sound( i,  soundindex)
                        end

                        antiloopadr1[i] = 1
                    end

                    if antiloopadr2[i] == 0 then
                        adrtime2[i] = mtime
                        adrnum2[i] = tonumber(et.gentity_get(i, "ps.powerups", 12))
                        antiloopadr2[i] = 1
                    end

                    adrenaline[i] = 1
                    local tottime = math.floor((((mtime - adrtime[i]) / 1000) + 0.05))
                    local tottime2 = math.floor((((mtime - adrtime2[i]) / 1000) + 0.05))

                    if tottime >= 1 then
                        antiloopadr1[i] = 0
                    end

                    if adrnum[i] ~= adrnum2[i] then
                        adrnum2[i] = tonumber(et.gentity_get(i, "ps.powerups", 12))

                        if k_adrensound == 1 then
                            et.G_Sound(i, soundindex)
                        end

                        adrtime[i] = mtime
                        adrtime2[i] = mtime
                    end

                    local atime = (adrentlimit - tottime2)
                    et.trap_SendServerCommand(i, string.format("cp \"^3Adrenaline ^1" .. atime .. "\n\""))
                else
                    adrenaline[i] = 0
                    antiloopadr1[i] = 0
                    antiloopadr2[i] = 0
                    adrnum[i] = 0
                    adrnum2[i] = 0
                end
            end
        end
    end


    for i = 0, clientsLimit, 1 do
        local mute = et.gentity_get(i, "sess.muted")

        if muted[i] > 0 then
            if mtime > muted[i] then
                if mute == 1 then
                    local name = et.gentity_get(i, "pers.netname")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref unmute \"" .. i .. "\"\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. name .." ^7has been auto unmuted.  Please watch your language!\n")
                end

                muted[i] = 0
            elseif mtime < muted[i] then
                if mute == 0 then
                    muted[i] = 0
                    setMute(i, 0)
                end
            elseif mute == 0 then
                muted[i] = 0
            end
        elseif muted[i] == -1 then
            if mute == 0 then
                muted[i] = 0
            end
        end
    end

    if k_disablevotes == 1 then
        local timelimit = tonumber(et.trap_Cvar_Get("timelimit"))

        if k_dvmode == 1 then
            local cancel_time = (timelimit - k_dvtime)
            if timecounter >= (cancel_time * 60) then
                if votedis == 0 then
                    votedis = 1
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings are now DISABLED\n")
                end
            else
                if votedis == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings have been reenabled due to timelimit change\n")
                end

                votedis = 0
            end
        elseif k_dvmode == 3 then
            if timecounter >= (k_dvtime * 60) then
                if votedis == 0 then
                    votedis = 1
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings are now DISABLED\n")
                end
            else
                if votedis == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings have been reenabled due to timelimit change\n")
                end

                votedis = 0
            end
        else
            local cancel_percent = (timelimit * (k_dvtime / 100))
            if timecounter >= (cancel_percent * 60) then
                if votedis == 0 then
                    votedis = 1
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings are now DISABLED\n")
                end
            else
                if votedis == 1 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings have been reenabled due to timelimit change\n")
                end

                votedis = 0
            end
        end
    end

    numAxisPlayers = 0
    numAlliedPlayers = 0
    active_players = 0
    total_players = 0

    for i = 0, clientsLimit, 1 do
        if et.gentity_get(i, "pers.connected") == 2 then
            local team = et.gentity_get(i, "sess.sessionTeam")

            if team == 1 then
                numAxisPlayers = numAxisPlayers + 1
            elseif team == 2 then
                numAlliedPlayers = numAlliedPlayers + 1
            end

            if team == 1 or team == 2 then
                active_players = active_players + 1
            end

            total_players = total_players + 1
        end
    end

    local k_panzerwarning1 = "^3Panzerlimit:^7  Please switch to a different weapon or be automatically moved to spec in ^11^3 minute!"
    local k_panzerwarning2 = "^3Panzerlimit:^7  Please switch to a different weapon or be automatically moved to spec in ^130^3 Seconds!"
    local k_panzermoved = "^1You have been moved to spectator for having a panzerfaust after being warned twice to switch!"
    local active_panzers = 0

    if k_autopanzerdisable == 1 then
        if panzdv == 0 and frenzdv == 0 and grendv == 0 and snipdv == 0 then
            if active_players < k_panzerplayerlimit then
                    for i = 0, clientsLimit, 1 do
                        if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                            active_panzers = 1
                            break
                        end
                    end

                    if panzer_antiloop == 0 then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit:  ^7Panzers have been disabled.\n")
                        panzer_antiloop = 1
                        panzers_enabled = 0
                    end

                    if active_panzers == 1 then
                        if panzer_antiloop1 == 0 then
                            panzertime = mtime
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay " .. k_panzerwarning1 .. "\n")
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers 0\n")
                            panzer_antiloop1 = 1
                        end

                        if ((mtime - panzertime) / 1000) > 30 then
                            if panzer_antiloop2 == 0 then
                                et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay " .. k_panzerwarning2 .. "\n")
                                panzer_antiloop2 = 1
                            end
                        end

                        if ((mtime - panzertime) / 1000) > 60 then
                            for i = 0, clientsLimit, 1 do
                                if tonumber(et.gentity_get(i, "sess.latchPlayerWeapon")) == 5 then
                                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref remove " .. i .. "\n")
                                    et.gentity_set(i, "sess.latchPlayerWeapon", 3)

                                    if k_advancedpms == 1 then
                                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. i .. " " .. k_panzermoved .. "\n")
                                    else
                                        local name = et.gentity_get(PlayerID,"pers.netname")
                                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "m \"" .. name .. "\" " .. k_panzermoved .. "\n")
                                    end
                                end
                            end

                            active_panzers = 0
                            panzer_antiloop = 0
                            panzer_antiloop1 = 0
                            panzer_antiloop2 = 0
                        end
                    else
                        active_panzers = 0
                        panzer_antiloop1 = 0
                        panzer_antiloop2 = 0
                    end
            else
                active_panzers = 0
                panzer_antiloop = 0
                panzer_antiloop1 = 0
                panzer_antiloop2 = 0
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "team_maxpanzers " .. k_panzersperteam .. "\n")

                if panzers_enabled == 0 then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Panzerlimit: ^7Panzers have been auto-enabled.  Each team is allowed only ^1" .. k_panzersperteam .. "^7 panzer(s) per team!\n")
                    panzers_enabled = 1
                end
            end
        end
    end
end

-- Client management

-- Called when a client disconnects.
--  clientNum is the client slot id.
function et_ClientDisconnect(clientNum)
    killingspree[clientNum] = 0
    flakmonkey[clientNum] = 0
    deathspree[clientNum] = 0
    multikill[clientNum] = 0
    nummutes[clientNum] = 0
    antiloopadr1[clientNum] = 0
    antiloopadr2[clientNum] = 0
    adrenaline[clientNum] = 0
    adrnum[clientNum] = 0
    adrnum2[clientNum] = 0
    adrtime[clientNum] = 0
    adrtime2[clientNum] = 0
    adrendummy[clientNum] = 0
    clientrespawn[clientNum] = 0
    invincDummy[clientNum] = 0
    switchteam[clientNum] = 0
    gibbed[clientNum] = 0

    playerwhokilled[clientNum] = 1022
    killedwithweapk[clientNum] = ""
    killedwithweapv[clientNum] = ""
    playerlastkilled[clientNum] = 1022
    selfkills[clientNum] = 0
    teamkillr[clientNum] = 0
    khp[clientNum] = 0
    AdminName[clientNum] = ""
    originalclass[clientNum] = ""
    originalweap[clientNum] = ""

    killr[clientNum] = 0

    kill1[clientNum] = ""
    kill2[clientNum] = ""
    kill3[clientNum] = ""
    kill4[clientNum] = ""
    kill5[clientNum] = ""
    kill6[clientNum] = ""

    PlayerName[clientNum] = ""

    if k_logchat == 1 then
        logChat(clientNum, "DISCONNECT", "DV2")
    end

    if muted[clientNum] > 0 then
        local muteDur = (muted[clientNum] - mtime) / 1000
        setMute(clientNum, muteDur)
        muted[clientNum] = 0
    elseif muted[clientNum] == 0 then
        local muteDur = 0
        setMute(clientNum, muteDur)
        muted[clientNum] = 0
    end
end

-- Called when a client begins (becomes active, and enters the gameworld).
--  clientNum is the client slot id.
function et_ClientBegin(clientNum)
    local name = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name")

    printModInfo(clientNum)
    loadAdmins()

    teamkillr[clientNum] = 0
    selfkills[clientNum] = 0
    muted[clientNum] = 0
    loadMutes()
    checkMute(clientNum)

    Bname[clientNum] = name

    if k_logchat == 1 then
        logChat(clientNum, "CONN", "DV")
    end
end

-- Called when a client is spawned.
--  clientNum is the client slot id.
--  revived is 1 if the client was spawned by being revived.
function et_ClientSpawn(clientNum, revived)
    if panzdv == 1 then
        local doublehealth = tonumber(et.gentity_get(clientNum, "health")) * 2
        local team = et.gentity_get(clientNum, "sess.sessionTeam")

        if team >= 1 and team < 3 then
            et.gentity_set(clientNum, "health", doublehealth)
        end
    end

    if revived == 0 then
        local team = et.gentity_get(clientNum, "sess.sessionTeam")

        if team >= 1 and team < 3 then
            clientrespawn[clientNum] = 1
        end
    end
end

-- commands

-- Called when a command is received from a client.
--  clientNum is the client slot id.
--  command is the command. The mod should return 1 if the command was intercepted by the mod,
--  and 0 if the command was ignored by the mod and should be passed through
--  to the server (and other mods in the chain).
function et_ClientCommand(clientNum, command)
    local name2 = et.gentity_get(clientNum, "pers.netname")
    local name2 = et.Q_CleanStr(name2)
    local arg0 = string.lower(et.trap_Argv(0))
    local arg1 = string.lower(et.trap_Argv(1))
    local muted = et.gentity_get(clientNum, "sess.muted")
    local cmd = string.lower(command)

    if muted == 0 then
        if arg0 == "say" then
            if k_logchat == 1 then
                logChat(clientNum, et.SAY_ALL, et.ConcatArgs(1))
            end

            say_parms = "qsay"
            et_ClientSay( clientNum, et.SAY_ALL, et.ConcatArgs(1))
        elseif arg0 == "say_team" then
            if k_logchat == 1 then
                logChat(clientNum, et.SAY_TEAM, et.ConcatArgs(1))
            end

            say_parms = "qsay"
            et_ClientSay(clientNum, et.SAY_TEAM, et.ConcatArgs(1))
        elseif arg0 == "say_buddy" then
            if k_logchat == 1 then
                logChat(clientNum, et.SAY_BUDDY, et.ConcatArgs(1))
            end

            say_parms = "qsay"
            et_ClientSay( clientNum, et.SAY_BUDDY, et.ConcatArgs(1))
        elseif arg0 == "say_teamnl" then
            if k_logchat == 1 then
                logChat(clientNum, et.SAY_TEAMNL, et.ConcatArgs(1))
            end

            say_parms = "qsay"
            et_ClientSay( clientNum, et.SAY_TEAMNL, et.ConcatArgs(1))
        elseif arg0 == "sc" then
            if getAdminLevel(clientNum) == 3 then
                local name = et.gentity_get(clientNum, "pers.netname")

                if k_advancedpms == 1 then
                    say_parms = "m2 " .. clientNum
                else
                    say_parms = "m " .. name
                end

                et_ClientSay(clientNum, SC, et.ConcatArgs(1))
                return 1
            end
        elseif arg0 == "vsay" then
            if k_logchat == 1 then
                logChat(clientNum, "VSAY_ALL", et.ConcatArgs(1))
            end
        elseif arg0 == "vsay_team" then
            if k_logchat == 1 then
                logChat(clientNum, "VSAY_TEAM", et.ConcatArgs(1))
            end
        elseif arg0 == "vsay_buddy" then
            if k_logchat == 1 then
                logChat(clientNum, "VSAY_BUDDY", et.ConcatArgs(1))
            end
        end
    end

    if arg0 == "m" or arg0 == "pm"  then
        if k_logchat == 1 then
            logChat(clientNum, "PMESSAGE", et.ConcatArgs(2), et.trap_Argv(1))
        end
    elseif arg0 == "ma" or arg0 == "pma" or arg0 == "msg" then
        if k_logchat == 1 then
            logChat(clientNum, "PMADMINS", et.ConcatArgs(1))
        end
    end

    if k_advplayers == 1 then
        if cmd == "players" then
            params         = {}
            params.command = 'client'
            params["arg1"] = clientNum
            dofile(kmod_ng_path .. '/kmod/command/client/players.lua')
            return execute_command(params)
        end

        if getAdminLevel(clientNum) >= 2 and cmd == "admins" then
            params         = {}
            params.command = 'client'
            params["arg1"] = clientNum
            dofile(kmod_ng_path .. '/kmod/command/client/admins.lua')
            return execute_command(params)
        end
    end

    local ref = tonumber(et.gentity_get(clientNum, "sess.referee"))

    if tonumber(et.gentity_get(clientNum, "sess.sessionTeam")) == 3 then
        if et.trap_Argv(0) == "team" and et.trap_Argv(1) then
            switchteam[clientNum] = 1
        end
    end

    if votedis == 1 then
        local vote = et.trap_Argv(1)

        if getAdminLevel(clientNum) < 3 then
            if et.trap_Argv(0) == "callvote" then
                if vote == "shuffleteamsxp" or vote == "shuffleteamsxp_norestart" or vote == "nextmap" or vote == "swapteams" or vote == "matchreset" or vote == "maprestart" or vote == "map" then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Voting has been disabled!\n")
                end
            end
        end
    end

    local vote = et.trap_Argv(1)

    if k_antiunmute == 1 then
        if vote == "unmute" then
            local client = et.trap_Argv(2)
            local clientnumber = part2id(client)
            local targetmuted = et.gentity_get(clientnumber, "sess.muted")

            if targetmuted == 1 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Cannot vote to unmute a muted person!\n")
            end
        end
    end

    if arg0 == "ref" and arg1 == "pause" and pausedv == 0 then
        GAMEPAUSED = 1
        dummypause = mtime
    elseif arg0 == "ref" and arg1 == "unpause" and pausedv == 1 then
        if ((mtime - dummypause) / 1000) >= 5 then
            GAMEPAUSED = 0
        end
    end

    if k_advancedpms == 1 then
        if cmd == "m" or cmd == "msg" or cmd == "pm" then
            if et.trap_Argv(1) == nil or et.trap_Argv(1) == "" or et.trap_Argv(1) == " " then
                et.trap_SendServerCommand(clientNum, string.format("print \"Useage:  /m \[pname/ID\] \[message\]\n"))
            else
                params         = {}
                params.command = 'client'
                params.commandSaid = true
                params["arg1"] = et.trap_Argv(1)
                params["arg2"] = clientNum
                params["arg3"] = et.ConcatArgs(2)
                dofile(kmod_ng_path .. '/kmod/command/both/private_message.lua')
                return execute_command(params)
            end
        end
    end

    if cmd == "ma" or cmd == "pma" then
        for i = 0, clientsLimit, 1 do
            if getAdminLevel(i) >= 2 then
                local name = et.gentity_get(clientNum, "pers.netname") 
                et.trap_SendServerCommand(i, ("b 8 \"^dPm to admins from " .. name .. "^d --> ^3" .. et.ConcatArgs(1) .. "^7"))

                if k_advancedpms == 1 then
                    et.G_ClientSound(i, pmsound)
                end
            end
        end

        if getAdminLevel(clientNum) < 2 then
            et.trap_SendServerCommand(clientNum, ("b 8 \"^dPm to admins has been sent^d --> ^3" .. et.ConcatArgs(1) .. "^7"))

            if k_advancedpms == 1 then
                et.G_ClientSound(clientNum, pmsound)
            end
        end

        return 1
    end

    if k_slashkilllimit == 1 then
        local name = et.gentity_get(clientNum, "pers.netname")
        local teamnumber = tonumber(et.gentity_get(clientNum, "sess.sessionTeam"))

        if cmd == "kill" then
            if teamnumber ~= 3 then
                if et.gentity_get(clientNum, "health") > 0 then
                    if selfkills[clientNum] < k_slashkills then
                        selfkills[clientNum] = selfkills[clientNum] + 1

                        if selfkills[clientNum] == k_slashkills then
                            if k_advancedpms == 1 then
                                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                                et.G_ClientSound(clientNum, pmsound)
                            else
                                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have reached your /kill limit!  You can no longer /kill for the rest of this map.\n")
                            end
                        elseif selfkills[clientNum] == (k_slashkills - 1) then
                            if k_advancedpms == 1 then
                                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You have ^11^7 /kill left for this map.\n")
                                et.G_ClientSound(clientNum, pmsound)
                            else
                                et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You have ^11^7 /kill left for this map.\n")
                            end
                        end
                    else
                        if k_advancedpms == 1 then
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "m2 " .. clientNum .. " ^7You may no longer /kill for the rest of this map!\n")
                            et.G_ClientSound(clientNum, pmsound)
                        else
                            et.trap_SendConsoleCommand(et.EXEC_APPEND, "m " .. name .. " ^7You may no longer /kill for the rest of this map!\n")
                        end

                        return 1
                    end
                end
            end
        end
    end

    return 0
end

-- Called when a command is entered on the server console.
-- The mod should return 1 if the command was intercepted by the mod,
-- and 0 if the command was ignored by the mod and should be passed through
-- to the server (and other mods in the chain).
function et_ConsoleCommand()
    arg0 = string.lower(et.trap_Argv(0))

    params         = {}
    params.command = 'console'
    params.nbArg   = et.trap_Argc()
    params["arg1"] = et.trap_Argv(1)
    params["arg2"] = et.trap_Argv(2)

    params.commandSaid = false
    params.say = say_parms

    if arg0 == k_commandprefix .. "setlevel" then
        dofile(kmod_ng_path .. '/kmod/command/both/setlevel.lua')
        return execute_command(params)
    elseif arg0 == "goto" then
        dofile(kmod_ng_path .. '/kmod/command/console/goto.lua')
        return execute_command(params)
    elseif arg0 == "iwant" then
        dofile(kmod_ng_path .. '/kmod/command/console/iwant.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "showadmins" then
        dofile(kmod_ng_path .. '/kmod/command/console/showadmins.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "readconfig" then
        dofile(kmod_ng_path .. '/kmod/command/console/readconfig.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "spree_restart" then
        dofile(kmod_ng_path .. '/kmod/command/both/spree_restart.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "panzerwar" then
        dofile(kmod_ng_path .. '/kmod/command/both/panzerwar.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "frenzy" then
        dofile(kmod_ng_path .. '/kmod/command/both/frenzy.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "grenadewar" then
        dofile(kmod_ng_path .. '/kmod/command/both/grenadewar.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "sniperwar" then
        dofile(kmod_ng_path .. '/kmod/command/both/sniperwar.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "crazygravity" then
        dofile(kmod_ng_path .. '/kmod/command/both/crazygravity.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "spec999" then
        dofile(kmod_ng_path .. '/kmod/command/both/spec999.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "gib" then
        dofile(kmod_ng_path .. '/kmod/command/both/gib.lua')
        return execute_command(params)
    elseif arg0 == k_commandprefix .. "slap" then
        dofile(kmod_ng_path .. '/kmod/command/both/slap.lua')
        return execute_command(params)
    elseif arg0 == "k_commandprefix" then
        et.G_Print("Unknown command in line k_commandprefix\n")
        return 1
    elseif arg0 == "m2" then  -- used when advancedpms is enabled
        if k_advancedpms == 1 then
            if (et.trap_Argc() < 2) then 
                et.G_Print("Useage:  /m \[pname/ID\] \[message\]\n")
                return 1
            else
                params["arg2"] = 1022
                params["arg3"] = et.ConcatArgs(2)
                dofile(kmod_ng_path .. '/kmod/command/both/private_message.lua')
                return execute_command(params)
            end

            if k_logchat == 1 then
                logChat(1022, "PMESSAGE", et.ConcatArgs(2), et.trap_Argv(1))
            end
        end

        return 1
    elseif arg0 == "m" or arg0 == "pm" or arg0 == "msg" then
        if k_advancedpms == 0 then
            if k_logchat == 1 then
                logChat(1022, "PMESSAGE", et.ConcatArgs(2),  et.trap_Argv(1))
            end
        end

        return 1
    elseif arg0 == "ma" or arg0 == "pma" then
            for i = 0, clientsLimit, 1 do
                if getAdminLevel(i) >= 2 then
                    et.trap_SendServerCommand(i, ("b 8 \"^dPm to admins from ^1SERVER^d --> ^3" .. et.ConcatArgs(1) .. "^7"))
                    et.G_ClientSound(i, pmsound)
                end
            end

            if k_logchat == 1 then
                logChat(1022, "PMADMINS", et.ConcatArgs(1))
            end

            et.G_Print("Private message sent to admins\n")
            return 1
    elseif arg0 == "ref" and string.lower(et.trap_Argv(1)) == "pause" and pausedv == 0 then
        GAMEPAUSED = 1
        dummypause = mtime
        return 0
    elseif arg0 == "ref" and string.lower(et.trap_Argv(1)) == "unpause" and pausedv == 1 then
        GAMEPAUSED = 0
        return 0
    else
        return 0
    end
end

-- miscellaneous

-- Called whenever the server or qagame prints a string to the console.
-- WARNING! text may contain a player name + their chat message.
-- This makes it very easy to spoof.
-- DO NOT TRUST STRINGS OBTAINED IN THIS WAY
function et_Print(text)
    local t = splitWord(text)

    if t[1] == "saneClientCommand:" and t[3] == "callvote" then
        local caller = tonumber(t[2])
        local vote = t[4]
        local target = tonumber(t[5])

        if (vote == "kick" or vote == "mute") and getAdminLevel(caller) < getAdminLevel(target) then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Admins cannot be vote kicked or vote muted!\n")
        end
    end

    if t[1] == "Medic_Revive:" then
        local reviver = tonumber(t[2])
        teamkillr[reviver] = teamkillr[reviver] + 1

        if teamkillr[reviver] > k_tklimit_high then
            teamkillr[reviver] = k_tklimit_high
        end
    end
end

-- Called whenever a player is killed.
function et_Obituary( victim, killer, meansOfDeath )
    local killername= ""
    local killedname=et.Info_ValueForKey(et.trap_GetUserinfo(victim), "name")
    local victimteam = tonumber(et.gentity_get(victim, "sess.sessionTeam"))
    local killerteam = tonumber(et.gentity_get(killer, "sess.sessionTeam"))
    weapon = ""

    if victimteam ~= killerteam and killer ~= 1022 and killer ~= victim then
        killername  = et.Info_ValueForKey(et.trap_GetUserinfo(killer), "name")
        lastblood   = killername
        khp[killer] = (mtime + 5000)

        if khp[victim] == nil then
            khp[victim] = 0
        end
    end

    if victimteam ~= killerteam and killer ~= 1022 and killer ~= victim then
        if killer ~= victim then
            if firstblood == 0 then
                firstblood = 1

                if k_firstblood == 1 then
                    local str = string.gsub(k_fb_message, "#killer#", killername)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, fb_location .. " " .. str .. "\n")

                    if k_firstbloodsound == 1 then
                        if k_noisereduction == 1 then
                            et.G_ClientSound(killer, firstbloodsound)
                        else
                            et.G_globalSound(firstbloodsound)
                        end
                    end
                end
            end
        end

        local killerhp = et.gentity_get(killer, "health")

        if k_killerhpdisplay == 1 then
            if khp[victim] < mtime then
                if killerhp >= 75 then
                    et.trap_SendServerCommand(victim, ("b 8 \"^7" .. killername .. "^" .. k_color .. "'s hp (^o" .. killerhp .. "^" .. k_color .. ")"))

                    if adrenaline[killer] == 1 then
                        et.trap_SendServerCommand(victim, ("b 8 \"^7" .. killername .. "^" .. k_color .. " is an adrenaline junkie!\""))
                    end
                elseif killerhp >= 50 and killerhp <= 74 then
                    et.trap_SendServerCommand(victim, string.format("b 8 \"^7" .. killername .. "^" .. k_color .. "'s hp (^o" .. killerhp .. "^" .. k_color .. ")"))

                    if adrenaline[killer] == 1 then
                        et.trap_SendServerCommand(victim, ("b 8 \"^7" .. killername .. "^" .. k_color .. " is an adrenaline junkie!\""))
                    end
                elseif killerhp >= 25 and killerhp <= 49 then
                    et.trap_SendServerCommand(victim, string.format("b 8 \"^7" .. killername .. "^" .. k_color .. "'s hp (^o" .. killerhp .. "^" .. k_color .. ")"))

                    if adrenaline[killer] == 1 then
                        et.trap_SendServerCommand(victim, ("b 8 \"^7" .. killername .. "^" .. k_color .. " is an adrenaline junkie!\""))
                    end
                elseif killerhp > 0 and killerhp <= 24 then
                    et.trap_SendServerCommand(victim, string.format("b 8 \"^7" .. killername .. "^" .. k_color .. "'s hp (^o" .. killerhp .. "^" .. k_color .. ")"))

                    if adrenaline[killer] == 1 then
                        et.trap_SendServerCommand(victim, ("b 8 \"^7" .. killername .. "^" .. k_color .. " is an adrenaline junkie!\""))
                    end
                end
            end

            if killerhp <= 0 then
                if meansOfDeath == 4 or meansOfDeath == 18 or meansOfDeath == 18 or meansOfDeath == 26 or meansOfDeath == 27 or meansOfDeath == 30 or meansOfDeath == 44 or meansOfDeath == 43 then
                    et.trap_SendServerCommand(victim, string.format("b 8 \"^" .. k_color .. "You were owned by ^7" .. killername .. "^" .. k_color .. "'s explosive inheritance"))
                end
            end
        end
    end

    kills(victim, killer, meansOfDeath, weapon)
    deaths(victim, killer, meansOfDeath, weapon)

    if meansOfDeath == 64 or meansOfDeath == 63 then
        switchteam[victim] = 1
    else
        switchteam[victim] = 0
    end

    --Weapons used!
    weapon = getMeansOfDeathName(meansOfDeath)
end

-- et_ClientSay has been removed
function et_ClientSay(clientNum,mode,text)
	local command1=""
	local commands = 0
	local first = ""
	local second = ""
	local third = ""
	local returnVal = 0
	s,e,first,second,third = string.find(text,"%s*([%p]?[.%S]*)%s+([.%S]*)%s+(.*)")

	local fd,len = et.trap_FS_FOpenFile( "badwords.list", et.FS_READ )
	if len > 0 then
		local filestr = et.trap_FS_Read( fd, len )

--		for level,comm,str in string.gfind(filestr, "[^%#](%d)%s*%-%s*([%w%_]*)%s*%=%s*([^%\n]*)") do
--		for Bword in string.gfind(filestr, "[^%#]([^%\n]*)[^%#]") do
--		for Bword in string.gfind(filestr, "([^%\n]+)%S*") do
		for Bword in string.gfind(filestr, "(%w*)") do
--			Bword = string.gsub(Bword, "(.+)%\n", "%1")
--			d,v,Bword = string.find(Bword, "([%w]*)")
--			if dv == nil then
--				et.G_Print("Bword = ".. Bword .." and it is ".. string.len(Bword) .." long\n" )
				for word in string.gfind(text, "([^%s]+)%p*") do
--					t,f=string.find(word, Bword)
--					if f ~= nil then
--						if f ~= 0 then
						if word == Bword then
--							et.trap_SendConsoleCommand( et.EXEC_APPEND, "qsay moo\n" )
							curseFilter( clientNum )
							break
						end
--					end
				end
--			end
		end
	end
	et.trap_FS_FCloseFile( fd )


	if(mode==et.SAY_ALL) then
		command1="say"
	elseif (mode==et.SAY_TEAM or mode==et.SAY_TEAMNL) then
		command1="say_team"
	elseif (mode==et.SAY_BUDDY) then
		command1="say_buddy"
	elseif (mode==SC) then
		command1="SC"
	end
	if(third~=nil) then
		commands=4
	else
		s,e,first,second = string.find(text,"%s*([^%s+]+)%s+(.+)%s*")
			third=""
			if(second~=nil) then
				commands = 3
			else
				second=""
				first = et.ConcatArgs(1)
				commands = 2
			end
	end
	return ClientUserCommand(clientNum, command1, first, second, third, commands)
end

function et.G_ClientSound(clientNum, soundFile)
    local tmpEntity = et.G_TempEntity(et.gentity_get(clientNum, "r.currentOrigin"), EV_GLOBAL_CLIENT_SOUND)
    et.gentity_set(tmpEntity, "s.teamNum", clientNum)
    et.gentity_set(tmpEntity, "s.eventParm", et.G_SoundIndex(soundFile))
end
