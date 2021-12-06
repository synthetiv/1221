(

{
	arg hz = 110;

	var beat_sec = 122 / 60;

	var prob = LFSaw.ar(beat_sec/7) * LFSaw.ar(beat_sec/3) + WhiteNoise.ar(0.1);
	var trig = (Impulse.ar(beat_sec*2) * prob) > 0;

	var kickAmp = EnvGen.ar(Env.perc(releaseTime: 0.7, curve: -9), trig);
	var kickPitch = Decay.ar(trig, 0.12);
	var kick = (SinOsc.ar(50 * (kickPitch * 2 + 1)) * kickAmp * 26.dbamp).softclip;

	var choke = 1 - EnvGen.ar(Env.perc(0.1, 1.7), trig);

	var hiss = RLPF.ar(WhiteNoise.ar(1000).softclip, 2000 * (LFNoise1.ar(210, 0.2) + 1), 0.9) * choke;

	// var stabTrig = Impulse.ar(beat_sec*2/3);
	var stabTrig = Mix.ar(Impulse.ar(beat_sec/5, [0, 1, 4, 7, 8, 10, 13, 14, 17 ] / 4 / 5)) * WhiteNoise.ar.range(0, 1) > 0.3;
	var stabAmp = EnvGen.ar(Env.perc(releaseTime: 0.5), stabTrig);
	var stabCut = EnvGen.ar(Env.perc(0.01, 0.1), stabTrig);
	var stab = RLPF.ar(Mix.ar(SawDPW.ar(hz * [2, 12/5, 3, 4])) * 6, 500 * (stabCut * 5 + 1)).distort * stabAmp * SelectX.ar(0.4, [choke, DC.ar(1)]);

	var hatTrig = Impulse.ar(beat_sec, 0.5);
	var hatAmp = EnvGen.ar(Env.perc(0.001, 0.1, -5), hatTrig);
	// var hat = (BPF.ar(LFNoise0.ar(2400) > 0, 3100, 0.7) * hatAmp).distort;
	var hat = BPF.ar(Mix.ar(Pulse.ar([1200, 1829, 2130, 2360, 2510, 2938] * 6)).distort, 8000, 0.2) * hatAmp;

	var echoSend = Mix.ar([
		LocalIn.ar * 0.4,
		stab,
		hat * -7.dbamp,
	]);
	var slew = 256;
	var cut = Slew.ar(WhiteNoise.ar, slew, slew, 4).softclip;
	// TODO: compand echo at input, including feedback
	var echo = RLPF.ar((DelayL.ar(echoSend, 1, 0.25/beat_sec + (SinOsc.kr(0.21) * 0.01)) * 3).tanh, 2400 * (cut + 1), 0.7) * SelectX.ar(0.5, [choke, DC.ar(1)]) * 0.4;

	// cut.scope;

	LocalOut.ar(echo);

	Mix.ar([
		kick,
		// hiss * -12.dbamp,
		stab * 3.dbamp,
		echo * 1.dbamp,
		hat * 1.dbamp
	]) * 0.05 ! 2;
}
.play;

)
