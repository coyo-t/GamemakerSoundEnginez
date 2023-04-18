function Active (_x=0, _y=0, _z=0) constructor begin
	x = _x
	y = _y
	z = _z
	pitch = 0
	yaw   = 0
	
	xprevious = x
	yprevious = y
	zprevious = z

	__removed = false

	///@func tick()
	static tick = function ()
	{
		update_previous()
	}
	
	///@func draw(tfac)
	static draw = function (_t)
	{
	}
	
	///@func is_removed()
	static is_removed = function ()
	{
		return __removed
	}
	
	///@func remove()
	static remove = function ()
	{
		__removed = true
	}
	
	///@func get_draw_x(tfac)
	static get_draw_x = function (_tfac)
	{
		return lerp(xprevious, x, _tfac)
	}
	
	///@func get_draw_y(tfac)
	static get_draw_y = function (_tfac)
	{
		return lerp(yprevious, y, _tfac)
	}
	
	///@func get_draw_z(tfac)
	static get_draw_z = function (_tfac)
	{
		return lerp(zprevious, z, _tfac)
	}
	
	///@func update_previous()
	static update_previous = function ()
	{
		xprevious = x
		yprevious = y
		zprevious = z
	}
end

function Entity (_x=0, _y=0, _z=0) : Active(_x,_y,_z)
constructor begin
	vspeed = 0  // x velocity
	hspeed = 0  // y velocity
	depth  = 0  // z velocity
	vspeedprevious = vspeed
	hspeedprevious = hspeed
	depthprevious  = depth
	
	///@func update_previous()
	static update_previous = function ()
	{
		xprevious = x
		yprevious = y
		zprevious = z
		vspeedprevious = vspeed
		hspeedprevious = hspeed
		depthprevious  = depth
	}
end


function Player (_x=0, _y=0, _z=0) : Entity(_x,_y,_z)
constructor begin
	f_input = 0  // Forwards input
	s_input = 0 // Strafe input
	
	///@func tick()
	static tick = function ()
	{
		update_previous()
		
		var sinyaw = dsin(yaw)
		var cosyaw = dcos(yaw)
		
		var finp = f_input
		var sinp = s_input
		var mmag = finp*finp + sinp*sinp
		if mmag != 0 and mmag != 1
		{
			mmag = 1.0 / sqrt(mmag)
			finp *= mmag
			sinp *= mmag
		}
		finp *= 0.1
		sinp *= 0.1
		
		hspeed += sinp * cosyaw + finp * sinyaw
		vspeed += finp * cosyaw - sinp * sinyaw
		
		x += hspeed
		y += vspeed
		
		vspeed *= 0.91 * 0.6
		hspeed *= 0.91 * 0.6
	}
	
	///@func draw(tfac)
	static draw = function (_t)
	{
		var dx = get_draw_x(_t)
		var dy = get_draw_y(_t)
		var sz = 0.6 * 0.5
		draw_primitive_begin(pr_trianglestrip)
			draw_vertex_colour(dx-sz, dy-sz, c_yellow, 1)
			draw_vertex_colour(dx+sz, dy-sz, c_yellow, 1)
			draw_vertex_colour(dx-sz, dy+sz, c_yellow, 1)
			draw_vertex_colour(dx+sz, dy+sz, c_yellow, 1)
		draw_primitive_end()
		
		draw_set_colour(c_white)
	}
	
	/// @func set_input(forwards, strafe)
	static set_input = function (_forward, _strafe)
	{
		f_input = _forward
		s_input = _strafe
	}
	
	/// @func clear_input()
	static clear_input = function ()
	{
		s_input = f_input = 0
	}
end

function TestEntity (_x=0, _y=0, _z=0) : Active(_x,_y,_z)
constructor begin
	static DIV = 0.0075
	static DIST = 32 * DIV
	xstart = x
	ystart = y
	zstart = z
	ticks = 0
	
	///@func tick()
	static tick = function ()
	{
		update_previous()
		
		x = xstart + sin(ticks / 10 * pi) * (-32*DIV)
		y = ystart + cos(ticks / 20 * pi) * (-16*DIV)
		ticks++
	}
	
	///@func draw(tfac)
	static draw = function (_t)
	{
		var dx = get_draw_x(_t)
		var dy = get_draw_y(_t)
		var tt = get_timer()/1000000
		draw_sprite_ext(spr_test, 0, dx+sin(tt*pi)*DIST, dy+cos(tt*pi)*DIST,DIV,-DIV,0,c_white,1)
		draw_primitive_begin(pr_linelist)
			draw_vertex_colour(dx-DIST,dy+DIST,c_yellow,1.0)
			draw_vertex_colour(dx+DIST,dy-DIST,c_yellow,1.0)
			draw_vertex_colour(dx-DIST,dy-DIST,c_yellow,1.0)
			draw_vertex_colour(dx+DIST,dy+DIST,c_yellow,1.0)
		draw_primitive_end()
	}
end


function ShitParticleEntity (_x=0,_y=0,_z=0) : Entity(_x,_y,_z)
constructor begin
	age = 0
	lifetime = 4 / (random_range(0.1, 0.3))
	part_size = random_range(4, 8) / 32.0
	yaw_speed = random_range(0, 45)
	oyaw = yaw
	///@func tick()
	static tick = function ()
	{
		update_previous()
		oyaw = yaw
		if (age++) >= lifetime
		{
			remove()
			return
		}
		
		x += hspeed
		y += vspeed
		
		yaw += yaw_speed
		yaw_speed *= 0.9
		
		vspeed *= 0.98
		vspeed -= 0.04
		hspeed *= 0.98
	}
	
	///@func draw(tfac)
	static draw = function (_t)
	{
		var dx = get_draw_x(_t)
		var dy = get_draw_y(_t)
		var dyaw = lerp(oyaw, yaw, _t)
		var m = matrix_get(matrix_world)
		var sz = part_size * clamp(1-power(1-(((lifetime-age)-_t)/lifetime), lifetime), 0, 1)
		matrix_stack_push(matrix_build(dx, dy, z, 0, 0, dyaw, 1, 1, 1))
		matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, sz, sz, 1))
		matrix_set(matrix_world, matrix_stack_top())
		matrix_stack_pop()
		matrix_stack_pop()
		
		draw_primitive_begin(pr_linestrip)
			draw_vertex(-1,-1)
			draw_vertex(+1,-1)
			draw_vertex(+1,+1)
			draw_vertex(-1,+1)
			draw_vertex(-1,-1)
		draw_primitive_end()
		
		matrix_set(matrix_world, m)
	}
	
end

function ShitTerrainParticleEntity (_x, _y, _z, _type) : ShitParticleEntity(_x,_y,_z)
constructor begin
	static tnfo = tileset_get_info(ts_terrain)
	static tuvs = tileset_get_uvs(ts_terrain)
	
	tiletype = _type
	
	s0 = irandom_range(0, 15)
	t0 = irandom_range(0, 15)
	s1 = irandom_range(s0+1, 16)
	t1 = irandom_range(t0+1, 16)

	u0 = _type & 15
	v0 = _type >> 4
	u0 = (tnfo.tile_horizontal_separator << 1) * u0 + (u0 << 4) + tnfo.tile_horizontal_separator
	v0 = (tnfo.tile_vertical_separator   << 1) * v0 + (v0 << 4) + tnfo.tile_vertical_separator
	
	u1 = u0 + s1
	v1 = v0 + t1
	u0 += s0
	v0 += t0
	u0 = lerp(tuvs[0], tuvs[2], u0/tnfo.width)
	v0 = lerp(tuvs[1], tuvs[3], v0/tnfo.height)
	u1 = lerp(tuvs[0], tuvs[2], u1/tnfo.width)
	v1 = lerp(tuvs[1], tuvs[3], v1/tnfo.height)
	
	///@func draw(tfac)
	static draw = function (_t)
	{
		var dx = get_draw_x(_t)
		var dy = get_draw_y(_t)
		var dyaw = lerp(oyaw, yaw, _t)
		var m = matrix_get(matrix_world)
		var sz = clamp(1-power(1-(((lifetime-age)-_t)/lifetime), lifetime), 0, 1)
		
		var sx = ((s1-s0) / 16.0) * sz
		var sy = ((t1-t0) / 16.0) * sz
		
		matrix_stack_push(matrix_build(dx, dy, z, 0, 0, dyaw, 1, 1, 1))
		matrix_stack_push(matrix_build(-sx*0.5, -sy*0.5, 0, 0, 0, 0, 1, 1, 1))
		matrix_set(matrix_world, matrix_stack_top())
		matrix_stack_pop()
		matrix_stack_pop()
		
		draw_primitive_begin_texture(pr_trianglestrip, tnfo.texture)
			draw_vertex_texture(0, 0, u0,v0)
			draw_vertex_texture(sx,0, u1,v0)
			draw_vertex_texture(0, sy,u0,v1)
			draw_vertex_texture(sx,sy,u1,v1)
		draw_primitive_end()
		draw_primitive_begin(pr_linestrip)
			draw_vertex_colour(0, 0, c_black,1)
			draw_vertex_colour(sx,0, c_black,1)
			draw_vertex_colour(sx,sy,c_black,1)
			draw_vertex_colour(0, sy,c_black,1)
			draw_vertex_colour(0, 0, c_black,1)
		draw_primitive_end()
		matrix_set(matrix_world, m)
	}
end

