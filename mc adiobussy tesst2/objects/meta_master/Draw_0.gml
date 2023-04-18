var t = get_timer()/1000000
var mx = floor(player_mouse.x)
var my = floor(player_mouse.y)

//gpu_push_state()
//gpu_set_tex_repeat(true)
//draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(spr_grid, 0))
//	draw_vertex_texture(-8, -8, 0,  16)
//	draw_vertex_texture(+8, -8, 16, 16)
//	draw_vertex_texture(-8, +8, 0,  0)
//	draw_vertex_texture(+8, +8, 16, 0)
//draw_primitive_end()
//gpu_pop_state()

begin // draw cursor highlight
	gpu_push_state()
	
	var ct = sin(t * 10) * 0.5 + 0.5
	ct *= 0.75
	var ct2 = sin(t * 5) * 0.5 + 0.5
	ct2 *= 0.5
	gpu_set_alphatestenable(false)
	gpu_set_ztestenable(false)
	
	var mrm = matrix_get(matrix_world)
	matrix_set(matrix_world, [1/16,0,0,0, 0,-1/16,0,0, 0,0,1,0, mx,my+1,0,1])
	
	draw_set_alpha(ct2)
	gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha)
	draw_tile(ts_terrain, player_cur_tile, 0, 0, 0)
	
	draw_set_alpha(ct)
	gpu_set_blendmode_ext(bm_src_alpha, bm_one)
	draw_tile(ts_terrain, player_cur_tile, 0, 0, 0)

	draw_set_alpha(1)
	matrix_set(matrix_world, mrm)
	//gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha)
	//draw_primitive_begin(pr_trianglestrip)
	//	draw_vertex_colour(mx,   my,   c_white, ct2)
	//	draw_vertex_colour(mx+1, my,   c_white, ct2)
	//	draw_vertex_colour(mx,   my+1, c_white, ct2)
	//	draw_vertex_colour(mx+1, my+1, c_white, ct2)
	//draw_primitive_end()
	
	//draw_primitive_begin(pr_trianglestrip)
		//draw_vertex_colour(mx,   my,   c_white, ct)
		//draw_vertex_colour(mx+1, my,   c_white, ct)
		//draw_vertex_colour(mx,   my+1, c_white, ct)
		//draw_vertex_colour(mx+1, my+1, c_white, ct)
	//draw_primitive_end()
	gpu_pop_state()
	draw_primitive_begin(pr_linestrip)
		draw_vertex_colour(mx,  my,  c_black,1)
		draw_vertex_colour(mx+1,my,  c_black,1)
		draw_vertex_colour(mx+1,my+1,c_black,1)
		draw_vertex_colour(mx,  my+1,c_black,1)
		draw_vertex_colour(mx,  my,  c_black,1)
	draw_primitive_end()
end

for (var i = array_length(entities)-1; i >= 0; i--)
{
	var entity = entities[i]
	if entity.is_removed()
	{
		array_delete(entities, i, 1)
		continue
	}
	entity.draw(tfac)
}

var dist = 1
var hhh = 0.0075

draw_sprite_ext(
	spr_speaker,
	0,
	-(sin(t*pi*0.5)*dist),
	+(cos(t*pi*0.5)*dist),
	hhh, -hhh, 0, c_white, 1
)


draw_primitive_begin(pr_linelist)
	draw_vertex_colour(0,   0,   c_red,    1.0)
	draw_vertex_colour(100, 0,   c_red,    1.0)
	draw_vertex_colour(0,   0,   c_yellow, 1.0)
	draw_vertex_colour(0,   100, c_yellow, 1.0)
draw_primitive_end()


