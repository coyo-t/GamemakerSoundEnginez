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
		
		var finp = f_input
		var sinp = s_input
		var mmag = finp*finp + sinp*sinp
		if mmag != 0 and mmag != 1
		{
			mmag = 1.0 / sqrt(mmag)
			finp *= mmag
			sinp *= mmag
		}
		vspeed += finp * 0.1
		hspeed += sinp * 0.1
		
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
		var ss = dsin(yaw)
		var sc = dcos(yaw)
		var ax = dx+ss*2
		var ay = dy+sc*2
		draw_set_colour(c_red)
		draw_primitive_begin(pr_linelist)
			draw_vertex(dx, dy)
			draw_vertex(ax, ay)
			draw_vertex(dx, dy)
			draw_vertex(dx-sc, dy+ss)
			draw_vertex(dx, dy)
			draw_vertex(dx+sc, dy-ss)
		draw_primitive_end()
		draw_primitive_begin(pr_trianglelist)
			draw_vertex(dx+ss*2, dy+sc*2)
			draw_vertex((dx+ss*1.8)-sc*.1, (dy+sc*1.8)+ss*.1)
			draw_vertex((dx+ss*1.8)+sc*.1, (dy+sc*1.8)-ss*.1)
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
	lifetime = 4 / (random_range(0.1, 0.2))
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
		matrix_set(matrix_world, matrix_build(dx, dy, 0, 0, 0, dyaw, part_size, part_size, 1))
		
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
