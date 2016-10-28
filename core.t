local Lua = require "lua"

C = terralib.includec("stdio.h")

local function show(x, maxdepth, depth, history, alwaysshow)
	history = history or {}
	alwaysshow = alwaysshow or {}
	depth = depth or 1
	if type(x) == "table" then
		io.write("table ["..tostring(x):gsub("%s+", " "):sub(1).."]")
		if maxdepth and depth > maxdepth + 1 then
			print()
		elseif history[x] then
			print()
		else
			if not alwaysshow[x] then
				history[x] = true
			end
			print(":")
			local indent = ("  "):rep(depth)
			for k, v in pairs(x) do
				io.write(indent)
				io.write(tostring(k).." = ")
				if k == "kind" then
					v = terralib.kinds[v] or v
				end
				show(v, maxdepth, depth + 1, history, alwaysshow)
			end
		end
	else
		print(tostring(x).." ["..type(x).."]")
	end
end

-- show (terralib)
-- show(Lua.State, nil, nil, {[Lua.State.methods] = true})
-- show(A)
-- show(Lua.State.methods, nil, nil, nil, {[terralib.types.pointer(Lua.State)] = true, [Lua.State] = true})
-- show(Lua.State.methods.Lopenlibs, nil, nil, {[Lua.State] = true})
-- show(Lua.State)

terra main() : int
	var L : &Lua.State = Lua.Lnewstate()
	L:Lopenlibs() -- this works now!
	L:getglobal("print")
	L:pushvalue(-1)
	L:pushstring("hello, world!")
	L:call(1, 0)
	L:newtable()
	L:call(1, 0)
	return 0
end

terralib.saveobj("atest", { main = main }, {"-llua5.1", "-lm", "-ldl"})
