// size of the chunks audio is processed in. smaller is faster but makes the deadline
// of the queue playback deadlier 
function get_samp ()
{
	static SAMP = 4410>>2
	return SAMP
}

// 2: sizeof(short), 2: channels (stereo)
function get_abuff_sz ()
{
	static samp = get_samp() * buffer_sizeof(buffer_s16) * 2
	return samp
}

function get_bff_count ()
{
	return 3
}

function get_cur_offset (_name = curr_name)
{
	return _name * get_abuff_sz()
}

curr_name = int64(0)
line = audio_create_play_queue(buffer_s16, 44100, audio_stereo)
f = buffer_create(get_abuff_sz() * get_bff_count(), buffer_fixed, 1)
buffer_fill(f, 0, buffer_u8, 0, buffer_get_size(f))


playing = [] // <ISoundDataSampler>

audio_mix = pakt_from_buffer(f, buffer_s16)

DBG_glass       = new SampleData(load_pmc("glass2.sfx"), 44100)
DBG_holyshit    = new SampleData(load_pmc("holyshit.sfx"), 44100)
DBG_armashatter = new SampleData(load_pmc("splitofmind2_stereo.sfx"), 44100, 2)

soundmap = {
	"glass":    { pcm: DBG_glass,    pitch: 0.8, volume: 1.0 },
	"holyshit": { pcm: DBG_holyshit, pitch: 1.0, volume: 1.0 },
}

function queue_sound (_sfx, _listener)
{
	var sfxf = new SoundClip(_sfx.pcm, _sfx.pitch+random_range(-0.05, 0.1), _sfx.volume)
	array_push(playing, new MonoSoundSampler(sfxf, _listener))
}


function run ()
{
	adv_samples()
	audio_queue_sound(line, f, get_cur_offset(), get_abuff_sz())
	curr_name = (curr_name + 1) mod get_bff_count()
}

function clample (_smpl)
{
	static MAXSMPL = 32000
	if _smpl < -MAXSMPL
	{
		return -MAXSMPL
	}
	if _smpl >= MAXSMPL
	{
		return +MAXSMPL
	}
	return floor(_smpl)
}

function adv_samples ()
{
	static RCHAN = buffer_create(get_samp()<<2, buffer_fixed, 1)
	static LCHAN = buffer_create(get_samp()<<2, buffer_fixed, 1)
	
	buffer_fill(RCHAN, 0, buffer_u8, 0, buffer_get_size(RCHAN))
	buffer_fill(LCHAN, 0, buffer_u8, 0, buffer_get_size(LCHAN))
	buffer_seek(RCHAN, buffer_seek_start, 0)
	buffer_seek(LCHAN, buffer_seek_start, 0)
	var lpl = array_length(playing)
	if lpl > 0
	{
		for (var i = lpl-1; i >= 0; i--)
		{
			var play = playing[i]
			if not play.sample_audio(RCHAN, LCHAN, get_samp())
			{
				delete play
				array_delete(playing, i, 1)
			}
		}
	}
	else
	{
		buffer_seek(f, buffer_seek_start, get_cur_offset())
		buffer_fill(f, get_cur_offset(), buffer_u8, 0, get_abuff_sz())
		return
	}
	buffer_seek(RCHAN, buffer_seek_start, 0)
	buffer_seek(LCHAN, buffer_seek_start, 0)
	buffer_seek(f, buffer_seek_start, get_cur_offset())
	var master = audio_get_master_gain(0)
	for (var i = get_samp(); (--i) >= 0;)
	{
		var samp_r = clample(buffer_read(RCHAN, buffer_s32) * master)
		var samp_l = clample(buffer_read(LCHAN, buffer_s32) * master)
		buffer_write(f, buffer_s16, samp_l)
		buffer_write(f, buffer_s16, samp_r)
	}
	
	
	//static TIME = 0
	//static SAMP = get_samp()
	//var herz = 1000
	//var vol = 0.1
	//var cofs = get_cur_offset()
	//buffer_seek(f, buffer_seek_start, cofs)
	//for (var i = SAMP; (--i) > 0;)
	//{
	//	var time = TIME / 44100
	//	var pan = sin(TIME/44100 * pi * 0.2) * 0.5 + 0.5
	//	//var pan = 1
	//	var smp = sin(time*pi*herz)*vol
		
	//	var lmix = (smp * pan)     * 0x8000
	//	var rmix = (smp * (1-pan)) * 0x8000
		
	//	begin
	//		var j = 0
	//		var things = [DBG_holyshit, DBG_glass]
	//		repeat 2 begin
	//			var fhfhjfh = things[j++]
	//			var ofst = TIME
	//			ofst *= 0.8
	//			ofst += sin(time*pi*1) * 44100 * 0.08
	//			//sdm(ofst)
	//			//var glassfx = buffer_peek(fhfhjfh, (int64(ofst)<<1) mod buffer_get_size(fhfhjfh), buffer_s16)
	//			var glassfx = fhfhjfh.get(int64(ofst) mod fhfhjfh.get_size())
	//			glassfx = int64(glassfx * 0.9 * 0x8000) >> 16
	//			lmix += glassfx
	//			rmix += glassfx
	//		end
	//	end
		
	//	var master = audio_get_master_gain(0)
	//	// left
	//	pakt_write(audio_mix, clamp(int64(lmix*master), -0x7d00, 0x7d00))
	//	// right
	//	pakt_write(audio_mix, clamp(int64(rmix*master), -0x7d00, 0x7d00))
	//	TIME++
	//}
}

for (var i = 0, len = get_bff_count(); i < len; ++i)
{
	audio_queue_sound(line, f, get_cur_offset(i), get_abuff_sz())
}
playback_index = audio_play_sound(line, 1, true)


