if ( target )
{
	lookat = new vec3(target.x, target.y, target.z);	
}
	
#region Look around

	if ( mouse_check_button(mb_right) )
	{
		var m = new vec2(window_mouse_get_x(), window_mouse_get_y());
		var c = new vec2(window_get_width()*.5, window_get_height()*.5);
		
		if ( !mouse_check_button_pressed(mb_right) )
		{		
			rotation.z -= ( m.x - c.x ) * sensitivity;
			rotation.y -= ( ( m.y - c.y ) * sensitivity ) * ( first_person ? -1 : 1 );
		}
		
		window_mouse_set(c.x, c.y);
	}
	rotation.y = clamp(rotation.y, -89, 89);
	forward = rotation.z - 90;
	
	distance += ( mouse_wheel_down() - mouse_wheel_up() ) * 32;
	distance = clamp(distance, 64, 480);
	
#endregion
#region Projection

	// Move camera according to rotation
	var l, o;
	if ( !first_person )
	{
		// Third person perspective
		l = new vec3(lookat);
		l. subtract(
			new vec3(
				dcos(rotation.z) * dcos(rotation.y) * distance,
				dsin(rotation.z) * dcos(rotation.y) * distance,
				dsin(rotation.y) * distance
			)
		);
			
		o = [ l, lookat ];
	}
	else
	{
		// First person perspective
		l = new vec3(lookat);
		l. add(
			new vec3(
				dcos(rotation.z) * dcos(rotation.y) * distance,
				dsin(rotation.z) * dcos(rotation.y) * distance,
				dsin(rotation.y) * distance
			)
		);
			
		o = [ lookat, l ];
	}
		
	// Build lookat
	var p = matrix_build_lookat( o[0].x, o[0].y, o[0].z, o[1].x, o[1].y, o[1].z, up.x, up.y, up.z );
	camera_set_view_mat(view_camera[view], p);
	
#endregion