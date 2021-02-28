pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--misc functions

function showbtns(x,y,btns)
	rectfill(x,y,x+3,y+4,0)
	rectfill(x+1,y+1,x+3,y+3,1)
	--le token save
	local col,dx,dy={8,11,13,10,12,14},{1,3,2,2,1,3},{3,3,2,3,1,1}
	for i=1,6 do
		if(btns&(1<<(i-1))!=0) pset(x+dx[i],y+dy[i],col[i])
	end
end

function getplayer()
	for o in all(objects) do
		if(o.base==player) return o
	end
end

function join(t)
	local s=t[1]
	for i=2,#t do s=s.." "..t[i] end
	return s
end

function copyvars(s,d,keys)
	for k in all(keys) do
		d[k]=s[k]
	end
	return d
end

function printvars(t,keys)
	if(not t) return "[none]"
	local s="{"
	for k in all(keys) do
		s=s..k.."="..t[k]..","
	end
	return s.."}"
end

function sprint(s,x,y,c)
	print(s,x+1,y+1,0)
	print(s,x,y,c)
end

function rprint(s,x,...)
	sprint(s,x-#tostr(s)*4+1,...)
end

function hprint(s)
	printh(s) printh(s,"seglog")
end

-->8
--functions

--every variable is init here
--for tokenz
nocopy,nocopy_sprs,
states,state_i,
btns,msgtime,
__update,__draw,_restart_level,
globals,
playervars,
level_index=
{},{[36]=true,[37]=true,[46]=true},
{},0,
0,0,
_update,_draw,restart_level,
split"input_x,input_jump_pressed,input_grapple_pressed,axis_x_value,axis_x_turned,input_jump,input_grapple,freeze_time,infade,level_index,level_intro,camera_x,camera_y,show_score,level_checkpoint",
split"x,y,speed_x,speed_y,remainder_x,remainder_y",
conf_level

--customized deepcopy function

function deepcopy(orig,copies)
	copies=copies or {}
	if not nocopy[orig] and type(orig)=='table' then
		if copies[orig] then
			return copies[orig]
		else
			local copy={}
			copies[orig]=copy
			for orig_key,orig_value in next,orig do
				copy[deepcopy(orig_key,copies)]=deepcopy(orig_value,copies)
			end
			--only metatable used is
			--`lookup`, so there's no
			--need to copy it
			setmetatable(copy,getmetatable(orig))
			return copy
		end
	else -- number, string, boolean, etc
		return orig
	end
end

function load_state(st)
	objects=deepcopy(st[1])
	copyvars(st[3],_ENV,globals)
end

function save_state(b)
	local o=deepcopy(objects)
 return {o,b,copyvars(_ENV,{},globals)}
end



--adjustments to cc2 functions

function restart_level()
	_restart_level()
	nocopy,current_player={},getplayer()
	level_intro,infade=0,15

	--set up nocopy to ignore static objects
	for o in all(objects) do
		if nocopy_sprs[o.base.spr] then
			nocopy[o]=true
		end
	end
	--additionally, we'll ignore
	--all types: player, checkpoint...
	for k,t in pairs(types) do
		nocopy[t]=true
	end

	if conf_player then
		for k,v in pairs(conf_player) do
			current_player[k]=v
		end
	end

	--snap camera once
	camera_modes[level.camera_mode](current_player.x,current_player.y)
	snap_camera()
	
	--go back to normal restart
	--for respawning
	restart_level=_restart_level
end

function next_level()
	level_finished=true
end

function draw_time()
end

-->8
--main

--rip
--needed tokens
--function logall()
--	hprint("level: "..conf_level)
--	hprint("begin: "..printvars(conf_player,playervars))
--
--	local s="[["
--	for st in all(states) do
--		s=s..st[2].." "
--	end
--	hprint(sub(s,1,#s-1).."]],")
--
--	hprint("end: "..printvars(current_player,playervars))
--end

--preload segment
if preload_seg then
	for b in all(split(preload_seg," ",true)) do
		if type(b)=="number" then
			add(states,{nil,b})
		end
	end
end

poke(0x5f2d,1) --kbm support
--variables are in prev tab

function _update()
	--read keyboard (one key is enough)
	local kbkey
	while stat(30) do kbkey=stat(31) end

	local gamebtns=nil
	if kbkey==" " then
		gamebtns=btn()
	elseif btn()!=0 then
		btns=btns|btn()&0xff
	elseif btn()==0 and btns!=0 then
		gamebtns=btns
		btns=0
	elseif kbkey=="." and state_i>0 then
		gamebtns=states[state_i][2]
	end

	if gamebtns and not level_finished then
		poke(0x5f4c,gamebtns)
		add(states,save_state(gamebtns),state_i+1)
		state_i+=1
		__update()
	elseif kbkey=="\b" then
		if state_i>0 then
			local st=deli(states,state_i)
			load_state(st)
			state_i-=1
		end
		level_finished=false
	end

	--this is kinda important
	current_player=getplayer()

	if kbkey=="i" then
--		logall()
		local s="[["
		for st in all(states) do
			s=s..st[2].." "
		end
		printh(sub(s,1,#s-1).."]],","@clip")
		msg="copied inputs"
		msgtime=60
	elseif kbkey=="o" then
--		logall()
		printh(printvars(current_player,playervars),"@clip")
		msg="copied coordinates"
		msgtime=60
	elseif kbkey=="-" then
		if state_i>0 then
			load_state(states[state_i])
			states[state_i][1]=nil
			state_i-=1
		end
	elseif kbkey=="=" then
		if state_i<#states then
			state_i+=1
			gamebtns=states[state_i][2]
			poke(0x5f4c,gamebtns)
			states[state_i]=save_state(gamebtns)
			__update()
		end
	end
end

function _draw()
	--no screenshake
	shake=0

	__draw()

	camera()

	sprint(join{current_player.x,current_player.y},0,0,7)
	rprint(join{current_player.speed_x,current_player.speed_y},128,0,12)
	rprint(join{current_player.remainder_x,current_player.remainder_y},128,6,14)

	sprint(join{state_i.."/"..#states,flr(stat(0))},0,6,stat(0)>=2000 and 8 or 10)

	local x=128-4*min(#states-state_i,16)
	for i=1,#states do
		showbtns(x-4+(i-state_i)*4,124,states[i][2])
	end
	line(x,124,x,128,7)

	if msgtime>0 then
		sprint(msg,0,118,7)
		msgtime-=1
	end

	camera(camera_x,camera_y)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
