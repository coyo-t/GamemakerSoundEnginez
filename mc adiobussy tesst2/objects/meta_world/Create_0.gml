tiles_lyr = layer_get_id("Tiles_1")
tiles = layer_tilemap_get_id(tiles_lyr)

function tilelyrdrawf ()
{
	static cur_world = undefined
	static wrld = matrix_build(0,0,0, 0,0,0, 1/16,-1/16,1)
	if is_undefined(cur_world)
	{
		cur_world = matrix_get(matrix_world)
		matrix_set(matrix_world, wrld)
	}
	else
	{
		matrix_set(matrix_world, cur_world)
		cur_world = undefined
	}
}

layer_script_begin(tiles_lyr, method(self, tilelyrdrawf))
layer_script_end(tiles_lyr, method(self, tilelyrdrawf))

function place_tile (_x, _y, _type)
{
	if _type == 0
	{
		return false
	}
	var tt = tilemap_get(tiles, _x, _y)
	if tt != 0 or tt == _type
	{
		return false
	}
	tilemap_set(tiles, _type, _x, _y)
	return true
}

function break_tile (_x, _y)
{
	var tt = tilemap_get(tiles, _x, _y)
	if tt == -1 or tt == 0
	{
		return 0
	}
	tilemap_set(tiles, 0, _x, _y)

	
	return tt
}
