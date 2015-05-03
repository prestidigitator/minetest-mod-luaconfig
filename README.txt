LuaConfig Minetet Mod
=====================

This mod makes it really, really easy for other mods to load Lua-based
configuration settings.  It's as simple as adding "luaconfig" to your mod's
depends.txt and putting this at the top of your init.lua:

   local config = luaconfig.loadConfig();

and then optionally (to make settings globally visible):

   mymod = { config = config };

This automatically detects the name and path of your mod and loads settings
from "config.lua" in your mod directory and/or "<myMod>_config.lua" in the
world directory, allowing the latter to add to or overwrite the former.  No
errors will be generated if either or both files are missing.

This mod allows simple Lua variable-based configuration settings that almost
guarantee that you don't accidentally set global variables (you can if you
REALLY try, but it's difficult).  You'll have access to all variables defined
from the config files using logic like:

   print(config.message);

Simple Example
--------------

Here's a mod that announces to all when a player joins and leaves, and greets
the player directly when he/she joins.  Keep in mind that the name "mymod" is
just an example, and would actually be replaced by the name of your own mod.

   -- mymod/init.lua

   local config = luaconfig.loadConfig();

   local function prepare(message, player)
      return string.gsub(message, "<player>", player:get_player_name());
   end;

   minetest.register_on_joinplayer(function(player)
      minetest.chat_send_all(
         prepare(config.joinAnnouncement, player));

      minetest.after(
         3.0,
         function()
            minetest.chat_send_player(player:get_player_name(),
                                      prepare(config.greeting, player));
         end);
   end);

   minetest.register_on_leaveplayer(function(player)
      minetest.chat_send_all(
         prepare(config.leaveAnnouncement, player));
   end);

Here is the mod's (default) config file:

   -- mymod/config.lua

   joinAnnouncement  = "<player> says hello!"
   leaveAnnouncement = "<player> says goodbye!"
   greeting          = "Hello <player>, and welcome"

And here's a world-specific config file for world "myworld":

   -- myworld/mymod_config.lua

   joinAnnouncement  = "<player> saunters in and says 'Howdy!'"
   leaveAnnouncement = "<player> tips his hat and says 'Adiós, amigos!'"
   greeting          = string.gsub(greeting, "Hello", "Howdy") .. " to myworld!"

Advanced Use/Examples
---------------------

The luaconfig.loadConfig() function takes two optional parameters, for
convenience.  The first is the name of your module.  It's auto-detected if
missing or nil, but passing it in is helpful if you don't call the function
right away (e.g. if you reload some settings periodically without restarting
the server), as there is no way to auto-detect what mod you are in once you get
to callbacks.  So you can do:

   local MOD_NAME = minetest.get_current_modname();
   -- and later, from a callback...
   local config = luaconfig.loadConfig(MOD_NAME);

The second optional parameter is an existing table to use instead of creating a
new one.  This same table is returned by the function, but can be safely
ignored.  This is useful if you want to set some defaults right from your mod
code before loading settings from the config files:

   local config = { greeting = "What, you're back?!" };
   luaconfig.loadConfig(nil, config);
   -- Use config.greeting as usual

If this second parameter is missing or nil, the luaconfig.loadConfig() function
looks for a globally visible table named after your module, and a 'config'
table inside that.  If it finds this, it uses it.  Otherwise it creates a new
table and returns it.  So doing this works just fine:

   mymod = {};
   mymod.config = {};
   mymod.config.greeting = "What, you're back?!";

   luaconfig.loadConfig();
   -- Use mymod.config.greeting as usual

Of course, if your mod uses a table called 'mymod.config' already, you can just
pass in an empty table and/or retrieve it back from the function to avoid
conflicts:

   local settings = luaconfig.loadConfig(nil, {});
   -- or
   mymod = { settings = {} };
   luaconfig.loadConfig(nil, mymod.settings);

Note that the "config.lua" file in the mod directory is loaded first, and then
the "<modName>_config.lua" file from the world directory.  The world-specific
file can thus access and modify settings made from the mod file, and both can
access and modify settings that your mod code makes before calling
luaconfig.loadConfig().  For more complicated (table-based) settings, you might
want to practice writing the configuration like:

   complexSettings = complexSettings or {};
   complexSettings.name = "Freeway";
   complexSettings.length = 16;
   complexSettings.units = "km";

so that it is easy to copy/paste, comment, and override individual settings
later from other files (or the mod code), whether or not the tables or
individual settings already exist:

   complexSettings = complexSettings or {};
   -- default complexSettings.name
   complexSettings.length = 20;
   -- default complexSettings.units

At this time there is NO built-in support for (re-)writing the config files
from within the game.  This is by design.  These config files contain
executable Lua code, and it's not usually advisable to auto-generate that.  If
you really want to you can implement something using, for example, io.open(),
file:write(), and some custom serialization (e.g. making use of
minetest.serialize() for each table entry).  This is left as an exercise for
brave and desperate readers.

Mod Information
---------------

Require Minetest Version: (probably any; tested in 0.4.12)

Dependencies: (none)

Soft Dependencies: (none)

Craft Recipes: (none)

API: luaconfig.loadConfig([modName, [configTable]])

Git Repo: https://github.com/prestidigitator/minetest-mod-luaconfig

Change History
--------------

Version 1.0

* Released 2015-05-03
* First working version.

Copyright and Licensing
-----------------------

All content, including documentation and source code, are original content
created by the mod author and are licensed under WTFPL.

Author: prestidigitator (as registered on forum.minetest.net)
License: WTFPL
