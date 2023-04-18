function Pakt (_size, _type, _buffer = -1) constructor begin
	sizeof = buffer_sizeof(_type)
	size = _size
	if _buffer == -1
	{
		data = buffer_create(_size * sizeof, buffer_fixed, sizeof)
	}
	else
	{
		data = _buffer
	}
	type = _type
end

function pakt_from_buffer (buffer, type)
{
	return new Pakt(buffer_get_size(buffer) / buffer_sizeof(type), type, buffer)
}

function pakt_create (_size, _type)
{
	return new Pakt(_size, _type)
}

function pakt_delete (f)
{
	buffer_delete(f.data)
	delete f
}

function pakt_get (f, i)
{
	buffer_peek(f, i*i.sizeof, f.type)
}

function pakt_set (f, i, value)
{
	buffer_poke(f, i*i.sizeof, i.type, value)
}

function pakt_length (f)
{
	return f.size
}

function pakt_byte_length (f)
{
	return buffer_get_size(f.data)
}

function pakt_tell (f)
{
	return buffer_tell(f.data) / f.sizeof
}

function pakt_seek (f, base=buffer_seek_start, offset)
{
	buffer_seek(f.data, base, offset)
}

function pakt_read (f)
{
	return buffer_read(f, f.type)
}

function pakt_write (f, value)
{
	buffer_write(f, f.type, value)
}
