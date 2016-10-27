local Lua = require "lua"

C = terralib.includec("stdio.h")

for k, v in pairs(Lua.State.methods) do
	print(k, v)
end

terra main() : int
	var L : &Lua.State = Lua.Lnewstate()
	[Lua.State.methods.Lopenlibs](L)
	-- L:Lopenlibs() -- this doesnt work for some reason?
	return 0
end

terralib.saveobj("atest", { main = main }, {"-llua", "-lm", "-ldl"})
