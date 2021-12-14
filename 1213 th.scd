(
Routine {
	SynthDef(\ls, {
		arg hz = 41;

		var thp = Impulse.kr(0.231);
		var thf = Select.kr(Stepper.kr(thp, Impulse.kr(0), 0, 5), [
			1, 1, 1, 21/20, 7/9, 5/6
		]);
		var th = MoogLadder.ar(
			Mix(LFSaw.ar(hz * 2.pow([-0.01, 0.01]) * thf)) + WhiteNoise.ar(0.3),
			EnvGen.ar(Env.perc(releaseTime: 1.6), thp).lincurve(0, 1, hz * 1.8, (hz * LFTri.kr(0.003, 3).lincurve(-1, 1, 1, 300, 4)).min(SampleRate.ir / 2), 1),
			0.53
		) * EnvGen.ar(Env.asr(releaseTime: 2), Trig.kr(thp, 2.1));

		var dc = Line.kr(0, 0.6, 1) * [
			1,
			SinOsc.kr(0.48, 0, 0.2, 0.9),
			SinOsc.kr(0.48, 2pi, 0.2, 0.9),
			1,
		] + (th * 0.6).tanh;

		var l1 = DelayL.ar(LocalIn.ar(4), 0.2, (hz * [1, 21/20, 21/20, 1]).reciprocal - (SampleRate.ir * BlockSize.ir));
		var l2 = DelayL.ar(l1 * 0.5 + dc, 0.2, (hz * [
			3.67,
			2.19 + SinOsc.kr(1.1, mul: 0.03),
			0.99 + SinOsc.kr(0.6, 3pi, 0.02),
			3.67,
		]).reciprocal);
		// modulating these cutoffs is great, but using periodic pulse waves isn't.
		// it would be nice to S&H the incoming delay line feedback or something,
		// in a way that "responded" to the activity of the feedback loop --
		// too stable? jump elsewhere, etc. some other time.
		var f = SVF.ar((l1 * 0.55 + (l2 - l2.cubed)).clip2, [
			1000, // + LFPulse.kr(0.033, 0.5, 0.3).range(0, 900).lag(0.3),
			1000 + SinOsc.kr(1.2, mul: 15),
			800,
			1100, // + LFPulse.kr(0.033, 0.5003, 0.3).range(0, 900).lag(0.5)
		], 0.1);
		var a = Splay.ar(LeakDC.ar(f), 0.8) / f.size * Line.kr(dur: 1);

		var m = (th ! 2) + (a * 4.dbamp);
		// Peak.ar(ArrayMax.ar(m)[0]).poll;
		LocalOut.ar(f);

		Out.ar(0, m);
	}).add;
	s.sync;
	Synth(\ls);
}.play;
)