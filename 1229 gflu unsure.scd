(
{
	var hzs = (24 + [ 23, 11, 30, 23, 35, 28, 27, 34, 34, 35, 35 ]).midicps * 0.25.midiratio;
	var noteclock = Impulse.kr(0.7.reciprocal);
	var whichVoice = Stepper.kr(noteclock, Impulse.ar(0), 0, 2);
	var whichHz = Stepper.kr(noteclock, Impulse.ar(0), 0, hzs.size - 1);
	var fb = LocalIn.ar(3);
	var voiceActive = Array.fill(3, { |v| BinaryOpUGen('==', v, whichVoice) });
	var voiceHz = Select.kr(Latch.kr(whichHz, voiceActive + Impulse.kr(0)), hzs);
	var pressure = EnvGen.kr(Env.asr(0.01, 0.7 /*SinOsc.kr(0.2, (0..10) / 11 * 2pi, 0.001, 0.8)*/, 2), Trig.kr(voiceActive, 1.4)) * (1 + WhiteNoise.ar(0.003));
	var embDelay = DelayL.ar(fb * 0.5 + pressure, 0.2, (voiceHz * 2).reciprocal * voiceHz.expexp(hzs[1], hzs[10], 1, 0.84));
	var boreTime = voiceHz.reciprocal - ControlRate.ir.reciprocal;
	var borDelay = DelayL.ar(fb * 0.55 + embDelay - embDelay.cubed, 0.2, boreTime);
	// var filter = OnePole.ar(borDelay.tanh, 0.8);
	var filter = SVF.ar(borDelay.tanh, 1000, 0.04 + SinOsc.kr(0.23, mul: 0.03));
	LocalOut.ar(filter);
	boreTime.poll;
	// embDelay.scope;
	Splay.ar(LeakDC.ar(filter) * -12.dbamp, 0.5);
}.play;
)

(24 + 11).midicps