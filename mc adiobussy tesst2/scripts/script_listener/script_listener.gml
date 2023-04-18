
function SampleData (_data_buffer, _samplerate, _channels = 1) constructor begin
	data = _data_buffer
	samplerate = _samplerate
	channels = _channels
	
	///@func get(index, [channel=0])
	static get = function (i, channel = 0)
	{
		//return buffer_peek(data, ((i*channels)+channel)<<1, buffer_s16)
		return buffer_peek(data, i<<1, buffer_s16)
	}
	
	///@func get_size()
	///@returns {real}
	static get_size = function ()
	{
		return buffer_get_size(data) >> 1
	}
end

function ISoundDataSampler () constructor begin
	///@func sample_audio(channel_r, channel_l, count)
	///@arg     {Buffer} channel_r
	///@arg     {Buffer} channel_l
	///@arg     {real}   count
	///@returns {bool}   whether theres more stuff to read
	static sample_audio = ABSTRACT_FUNC
end

function SoundInstance () constructor begin
	volume = 1.0
	
	///@func get_samples(output, count)
	///@arg     {Buffer} output
	///@arg     {Real}   count
	///@returns {Real}   How much data was written
	static get_samples = function (_outp, _count)
	{
		return 0
	}
	
	///@func get_volume()
	///@returns {real}
	static get_volume = function ()
	{
		return volume
	}
end

///@func SoundClip(sfx, pitch, volume)
///@arg {struct.SoundInstance} sfx
///@arg {real}                 pitch
///@arg {real}                 volume
function SoundClip (_sfx, _pitch, _volume) : SoundInstance() constructor begin
	play_time = 0.0
	sfx = _sfx
	samplerate = _pitch * 44100 / _sfx.samplerate
	volume = _volume
	
	///@func get_samples(output, count)
	///@arg     {Buffer} output
	///@arg     {Real}   count
	///@returns {Real}   How much data was written
	static get_samples = function (_outp, _count)
	{
		var dlen = sfx.get_size()
		if (play_time >= dlen)
		{
			return 0;
		}
		var f = sfx.data
		for (var i = 0; i < _count; ++i)
		{
			var tndex = int64(play_time)
			var smp_cur = buffer_peek(f, tndex<<1, buffer_s16)
			var smp_nxt = tndex < dlen - 1 ? buffer_peek(f, (tndex+1)<<1, buffer_s16) : 0
			
			// lerpz
			buffer_poke(_outp, i<<1, buffer_s16, int64(lerp(smp_cur, smp_nxt, play_time-tndex)))
			play_time += samplerate
			if (play_time >= dlen)
			{
				return i
			}
		}
		return _count
	}
end



///@func MonoSoundSampler(sound_instance, emitter)
///@arg {struct.SoundInstance} sound_instance
///@arg {struct.ASoundEmitter} emitter
function MonoSoundSampler (_soundinst, _emit) : ISoundDataSampler() constructor begin
	static SAMPLES = buffer_create(2, buffer_fixed, 1)
	sfx_inst = _soundinst
	emit = _emit
	opan = _emit.get_pan()
	ovol = _emit.get_volume()
	
	///@func sample_audio(channel_r, channel_l, count)
	///@arg     {Buffer} channel_r
	///@arg     {Buffer} channel_l
	///@arg     {real}   count
	///@returns {bool}   whether theres more stuff to read
	static sample_audio = function (_rchan, _lchan, _count)
	{
		if buffer_get_size(SAMPLES) < (_count<<1)
		{
			buffer_resize(SAMPLES, _count << 1)
		}
		
		var remaining = sfx_inst.get_samples(SAMPLES, _count);
		var hasRemaining = remaining > 0;

		var pan = emit.get_pan(),
		var vol = emit.get_volume() * sfx_inst.get_volume();

		var omix_l = (((opan > 0) ? 1-opan : 1) * ovol * 0x10000) // 0x10000 0x7FFF
		var omix_r = (((opan < 0) ? 1+opan : 1) * ovol * 0x10000)
		var mix_l  = (((pan  > 0) ? 1-pan  : 1) * vol  * 0x10000)
		var mix_r  = (((pan  < 0) ? 1+pan  : 1) * vol  * 0x10000)
		
		var diff_l = mix_r - omix_r,
		var diff_r = mix_l - omix_l;
		
		if (diff_r != 0 or diff_l != 0)
		{
			for (var i = 0; i < remaining; ++i)
			{
				var i8 = omix_r + diff_r * i / _count;
				var i9 = omix_l + diff_l * i / _count;
				var cr = buffer_peek(SAMPLES, i<<1, buffer_s16)
				var samp = buffer_peek(_rchan, i<<2, buffer_s32)
				buffer_poke(_rchan, i<<2, buffer_s32, samp + (int64(cr * i8) >> 16))
				samp = buffer_peek(_lchan, i<<2, buffer_s32)
				buffer_poke(_lchan, i<<2, buffer_s32, samp + (int64(cr * i9) >> 16))
			}
		}
		else if (omix_r >= 0 || omix_l != 0)
		{
			for (var i = 0; i < remaining; ++i)
			{
				// we do a little fixed point
				var cr = buffer_peek(SAMPLES, i<<1, buffer_s16)
				var samp = buffer_peek(_rchan, i<<2, buffer_s32)
				buffer_poke(_rchan, i<<2, buffer_s32, samp + (int64(cr * omix_r) >> 16))
				samp = buffer_peek(_lchan, i<<2, buffer_s32)
				buffer_poke(_lchan, i<<2, buffer_s32, samp + (int64(cr * omix_l) >> 16))
			}
		}
		opan = pan;
		ovol = vol;
		return hasRemaining;
	}
end


// ============================================================================
// Emitters and listener
// ============================================================================
function ISoundSource () constructor begin
	///@func get_pan()
	///@returns {real}
	static get_pan = ABSTRACT_FUNC
	
	///@func get_volume()
	///@returns {real}
	static get_volume = ABSTRACT_FUNC
end

function ASoundEmitter (_listener) : ISoundSource() constructor begin
	listener = _listener // <Active>
	
	///@func get_pan_at(x, z)
	///@returns {real}
	static get_pan_at = function (x, z)
	{
		var xx = x - listener.x
		var zz = z - listener.z
		var mag = xx * xx + zz * zz

		if (mag == 0)
		{
			return 0
		}
		mag = sqrt(mag)
		
		xx /= mag
		zz /= mag
		mag /= 2
		
		var yr = -listener.yaw + 180
		return (dsin(yr) * zz - dcos(yr) * xx) * (mag > 1 ? 1 : mag);
	}
	
	///@func get_volume_at(x, y, z)
	///@returns {real}
	static get_volume_at = function (x, y, z)
	{
		var dx = x - listener.x,
		var dy = y - listener.y,
		var dz = z - listener.z;

		var vol = 1 - sqrt(dx*dx + dy*dy + dz*dz) / 32;
		return vol < 0 ? 0 : vol;
	}
end


function EntityEmitter (_sound_source,
                        _listener_origin) : ASoundEmitter(_listener_origin) constructor begin
	sound_source = _sound_source // <Entity>
	
	///@func get_pan()
	///@returns {real}
	static get_pan = function ()
	{
		return get_pan_at(sound_source.x, sound_source.z)
	}
	
	///@func get_volume()
	///@returns {real}
	static get_volume = function ()
	{
		return get_volume_at(sound_source.x, sound_source.y, sound_source.z)
	}
end


function PointEmitter (_source_x,
                       _source_y,
                       _source_z,
                       _listener_origin) : ASoundEmitter(_listener_origin) constructor begin
	x = _source_x
	y = _source_y
	z = _source_z
	
	///@func get_pan()
	///@returns {real}
	static get_pan = function ()
	{
		return get_pan_at(x, z)
	}
	
	///@func get_volume()
	///@returns {real}
	static get_volume = function ()
	{
		return get_volume_at(x, y, z)
	}
end



