player.set_input(
	keyboard_check(ord("W")) - keyboard_check(ord("S")),
	keyboard_check(ord("D")) - keyboard_check(ord("A"))
)

begin
	var hinp = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left)
	var vinp = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up)
	
	if hinp | vinp == 0
	{
		player_cur_tile += mouse_wheel_down() - mouse_wheel_up()
		player_cur_tile &= 0xFF
	}
	else
	{
		var tx = player_cur_tile & 0xF
		var ty = (player_cur_tile >> 4) & 0xF
		tx += hinp
		ty += vinp
		tx &= 0xF
		ty &= 0xF
		player_cur_tile = tx | (ty << 4)
	}
end

var ww = window_get_width()
var wh = window_get_height()
var mmouse = mouse_check_button(mb_middle)
var rmouse = mouse_check_button_pressed(mb_right)
var lmouse = mouse_check_button_pressed(mb_left)

begin
	var asp = window_get_height()/window_get_width()
	var mx = (display_mouse_get_x() - window_get_x()) / window_get_width()  * 2 - 1
	var my = (display_mouse_get_y() - window_get_y()) / window_get_height() * 2 - 1
	mx *= 8
	my *= 8 * -asp
	mx *= 0.5
	my *= 0.5

	var rsin = dsin(player.yaw)
	var rcos = dcos(player.yaw)
	var tx = mx
	player_mouse.x = player.get_draw_x(tfac) + (mx*rcos + my*rsin)
	player_mouse.y = player.get_draw_y(tfac) + (my*rcos - tx*rsin)
	
end

if mmouse
{
	var hww = ww>>1
	var hwh = wh>>1
	if mouse_check_button_pressed(mb_middle) or mouse_check_button_pressed(mb_right)
	{
		window_mouse_set(hww, hwh)
	}
	else
	{
		var mx = display_mouse_get_x() - window_get_x()
		var my = display_mouse_get_y() - window_get_y()
		window_mouse_set(hww, hwh)
		if mmouse
		{
			player.yaw -= (hww - mx) * 0.5
		}
		//if mmouse
		//{
		//	var dt = delta_time / 1000000
		//	var vs = (hwh-my) * 0.05 * dt
		//	var hs = (mx-hww) * 0.05 * dt
		//	player.hspeed += hs
		//	player.vspeed += vs
		//}
	}
}


if lmouse or rmouse
{
	var px = floor(player_mouse.x)+0.5
	var py = floor(player_mouse.y)+0.5
	if lmouse || (rmouse && player_cur_tile == 0)
	{
		var tt = world.break_tile(floor(player_mouse.x), -floor(player_mouse.y)-1)
		if tt > 0
		{
			audio.queue_sound(audio.soundmap[$"glass"], new PointEmitter(px, py, depth, player))
			var i = 0
			repeat irandom_range(8, 16)
			{
				var rx = random_range(-0.4, +0.4) + player.hspeed
				var ry = random_range(-0.4, +0.4) + player.vspeed
				var part = new ShitTerrainParticleEntity(px+rx, py+ry, depth+irandom_range(-i,i), tt)
				part.hspeed = rx * random_range(0.075, 0.25)
				part.vspeed = random_range(0.1, 0.4) + abs(ry * 0.2)
				part.yaw_speed *= part.hspeed * part.vspeed * 64
				part.x += part.hspeed
				part.y += part.vspeed
				add_entity(part)
				i++
			}
		}
	}
	else
	{
		if world.place_tile(floor(player_mouse.x), -floor(player_mouse.y)-1, player_cur_tile)
		{
			audio.queue_sound(audio.soundmap[$"stone"], new PointEmitter(px, py, depth, player))
		}
	}
}

