// fly around
var i = new vec2(
		keyboard_check(ord("D")) - keyboard_check(ord("A")), 
		keyboard_check(ord("S")) - keyboard_check(ord("W"))
	);

var d = point_direction(0,0,i.x,i.y) + forward;
var s = point_distance(0,0,i.x,i.y);
var spd = s * 4;
x += dcos(d)*spd;
y += dsin(d)*spd;
z += dsin(rotation.y)*spd*-i.y;

// Texture change input
var k = keyboard_check(vk_space);

// Rotate player model
with ( model )
{
	rotation.z++;
	
	// Adjust material 0
	with ( material[0] )
	{	
		// Swap texture
		texture		= k ? texchg : texdef;				// swap textures
		texrepeat	= k ? new vec2(4) : new vec2(1);	// repeat the texture if swapped
		
		// make rim lighting glow
		rim = abs(dsin(current_time/8)) * .5;
		
		// Offset the textures y coordinate
		texoffset.y -= .01;
		
		// Hue shift albedo.
		// Albedo must be (r,g,b) and only be between 0-1
		hue++; hue%=255;
		var c = make_color_hsv(hue, 255, 255);
		albedo = new vec3(
		
			color_get_red(c), 
			color_get_green(c), 
			color_get_blue(c)
			
		). divide(255);
	}
}

// Modify suzanne material
with ( suzanne.material[0] )
{
	// Set our suzanne model material to be the
	// same albedo and opposite texture as our player models
	// This will automatically effect all batched meshes as well
	// Since they share the same material
	var player_model = other.model;
	albedo	= player_model.material[0].albedo;
	
	var t1 = player_model.material[0].texchg;
	var t2 = player_model.material[0].texdef;
	texture = k ? t2 : t1;
}