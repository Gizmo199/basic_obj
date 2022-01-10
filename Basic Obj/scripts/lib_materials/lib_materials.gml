globalvar Material;
Material = {};
Material.library = ds_map_create();

function material3d(n) constructor
{
	///@func material3d(material_name)
	if ( !is_undefined(Material.library[? n]) )
	{
		show_debug_message("Material: '"+n+"' already existed! Material '"+n+"' was overwritten!");
	}
	Material.library[? n] = self;
	
	name		= n;
	shader		= shd_mtl_default;
	
	sun_dir		= new vec3(0, .5, -1);
	
	texture		= -1;
	texoffset   = new vec2(0);
	texrepeat	= new vec2(1);
	
	albedo		= new vec3(1);
	diffuse		= .5;
	specular	= .5;
	gloss		= .5;
	rim			= .1;
	
	static set_bounds = function(v1,v2)
	{
		///@func set_bounds(min_vec3, max_vec3)
		shader_set_vec3("bounds_min", v1);
		shader_set_vec3("bounds_max", v2);
	}
	
	static set = function()
	{
		///@func set()
		shader_set(shader);
		shader_set_vec2("texrepeat",	texrepeat);
		shader_set_vec2("texoffset",	texoffset);
		shader_set_vec3("sun_dir",		sun_dir);
		
		shader_set_vec3("albedo",		albedo);
		shader_set_float("diffuse",		diffuse);
		shader_set_float("specular",	specular);
		shader_set_float("glossiness",	gloss);
		shader_set_float("rim",			rim);
	}
	
	static reset = function()
	{
		///@func reset()
		shader_reset();
	}
	
	static clone = function(n)
	{
		///@func clone(new_material_name)
		var m = new material3d(n);
		with ( m )
		{
			name		= n;
			shader		= other.shader;
			sun_dir		= other.sun_dir;
			
			texture		= other.texture;
			texrepeat	= other.texrepeat;
			texoffset	= other.texoffset;
			
			albedo		= other.albedo;
			diffuse		= other.diffuse;
			specular	= other.specular;
			gloss		= other.gloss;
			rim			= other.rim;
		}
		return m;
	}
}
function material_library_delete()
{
	ds_map_destroy(Material.library);	
}
function material_exists(n)
{
	///@func material_exists(material_name)
	return !is_undefined(Material.library[? n]);
}
function material_get(n)
{
	///@func material_get(material_name)
	if ( !material_exists(n) )
	{
		show_debug_message("Material: '"+n+"' does not exist!");
		return -1;	
	}
	return Material.library[? n];
}