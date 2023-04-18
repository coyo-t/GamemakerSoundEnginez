tfac = 1.0-(time_source_get_time_remaining(timer)/time_source_get_period(timer))

var cur_viewmat = matrix_get(matrix_view)
var cur_projmat = matrix_get(matrix_projection)

matrix_set(matrix_view,       viewmat)
matrix_set(matrix_projection, projmat)
gpu_push_state()

gpu_push_state()
gpu_set_tex_repeat(true)
draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(spr_grid, 0))
	draw_vertex_texture(-8, -8, 0,  16)
	draw_vertex_texture(+8, -8, 16, 16)
	draw_vertex_texture(-8, +8, 0,  0)
	draw_vertex_texture(+8, +8, 16, 0)
draw_primitive_end()
gpu_pop_state()

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

var t = get_timer()/1000000
var dist = 1
var hhh = 0.0075
draw_sprite_ext(
	spr_speaker,
	0,
	-(sin(t*pi*0.5)*dist),
	+(cos(t*pi*0.5)*dist),
	hhh, -hhh, 0, c_white, 1
)

gpu_pop_state()
matrix_set(matrix_view,       cur_viewmat)
matrix_set(matrix_projection, cur_projmat)


