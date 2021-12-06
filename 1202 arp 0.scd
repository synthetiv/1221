(

{

	arg hz = 130;

	var nVoices = 6;

	var chord = [ 15/16, 1/1, 5/4, 3/2, 15/8, 2, 5/2, 3, 15/4 ];
	var addr = LFTri.kr(1.1 * 1.3.pow(LFTri.kr(0.16))).range(4, 1)
	+ SinOsc.kr(0.1 * 2.pow(LFTri.kr(0.019))).range(-1, 2)
	+ LFTri.kr(0.07).range(0, 1)
	+ (SinOsc.kr(0.01) * SinOsc.kr(0.004)).range(-1, 3);
	var nextRatio = Select.kr(addr, chord);
	var gate = Trig.kr(Changed.kr(nextRatio), LFTri.kr(0.6).range(0.05, 0.2));

	var voiceSel = Stepper.kr(gate, min: 0, max: nVoices - 1);
	var voiceGate = Array.fill(nVoices, { |i| gate * BinaryOpUGen('==', voiceSel, i) });

	var voices = Splay.arFill(nVoices, { |i|
		var gate = voiceGate[i];
		// Latch needs one pulse at the beginning to initialize it, otherwise Saws start with freq = 0, which Sounds Bad
		var osc = Mix.ar(Saw.ar(hz * Latch.kr(nextRatio, gate + Impulse.kr(0)) * 2.pow(0.001 * [-3, 0, 3])));
		var fenv = EnvGen.kr(Env.adsr(0.05, 0.1, 0.5, 0.6), gate);
		var filter = RLPF.ar(osc, 500 + (fenv * 2000 * LFTri.kr(0.024, 2).range(0.5, 2)), 0.88);
		var env = EnvGen.kr(Env.adsr(0.1, 0.2, 0.8, 0.9), gate);
		filter * env * -12.dbamp;
	}, levelComp: false);

	var droneRatios = [1/2, 1, 3/2, 2];
	var drone = Mix.arFill(droneRatios.size, { |i|
		RLPF.ar(
			Saw.ar(hz * droneRatios[i]),
			(200 + VarSaw.kr(0.12, i / droneRatios.size, 0.1).range(0, 1000)) * droneRatios[i]
		);
	}) * -24.dbamp ! 2;

	var echoSend = Splay.ar(Mix.ar(voices) + drone + (LocalIn.ar(2) * 0.7), -0.8, levelComp: false);
	var echoComp = (Compander.ar(echoSend, echoSend, -12.dbamp, slopeBelow: 0.95, slopeAbove: 0.2) * 3).tanh;
	var echo = RLPF.ar(DelayL.ar(echoComp, 1, 0.7 + SinOsc.kr(0.03, [2, 3.5], 0.05)), 2900 * 2.6.pow(LFTri.kr(0.045, [0, 1.5])), 0.9) * -12.dbamp;

	LocalOut.ar(echo);

	(voices + drone + Splay.ar(echo, 0.8, levelComp: false)) * Linen.kr(attackTime: 1.4);

}
.play;

)
