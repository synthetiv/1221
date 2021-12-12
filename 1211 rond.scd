(

Routine {

	SynthDef(\flu, {

		arg hz = 190, noise = 0.0256, fb1 = 0.5, fb2 = 0.55;

		var init = Impulse.kr(0);
		var rate = 0.87;
		var clock = Impulse.kr(rate);
		// var pitches = [ 3/2, 6/5, 9/8, 1, 7/4, 49/32 ]; // tuning gets weird enough thanks to embouchere line + filter that "exotic" ratios are a bit much
		var pitches = [ 3/2, 1, 7/4, 1/2, 9/8, 3, 6/5 ];
		var pitch = Select.kr(Stepper.kr(clock, init, 0, pitches.size - 1), pitches) * 2.pow(LFTri.kr(0.1).cubed.floor + 0.5);
		var voice = Stepper.kr(clock, init, 0, 4);
		var fbIn = LocalIn.ar(5);
		var flow = VarSaw.kr(0.022, 0, 0.86, 0.06, 0.05) + 0.5;

		// NB: there's something wrong with these -- they output a DC offset even when gate is low,
		// and the Latches are starting at 0 even though adding the 'init' pulse to the trig argument
		// should (?) initialize them... and the Latch weirdness can't be explained by the fact that
		// they're control rate, either, because even if I make them audio rate, I get NaNs
		var voices = Array.fill(5, { |v|
			var vgate = Trig.kr(BinaryOpUGen('==', v, voice), rate.reciprocal * 4);
			var vhz = (hz * Latch.kr(pitch, vgate + init)).max(1);
			var bi = Latch.kr(LFTri.kr((11 + v) / 13, v * 4 / 5).range(0.01, 3.99), vgate);
			var env = EnvGen.kr(Env.asr(bi * rate, 1, (4 - bi) * rate), vgate) * (1 + SinOsc.kr(0.21, v * 2pi / 5, 0.1));
			var air = flow * env * (1 + WhiteNoise.ar(noise));
			var vfb = DelayL.ar(fbIn[v], 0.2, vhz.reciprocal - (BlockSize.ir / SampleRate.ir));
			var emb = Latch.kr(LFTri.kr((13 + v) / 11).range(1.1, 3.5), vgate + init).clip(1.5, 2.5);
			var embDel = DelayL.ar(vfb * fb1 + air, 0.2, (vhz * emb).reciprocal);
			var coef = Latch.kr(LFTri.kr((11 + v) / 17).range(0.55, 0.83), vgate + init);
			OnePole.ar(vfb * fb2 + (embDel - embDel.cubed), coef);
		});

		LocalOut.ar(voices);

		Out.ar(0,
			Splay.ar(LeakDC.ar(voices.at((0..2))), 0.8) + Splay.ar(LeakDC.ar(voices.at((3..4))), 0.8 * 2/3).reverse * -12.dbamp
		);

	}).add;

	s.sync;

	y = Synth(\flu);

}.play;

)