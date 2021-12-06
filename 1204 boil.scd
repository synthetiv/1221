b = Buffer.alloc(s, 48000, 2);

(

{

	var envRate = 1;
	var env = Mix.new([
		VarSaw.kr(0.1 * envRate, width: 0.1) * SinOsc.kr(0.07 * envRate),
		VarSaw.kr(0.031 * envRate, width: 0.9) * SinOsc.kr(0.012, 0.011 * envRate)
	]).squared.softclip;
	var noise = Integrator.ar(Integrator.ar(WhiteNoise.ar, 0.99), 0.92) * 0.1 * env;

	var fry = Pan2.ar(SinOsc.ar(6300 * 1.02.pow(noise)), SinOsc.ar(env)) * 1.09.pow(noise.abs) * env * -12.dbamp;

	var delIn = RLPF.ar(LocalIn.ar(2) + fry, (8900 * 1.03.pow(LFTri.kr(1))).min(SampleRate.ir / 2), 0.902).distort;
	var delRec = RecordBuf.ar(delIn, b, run: -1);
	var blockDur = BlockSize.ir * SampleDur.ir;
	var delTimes = 700.reciprocal * (2..14);
	var delPlay = PlayBuf.ar(2, b, -1, startPos: delTimes * SampleRate.ir - blockDur, loop: 1);
	var delReset = Impulse.kr(0.35);
	var delSel = Slew.kr(Phasor.kr(delReset, 0.2 * blockDur).lincurve(0, 1, TIRand.kr(0, 4, delReset), TIRand.kr(9, 14, delReset), 2).floor, 100, 100);
	var del = LinSelectX.ar(delSel, delPlay);
	var delTime = LinSelectX.kr(delSel, delTimes);

	LocalOut.ar(del * -0.1.dbamp);
	del = DelayN.ar(del, blockDur, blockDur);

	del * -8.dbamp + fry;

}.play;

)
