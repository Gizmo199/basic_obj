varying vec3	v_vPosition;
varying vec2	v_vTexcoord;
varying vec4	v_vColour;
varying vec3	v_vNormal;
varying vec3	v_vEye;
varying float	v_vDis;
varying float	v_vRim;

uniform vec3	bounds_min;
uniform vec3	bounds_max;
uniform vec3	sun_dir;
uniform vec2	texrepeat;
uniform vec2	texoffset;
uniform vec3	albedo;
uniform float	specular;
uniform float	glossiness;
uniform float	diffuse;

void main()
{
	// Texture
	vec4 base_col = texture2D( gm_BaseTexture, ( v_vTexcoord + texoffset ) * texrepeat );

	// Vertex color
	base_col.rgb *= albedo;
	
	// Diffuse Shading
	base_col.rgb *= diffuse + ( max(dot(v_vNormal, normalize(sun_dir)), 0.) );
	
	// Specular & Gloss highlights
	base_col.rgb += min(specular, 1.) * ( pow(max(dot(normalize(reflect(v_vEye, v_vNormal)), normalize(sun_dir)), 0.), max(glossiness * 50., 1.)) );
	
	// Outpute color
	gl_FragColor = base_col;
}
