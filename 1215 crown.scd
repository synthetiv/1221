(
Routine {
	SynthDef(\ch, {
		arg lf = 10, hz = 379, a = 1.4, b = 0.3;

		var hen = HenonL.ar(lf, a + [0.01, 0, -0.01, -0.02], b);
		var htri = hen.min(0).neg;
		var scale = 2;
		var leng = LFTri.kr(lf / [200, 145, 139, 111] * scale, 3)
			+ LFTri.kr(lf / [790, 830, 610, 540] * scale, 1);
		var lengavg = Mix(leng) / 4;
		var lengcurve = leng.lincurve(-2, 2, 0.1, 2, 2);
		var lengmax = ArrayMax.kr(lengcurve)[0];
		var long = LagUD.ar(htri, 0.01, lengcurve);

		var rs = [1, 20/21, 3/2, 2];
		var bel = SVF.ar(Pulse.ar(hz * rs, LFTri.kr((7..10) * 0.005).range(0.2, 0.8) + WhiteNoise.kr(0.01)), hz * 3.8 + (1000 * rs * htri.squared), 0.2) * long * rs.expexp(1, 2, 1, -6.dbamp);
		var ring = Mix(Pan2.ar(bel, SinOsc.kr(0.1, (0..3) / 2 * pi)));

		var the = 1 - Schmidt.kr(lengavg, -0.1, 0.1);
		var them = the * Phasor.kr(the, (ControlRate.ir * -8).reciprocal) > 0.2;
		var it = EnvGen.kr(Env.asr(3, 1, 3), them);
		var prs = 0.125 * [1/2, 1, 2, 1, 3/2, 8/7, 1/2, 4/3, 3/2, 1, 9/5, 4/5, 4/3, 2, 1, 40/21, 4/3, 3/2 ];
		var wh = Stepper.kr(them, Impulse.ar(0), 0, prs.size - 1, resetval: prs.size - 1);
		var em = Select.kr(wh, prs);
		var pul = LFPulse.kr(lf / 2, SinOsc.kr(lf / 13).neg.range(0, 1));
		var ser = MoogLadder.ar(Mix(Saw.ar(hz * em * [1.003, 1.997])), LFTri.kr(0.071, 3, 5, 6).linexp(1, 11, hz, 6000) * lengmax * it, 0.67) * EnvGen.kr(Env.perc(0.01, lengmax), pul);
		var sar = it * ser;

		var mix = Mix([
			ring * -13.dbamp,
			sar
		]);

		Out.ar(0, mix);
	}).add;
	s.sync;
	y = Synth(\ch);
}.play
)