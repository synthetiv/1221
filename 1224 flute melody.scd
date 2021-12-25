(
{
	arg hz = 198;
	var rs = [ 1/1, 16/15, 3/2, 8/5, 8/9, 2 ];
	var rhz = Latch.ar(
		Select.ar(VarSaw.kr(1, 0.5, 0.25 + LFTri.kr(0.09, 0, 0.1)).range(0, 1).cubed * 3 + VarSaw.kr(0.25).range(0, 3), DC.ar(rs)),
		Impulse.kr(8)
	) * hz;
	var gate = LFPulse.kr(0.25, 0, 0.875);
	var str = HenonN.ar(4, 0.9, 0.5, 0, 0) * 0.5;
	var env = EnvGen.kr(Env.asr(0.1, 1, 1), gate) * 0.5 * (str.lag(0.5) * 0.4 + 1.1);
	var fb = LocalIn.ar;
	var vib = SinOsc.ar(3.9) * (1 - EnvGen.kr(Env.perc(0, 2), Changed.ar(rhz) + Impulse.ar(0))) * 70;
	var dem = DelayL.ar(fb * 0.5 + (env + WhiteNoise.ar(0.001)), 0.2, ((rhz * 2).lag(0.3) + vib).reciprocal);
	var dbo = OnePole.ar(DelayL.ar(fb * 0.55 + dem - dem.cubed, 0.2, rhz.lag(0.1).reciprocal - ControlRate.ir.reciprocal), 0.6);
	var out = (dbo - env) * -4.dbamp;
	LocalOut.ar(dbo);
	Peak.ar(out).poll;
	Line.kr * out.clip2 ! 2;
}.play;
)