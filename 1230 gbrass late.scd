MIDIClient.init;

(
Routine {
	SynthDef(\brass, {
		arg attack = 0.7, decay = 2, sustain = 0.95, release = 1, noise = 0.001, press = 1, density = 1, cutoffRatio = 1.8, tune = 2.12, wet = 0;//.35;
		var notes = [ 12, 0, 19, 12, 24, 17, 16, 23, 23, 24, 24 ];
		// var hzs = (24 + [ 23, 11, 30, 23, 35, 28, 27, 34, 34, 35, 35 ]).midicps;
		var noteclock = Impulse.kr(0.7.reciprocal);
		var whichVoice = Stepper.kr(noteclock, Impulse.ar(0), 0, 3);
		var whichNote = Stepper.kr(noteclock, Impulse.ar(0), 0, notes.size - 1);

		var voiceActive = Array.fill(4, { |v| BinaryOpUGen('==', v, whichVoice) }).dup.flatten;
		var voiceGate = Trig.kr(voiceActive * Dust.kr(density), 2.6 + Latch.kr(LFTri.kr(0.19) * 0.7, voiceActive));
		var voiceNote = Select.kr(Latch.kr(whichNote, voiceActive + Impulse.kr(0)), notes);
		var voiceHz = Lag.ar(K2A.ar(voiceNote + 11 + tune + (12 * 3)).midicps, SinOsc.kr(1, [0, 0.5pi], 0.03, [0.035, 0.05]));

		var modmod = 1.4.pow(SinOsc.kr(0.17, (0..5) / 6 * 2pi));
		var mod = SinOsc.kr(0.59 * modmod) * modmod * 0.05 + 1.04;

		var pressure = press * EnvGen.ar(Env.adsr(attack + SinOsc.kr(0.11, mul: [0.1, 0.2]), decay, sustain, release), voiceGate) * mod * voiceHz.linlin(400, 800, 1, 0.95) * (1 + WhiteNoise.kr(noise));
		// avoid 3rd-harmonic overblowing when playing the 7th scale degree
		var fifthBlocked = Lag.ar(K2A.ar(BinaryOpUGen('==', voiceNote, 23)), 0.1);
		var rq = (SinOsc.ar(0.071, [1.5pi, 0], 0.13) + [1.4, 1.3]).max(fifthBlocked * 0.55 + 0.8);
		var filterCutoff = (cutoffRatio * voiceHz) * 1.02.pow(SinOsc.ar(2.3, (0..3) / 4 * 2pi));
		//	var filter = BLowPass.ar(LocalIn.ar(8) * -0.93 + pressure, filterCutoff, rq).squared;
		var filter = RLPF.ar(LocalIn.ar(8) * -0.93 + pressure, filterCutoff, rq).squared;
		var out = filter * pressure;
		var delayTime = voiceHz.reciprocal * [1, 1.005] - ControlRate.ir.reciprocal;
		var delay = DelayL.ar(out, 0.2, delayTime);
		var audio = Mix((LeakDC.ar(out) * voiceHz.linlin(400, 800, 1, 0.5) * rq.linexp(1, 1.2, 0.5, 1, nil) * -10.dbamp).softclip);

		// audio = audio + SinOsc.ar(Select.kr(whichNote, notes + 47).midicps.lag, 0, -15.dbamp);

		// var buf = Buffer.alloc(s, s.sampleRate);
		// var echo = MultiTap.ar(`((0..6) * -1.midicps.reciprocal), `(SinOsc.ar(0.123, (0..6) / 7 * 2pi)), audio, 1, 0, buf);
		// var echo = MultiTap.ar(`[SinOsc.ar(1, 0, 0.2, 0.3)], `[1], audio, 1, 0, buf);
		var echo = Mix(DelayL.ar(audio, 1, SinOsc.ar([2.9, 1.79, 0.81], (0..2), [0.0005, 0.0015, 0.002] * 0.5, [0.05, 0.19, 0.37])));
		var dry = DelayL.ar(audio, 0.5, 0.37);
		var mix = BHiPass.ar(echo, 400, 1.5) * wet + dry;

		LocalOut.ar(delay);
		Out.ar(0, mix * -10
			.dbamp ! 2);
	}).add;
	s.sync;
	y = Synth(\brass);
	MIDIFunc({ |val| y.set(\density, val.linlin(0, 127, 0, 10)); }, 32, msgType: \control);
	MIDIFunc({ |val| y.set(\wet, val.lincurve(0, 127, 0, 1, 4)); }, 33, msgType: \control);
	MIDIFunc({ |val| y.set(\noise, val.lincurve(0, 127, 0, 0.1, 4)); }, 34, msgType: \control);
	MIDIFunc({ |val| y.set(\press, val.lincurve(0, 127, 0.9, 1.1, 4)); }, 35, msgType: \control);

	MIDIFunc({ |val| y.set(\attack, val.lincurve(0, 127, 0.1, 1.5, 4)); }, 36, msgType: \control);
	MIDIFunc({ |val| y.set(\decay, val.lincurve(0, 127, 0.1, 3, 4)); }, 37, msgType: \control);
	MIDIFunc({ |val| y.set(\sustain, val.lincurve(0, 127, 0.8, 1, 4)); }, 38, msgType: \control);
	MIDIFunc({ |val| y.set(\release, val.lincurve(0, 127, 0.5, 2, 4)); }, 39, msgType: \control);

}.play;
)

y.set(\attack, 1);
y.set(\sustain, 1);

y.set(\noise, 0.1);
y.set(\noise, 0.001);
y.set(\press, 0.93);
y.set(\press, 1.05);

y.set(\density, 0);
y.set(\density, 14);

y.set(\cutoffRatio, 2.2);
y.set(\tune, 1.70);