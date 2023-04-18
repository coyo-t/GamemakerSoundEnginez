function load_pmc (_path, _bfftype = buffer_fixed)
{
	var ff = buffer_load(_path)
	var outp = buffer_create(buffer_get_size(ff), _bfftype, 1)
	buffer_copy(ff, 0, buffer_get_size(ff), outp, 0)
	buffer_delete(ff)
	return outp
}


function uuid_generate ()
{
	static dec_to_hex = function (dec)
	{
		static h = "0123456789ABCDEF"
		var byte, hi, lo
		var hex = dec ? "" : "0"
		while (dec != 0)
		{
			byte = dec & 0xFF
			
			hi = string_char_at(h, (byte >> 4) + 1)
			lo = string_char_at(h, (byte & 15) + 1)
			hex = (hi!="0" ? hi : "") + lo + hex
			dec = dec >> 8
		}
		return hex
	}
	
	var uuid = array_create(32)
	begin
		var d = round(date_second_span(date_create_datetime(2016,1,1,0,0,1), date_current_datetime()))
		d = current_time + d * 10000

		for (var i = array_length(uuid)-1; i >= 0; i--)
		{
			var r = int64((d + random(1) * 16)) & 15

			if (i == 16)
			{
				uuid[i] = dec_to_hex(r & $3|$8)
			}
			else
			{
				uuid[i] = dec_to_hex(r)
			}
		}

		uuid[12] = "4"
	end
	
	begin // uuid_array_implode
		//return string_ext("{0}{1}{2}{3}{4}{5}{6}{7}-{8}{9}{10}{11}-{12}{13}{14}{15}-", a)
		static sep = "-"
		var s = ""
		var i = 0

		repeat 8
		{
			s += uuid[i++]
		}
		s += sep;

		repeat 4
		{
			s += uuid[i++]
		}
		s += sep;

		repeat 4
		{
			s += uuid[i++]
		}
		s += sep;

		repeat 4
		{
			s += uuid[i++]
		}
		s += sep;

		repeat 12
		{
			s += uuid[i++]
		}
		return s
	end
}

