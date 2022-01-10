globalvar Render;
Render = {};
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
Render.format = vertex_format_end();
Render.matrix_default = matrix_build_identity();

// .obj file parse
function obj_import(fn,format)
{
	///@func obj_import(filename, import_format)
	// returns : ds_map populated with datameshes
	show_debug_message("[Loading...] "+fn);
	var fd = parse_string(fn, "/");
	var directory = "";
	if ( array_length(fd) > 1 )
	{
		for ( var i=0; i<array_length(fd)-1; i++ )
		{
			directory += fd[i]+"/";
		}
	}
		
	var f = parse_begin(fn);
	if ( !f ) { exit; }
	
	var mtl		= "";
	var mfn		= ds_map_create();
	var mesh 	= ds_map_create();
	var vertex	= ds_list_create();
	var normal	= ds_list_create();
	var tcoord	= ds_list_create();
		
	while ( !parse_completed(f) )
	{
		var t = parse_line_ext(f, " ");
		switch(t[0])
		{
			case "mtllib"	: 
				var mfile = parse_begin(directory+t[1]);
				if ( !mfile ) { break; } 
				
				var cmtl = "";
				while ( !parse_completed(mfile) )
				{
					var mstr = parse_line_ext(mfile, " ");
					switch(mstr[0])
					{
						case "newmtl"	:
							if ( is_undefined(mfn[? mstr[1]]) )
							{
								mfn[? mstr[1]] = new datamtl();
								mfn[? mstr[1]].name = mstr[1];
								
								show_debug_message(".	Material '"+mstr[1]+"' succesfully loaded!");
							}
							cmtl = mstr[1];
						break;
						case "Kd"		: 
							mfn[? cmtl].color = new vec3(real(mstr[1]), real(mstr[2]), real(mstr[3]));
						break;
						case "map_Kd"	: 
							if ( file_exists(directory+mstr[1]) )
							{
								mfn[? cmtl].texture = sprite_add(directory+mstr[1], 0, 0, 0, 0, 0);
								show_debug_message(".	Texture '"+mstr[1]+"' succesfully loaded!");
							}
						break;
					}
				}
				parse_end(mfile);
			break;
			
			case "vt"		: ds_list_add( tcoord, new vec2(
								real(t[1]), 
								real(t[2])) 
							); break;
							
			case "v"		: ds_list_add( vertex, new vec3(
								real(t[abs(format[0])])*sign(format[0]),
								real(t[abs(format[1])])*sign(format[1]), 
								real(t[abs(format[2])])*sign(format[2])) 
							);  break;
							
			case "vn"		: ds_list_add( normal, new vec3(
								real(t[abs(format[0])])*sign(format[0]),
								real(t[abs(format[1])])*sign(format[1]), 
								real(t[abs(format[2])])*sign(format[2])) 
							);  break;
										
			case "usemtl"	: 
				mtl = t[1];
				if ( is_undefined(mesh[? mtl]) )
				{ 
					mesh[? mtl] = new datamesh();
				} 
			break;
			case "f"		: 
				for ( var a=1; a<array_length(t); a++ )
				{
					var v, n, c;
					v = vertex;
					n = normal;
					c = tcoord;

					var info = parse_string(t[a], "/");
					if ( !is_undefined(mesh[? mtl]) )
					{
						with ( mesh[? mtl] )
						{
							var vv = ds_list_find_value(v, real(info[0]) - 1 );
							var nn = ds_list_find_value(n, real(info[2]) - 1 );
							var tt = ds_list_find_value(c, real(info[1]) - 1 );
							
							// Build quads if needed (useful for blender)
							if ( a > 3 )
							{
								var v1,v2,n1,n2,t1,t2,i1,i2;
								var i1 = parse_string(t[a-3], "/");
								var i2 = parse_string(t[a-1], "/");
								
								v1 = ds_list_find_value(v, real(i1[0]) - 1 );
								n1 = ds_list_find_value(n, real(i1[2]) - 1 );
								t1 = ds_list_find_value(c, real(i1[1]) - 1 );
																		 
								v2 = ds_list_find_value(v, real(i2[0]) - 1 );
								n2 = ds_list_find_value(n, real(i2[2]) - 1 );
								t2 = ds_list_find_value(c, real(i2[1]) - 1 );
								
								ds_list_add( verts, v1 );
								ds_list_add( norms, n1 );
								ds_list_add( coord, t1 );
								
								ds_list_add( verts, v2 );
								ds_list_add( norms, n2 );
								ds_list_add( coord, t2 );
							}
							
							// Add vertices, normals, and texcoords
							ds_list_add( verts, vv );
							ds_list_add( norms, nn );
							ds_list_add( coord, tt );
							
							// Create bounds
							calculate_bounds(vv);
							
							// Add material
							var newmtl = mfn[? mtl];
							if ( is_undefined(newmtl) )
							{
								newmtl = new datamtl();
								newmtl.name += string(ds_map_size(mfn)+1);
							}
							mtl_add(newmtl);
						}
					}
				}
			break;
		}
	}
	parse_end(f);

	
	ds_list_destroy(vertex);
	ds_list_destroy(normal);
	ds_list_destroy(tcoord);
	ds_map_destroy(mfn);
	
	if ( ds_map_size(mesh) > 0 )
	{
		show_debug_message(".	Mesh '"+fn+"' succesfully loaded!");	
		show_debug_message("");
	}
	return mesh;
}

// Datamesh
function datamesh() constructor
{
	///@func datamesh()
	verts	= ds_list_create();
	norms	= ds_list_create();
	coord	= ds_list_create();
	
	color	= new vec3(1);
	texture = -1;
	mtlname = "empty_material";

	bounds = [ 999999, 999999, 999999, -999999, -999999, -999999 ];
	
	static free = function()
	{
		///@func free()
		ds_list_destroy(verts);
		ds_list_destroy(norms);
		ds_list_destroy(coord);
	}
	
	static calculate_bounds = function(v)
	{
		///@func calculate_bounds(vec3)
		bounds[@ 0] = min(bounds[0], v.x);
		bounds[@ 1] = min(bounds[1], v.y);
		bounds[@ 2] = min(bounds[2], v.z);
		bounds[@ 3] = max(bounds[3], v.x);
		bounds[@ 4] = max(bounds[4], v.y);
		bounds[@ 5] = max(bounds[5], v.z);
	}
	
	static mtl_add = function(m)
	{
		///@func mtl_add(datamtl);
		color	= m.color;
		texture = m.texture;
		mtlname = m.name;
	}
	
	static build = function()
	{
		///@func build()
		var buffer = buffer_create(1, buffer_grow, 1);
		
		for ( var i=0; i<ds_list_size(verts); i++ )
		{
			var v, n, t;
			v = verts[| i];
			n = norms[| i];
			t = coord[| i];
						
			buffer_write(buffer, buffer_f32, v.x);
			buffer_write(buffer, buffer_f32, v.y);
			buffer_write(buffer, buffer_f32, v.z);
			
			buffer_write(buffer, buffer_f32, n.x);
			buffer_write(buffer, buffer_f32, n.y);
			buffer_write(buffer, buffer_f32, n.z);
			
			buffer_write(buffer, buffer_u8, 255);
			buffer_write(buffer, buffer_u8, 255);
			buffer_write(buffer, buffer_u8, 255);
			buffer_write(buffer, buffer_u8, 255);
			
			buffer_write(buffer, buffer_f32, t.x);
			buffer_write(buffer, buffer_f32, t.y);
		}
		return buffer;
	}
}
function datamesh_map_free(d)
{
	///@func datamesh_map_free(datamesh_map)
	for ( var m=ds_map_find_first(d); !is_undefined(m); m=ds_map_find_next(d, m) )
	{
		d[? m]. free();
	}
	ds_map_destroy(d);
}	
function datamtl() constructor
{
	name	= "new_material";
	texture = -1;
	color	= new vec3(1);
}	

// Mesh building
function mesh_struct() constructor
{	
	///@func mesh_struct();
	buff		= [];
	vbuff		= [];
	material	= [];
	bounds		= [];
	mesh_total	= 0;
	primtype	= pr_trianglelist;
			
	static load = function(d)
	{
		///@func load(datamesh_map)
		for ( var m=ds_map_find_first(d); !is_undefined(m); m=ds_map_find_next(d, m) )
		{	
			// Get datamesh data
			var mesh = d[? m];
			
			// Buffers
			buff[mesh_total]	= mesh. build();
			vbuff[mesh_total]	= vertex_create_buffer_from_buffer(buff[mesh_total], Render.format);
			
			// Bounds
			bounds[mesh_total]	= 
			{
				minimum : new vec3(mesh.bounds[0], mesh.bounds[1], mesh.bounds[2]),
				maximum : new vec3(mesh.bounds[3], mesh.bounds[4], mesh.bounds[5])
			}
			
			// Load materials
			material[mesh_total]				= new material3d(mesh. mtlname);
			material[mesh_total].albedo			= new vec3(mesh.color);
			material[mesh_total].texture		= mesh.texture == -1 ? -1 : sprite_get_texture(mesh. texture, 0);
			
			// Finalize
			vertex_freeze(vbuff[mesh_total]);
			mesh_total++;
		}	
	}
	
	static destroy = function()
	{
		for ( var i=0; i<mesh_total; i++ )
		{	
			vertex_delete_buffer(vbuff[mesh_total]);
			buffer_delete(buff[mesh_total]);
		}
	}
	
	static draw = function()
	{
		///@func draw()
		for ( var i=0; i<mesh_total; i++ )
		{
			var b = bounds[i];
			
			material[i]. apply();
			material[i]. set_bounds(b.minimum, b.maximum);
			
				vertex_submit(
					vbuff[i], 
					primtype, 
					material[i].texture
				);
				
			material[i]. reset();
		}
	}
	
	static draw_ext = function(p,r,s)
	{
		///@func draw_ext(pos_vec, rot_vec, scl_vec)
		matrix_set(matrix_world, mat3(p,r,s));
			draw();
		matrix_set(matrix_world, Render.matrix_default);
	}
		
	static get_material_names = function()
	{
		///@func get_material_names()
		// returns: array of material id names
		var m = [];
		for ( var i=0; i<mesh_total; i++ )
		{
			m[i] = material[i].name;
		}
		return m;
	}
}
function mesh_import(f)
{
	///@func mesh_import(filename, *import_format)
	var dm, p, m;
	p = [ f, [1,2,3] ];
	
	for ( var i=0; i<argument_count; i++ )
	{
		p[i] = argument[i];	
	}

	dm	= obj_import(p[0], p[1]);
	m	= new mesh_struct();
	with ( m ) load(dm);
	
	datamesh_map_free(dm);
	return m;
}
