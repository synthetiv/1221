(
Routine {
	SynthDef(\pip, {
		arg hz = 230, noise = 0.0356, flow = 0.3, emb = 1.9, fb1 = 0.5, fb2 = 0.55;

		var in = LocalIn.ar;

		var arpnotes = [ 7/12, 3/4, 1, 7/6, 3/2, 14/9, 2, 56/27, 7/3 ];
		var arpstream = Select.kr(LFTri.kr(0.1, [0, 3]).range(1.5, arpnotes.size - 1.5) + SinOsc.ar(0.021, [1.9pi, 2.1pi]), arpnotes);
		var arphum = LFTri.ar((hz * arpstream[0]).lag(0.2 + LFTri.kr(0.12, 3, 0.1))) * LFTri.kr(0.1 * arpnotes.size).range(0.2, 1);

		var env = LFTri.kr(0.1 * arpnotes.size, 2).range(0.6, 1);
		var air = flow * env * (arphum * 0.5 + 1 + WhiteNoise.ar(noise));
		var vfb = DelayL.ar(in, 0.2, (hz * arpstream[1]).reciprocal - (BlockSize.ir / SampleRate.ir));
		var embDel = DelayL.ar(vfb * fb1 + air, 0.2, (hz * arpstream[1] * emb).reciprocal);
		var cut = Latch.kr(VarSaw.kr(0.07, 0, LFTri.kr(0.029, 1)), Changed.kr(arpstream[1])).range(1, 2).linexp(1, 2, 300, 1800).lag(0.1);
		var filter = SVF.ar((vfb * fb2 + (embDel - embDel.cubed)).clip2, cut, 0.3);

		LocalOut.ar(filter);

		filter = LeakDC.ar(filter) * -8.dbamp;

		Out.ar(0, filter ! 2);
	}).add;
	s.sync;
	y = Synth(\pip);
}.play;
)