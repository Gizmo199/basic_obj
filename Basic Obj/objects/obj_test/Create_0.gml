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
	
	var import_scale = new vec3(32, 32, -32);
	model = mesh_import( "Player/player.obj", import_scale );
	with ( model )
	{
		position = new vec3(other.x, other.y + 64, 0);
		rotation = new vec3(0);
		scale	 = new vec3(1);
		
		// Set some parameters for altering material 0
		with ( material[0] )
		{
			texchg	= sprite_get_texture(sp_texture, 0);	// Set our 'change' texture
			texdef	= texture;								// get our default texture and save it
			hue		= 0;									// set start hue to red
		}
	}
	
#endregion
#region Batched Suzanne models

	// Create a batch mesh
	suzanne = mesh_import( "Suzanne/Suzanne.obj", import_scale);
	with ( suzanne )
	{
		// We need to invert the normal format of suzanne since she
		// is a blender export. This is only used for batching
		norm_format = new vec3(-1);
				
		// Set some material stuff. Suzannes.obj is has a 'none' material
		// You can also call material[0] = new material3d("suzanne_material");
		with ( material[0] )
		{
			cullmode	= cull_counterclockwise;	
			texture		= sprite_get_texture(sp_texture, 0);
			texrepeat	= new vec2(10);
		}
	}
	
	var bmesh = new batch_mesh();
		
	// Add randomly rotated and scaled models to our batch mesh
	repeat(4)
	{
		var xx = random(room_width);	// randomized x position
		var yy = random(room_height);	// randomized y position
		var zz = random_range(0, 64);	// randomized z position
		var rx = random(360);			// randomized x rotation
		var ry = random(360);			// randomized y rotation
		var rz = random(360);			// randomized z rotation
		var sc = random_range(.5, 1.5)	// randomized scaling
		
		var pos = new vec3(xx, yy, zz);	// position vector 3
		var rot = new vec3(rx, ry, rz);	// rotation vector 3
		var scl = new vec3(sc);			// scale vector 3
		
		// Add our previously imported suzanne model to our batch mesh
		// We will then set the model to be randomly positioned, rotated, and scaled
		bmesh. add( suzanne, pos, rot, scl );	// You could even put: choose(suzanne, model) and it will randomly add one or the other!
	}
		
	// We then need to build our batch mesh
	batch = bmesh. build();
	
#endregion