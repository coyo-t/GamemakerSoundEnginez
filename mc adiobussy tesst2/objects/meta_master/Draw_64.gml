
//draw_set_colour(c_yellow)
//draw_text(32, 32, array_reduce(entity_uuids, function(p,c,i){return p+"\n"+c}, ""))
//draw_set_colour(c_white)

draw_set_colour(c_green)

draw_set_font(font_0)
draw_text(32, 32, string_ext(
	"X: {0}\nY: {1}\nYaw: {2}",
	[
		string(player.get_draw_x(tfac)), string(player.get_draw_y(tfac)), string(player.yaw)
	]
))

//var playing = audio.playing
//var olen = array_length(playing)
//var outs = "Not Playing... -v-\""
//if olen > 1
//{
//	outs = string(playing[olen-1])
//	if olen > 2
//	{
//		for (var i = olen-2; i >= 0; i--)
//		{
//			var e = playing[i]
//			outs = string_ext("{0}\n{1}", [string(e), outs])
//		}
//	}
//}
//draw_text(32, 32, outs)

draw_set_colour(c_white)
