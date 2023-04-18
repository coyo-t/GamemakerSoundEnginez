show_debug_overlay(true)
//audio_debug(true)
audio_master_gain(0.9)

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
