local MOD_NAME = minetest.get_current_modname() or "luaconfig";
local MOD_PATH = minetest.get_modpath(MOD_NAME);

local luaconfig = { MOD_NAME = MOD_NAME, MOD_PATH = MOD_PATH };
_G[MOD_NAME] = luaconfig;

local function loadConfigFile(filePath)
   -- test for existence/readability
   local file = io.open(filePath, 'r');
   if not file then return nil; end;
   file:close();

   local chunk, err = loadfile(filePath);
   return chunk or error(err);
end;

function luaconfig.loadConfig(modName, config)
   modName = modName or minetest.get_current_modname();
   if not modName or modName == "" then
      error(MOD_NAME ..  ": Couldn't determine mod name for loading config");
   end;
   local modPath =
      minetest.get_modpath(modName) or
      error(MOD_NAME .. ": Couldn't determine mod path for loading config");

   local modConfigFile =
      modPath .. "/config.lua";
   local worldConfigFile =
      minetest.get_worldpath() .. "/" .. modName .. "_config.lua";

   -- Avoids errors due to testing for nil global variables
   local gCopy = {};
   for k, v in pairs(_G) do gCopy[k] = v; end;

   if not config then
      local modApi    = gCopy[modName];
      local modConfig = (type(modApi) == 'table') and modApi.config;
      config = (type(modConfig) == 'table' and modConfig) or {};
   end;

   local modConfigFunc   = loadConfigFile(modConfigFile);
   local worldConfigFunc = loadConfigFile(worldConfigFile);
   if not modConfigFunc and not worldConfigFunc then return config; end;

   -- Setting any "global" variable in the config files actually modifies the
   -- local config table (unless the variable is accessed through another
   -- existing table like _G or minetest).
   local configEnv =
      setmetatable(
      {},
      {
         __index = function(self, key)
            local v = config[key];
            if v ~= nil then return v; else return gCopy[key]; end;
         end,

         __newindex = function(self, key, value)
            config[key] = value;
            return true;
         end
      });

   if modConfigFunc then
      setfenv(modConfigFunc, configEnv);
      modConfigFunc();
   end;

   if worldConfigFunc then
      setfenv(worldConfigFunc, configEnv);
      worldConfigFunc();
   end;

   return config;
end;
