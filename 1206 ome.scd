(

{
	arg hz = 130;

	var trigFreq = 0.57;
	var trig = Impulse.kr(trigFreq);

	// someday I'll refine this Select/Stepper idiom so it starts at 0 instead of 1...
	var nhz = Select.kr(Stepper.kr(trig, 1, max: 4), [5/6, 7/8, 15/16, 6/5, 1] * hz);

	// anvil
	var tak = WhiteNoise.ar * Decay.kr(trig, 0.26);
	var ring = Mix(SinOsc.ar(nhz * 27 * [1, 1.98, 2.89])) * EnvGen.ar(Env.perc(releaseTime: 0.45), trig);
	var fil = BPF.ar((tak * 2 + ring).softclip, nhz * 38, 0.8);

	// an Ugly Reverb
	var pre = DelayL.ar(fil, trigFreq.reciprocal / 4);
	var diffDecay = 0.09;
	var dels;
	var diff = AllpassL.ar(pre + LocalIn.ar(2), 1, 109 / SampleRate.ir, diffDecay);
	diff = AllpassL.ar(diff, 1, 297 / SampleRate.ir, diffDecay);
	diff = AllpassL.ar(diff, 1, 568 / SampleRate.ir, diffDecay);
	diff = AllpassL.ar(diff, 1, 701 / SampleRate.ir, diffDecay);

	dels = DelayL.ar(diff, 0.2, ([1638, 1391] + SinOsc.ar([0.17, 0.11], [0, 3], EnvGen.ar(Env.new([0, 900], [0.3]), trig))) / SampleRate.ir);
	LocalOut.ar(LPF.ar(Splay.ar(dels, -0.9), 5000) * 2.dbamp);

	(fil ! 2 + (dels * -6.dbamp)) * -3.dbamp;
}.scope;

)