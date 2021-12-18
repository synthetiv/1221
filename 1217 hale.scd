(
{
	var hz = 291;
	var lfhz = 0.26;
	var modrat = 0.21;
	// a set of phase-modulated sines, with amplitude compensation so that maximum slope stays constant
	// i.e. amplitude increases as effective frequency decreases
	var wav = SinOsc.kr(lfhz, (0..4) * pi / 2.5 + SinOsc.kr(lfhz * modrat, 1)) * (1 - SinOsc.kr(lfhz * modrat, 1.5pi, modrat));
	var tones = Select.ar(wav >= 0, SinOsc.ar(hz * [ [1, 21/20, 8/9, 14/15, 1/4], [3/4, 63/64, 4/3, 21/18, 1/8] ])) * wav;
	SelectX.ar(SinOsc.ar(lfhz / 29, 0.5pi, 0.4, 0.5), tones.clump(2)) + (tones[4] ! 2) / 4 * Line.ar(dur: 4).squared;
}.play;
)