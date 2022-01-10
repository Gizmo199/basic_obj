function parse_begin(f)
{
	///@func parse_begin(filename)
	if ( !file_exists(f) ) 
	{ 
		show_debug_message("File '"+f+"' does not exist!"); 
		return false; 
	}
	return file_text_open_read(f);
}
function parse_completed(f)
{
	///@func parse_completed(file_id);
	return file_text_eof(f);
}
function parse_end(f)
{
	///@func parse_end(file_id);
	file_text_close(f);
}	
function parse_line(f)
{
	///@func parse_line(file_id)
	var fl = file_text_read_string(f);
	file_text_readln(f);
	return fl;
}
function parse_line_ext(f, s)
{
	///@func parse_line_ext(file_id, substr)	
	var p = 0;
	var st = []; st[0] = "";
	var l = parse_line(f);
	for ( var i=1; i<string_length(l) + 1; i++ )
	{
		if ( string_char_at(l, i) == s )
		{
			p++;
			st[p] = "";
		}
		else
		{
			st[p] += string_char_at(l, i);	
		}
	}
	return st;
}
function parse_string(s, ss)
{
	///@func parse_string(string, substring)
	var p = 0;
	var st = []; st[0] = "";
	for ( var i=1; i<string_length(s) + 1; i++ )
	{
		if ( string_char_at(s, i) == ss )
		{
			p++;
			st[p] = "";
		}
		else
		{
			st[p] += string_char_at(s, i);	
		}
	}
	return st;
}