(
{
	// var hzs = [125, 250, 500];
	var hzs = (36 + [ 23, 11, 30, 23, 35, 28, 27, 34, 34, 35, 35 ]).midicps * 0.25.midiratio;
	var noteclock = Impulse.kr(0.7.reciprocal);
	var whichVoice = Stepper.kr(noteclock, Impulse.ar(0), 0, 2);
	var whichHz = Stepper.kr(noteclock, Impulse.ar(0), 0, hzs.size - 1);
	var fb = LocalIn.ar(3);
	var voiceActive = Array.fill(3, { |v| BinaryOpUGen('==', v, whichVoice) });
	var voiceHz = Select.kr(Latch.kr(whichHz, voiceActive + Impulse.kr(0)), hzs);
	var pressure = EnvGen.kr(Env.asr(0.06, 0.78 + SinOsc.kr(0.2, (0..2) / 3 * 2pi, 0.04), 4), Trig.kr(voiceActive, 1)) * (1 + WhiteNoise.ar(0.003));
	// 0.72 works for BLowPass 1000, 0.84 for 2000
	// 0.71 works for SVF 1000, 0.87 for 2000
	var filterCutoff = Latch.kr(1300 + SinOsc.kr(0.31, mul: 700), voiceActive).lag(0.2);
	var filterCompensation = voiceHz.linlin(hzs[0], hzs[hzs.size - 1], 1, filterCutoff.explin(1000, 2000, 0.71, 0.87));
	var embDelay = DelayL.ar(fb * 0.5 + pressure, 0.2, (voiceHz * 2).reciprocal * filterCompensation);
	var boreTime = voiceHz.reciprocal - ControlRate.ir.reciprocal;
	var borDelay = DelayL.ar(fb * 0.55 + embDelay - embDelay.cubed, 0.2, boreTime);
	// var filter = OnePole.ar(borDelay.tanh, 0.8);
	// var filter = BLowPass.ar(borDelay.tanh, filterCutoff, 1); // 1300 + Latch.kr(SinOsc.kr(0.39, (0..2) / 3 * 2pi, 300), voiceActive).lag(0.1), 1.3); // 1.5 + SinOsc.kr(0.23, (0..2) / 3 * 2pi, 0.5));
	// var filter = SVF.ar(borDelay.tanh, 500, 0.04 + SinOsc.kr(0.23, mul: 0.025));
	var filter = SVF.ar(borDelay.tanh, filterCutoff, 0.04 + SinOsc.kr(0.5, mul: 0.02));
	LocalOut.ar(filter);
	boreTime.poll;
	// embDelay.scope;
	Splay.ar(LeakDC.ar(filter) * -19.dbamp, 0.5);
}.play;
)