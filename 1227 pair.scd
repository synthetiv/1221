(
{
	var hz = 290;
	var rs = [ 1, 9/8 ];
	var modmod = SinOsc.kr(0.19, 0, 0.1, 1);
	var mod = SinOsc.kr(1.1 * modmod, [0, 0.5pi]) / modmod;
	var breath = LagUD.kr(LFPulse.kr(0.076, 0, 0.9), 3, 2) * mod.range(0.76, 0.83) * Line.kr(dur: 2);
	var air = breath * (1 + WhiteNoise.ar(0.001));
	var which = SinOsc.kr(0.13, 0, 2).clip(0, 1);
	var feed = LocalIn.ar(2).tanh;
	var embo = DelayL.ar(feed * 0.5 + air, 0.2, (hz * rs * 2).reciprocal);
	var bore = DelayL.ar(feed * 0.55 + embo - embo.cubed, 0.2, (hz * rs).reciprocal - ControlRate.ir.reciprocal);
	var fil = SVF.ar(bore, hz * (2.pow(LFSaw.kr(0.036, [0, 1], 2, 2).floor) * Select.kr(SinOsc.kr(0.09, [0, pi]).range(0, rs.size), rs)).lag(0.5), 0.06);
	var out = Splay.ar(fil, 0.3);
	LocalOut.ar(fil);
	out * -2.dbamp;
}.play;
)