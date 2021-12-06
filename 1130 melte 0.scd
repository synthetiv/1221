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
	].collect({ |r| r * [1, 3, 5] }).flatten;

	var fb = DelayL.ar(LocalIn.ar(ratios.size), delaytime: hz.reciprocal * 4 - (BlockSize.ir * SampleDur.ir));

	oscs = ratios.collect({ |r, i|
		var d = r - 1;
		var detune = 0;
		var osc = SinOsc.ar(hz + LFNoise1.kr(d / 100, detune) * r, Select.ar(LFNoise0.kr(d/3).range(0, ratios.size - 1), fb) * fbAmt); // TODO: detuning: good or bad?
		osc = osc * r.linexp(1, 2, 1, -6.dbamp); // -6db/oct amp falloff
		osc = osc * SinOsc.ar(d / 27, i * 0.5pi).linlin(-1, 1, 0, 1); // envelope
	});

	LocalOut.ar(oscs);

	snd = Mix.ar(ratios.collect({ |r, i|
		var d = r - 1;
		Pan2.ar(
			oscs[i],
			SinOsc.ar(d / 21)
		);
	}));

	snd / ratios.size * -6.dbamp * Linen.kr(attackTime: 2);
}
.play;

)
