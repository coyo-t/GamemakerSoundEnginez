show_debug_overlay(true)
//audio_debug(true)
audio_master_gain(0.75)

gpu_set_alphatestenable(true)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)

player_cur_tile = 31//1

tfac = 0

function tick ()
{
	for (var i = array_length(entities)-1; i >= 0; i--)
	{
		var entity = entities[i]
		if entity.is_removed()
		{
			remove_entity(i)
			continue
		}
		entity.tick()
	}
	player.clear_input()
}

audio = instance_create_depth(0,0,0,meta_audio)
world = instance_create_depth(0,0,0,meta_world)

timer = time_source_create(
	time_source_game,
	1.0 / 20.0,
	time_source_units_seconds,
	method(self, tick),
	[],
	-1
)

time_source_start(timer)

function add_entity (e)
{
	array_push(entities, e)
	array_push(entity_uuids, uuid_generate())
}

function remove_entity (i)
{
	array_delete(entities, i, 1)
	array_delete(entity_uuids, i, 1)
}

player = new Player(0, 0)
entities     = []
entity_uuids = []

player_mouse = {
	x: 0,
	y: 0,
}

view_scale = 1/8
viewmat = [
	view_scale,0,0,0,
	0,view_scale,0,0,
	0,0,1,0,
	0,0,16000,1
]
projmat = matrix_build_projection_ortho(1, room_height/room_width, 0, 32000)

testent = new TestEntity(0, 0)
//add_entity(testent)
add_entity(player)

function setup_draw (_is_begin)
{
	static cur_viewmat = undefined
	static cur_projmat = undefined
	if _is_begin
	{
		tfac = 1.0-(time_source_get_time_remaining(timer)/time_source_get_period(timer))

		cur_viewmat = matrix_get(matrix_view)
		cur_projmat = matrix_get(matrix_projection)

		matrix_stack_push(viewmat)
		matrix_stack_push(matrix_build(0,0,0, 0,0,-player.yaw,1,1,1))
		matrix_stack_push(matrix_build(-player.get_draw_x(tfac),-player.get_draw_y(tfac),0, 0,0,0,1,1,1))
		matrix_set(matrix_view,       matrix_stack_top())
		matrix_stack_clear()

		matrix_set(matrix_projection, projmat)
		gpu_push_state()
	}
	else
	{
		gpu_pop_state()
		matrix_set(matrix_view,       cur_viewmat)
		matrix_set(matrix_projection, cur_projmat)
	}
}
