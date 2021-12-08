(

{
	var hz = 190;

	var nudge = LFPulse.kr(0.09 * 2.pow(LocalIn.kr * -0.4), 0, 0.2);
	var waves = Ringz.kr(nudge, [0.79, 1.106, 1.7, 1.82, 2.1], 3);
	var ratios = [1, 15/14, 35/32, 2, 15/7];
	var oscs = SinOscFB.ar(hz * ratios, waves.wrapAt((2..6)).squared * 0.001) * waves * -44.dbamp;

	var subTrig = Trig.kr(nudge, 1);
	var sub = Mix(SinOsc.ar(hz * 7 / [32, 16]) * EnvGen.kr(Env.perc(0.06, [2.7, 1], [1, 0.08], -7), subTrig));

	var echoIn = Splay.ar(LocalIn.ar(2) * -6.dbamp + oscs, -3).softclip;
	var echo = RLPF.ar(
		RHPF.ar(
			DelayL.ar(echoIn, 1, 0.2 + SinOsc.kr(0.13 * 2.pow(LocalIn.kr * 0.2), 0, 0.01)),
			300,
			1
		),
		6700,
		0.9
	);
	LocalOut.ar(echo);

	LocalOut.kr(Mix(waves) / 5);

	Splay.ar(oscs, 0.4) + (sub * -6.dbamp) + (echo * -3.dbamp);
}
.play;

)