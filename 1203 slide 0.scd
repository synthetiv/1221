s.boot;

(

{
	arg hz = 101,
	pulse = 0.31;

	var chord = Select.kr(Stepper.kr(Impulse.kr(pulse), min: 0, max: 3), [
		[ 4/3,   2,  8/3, 16/5, 32/9 ],
		[ 1/1, 3/2,    2, 12/5,    3 ],
		[ 3/2, 9/4,    3, 15/4,  9/2 ],
		[ 3/2,   2, 12/5,    3,    4 ],
	]);

	var gate = LFPulse.kr(pulse, width: 0.2);

	var ratio = Lag.kr(chord, pulse.reciprocal * 0.8);
	var triEnv = EnvGen.kr(Env.perc(0.8, 4), DelayN.kr(gate, 0.5, pulse.reciprocal * 0.1));
	var tri = Mix.ar(LFTri.ar(hz * ratio)) * triEnv;
	var triFilt = RLPF.ar(tri, 800 + (triEnv * 1000), 1.3) * -24.dbamp;

	var sawEnv = EnvGen.kr(Env.perc(releaseTime: 0.3), Impulse.kr(pulse * 24));
	var saw = Mix.ar(Saw.ar(hz * ratio * 2)) * SinOsc.kr(0.07) * SinOsc.kr(0.19) * SinOsc.kr(0.003).squared;
	var sawFilt = RLPF.ar(saw, 200 + (2000 * sawEnv), 0.8) * sawEnv * -30.dbamp;

	var strings = triFilt + sawFilt;

	var echoIn = strings ! 2 + (LocalIn.ar(2) * -8.dbamp);
	var echoComp = RLPF.ar((Compander.ar(echoIn, echoIn, -10.dbamp, 0.9, 0.3, 0.1, 1) * 2).distort, 3000 + (LFTri.kr(0.41) * 400), 0.8);
	var echo = DelayC.ar(echoComp, pulse.reciprocal, pulse.reciprocal / [pi, 1.exp] + (LFTri.kr(0.09) * 0.007));
	echo = Splay.ar(echo, -0.7);

	LocalOut.ar(echo);

	strings ! 2 + (echo * -4.dbamp);
}
.play;

)

1.exp