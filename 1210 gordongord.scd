(

// gordon with different phase offsets + a looper

{

	arg hz = 57, flow = 0.6, noise = 0.0356, fb1 = 0.5, fb2 = 0.55;

	var fbIn = LocalIn.ar(4);

	var boreDel = DelayL.ar(fbIn.at([0, 1]), 0.2, hz.reciprocal);

	var flowEnv = VarSaw.kr(0.39, 0, LFTri.kr([0.61, 0.39]).range(0.01, 0.99)).range(-0.3, 1).lincurve(0, 1, 0, 1, -4);
	var air = flow * flowEnv * (1 + WhiteNoise.ar(noise));

	var chg = flowEnv < 0.1;

	var emb = Latch.kr(LFTri.kr([0.12, 0.21], [0.1, 3]).range(1.5, 2.5), chg);
	var embDel = DelayL.ar(boreDel * fb1 + air, 0.2, (hz * emb.clip(1.1, 5).lag(0.2)).reciprocal - (BlockSize.ir / SampleRate.ir));

	var cut = Latch.kr(Mix(LFTri.kr([0.321, 0.123], 2).range(0.5, 1)).linexp(1, 2, hz * 4, hz * 64), chg);
	var filter = RLPF.ar(boreDel * fb2 + (embDel - embDel.cubed), cut.lag(0.2), 1);
	var dec = Line.ar(-0.2, 1, 3).clip(0, 1) * Splay.ar(LeakDC.ar(filter), 0.5);

	var ec = RLPF.ar(
		DelayL.ar(
			Splay.ar(fbIn.at([2, 3]), 0.8) + dec,
			6.5,
			6.4 + Mix(SinOsc.kr([2.3, 0.99], mul: [0.0003, 0.0002]))
		).distort,
		5000,
		1
	) * 0.51;

	LocalOut.ar([filter, ec].flatten);

	Out.ar(0, (dec + ec) * -4.dbamp);

}.play;

)