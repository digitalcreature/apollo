local prefix = "lua5.1/"

local lua = terralib.includec(prefix.."lua.h")
local lib = terralib.includec(prefix.."lualib.h")
local aux = terralib.includec(prefix.."lauxlib.h")

local Lua = {}

local state_t = lua.lua_State

local function isstatemethod(f)
	if terralib.isfunction(f) then
		local params = f.definitions[1].type.parameters
		return params[1] and params[1]:ispointer() and params[1].type == state_t
	end
end

local function load(t)
	for k, v in pairs(t) do
		local m = k:match("lua_(.+)")
		if m then
			k = m
		else
			m = k:match("luaL_(.+)")
			if m then
				k = "L"..m
			end
		end
		if isstatemethod(v) then
			state_t.methods[k] = v
		else
			Lua[k] = v
		end
	end
end
load(lua)
load(lib)
load(aux)

-- print (Lua.State)
-- print (Lua.State.methods.Lopenlibs.name)
-- print (lib.luaL_openlibs.definitions[1].type)

return Lua
