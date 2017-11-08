--[[

    ██╗   ██╗██████╗ ███████╗██████╗     ███╗   ███╗ ██████╗ ██████╗ 
    ██║   ██║██╔══██╗██╔════╝██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗
    ██║   ██║██████╔╝█████╗  ██████╔╝    ██╔████╔██║██║   ██║██║  ██║
    ██║   ██║██╔══██╗██╔══╝  ██╔══██╗    ██║╚██╔╝██║██║   ██║██║  ██║
    ╚██████╔╝██████╔╝███████╗██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝
    ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ 

This program is free software. you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License.

Source : https://github.com/cyrillePrigent/umod
Author : Yellux

--]]

umod_path = et.trap_Cvar_Get("fs_basepath") .. "/" .. et.trap_Cvar_Get("gamename") .. "/umod/"

dofile(umod_path .. "core.lua")
