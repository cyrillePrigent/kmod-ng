<snippet>
  <content><![CDATA[
# ${1:Project Name}

This lua was created to replace etadmin & kmod mod.
It's a complete rewriting of kmod, much modulable.
You can enabled only modules you need.
ETpro fix is included.

## Installation

Extract all files into the etpro folder on your server.
Dont forget to add the kmod.pk3 to your fast download site!

Open the server.cfg from your server and copy and paste the following lines at the bottom then restart your server:

```
set lua_modules "kmod-ng.lua"
set lua_allowedmodules "374529E3DF838F71B4CF0107413D3D318279DDAF"
exec "kmod-ng/kmod-ng.cfg"
```

## Usage

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

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Sources

Kmod SOURCES:
    Some code and ideas dirived from G073nks which can be found here<br />
        [http://wolfwiki.anime.net/index.php/User:Gotenks](http://wolfwiki.anime.net/index.php/User:Gotenks)<br />
    Code to get slot number from name was from the slap command I found on the ETPro forum here<br />
        [http://bani.anime.net/banimod/forums/viewtopic.php?t=6579&highlight=slap](http://bani.anime.net/banimod/forums/viewtopic.php?t=6579&highlight=slap)<br />
    Infty's NoKill lua code was used and edited for the slashkill limit which can be found here<br />
        [http://wolfwiki.anime.net/index.php/User:Infty](http://wolfwiki.anime.net/index.php/User:Infty)<br />
    Ideas dirived from ETAdmin_mod found here<br />
        [http://et.d1p.de/etadmin_mod/wiki/index.php/Main_Page](http://et.d1p.de/etadmin_mod/wiki/index.php/Main_Page)<br />

## Credits

Kmod AUTHOR:<br />
    Clutch152<br />
<br />
Kmod CREDITS:<br />
    Special to<br />
        Noobology<br />
        Armymen<br />
        Rikku<br />
        Monkey Spawn<br />
        Brunout<br />
        Dominator<br />
        James<br />
        Pantsless Victims<br />
<br />
        And the entire -=War-torn=- Clan<br />
        For helping with testing<br />

## License

This program is free software. you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>
