attribute vec3 in_Position;                
attribute vec3 in_Normal;                  
attribute vec4 in_Colour;                  
attribute vec2 in_TextureCoord;            

varying vec3	v_vPosition;
varying vec2	v_vTexcoord;
varying vec4	v_vColour;
varying vec3	v_vNormal;
varying vec3	v_vEye;
varying float	v_vRim;

void main()
{
	// Baseline position & normal
    vec4 object_space_pos = vec4(in_Position, 1.0);
	vec4 object_space_norm = vec4(in_Normal, 0.0);
	
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	// Eye vector
	vec3 c = -(gm_Matrices[MATRIX_VIEW][3] * gm_Matrices[MATRIX_VIEW]).xyz;
	vec3 v =  (gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz;
	v_vEye = v - c;
	
	// Color, texcoord, normal, & position
	v_vColour = in_Colour;    
    v_vTexcoord = in_TextureCoord;
	v_vNormal = normalize((gm_Matrices[MATRIX_WORLD] * object_space_norm).xyz);
	v_vPosition = object_space_pos.xyz;
	
	// Rim lighting
	v_vRim = normalize((gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_norm).xyz).z;
}
