local prefix = "lua5.1/"

local imports = ([[
	#include "PREFIXlua.h"
	#include "PREFIXlualib.h"
	#include "PREFIXlauxlib.h"

	// redeclare as a function bc terra doesn't import macros
	#undef lua_getglobal
	inline void lua_getglobal(lua_State *L, const char *name) {
		return lua_getfield(L, LUA_GLOBALSINDEX, name);
	}

]]):gsub("PREFIX", prefix)

luah = terralib.includecstring(imports)

local Lua = {}

Lua.State = luah.lua_State
Lua.State.undefined = false -- trick terra into completing the definition of an opaque type

local function isstatemethod(f)
	if terralib.isfunction(f) then
		local params = f.type.parameters
		return params[1] and params[1]:ispointer() and params[1].type == Lua.State
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
			Lua.State.methods[k] = v
		else
			Lua[k] = v
		end
	end
end
load(luah)

--gotta wrap some things :c
terra Lua.State:newtable()
	self:createtable(0, 0)
end

return Lua
