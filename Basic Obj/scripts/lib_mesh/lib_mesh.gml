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
function obj_import(fn,scale,format)
{
	///@func obj_import(filename, scale_vec3, import_format)
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
								real(t[abs(format[2])])*sign(format[2])). multiply(scale) 
							);  break;
							
			case "vn"		: ds_list_add( normal, new vec3(
								real(t[abs(format[0])])*sign(format[0]),
								real(t[abs(format[1])])*sign(format[1]), 
								real(t[abs(format[2])])*sign(format[2])). normalize()
							)  break;
										
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
	verts		= [];
	mesh_total	= 0;
	primtype	= pr_trianglelist;
	norm_format = new vec3(1);
			
	static load = function(d)
	{
		///@func load(datamesh_map)
		for ( var m=ds_map_find_first(d); !is_undefined(m); m=ds_map_find_next(d, m) )
		{	
			// Get datamesh data
			var mesh = d[? m];
			
			// Save the number of vertices
			verts[mesh_total]	= ds_list_size(mesh.verts);
			
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
			if ( is_undefined(Material.library[? mesh.mtlname]) )
			{
				material[mesh_total]			= new material3d(mesh.mtlname);
				material[mesh_total].albedo		= new vec3(mesh.color);
				material[mesh_total].texture	= mesh.texture;
				
				Material.library[? mesh.mtlname] = material[mesh_total];
			}
			else
			{
				material[mesh_total] = Material.library[? mesh.mtlname];	
			}
			
			
			// Finalize
			vertex_freeze(vbuff[mesh_total]);
			mesh_total++;
		}	
	}
	
	static destroy = function()
	{
		for ( var i=0; i<mesh_total; i++ )
		{	
			vertex_delete_buffer(vbuff[i]);
			buffer_delete(buff[i]);
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
			
			var t = material[i].texture;
			if ( t != -1 )
			{
				if ( typeof(t) != "ptr" )
				{
					t = sprite_get_texture(material[i].texture, 0);
					material[i].texture = t;
				}
			}
			
			vertex_submit( vbuff[i], primtype, material[i].texture );
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
	///@func mesh_import(filename, *scale_vec3, *import_format)
	var dm, p, m;
	p = [ f, new vec3(1), [1,2,3] ];
	
	for ( var i=0; i<argument_count; i++ )
	{
		p[i] = argument[i];	
	}

	dm	= obj_import(p[0], p[1], p[2]);
	m	= new mesh_struct();
	with ( m ) load(dm);
	
	datamesh_map_free(dm);
	return m;
}

function batch_mesh() constructor
{
	///@func batch_mesh()
	mtl_lib		= ds_map_create();
	show_debug_message("Batch mesh sucessfully created!");

	static add = function(m)
	{
		///@func add(mesh_struct, *pos_vec3, *rot_vec3, *scl_vec3)
		var m3 = [ new vec3(0), new vec3(0), new vec3(1) ];
		for ( var i = 1; i<argument_count; i++ )
		{
			m3[i-1] = argument[i];
		}
		
		var i = -1;
		while ( ++i < array_length(m.material) )
		{
			var mtl = m.material[i];
			var msh = 
			{
				buff : m.buff[i],
				verts: m.verts[i],
				matx : m3,
				matl : m.material[i],
				fmat : m.norm_format
			}
			
			if ( is_undefined(mtl_lib[? mtl.name]) )
			{
				mtl_lib[? mtl.name] = ds_list_create();	
			}
			ds_list_add(mtl_lib[? mtl.name], msh);
		}
		show_debug_message("+	Mesh added to batch mesh!");
	}
	
	static build = function()
	{
		///@func build();
		show_debug_message("[Building...] Batch mesh");

		var dmap = ds_map_create();
		for ( var i = ds_map_find_first(mtl_lib); !is_undefined(i); i = ds_map_find_next(mtl_lib, i) )
		{
			var mtl			= mtl_lib[? i];
			
			dmap[? mtl]	= new datamesh();
			var dmesh = dmap[? mtl];
			
			var j = -1;
			while ( ++j < ds_list_size(mtl) )
			{				
				var msh		= mtl[| j].buff;
				var matx	= mtl[| j].matx;
				var matl	= mtl[| j].matl;
				var mnf		= mtl[| j].fmat;
				var size	= buffer_get_size(msh);
				var sbyte	= size / mtl[| j].verts;
				
				buffer_seek(msh, buffer_seek_start, 0);
				for ( var b = 0; b<size; b+=sbyte )
				{
					var v1 = new vec3(
						buffer_read(msh, buffer_f32),
						buffer_read(msh, buffer_f32),
						buffer_read(msh, buffer_f32)
					);
					var n1 = new vec3(
						buffer_read(msh, buffer_f32),
						buffer_read(msh, buffer_f32),
						buffer_read(msh, buffer_f32)
					);
					var c1 = new vec3(
						buffer_read(msh, buffer_u8),
						buffer_read(msh, buffer_u8),
						buffer_read(msh, buffer_u8)
					);
					buffer_read(msh, buffer_u8);
				
					var t1 = new vec2(
						buffer_read(msh, buffer_f32),
						buffer_read(msh, buffer_f32)
					);
					
					var vmat = mat3(matx[0], matx[1], matx[2]);
					var tran = matrix_transform_vertex(vmat, v1.x, v1.y, v1.z);
					var v2 = new vec3(tran[0], tran[1], tran[2]);
					
					var nmat = mat3( new vec3(0), matx[1], new vec3(1) );
					var tran = matrix_transform_vertex(nmat, n1.x, n1.y, n1.z);
					
					var f  = mnf. vec_sign();
					var n2 = new vec3(tran[0]*f.x, tran[1]*f.y, tran[2]*f.z);
									
					with ( dmesh )
					{
						ds_list_add(verts, v2);
						ds_list_add(norms, n2);
						ds_list_add(coord, t1);
					
						color = new vec3(c1);
						mtlname = matl.name;
						texture = matl.texture;
					
						calculate_bounds(v2);
					}
				}
			}
			show_debug_message(".	Mesh with material '"+string(matl.name)+"' built to batch mesh");
		}
		
		ds_map_destroy(mtl_lib);
		
		var m = new mesh_struct();
		m. load(dmap);
		datamesh_map_free(dmap);
		return m;
	}
}
