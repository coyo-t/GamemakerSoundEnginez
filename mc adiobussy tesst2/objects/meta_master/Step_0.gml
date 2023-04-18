player.set_input(
	keyboard_check_direct(ord("W")) - keyboard_check_direct(ord("S")),
	keyboard_check_direct(ord("D")) - keyboard_check_direct(ord("A"))
)

var mmouse = mouse_check_button(mb_middle)
var rmouse = mouse_check_button(mb_right)

if rmouse or mmouse
{
	var ww = window_get_width()>>1
	var wh = window_get_height()>>1
	if mouse_check_button_pressed(mb_middle) or mouse_check_button_pressed(mb_right)
	{
		window_mouse_set(ww, wh)
	}
	else
	{
		var mx = display_mouse_get_x() - window_get_x()
		var my = display_mouse_get_y() - window_get_y()
		window_mouse_set(ww, wh)
		if rmouse
		{
			player.yaw -= (ww - mx) * 0.5
		}
		if mmouse
		{
			var dt = delta_time / 1000000
			var vs = (wh-my) * 0.05 * dt
			var hs = (mx-ww) * 0.05 * dt
			player.hspeed += hs
			player.vspeed += vs
		}
	}
}


if mouse_check_button_pressed(mb_left)
{
	audio.queue_sound(audio.soundmap[$"glass"], new PointEmitter(0, 0, 0, player))
	
	repeat irandom_range(8, 16)
	{
		var rx = random_range(-0.8, 0.8)
		var ry = random_range(-0.8, 0.8)
		var part = new ShitParticleEntity(rx, ry, 0)
		part.hspeed = rx * random_range(0.075, 0.15)
		part.vspeed = random_range(0.1, 0.4) + abs(ry * 0.2)
		part.yaw_speed *= part.hspeed * part.vspeed * 64
		add_entity(part)
	}
	
	//audio.queue_sound(audio.soundmap[$"holyshit"], new EntityEmitter(testent, player))
	//audio_play_sound(sfx_themoney, 1, false)
}

