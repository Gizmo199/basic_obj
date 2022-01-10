#region Camera

	first_person	= true;			// First person camera
	view			= 0;			// View index
	fov				= 90;			// Perspective field of view
	distance		= 256;			// Distance from target (third person)
	aspect_ratio	= 16/9;			// Standard 16:9 aspect ratio
	near			= 1;			// Near clipping plane
	far				= 32000;		// Far clipping plane
	sensitivity		= .1;			// How sensitive our mouse look is


	view_enabled	= true;
	view_visible[view] = true;
					
	rotation		= new vec3(0, 0, 90);
	lookat			= new vec3(0);
	up				= new vec3(0, 0, -1);
	forward			= 0;
	target			= noone;

	display_reset(4, true);
	gpu_set_texrepeat(true);
	gpu_set_tex_mip_enable(mip_on);
	gpu_set_tex_mip_filter(tf_anisotropic);
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
	gpu_set_alphatestenable(true);
	layer_force_draw_depth(true, 0);

	var v = matrix_build_projection_perspective_fov(-fov, -aspect_ratio, near, far);	
	camera_set_proj_mat(view_camera[view], v);

	z		= -32;
	zstart	= z;
	target	= id;

#endregion
#region Model
	
	model = mesh_import("player.obj");
	with ( model )
	{
		position = new vec3(other.x, other.y + 64, 0);
		rotation = new vec3(0);
		scale	 = new vec3(32, 32, -32);
		
		// Play with the albedo color
		with ( material[0] )
		{
			texchg	= sprite_get_texture(sp_texture, 0);	// Set our 'change' texture
			texdef	= texture;								// get our default texture and save it
			hue		= 0;									// set start hue to red
		}
	}
	
#endregion