(

{
	arg hz = 103;

	var trig = Impulse.kr(0.2);

	var rat = EnvGen.kr(Env.new(levels: [0, 5, 0], times: [3, 0]), trig).floor;
	var hhTrig = Impulse.kr(4 * rat);
	var hh = BPF.ar(Mix.new(WhiteNoise.ar(0.12) + Pulse.ar([3937, 4101, 4736, 5100])).softclip, 12000, 0.6) * EnvGen.ar(Env.perc(0.003, 0.1), hhTrig) * -15.dbamp;

	var strTrig = DelayN.kr(trig, 4.6, 4.6);
	var ch = Select.kr(Stepper.kr(strTrig, Impulse.kr(0), max: 2), [
		[1, 2, 3, 5],
		[16/15, 2, 16/5, 4],
		[6/5, 3, 7/2, 6],
	]);
	var rsel = LFSaw.kr([0.01, 0.011], [1.5, 0]).range(0, 4);
	var rs = Latch.kr(Select.kr(rsel, ch), strTrig);
	var strEnv = EnvGen.kr(Env.new([0, 1, 0], [3.3, 0.2], 4), strTrig);
	var str = RLPF.ar(Mix.new(Pulse.ar(hz * rs, LFTri.kr([0.7, 0.8] * (rat / 2 + 1), 0, 0.3, 0.5))), 1900 + (strEnv * 2300), 0.8) * strEnv * -19.dbamp;

	var bdTrig = DelayN.kr(trig, 3, 3);
	var bd = Splay.ar([
		SinOsc.ar(30 + Decay.kr(bdTrig, 2, 50) + SinOsc.kr(0.36, [0, 0.5pi], 6)) * EnvGen.ar(Env.new([0, 32, 4, 0], [0.03, 0.2, 3], -9), bdTrig) * 36.dbamp,
		WhiteNoise.kr * EnvGen.ar(Env.perc(0.005, 0.3), bdTrig) * 59.dbamp ! 2,
		SinOsc.ar(32) * EnvGen.ar(Env.perc(0.1, 7), bdTrig) * 6.dbamp ! 2
	], 0.3).distort * -6.dbamp;
	bd = RLPF.ar(bd, 130 + EnvGen.ar(Env.perc(0.01, 3), bdTrig).lincurve(0, 1, 0, 2900, 3), 0.8);

	bd + ((hh + str) ! 2) * -3.dbamp;
}
.play;

)