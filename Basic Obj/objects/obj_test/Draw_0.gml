draw_set_color(c_ltgray);
draw_rectangle(0,0,room_width,room_height,false);

with ( model )
{
	draw_ext(position, rotation, scale);
}