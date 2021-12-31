(
Routine {
	SynthDef(\brass, {
		arg attack = 0.4, decay = 2, release = 0.3;
		var notes = [ 12, 0, 19, 12, 24, 17, 16, 23, 23, 24, 24 ];
		// var hzs = (24 + [ 23, 11, 30, 23, 35, 28, 27, 34, 34, 35, 35 ]).midicps;
		var noteclock = Impulse.kr(0.7.reciprocal);
		var whichVoice = Stepper.kr(noteclock, Impulse.ar(0), 0, 3);
		var whichNote = Stepper.kr(noteclock, Impulse.ar(0), 0, notes.size - 1);

		var voiceActive = Array.fill(4, { |v| BinaryOpUGen('==', v, whichVoice) }).dup.flatten;
		var voiceNote = Select.kr(Latch.kr(whichNote, voiceActive + Impulse.kr(0)), notes);
		var voiceHz = (voiceNote + 11 + 2.12 + (12 * 3)).midicps;

		var modmod = 1.4.pow(SinOsc.kr(0.17, (0..5) / 6 * 2pi));
		var mod = SinOsc.kr(0.7 * modmod) * modmod * 0.05 + 1.04;

		var variGate = DelayN.kr(voiceActive, 0.2, SinOsc.kr(0.1, [0, pi], 0.2, 0.1));
		var voiceGate = Trig.kr(variGate, 1.6 + Latch.kr(LFTri.kr(0.19) * 0.4, voiceActive));

		var pressure = EnvGen.kr(Env.adsr(attack + SinOsc.kr(0.11, mul: [0.1, 0.2]), decay, 0.95, release), voiceGate) * mod * voiceHz.linlin(400, 800, 1, 0.95) * (1 + WhiteNoise.kr(0.001));
		// avoid 3rd-harmonic overblowing when playing the 7th scale degree
		var fifthBlocked = BinaryOpUGen('==', voiceNote, 23);
		var rq = (SinOsc.kr(0.071, [1.5pi, 0], 0.13) + [1.4, 1.1]).max(fifthBlocked * 0.3 + 0.8);
		var filterCutoff = (1.8 * voiceHz) * 1.02.pow(SinOsc.kr(2.3, (0..3) / 4 * 2pi));
		var filter = BLowPass.ar(LocalIn.ar(8) * -0.93 + pressure, filterCutoff, rq).squared;
		var out = filter * pressure;
		var delayTime = voiceHz.reciprocal * [1, 1.01] - ControlRate.ir.reciprocal;
		var delay = DelayL.ar(out, 0.2, delayTime);
		var audio = Mix((LeakDC.ar(out) * voiceHz.linlin(400, 800, 1, 0.5) * rq.linexp(1, 1.2, 0.5, 1, nil) * -10.dbamp).softclip);

		var buf = Buffer.alloc(s, s.sampleRate);
		var echo = MultiTap.ar(`[0, 0.23, 0.31], `[-4.dbamp, -2.dbamp, 1], audio, 1, 0, buf);
		var dry = DelayL.ar(audio, 0.4, 0.37);
		var mix = BHiPass.ar(echo, 400, 1.5) * -2.dbamp + dry;
		// var echoFilter = BHiPass.ar(echo, [4, 4, 4, 1] * 100

		// delay.scope;
		variGate.size.poll;

		LocalOut.ar(delay);
		Out.ar(0, mix * -10.dbamp ! 2); // + SinOsc.ar(Select.kr(whichNote, notes + 47).midicps.lag, 0, -15.dbamp) ! 2);
	}).add;
	s.sync;
	y = Synth(\brass);
}.play;
)