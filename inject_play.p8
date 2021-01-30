pico-8 cartridge // http://www.pico-8.com
version 29
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
--main

--setup
_restart_level=restart_level
function restart_level()
	_restart_level()

	--global variable!
	current_player=getplayer()
	--to track for ui etc

	if conf_player then
		for k,v in pairs(conf_player) do
			current_player[k]=v
		end
	end

	--fix camera
	camera_modes[level.camera_mode](current_player.x,current_player.y)
	snap_camera()
end

--join segments together
btnseq={}
for i=1,#segments do
	for b in all(split(segments[i]," ",true)) do
		add(btnseq,b)
	end
end

playervars=split"x,y,speed_x,speed_y,remainder_x,remainder_y"

poke(0x5f2d,1) --kbm
btn_i=1
pause=false
skip=false
msgtime=0

function advance()
	poke(0x5f4c,btnseq[btn_i])
	__update()
	btn_i+=1
end

__update=_update
function _update()
	local kbkey
	while(stat(30)) kbkey=stat(31)

	if skip then
		while btn_i<=#btnseq do
			advance()
		end
	end
	if btn_i<=#btnseq then
		if not pause or kbkey==" " then
			advance()
		end
	end
	if(kbkey=="t") pause=not pause
	if(kbkey=="y") skip=true
	if kbkey=="o" then
		current_player=getplayer()
		printh(printvars(current_player,playervars),"@clip")
		msg="copied coordinates"
		msgtime=60
	end
end

__draw=_draw
function _draw()
	__draw()

	camera()
	
	if showoverlays then
		if current_player then
			sprint(join{current_player.x,current_player.y},0,0,7)
			rprint(join{current_player.speed_x,current_player.speed_y},128,0,12)
			rprint(join{current_player.remainder_x,current_player.remainder_y},128,6,14)
		end
	
		for i=btn_i-1,max(1,btn_i-1-32),-1 do
			showbtns(124+(i+1-btn_i)*4,124,btnseq[i])
		end
		
		if msgtime>0 then
			sprint(msg,0,118,7)
			msgtime-=1
		end
	end

	camera(camera_x,camera_y)
end

level_index=conf_level

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
