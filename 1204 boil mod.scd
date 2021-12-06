s.boot;

b = Buffer.alloc(s, 48000, 2);

RecordBuf

(

{

	var envRate = 1;
	var env = Mix.new([
		VarSaw.kr(0.1 * envRate, width: 0.1) * SinOsc.kr(0.07 * envRate),
		VarSaw.kr(0.031 * envRate, width: 0.9) * SinOsc.kr(0.012, 0.011 * envRate)
	]).squared.softclip;
	var noise = Integrator.ar(Integrator.ar(WhiteNoise.ar, 0.99), 0.92) * 0.1 * env;

	var fry = Pan2.ar(SinOsc.ar(6300 * 1.02.pow(noise)), SinOsc.ar(1 - env)) * 1.09.pow(noise.abs) * env * -12.dbamp;

	var delIn = RLPF.ar(LocalIn.ar(2) + fry, (8900 * 1.03.pow(LFTri.kr(1))).min(SampleRate.ir / 2), 0.87).distort;
	var delPhase = Phasor.ar(start: BufFrames.ir(b), end: 0);
	var delWrite = BufWr.ar(delIn, b, delPhase);
	var blockDur = BlockSize.ir * SampleDur.ir;
	var delTimes = Array.fill(12, { |i| 700.reciprocal * (i + 2) + SinOsc.ar(2.3 * 1.03.pow(i), 2pi * i / 12, 0.00001) }); // TODO: this is still too much mod!
	var delRead = BufRd.ar(2, b, (delPhase - (delTimes * SampleRate.ir - blockDur)).wrap(0, BufFrames.ir(b)));
	var delReset = Impulse.kr(0.35);
	var delSel = Slew.kr(Phasor.kr(delReset, 0.2 * blockDur).lincurve(0, 1, TIRand.kr(0, 4, delReset), TIRand.kr(9, 14, delReset), 2).floor, 100, 100);
	var del = LinSelectX.ar(delSel, delRead);
	var delTime = LinSelectX.kr(delSel, delTimes);

	LocalOut.ar(del * -0.0005.dbamp);
	del = DelayN.ar(del, blockDur, blockDur);

	del * -8.dbamp + fry;

}.play;

)