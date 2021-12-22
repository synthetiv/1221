(
{
	arg hz = 198;
	var rs = [ 1/1, 16/15, 3/2, 8/5, 8/9, 2 ];
	var rhz = Latch.kr(Select.kr(VarSaw.kr(1, 0.5, 0.25 + LFTri.kr(0.09, 0, 0.1)).range(0, 1).cubed * 3 + VarSaw.kr(0.25).range(0, 3), rs), Impulse.kr(8)) * hz;
	var gate = LFPulse.kr(0.25, 0, 0.875);
	var env = EnvGen.kr(Env.adsr(0.2, 0.4, 0.7, 1), gate);
	var flex = HenonN.ar(8, 0.9, 0.5, 0, 0) * 0.5;
	var out = SinOscFB.ar(Gate.kr(rhz, gate), Gate.ar(flex, gate)) * env * -4.dbamp;
	Peak.ar(out).poll;
	Line.kr * out ! 2;
}.play;
)