s.boot;

(

{
	arg hz = 110,
	amp = 1,
	detune = 0,
	fbAmt = 0; // .5pi;

	var oscs;
	var snd;

	var ratios = [
		1/2,
		14/15,
		1,
		8/7,
		6/5,

		// *3:
		// 3/2,
		// 14/5,
		3,
		24/7,
		18/5,

		// *5:
		// 5/2,
		// 14/3,
		// 5,
		// 40/7,
		// 6

		// *7:
		// 7/2,
		98/15,
		7,
		8,
		// 42/5

		// *8, for an extra note between 7/1 and 8/1:
		112/15,
	].sort; // .collect({ |r| r * [1, 3, 5] }).flatten;

	var fb = DelayL.ar(LocalIn.ar(ratios.size), delaytime: hz.reciprocal * 4 - (BlockSize.ir * SampleDur.ir));

	oscs = ratios.collect({ |r, i|
		var d = r - 1;
		var detune = 0;
		var osc = SinOsc.ar(hz + LFNoise1.kr(d / 100, detune) * r, Select.ar(LFNoise0.kr(d/3).range(0, ratios.size - 1), fb) * fbAmt); // TODO: detuning: good or bad?
		osc = osc * r.linexp(1, 2, 1, -6.dbamp); // -6db/oct amp falloff
		// osc = osc * SinOsc.ar(d / 27, i * 0.5pi).linlin(-1, 1, 0, 1); // envelope
	});

	LocalOut.ar(oscs);

	/*
	snd = Mix.ar(ratios.collect({ |r, i|
		var d = r - 1;
		Pan2.ar(
			oscs[i],
			SinOsc.ar(d / 21)
		);
	}));

	snd / ratios.size * -6.dbamp * Linen.kr(attackTime: 2);
	*/

	// TODO: I think this is how I'd like to handle the higher frequencies, scanning between them... whlie the lower freqs are fine as is
	snd = SelectX.ar(LFTri.ar(0.2).range(0, ratios.size - 1), oscs) * -6.dbamp * Linen.kr(attackTime: 2);
}
.play;

)