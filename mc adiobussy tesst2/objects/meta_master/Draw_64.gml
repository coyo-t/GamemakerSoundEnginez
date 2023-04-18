var mx = display_mouse_get_x() - window_get_x()
var my = display_mouse_get_y() - window_get_y()


begin
	var sz = 4
	var dx = mx+16*sz
	var dy = my+16*sz
	matrix_set(matrix_world, [sz,0,0,0, 0,sz,0,0, 0,0,1,0, dx,dy,0,1])
	var tnfo = tileset_get_info(ts_terrain)
	var tuvs = tileset_get_uvs(ts_terrain)

	var u0 = player_cur_tile & 15
	var v0 = player_cur_tile >> 4
	u0 = (tnfo.tile_horizontal_separator << 1) * u0 + (u0 << 4) + tnfo.tile_horizontal_separator
	v0 = (tnfo.tile_vertical_separator   << 1) * v0 + (v0 << 4) + tnfo.tile_vertical_separator
	
	var u1 = u0 + 16
	var v1 = v0 + 16

	u0 = lerp(tuvs[0], tuvs[2], u0/tnfo.width)
	v0 = lerp(tuvs[1], tuvs[3], v0/tnfo.height)
	u1 = lerp(tuvs[0], tuvs[2], u1/tnfo.width)
	v1 = lerp(tuvs[1], tuvs[3], v1/tnfo.height)

	/*
	       TC
	     _.o._
	LU o<_   _>o  RU
	   |  'o'--|- MC
	LD o._ | _.o  RD
	      'o'
	       BC
	*/
	begin
		draw_primitive_begin_texture(pr_trianglelist, tnfo.texture)
			var c = c_white
			draw_vertex_texture_colour(  0,   0, u0, v1, c, 1.0) // mc
			draw_vertex_texture_colour(  0, -16, u1, v0, c, 1.0) // tc
			draw_vertex_texture_colour(-14,  -8, u0, v0, c, 1.0) // lu
			draw_vertex_texture_colour(  0, -16, u1, v0, c, 1.0) // tc
			draw_vertex_texture_colour(  0,   0, u0, v1, c, 1.0) // mc
			draw_vertex_texture_colour( 14,  -8, u1, v1, c, 1.0) // rc
			
			c = c_grey
			draw_vertex_texture_colour(  0, 16, u1, v1, c, 1.0) // bc
			draw_vertex_texture_colour(-14,  8, u0, v1, c, 1.0) // ld
			draw_vertex_texture_colour(-14, -8, u0, v0, c, 1.0) // lu
			draw_vertex_texture_colour(-14, -8, u0, v0, c, 1.0) // ld
			draw_vertex_texture_colour(  0, 16, u1, v1, c, 1.0) // bc
			draw_vertex_texture_colour(  0,  0, u1, v0, c, 1.0) // mc
			
			c = c_ltgrey
			draw_vertex_texture_colour(0,   0, u0, v0, c, 1.0) // mc
			draw_vertex_texture_colour(0,  16, u0, v1, c, 1.0) // bc
			draw_vertex_texture_colour(14,  8, u1, v1, c, 1.0) // rd
			draw_vertex_texture_colour(0,   0, u0, v0, c, 1.0) // mc
			draw_vertex_texture_colour(14,  8, u1, v1, c, 1.0) // rd
			draw_vertex_texture_colour(14, -8, u1, v0, c, 1.0) // ru
		draw_primitive_end()
	end
	matrix_set(matrix_world, matrix_build_identity())
end
