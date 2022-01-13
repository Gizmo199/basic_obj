// Draw our player model
with ( model )
{
	draw_ext(position, rotation, scale);
}

// Draw our suzanne batch mesh
with ( batch )
{
	draw_ext(
		new vec3(0, 0, -64),
		new vec3(0),
		new vec3(1)
	);
}